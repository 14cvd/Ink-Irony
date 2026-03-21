//
//  GameView.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI

public struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    // External Word/Difficulty for MVP testing
    let startingWord: Word
    let startingDifficulty: Difficulty
    
    // Game Over routing closure injected by Coordinator
    let onGameEnd: ((Bool, Int) -> Void)?
    
    public init(word: Word = Word(text: "SKETCHBOOK", language: .english, category: "Theme"), difficulty: Difficulty = .medium, onGameEnd: ((Bool, Int) -> Void)? = nil) {
        self.startingWord = word
        self.startingDifficulty = difficulty
        self.onGameEnd = onGameEnd
    }
    
    // Dynamic ink color helper for borders
    private var inkColor: Color {
        colorScheme == .dark ? ThemeManager.Colors.graphiteGray : ThemeManager.Colors.ballpointBlue
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            
            // Header: Difficulty, Timer, Lives
            HStack {
                Text(viewModel.difficulty.rawValue.uppercased())
                    .font(.custom("Noteworthy", size: 18).bold())
                    .sketchbookInkText()
                
                Spacer()
                
                if viewModel.difficulty != .easy {
                    Text(viewModel.formattedTime)
                        .font(.custom("Noteworthy", size: 20).bold())
                        .sketchbookInkText(isError: viewModel.timeRemaining < 10 && viewModel.timeRemaining > 0)
                }
                
                Spacer()
                
                Text("LIVES: \(viewModel.remainingLives)")
                    .font(.custom("Noteworthy", size: 18).bold())
                    .sketchbookInkText(isError: viewModel.remainingLives <= 2)
            }
            .padding(.horizontal, 45) // Placed inside the red notebook margin
            .padding(.top, 20)
            
            Spacer().frame(height: 20)
            
            // Rive Animation Sketch Area
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .handDrawnStroke(color: inkColor, lineWidth: 2, jitter: 1.5)
                    .frame(height: 220)
                    .padding(.horizontal, 50)
                
                // Pure SwiftUI Sketching Animation automatically scaling mistakes to exactly 8 drawing parts
                let mistakes = viewModel.difficulty.lives - viewModel.remainingLives
                let scaledMistakes = Int((Double(mistakes) / Double(viewModel.difficulty.lives)) * 8.0)
                
                SketchGallowsView(wrongGuesses: scaledMistakes)
                    .frame(height: 200)
            }
            
            Spacer().frame(height: 30)
            
            // Claude's Savage Taunt Area
            VStack {
                if let taunt = viewModel.currentTaunt {
                    TauntBubbleView(text: taunt)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Text(statusMessage)
                        .font(.custom("Noteworthy", size: 22))
                        .sketchbookInkText(isError: viewModel.gameState == .lost)
                        .padding(.horizontal, 50)
                }
            }
            .frame(height: 100)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: viewModel.currentTaunt)
            
            Spacer().frame(height: 20)
            
            // Masked Word Display
            Text(viewModel.maskedWord)
                .font(.custom("Courier", size: 36).bold()) // Monospace to look like rigid sketching
                .sketchbookInkText()
                .tracking(6)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 45)
            
            Spacer()
            
            // Interactive Keyboard Grid natively adapting to localized language alphabets safely
            DynamicKeyboardView(
                language: viewModel.language,
                guessedLetters: viewModel.guessedLetters,
                onGuess: { char in
                    viewModel.guess(letter: char)
                }
            )
            .padding(.leading, 35) // Offset to sit to the right of the vertical notebook line
            .padding(.bottom, 20)
            // Visually disable interaction if the game abruptly ends
            .disabled(viewModel.gameState == .won || viewModel.gameState == .lost)
            .opacity(viewModel.gameState == .won || viewModel.gameState == .lost ? 0.4 : 1.0)
            
        }
        .sketchbookBackground()
        .onAppear {
            setupViewModel()
            if viewModel.gameState == .idle {
                viewModel.startNewGame(word: startingWord, difficulty: startingDifficulty)
            }
        }
    }
    
    private var statusMessage: String {
        switch viewModel.gameState {
        case .idle, .inProgress: return "Guess a letter..."
        case .won: return "YOU SURVIVED."
        case .lost: return "GAME OVER."
        }
    }
    
    private func setupViewModel() {
        // Wire up TauntService to trigger when a life is lost
        viewModel.onWrongGuess = { [weak viewModel] livesLeft, language in
            Task {
                guard let viewModel = viewModel else { return }
                let mistakes = viewModel.difficulty.lives - livesLeft
                
                let taunt = await TauntService.shared.fetchTaunt(
                    language: language,
                    wrongCount: mistakes,
                    difficulty: viewModel.difficulty
                )
                
                await MainActor.run {
                    viewModel.setTaunt(taunt)
                }
                
                // Trigger tactile drawing feedback alongside the SketchGallowsView.swift drawing animation natively
                HapticService.shared.playSketchTexture(duration: 0.6)
                AudioService.shared.play(.penScratch)
            }
        }
        
        // Execute the Coordinator routing closure seamlessly
        viewModel.onGameOver = { [weak viewModel] won in
            if won {
                HapticService.shared.playSuccessPulse()
                AudioService.shared.play(.checkmark)
            } else {
                HapticService.shared.playErrorPulse()
                AudioService.shared.play(.pencilSnap)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    AudioService.shared.play(.paperTear)
                }
            }
            
            if let onGameEnd = onGameEnd {
                onGameEnd(won, viewModel?.remainingLives ?? 0)
            }
        }
    }
}
