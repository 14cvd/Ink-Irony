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
    
    // Hint system
    @Published public private(set) var hintsRemaining: Int = 2
    @Published public private(set) var hintText: String? = nil
    
    // Tracking for score/achievements
    @Published public private(set) var wrongGuessCount: Int = 0
    private var startTime: Date = Date()
    
    public var elapsedSeconds: Int {
        Int(Date().timeIntervalSince(startTime))
    }
    
    // MARK: - Private State
    private var timer: AnyCancellable?
    
    // MARK: - Callbacks for Services Integration
    public var onWrongGuess: ((_ remainingLives: Int, _ language: Language) -> Void)?
    public var onGameOver: ((_ won: Bool) -> Void)?
    public var onTimeWarning: ((_ timeLeft: Int, _ language: Language) -> Void)?
    
    public init() {}
    
    // MARK: - Game Lifecycle
    
    public func startNewGame(word: Word, difficulty: Difficulty) {
        self.currentWord = word
        self.language = word.language
        self.difficulty = difficulty
        
        self.guessedLetters.removeAll()
        self.remainingLives = difficulty.lives
        self.gameState = .inProgress
        self.currentTaunt = nil
        self.hintsRemaining = 2
        self.hintText = nil
        self.wrongGuessCount = 0
        self.startTime = Date()
        
        // Reset quote cycling for new game
        Task { await TauntService.shared.resetIndex(for: word.language) }
        
        setupTimer(for: difficulty)
    }
    
    public func resetGame() {
        self.gameState = .idle
        self.currentWord = nil
        self.guessedLetters.removeAll()
        self.timer?.cancel()
        self.timer = nil
        self.currentTaunt = nil
        self.hintText = nil
    }
    
    // MARK: - Hint System
    
    /// Use a hint — reveals the hint text and decrements counter
    public func useHint() {
        guard hintsRemaining > 0, gameState == .inProgress else { return }
        
        if hintsRemaining == 2 {
            // First hint click: short hint
            hintText = currentWord?.hint
        } else if hintsRemaining == 1 {
            // Second hint click: deeper definition hint (movzuya hakim)
            if let def = currentWord?.definition, !def.isEmpty {
                hintText = (currentWord?.hint ?? "") + "\n\n" + def
            }
        }
        
        hintsRemaining -= 1
        HapticService.shared.playPenStrike()
    }
    
    // MARK: - Core Game Logic
    
    public var maskedWord: String {
        guard let word = currentWord else { return "" }
        return word.text.map { char in
            if char.isWhitespace { return "  " }
            else if guessedLetters.contains(char) { return String(char) }
            else { return "_" }
        }.joined(separator: " ")
    }
    
    public func guess(letter: Character) {
        guard gameState == .inProgress else { return }
        
        let upperChar = Character(letter.uppercased())
        guard !guessedLetters.contains(upperChar) else { return }
        
        guessedLetters.insert(upperChar)
        
        // Reset per-guess timer if difficulty has a timer
        if difficulty.timerSeconds != nil {
            self.timeRemaining = difficulty.timerSeconds!
        }
        
        HapticService.shared.playPenStrike()
        AudioService.shared.play(.penScratch)
        
        guard let wordText = currentWord?.text else { return }
        
        if wordText.contains(upperChar) {
            AudioService.shared.play(.sfxCorrect)
            checkWinCondition()
        } else {
            remainingLives -= 1
            wrongGuessCount += 1
            
            HapticService.shared.playErrorPulse()
            AudioService.shared.play(.sfxWrong)
            
            onWrongGuess?(remainingLives, language)
            
            if remainingLives <= 0 {
                endGame(won: false)
            }
        }
    }
    
    public func setTaunt(_ text: String) {
        self.currentTaunt = text
    }
    
    // MARK: - Score Calculation
    
    public func calculateScore() -> Int {
        let secs = elapsedSeconds
        let raw = 100.0 + (Double(remainingLives) * 20.0) - (Double(secs) * 0.5)
        return max(0, Int(raw.rounded()))
    }
    
    // MARK: - Win/Loss Checks
    
    private func checkWinCondition() {
        guard let word = currentWord else { return }
        let unmasked = word.text.filter { !$0.isWhitespace }
        if unmasked.allSatisfy({ guessedLetters.contains($0) }) {
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
    
    private func setupTimer(for difficulty: Difficulty) {
        timer?.cancel()
        
        // Use per-difficulty timer; 60s is the per-guess timer (resets on each guess)
        let initialTime = difficulty.timerSeconds ?? 60
        self.timeRemaining = initialTime
        
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
                endGame(won: false)
            }
        }
    }
    
    public var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    public func isKeyDisabled(_ char: Character) -> Bool {
        return guessedLetters.contains(Character(char.uppercased()))
    }
}
