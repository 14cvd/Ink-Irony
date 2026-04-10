//
//  ContentView.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI

// MARK: - Navigation Routing State
public enum AppRoute: Hashable {
    case setup
    case game(difficulty: Difficulty, language: Language, wordText: String, category: GameCategory, hint: String, definition: String)
    case result(isWin: Bool, wordText: String, difficulty: Difficulty, language: Language, livesLeft: Int, timeTaken: Int, category: GameCategory, definition: String, hintsUsed: Int, wrongGuesses: Int)
    case daily
}

public struct ContentView: View {
    @State private var navigationPath = NavigationPath()
    @State private var hasCompletedOnboarding: Bool = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var audioService = AudioService.shared
    @StateObject private var hapticService = HapticService.shared
    
    @State private var chosenLanguage: Language = .english
    @State private var chosenDifficulty: Difficulty = .medium
    @State private var chosenCategory: GameCategory = .random
    
    public init() {}
    
    public var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingFlow(onboardingComplete: $hasCompletedOnboarding)
                    .transition(.opacity)
            } else {
                NavigationStack(path: $navigationPath) {
                    MainMenu(path: $navigationPath)
                        .navigationDestination(for: AppRoute.self) { route in
                            destinationView(for: route)
                        }
                }
            }
        }
        .environmentObject(themeManager)
        .environmentObject(scoreManager)
        .environmentObject(audioService)
        .environmentObject(hapticService)
    }
    
    // MARK: - Route → Destination (extracted to help the Swift type-checker)
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .setup:
            GameSetupCoordinator(
                path: $navigationPath,
                chosenLanguage: $chosenLanguage,
                chosenDifficulty: $chosenDifficulty,
                chosenCategory: $chosenCategory
            )
            .navigationBarBackButtonHidden()
            
        case .game(let difficulty, let language, let wordText, let category, let hint, let definition):
            gameDestination(
                difficulty: difficulty,
                language: language,
                wordText: wordText,
                category: category,
                hint: hint,
                definition: definition
            )
            
        case .result(let isWin, let wordText, let difficulty, let language, let livesLeft, let timeTaken, let category, let definition, let hintsUsed, let wrongGuesses):
            ResultScreen(
                isWin: isWin,
                wordText: wordText,
                difficulty: difficulty,
                language: language,
                remainingLives: livesLeft,
                timeTaken: timeTaken,
                category: category,
                definition: definition,
                hintsUsed: hintsUsed,
                wrongGuesses: wrongGuesses,
                actionPlayAgain: {
                    navigationPath.removeLast(navigationPath.count)
                    navigationPath.append(AppRoute.setup)
                },
                actionMenu: {
                    navigationPath.removeLast(navigationPath.count)
                }
            )
            .navigationBarBackButtonHidden()
            
        case .daily:
            DailyChallengeView(path: $navigationPath)
                .navigationBarBackButtonHidden()
        }
    }
    
    // Extracted further to reduce per-closure complexity
    @ViewBuilder
    private func gameDestination(
        difficulty: Difficulty,
        language: Language,
        wordText: String,
        category: GameCategory,
        hint: String,
        definition: String
    ) -> some View {
        GameDestinationView(
            difficulty: difficulty,
            language: language,
            wordText: wordText,
            category: category,
            hint: hint,
            definition: definition,
            navigationPath: $navigationPath
        )
    }
}

// MARK: - Game Destination View (isolated struct to avoid type-checker timeout)
private struct GameDestinationView: View {
    let difficulty: Difficulty
    let language: Language
    let wordText: String
    let category: GameCategory
    let hint: String
    let definition: String
    @Binding var navigationPath: NavigationPath

    var body: some View {
        let word = Word(
            text: wordText,
            language: language,
            category: category,
            hint: hint,
            definition: definition
        )
        return GameView(word: word, difficulty: difficulty, onGameEnd: buildCallback())
            .navigationBarBackButtonHidden()
    }

