//
//  GameViewModel.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Game View Model
@MainActor
public class GameViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public private(set) var currentWord: Word?
    @Published public private(set) var difficulty: Difficulty = .medium
    @Published public private(set) var language: Language = .english
    
    @Published public private(set) var guessedLetters: Set<Character> = []
    @Published public private(set) var remainingLives: Int = 6
    @Published public private(set) var gameState: GameState = .idle
    
    @Published public private(set) var timeRemaining: Int = 0
    @Published public private(set) var currentTaunt: String? = nil
    
    // MARK: - Private State
    private var timer: AnyCancellable?
    
    // MARK: - Callbacks for Services Integration
    // These closures act as hooks for Audio, Haptic, Rive and Taunt services.
    public var onWrongGuess: ((_ remainingLives: Int, _ language: Language) -> Void)?
    public var onGameOver: ((_ won: Bool) -> Void)?
    public var onTimeWarning: ((_ timeLeft: Int, _ language: Language) -> Void)?
    
    public init() {}
    
    // MARK: - Game Lifecycle
    
    /// Starts a new session with the given word and difficulty
    public func startNewGame(word: Word, difficulty: Difficulty) {
        self.currentWord = word
        self.language = word.language
        self.difficulty = difficulty
        
        self.guessedLetters.removeAll()
        self.remainingLives = difficulty.lives
        self.gameState = .inProgress
        self.currentTaunt = nil
        
        setupTimer()
    }
    
    /// Resets the game to an idle state
    public func resetGame() {
        self.gameState = .idle
        self.currentWord = nil
        self.guessedLetters.removeAll()
        self.timer?.cancel()
        self.timer = nil
        self.currentTaunt = nil
    }
    
    // MARK: - Core Game Logic
    
    /// Returns the word with unguessed letters masked as underscores, spaced out for the notebook look.
    public var maskedWord: String {
        guard let word = currentWord else { return "" }
        
        return word.text.map { char in
            if char.isWhitespace {
                return "  " // Extra space for word breaks
            } else if guessedLetters.contains(char) {
                return String(char)
            } else {
                return "_"
            }
        }.joined(separator: " ")
    }
    
    /// Processes a letter guess from the custom language keyboard
    public func guess(letter: Character) {
        // Only process guesses while the game is actively in progress
        guard gameState == .inProgress else { return }
        
        let upperChar = Character(letter.uppercased())
        
        // Prevent duplicate guesses
        guard !guessedLetters.contains(upperChar) else { return }
        
        guessedLetters.insert(upperChar)
        
        // Reset timer on every valid guess
        self.timeRemaining = 60
        
        // Initial light tap representing the physical friction of writing a letter
        HapticService.shared.playPenStrike()
        AudioService.shared.play(.penScratch)
        
        guard let wordText = currentWord?.text else { return }
        
        if wordText.contains(upperChar) {
            // Correct Guess
            AudioService.shared.play(.sfxCorrect) // Quick checkmark swoosh as requested
            checkWinCondition()
        } else {
            // Wrong Guess
            remainingLives -= 1
            
            // Heavy rigid pulse for error representing a snapped pencil tip as requested
            HapticService.shared.playErrorPulse()
            AudioService.shared.play(.sfxWrong)
            
            // Trigger contextual callbacks (e.g. Claude taunt generation scaling to difficulty)
            onWrongGuess?(remainingLives, language)
            
            if remainingLives <= 0 {
                endGame(won: false)
            }
        }
    }
    
    /// Set a taunt received from the Claude API (Savage AI feature)
    public func setTaunt(_ text: String) {
        self.currentTaunt = text
    }
    
    // MARK: - Win/Loss Condition Checks
    
    private func checkWinCondition() {
        guard let word = currentWord else { return }
        
        let unmaskedCharacters = word.text.filter { !$0.isWhitespace }
        let isWon = unmaskedCharacters.allSatisfy { guessedLetters.contains($0) }
        
        if isWon {
            endGame(won: true)
        }
    }
    
    private func endGame(won: Bool) {
        gameState = won ? .won : .lost
        timer?.cancel()
        timer = nil
        onGameOver?(won)
    }
    
    // MARK: - Timer Logic
    
    private func setupTimer() {
        timer?.cancel()
        
        self.timeRemaining = 60
        
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    private func tick() {
        guard gameState == .inProgress else { return }
        
        if timeRemaining > 0 {
            timeRemaining -= 1
            
            if timeRemaining == 30 || timeRemaining == 10 {
                onTimeWarning?(timeRemaining, language)
            }
            
            if timeRemaining == 0 {
                // Time's up! Running out of time means losing the game.
                endGame(won: false)
            }
        }
    }
    
    // Helper to format time remaining as MM:SS (e.g., 01:30)
    public var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Helper to know if a character key should be disabled/crossed out on the UI keyboard
    public func isKeyDisabled(_ char: Character) -> Bool {
        return guessedLetters.contains(Character(char.uppercased()))
    }
}
