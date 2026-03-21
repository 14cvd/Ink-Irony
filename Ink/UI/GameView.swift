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
    @ObservedObject private var scoreManager = ScoreManager.shared
    
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
        ThemeManager.Colors.inkPrimary(for: colorScheme)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            
            // Header: Difficulty, Timer, Lives
            HStack {
                Text(LocalizationService.t(viewModel.difficulty.rawValue.uppercased(), lang: scoreManager.uiLanguage))
                    .font(ThemeManager.Typography.micro(for: colorScheme).bold())
                    .sketchbookInkText()
                
                Spacer()
                
                if viewModel.difficulty != .easy {
                    Text(viewModel.formattedTime)
                        .font(ThemeManager.Typography.micro(for: colorScheme).bold())
                        .sketchbookInkText(isError: viewModel.timeRemaining < 10 && viewModel.timeRemaining > 0)
                }
                
                Spacer()
                
                Text(LocalizationService.t("LIVES: ", lang: scoreManager.uiLanguage) + "\(viewModel.remainingLives)")
                    .font(ThemeManager.Typography.micro(for: colorScheme).bold())
                    .sketchbookInkText(isError: viewModel.remainingLives <= 2)
            }
            .padding(.horizontal, ThemeManager.Layout.spacingMajor) // Placed inside the red notebook margin
            .padding(.top, ThemeManager.Layout.spacingLG)
            
            Spacer().frame(height: 20)
            
            // Rive Animation Sketch Area
            ZStack {
                RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerMD)
                    .handDrawnStroke(color: inkColor, lineWidth: ThemeManager.Layout.strokeKey, jitter: 1.5)
                    .frame(height: 220)
                    .padding(.horizontal, ThemeManager.Layout.spacingMajor)
                
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
                        .font(ThemeManager.Typography.h2(for: colorScheme))
                        .sketchbookInkText(isError: viewModel.gameState == .lost)
                        .padding(.horizontal, ThemeManager.Layout.spacingMajor)
                }
            }
            .frame(height: 100)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: viewModel.currentTaunt)
            
            Spacer().frame(height: 20)
            
            // Masked Word Display
            Text(viewModel.maskedWord)
                .font(.custom("Caveat-Bold", size: 52)) // Token "Letter Blanks"
                .sketchbookInkText()
                .tracking(6)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, ThemeManager.Layout.spacingMajor)
            
            Spacer()
            
            // Interactive Keyboard Grid natively adapting to localized language alphabets safely
            DynamicKeyboardView(
                language: viewModel.language,
                guessedLetters: viewModel.guessedLetters,
                onGuess: { char in
                    viewModel.guess(letter: char)
                }
            )
            .padding(.leading, ThemeManager.Layout.spacingXL) // Offset to sit to the right of the vertical notebook line
            .padding(.bottom, ThemeManager.Layout.spacingLG)
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
        case .idle, .inProgress: return LocalizationService.t("Guess a letter...", lang: scoreManager.uiLanguage)
        case .won: return LocalizationService.t("YOU SURVIVED.", lang: scoreManager.uiLanguage)
        case .lost: return LocalizationService.t("GAME OVER.", lang: scoreManager.uiLanguage)
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