    private func buildCallback() -> (Bool, Int, Int, Int, Int) -> Void {
        return { won, remainingLives, timeTaken, hintsUsed, wrongGuesses in
            let rawScore: Double = 100.0 + Double(remainingLives) * 20.0 - Double(timeTaken) * 0.5
            let score: Int = max(0, Int(rawScore.rounded()))
            let route = AppRoute.result(
                isWin: won,
                wordText: wordText,
                difficulty: difficulty,
                language: language,
                livesLeft: remainingLives,
                timeTaken: timeTaken,
                category: category,
                definition: definition,
                hintsUsed: hintsUsed,
                wrongGuesses: wrongGuesses
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                navigationPath.append(route)
            }
        }
    }
}


// MARK: - Main Menu
public struct MainMenu: View {
    @Binding var path: NavigationPath
    @State private var showRecords = false
    @State private var showSettings = false
    @ObservedObject private var scoreManager = ScoreManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.colorScheme) private var colorScheme
    
    public var body: some View {
        VStack(spacing: ThemeManager.Layout.spacingXL) {
            Spacer()
            
            Text(LocalizationService.t("INK & IRONY", lang: scoreManager.uiLanguage))
                .font(.custom("Caveat-Bold", size: 36))
                .sketchbookInkText(isError: true)
            
            Spacer()
            
            // START EXAM
            Button(LocalizationService.t("START EXAM", lang: scoreManager.uiLanguage)) {
                HapticService.shared.playPenStrike()
                AudioService.shared.play(.penScratch)
                path.append(AppRoute.setup)
            }
            .doodleButtonStyle()
            .padding(.horizontal, ThemeManager.Layout.spacingXL)
            
            // DAILY CHALLENGE (new)
            Button(LocalizationService.t("DAILY CHALLENGE", lang: scoreManager.uiLanguage)) {
                HapticService.shared.playPenStrike()
                AudioService.shared.play(.penScratch)
                path.append(AppRoute.daily)
            }
            .doodleButtonStyle()
            .padding(.horizontal, ThemeManager.Layout.spacingXL)
            
            // RECORDS
            Button(LocalizationService.t("RECORDS", lang: scoreManager.uiLanguage)) {
                HapticService.shared.playPenStrike()
                showRecords = true
            }
            .doodleButtonStyle()
            .opacity(0.8)
            .padding(.horizontal, ThemeManager.Layout.spacingXL)
            .sheet(isPresented: $showRecords) {
                RecordsView()
                    .preferredColorScheme(themeManager.preferredColorScheme)
            }
            
            // SETTINGS (new)
            Button(LocalizationService.t("SETTINGS", lang: scoreManager.uiLanguage)) {
                HapticService.shared.playPenStrike()
                showSettings = true
            }
            .doodleButtonStyle()
            .opacity(0.8)
            .padding(.horizontal, ThemeManager.Layout.spacingXL)
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .preferredColorScheme(themeManager.preferredColorScheme)
            }
            
            Spacer()
        }
        .sketchbookBackground()
    }
}

// MARK: - Setup Coordinator
public struct GameSetupCoordinator: View {
    @Binding var path: NavigationPath
    @Binding var chosenLanguage: Language
    @Binding var chosenDifficulty: Difficulty
    @Binding var chosenCategory: GameCategory
    
    @State private var internalIsSetupComplete: Bool = false
    
    public var body: some View {
        GameSetupView(
            isSetupComplete: $internalIsSetupComplete,
            chosenLanguage: $chosenLanguage,
            chosenDifficulty: $chosenDifficulty,
            chosenCategory: $chosenCategory
        )
        .onAppear { internalIsSetupComplete = false }
        .onChange(of: internalIsSetupComplete) { complete in
            if complete {
                Task {
                    let targetWord = await WordRepository.shared.fetchRandomWord(
                        language: chosenLanguage,
                        difficulty: chosenDifficulty,
                        category: chosenCategory
                    )
                    
                    await MainActor.run {
                        path.append(AppRoute.game(
                            difficulty: chosenDifficulty,
                            language: chosenLanguage,
                            wordText: targetWord.text,
                            category: targetWord.category,
                            hint: targetWord.hint,
                            definition: targetWord.definition
                        ))
                    }
                }
            }
        }
    }
}
