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
    @AppStorage("showTimer") private var showTimer: Bool = true
    @AppStorage("teacherQuotes") private var teacherQuotesEnabled: Bool = true
    
    let startingWord: Word
    let startingDifficulty: Difficulty
    
    // Game over closure now includes timeTaken, hintsUsed, wrongGuesses
    let onGameEnd: ((Bool, Int, Int, Int, Int) -> Void)?
    
    public init(
        word: Word = Word(text: "SKETCHBOOK", language: .english, category: .random),
        difficulty: Difficulty = .medium,
        onGameEnd: ((Bool, Int, Int, Int, Int) -> Void)? = nil
    ) {
        self.startingWord = word
        self.startingDifficulty = difficulty
        self.onGameEnd = onGameEnd
    }
    
    private var inkColor: Color { ThemeManager.Colors.inkPrimary(for: colorScheme) }
    private var accentRed: Color { ThemeManager.Colors.accentRed(for: colorScheme) }
    
    public var body: some View {
        VStack(spacing: 0) {
            
            // ── Top Bar: Difficulty | Timer | Lives ──
            HStack {
                Text(LocalizationService.t(viewModel.difficulty.rawValue.uppercased(), lang: scoreManager.uiLanguage))
                    .font(ThemeManager.Typography.micro(for: colorScheme).bold())
                    .sketchbookInkText()
                
                Spacer()
                
                if showTimer {
                    Text(viewModel.formattedTime)
                        .font(ThemeManager.Typography.micro(for: colorScheme).bold())
                        .sketchbookInkText(isError: viewModel.timeRemaining <= 10)
                    
                    Spacer()
                }
                
                Text(LocalizationService.t("LIVES: ", lang: scoreManager.uiLanguage) + "\(viewModel.remainingLives)")
                    .font(ThemeManager.Typography.micro(for: colorScheme).bold())
                    .sketchbookInkText(isError: viewModel.remainingLives <= 2)
            }
            .padding(.horizontal, ThemeManager.Layout.spacingMajor)
            .padding(.top, ThemeManager.Layout.spacingLG)
            
            // ── Category Badge (NEW) ──
            if let word = viewModel.currentWord {
                HStack(spacing: 4) {
                    Text(word.category.emoji)
                        .font(.system(size: 12))
                    Text(word.category.displayName(for: scoreManager.uiLanguage).uppercased())
                        .font(ThemeManager.Typography.micro(for: colorScheme).bold())
                        .foregroundColor(accentRed)
                }
                .padding(.horizontal, ThemeManager.Layout.spacingMD)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerSM)
                        .stroke(accentRed, style: StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
                )
                .padding(.top, ThemeManager.Layout.spacingSM)
            }
            
            Spacer().frame(height: 16)
            
            // ── Sketch Gallows ──
            ZStack {
                RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerMD)
                    .handDrawnStroke(color: inkColor, lineWidth: ThemeManager.Layout.strokeKey, jitter: 1.5)
                    .frame(height: 200)
                    .padding(.horizontal, ThemeManager.Layout.spacingMajor)
                
                let mistakes = viewModel.difficulty.lives - viewModel.remainingLives
                let scaledMistakes = Int((Double(mistakes) / Double(viewModel.difficulty.lives)) * 8.0)
                SketchGallowsView(wrongGuesses: scaledMistakes)
                    .frame(height: 180)
            }
            
            Spacer().frame(height: 20)
            
            // ── Teacher Taunt / Status ──
            VStack {
                if teacherQuotesEnabled {
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
            }
            .frame(height: 80)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: viewModel.currentTaunt)
            
            Spacer().frame(height: 12)
            
            // ── Word Display ──
            Text(viewModel.maskedWord)
                .font(.custom("Caveat-Bold", size: 48))
                .sketchbookInkText()
                .tracking(6)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
                .padding(.horizontal, ThemeManager.Layout.spacingMajor)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: viewModel.maskedWord)
            
            Spacer().frame(height: 12)
            
            // ── Hint Button + Hint Text (NEW) ──
            VStack(spacing: ThemeManager.Layout.spacingSM) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.useHint()
                    }
                }) {
                    HStack(spacing: 6) {
                        Text("💡")
                        Text("\(LocalizationService.t("HINT", lang: scoreManager.uiLanguage)) \(LocalizationService.hintSuffix(viewModel.hintsRemaining, lang: scoreManager.uiLanguage))")
                            .font(ThemeManager.Typography.micro(for: colorScheme).bold())
                    }
                    .foregroundColor(viewModel.hintsRemaining > 0 ? accentRed : ThemeManager.Colors.inkPrimary(for: colorScheme).opacity(0.4))
                    .padding(.horizontal, ThemeManager.Layout.spacingMD)
                    .padding(.vertical, ThemeManager.Layout.spacingXS)
                    .background(
                        RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerSM)
                            .stroke(
                                viewModel.hintsRemaining > 0 ? accentRed.opacity(0.6) : ThemeManager.Colors.inkPrimary(for: colorScheme).opacity(0.2),
                                style: StrokeStyle(lineWidth: 1.5, dash: [5, 3])
                            )
                    )
                }
                .disabled(viewModel.hintsRemaining == 0 || viewModel.gameState != .inProgress)
                .frame(minHeight: 44)
                
                if let hint = viewModel.hintText {
                    Text(hint)
                        .font(ThemeManager.Typography.micro(for: colorScheme))
                        .foregroundColor(ThemeManager.Colors.hintBoxText(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, ThemeManager.Layout.spacingMD)
                        .padding(.vertical, ThemeManager.Layout.spacingXS)
                        .background(
                            RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerSM)
                                .stroke(ThemeManager.Colors.hintBoxBorder(for: colorScheme), style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
                        )
                        .padding(.horizontal, ThemeManager.Layout.spacingMajor)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            
            Spacer()
            
            // ── Keyboard ──
            DynamicKeyboardView(
                language: viewModel.language,
                guessedLetters: viewModel.guessedLetters,
                onGuess: { char in viewModel.guess(letter: char) }
            )
            .padding(.leading, ThemeManager.Layout.spacingXL)
            .padding(.bottom, ThemeManager.Layout.spacingLG)
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
        viewModel.onTimeWarning = { [weak viewModel] timeLeft, language in
            Task {
                guard let viewModel = viewModel else { return }
                let taunt = await TauntService.shared.fetchTaunt(language: language, wrongCount: 0, difficulty: viewModel.difficulty)
                await MainActor.run {
                    let prefixStr = "⏱️ \(timeLeft)s: "
                    viewModel.setTaunt(prefixStr + taunt)
                }
                HapticService.shared.playPenStrike()
            }
        }
        
        viewModel.onWrongGuess = { [weak viewModel] livesLeft, language in
            Task {
                guard let viewModel = viewModel else { return }
                let mistakes = viewModel.difficulty.lives - livesLeft
                let taunt = await TauntService.shared.fetchTaunt(language: language, wrongCount: mistakes, difficulty: viewModel.difficulty)
                await MainActor.run {
                    viewModel.setTaunt(taunt)
                }
                HapticService.shared.playSketchTexture(duration: 0.6)
                AudioService.shared.play(.penScratch)
            }
        }
        
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
                let elapsed = viewModel?.elapsedSeconds ?? 0
                let hintsUsed = 2 - (viewModel?.hintsRemaining ?? 0)
                let wrongs = viewModel?.wrongGuessCount ?? 0
                onGameEnd(won, viewModel?.remainingLives ?? 0, elapsed, hintsUsed, wrongs)
            }
        }
    }
}
