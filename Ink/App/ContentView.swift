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
    case game(difficulty: Difficulty, language: Language, wordText: String)
    case result(isWin: Bool, wordText: String, difficulty: Difficulty, language: Language, livesLeft: Int)
}

public struct ContentView: View {
    @State private var navigationPath = NavigationPath()
    @State private var hasCompletedOnboarding: Bool = false
    
    // Global Environment Objects initialized identically at the root
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var audioService = AudioService.shared
    @StateObject private var hapticService = HapticService.shared
    
    // Global Setup Bindings
    @State private var isSetupComplete: Bool = false
    @State private var chosenLanguage: Language = .english
    @State private var chosenDifficulty: Difficulty = .medium
    
    public init() {}
    
    public var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingFlow(onboardingComplete: $hasCompletedOnboarding)
                    .transition(.opacity) // Elegant fade into the main menu when complete
            } else {
                NavigationStack(path: $navigationPath) {
                    MainMenu(path: $navigationPath)
                        .navigationDestination(for: AppRoute.self) { route in
                            switch route {
                            case .setup:
                                GameSetupCoordinator(
                                    path: $navigationPath,
                                    chosenLanguage: $chosenLanguage,
                                    chosenDifficulty: $chosenDifficulty
                                )
                                .navigationBarBackButtonHidden()
                                
                            case .game(let difficulty, let language, let wordText):
                                let startingWord = Word(text: wordText, language: language, category: "General")
                                
                                GameView(word: startingWord, difficulty: difficulty) { won, remainingLives in
                                    // Wait for the Savage AI taunt / Rive death animation natively
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                        navigationPath.append(AppRoute.result(isWin: won, wordText: wordText, difficulty: difficulty, language: language, livesLeft: remainingLives))
                                    }
                                }
                                .navigationBarBackButtonHidden()
                                
                            case .result(let isWin, let wordText, let difficulty, let language, let livesLeft):
                                ResultScreen(
                                    isWin: isWin,
                                    wordText: wordText,
                                    difficulty: difficulty,
                                    language: language,
                                    remainingLives: livesLeft,
                                    actionPlayAgain: {
                                        // Quick play again jumps straight back to a new Setup page (clearing history to prevent double pop)
                                        navigationPath.removeLast(navigationPath.count) // Pop to root
                                        navigationPath.append(AppRoute.setup) // Push Setup immediately
                                    },
                                    actionMenu: {
                                        // Pop completely back to MainMenu
                                        navigationPath.removeLast(navigationPath.count)
                                    }
                                )
                                .navigationBarBackButtonHidden()
                            }
                        }
                }
            }
        }
        // Inject singletons universally
        .environmentObject(themeManager)
        .environmentObject(scoreManager)
        .environmentObject(audioService)
        .environmentObject(hapticService)
    }
}

// MARK: - Dedicated Main Menu
public struct MainMenu: View {
    @Binding var path: NavigationPath
    @State private var animateTitle = false
    @State private var showLeaderboard = false
    
    public var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text("INK & IRONY")
                .font(.custom("Marker Felt", size: 60).bold())
                .sketchbookInkText(isError: true)
                .rotationEffect(.degrees(animateTitle ? -2 : 2))
                .animation(.easeInOut(duration: 0.15).repeatForever(autoreverses: true), value: animateTitle)
                .onAppear { animateTitle = true }
            
            Spacer()
            
            Button("START EXAM") {
                HapticService.shared.playPenStrike()
                AudioService.shared.play(.penScratch)
                path.append(AppRoute.setup)
            }
            .doodleButtonStyle()
            .padding(.horizontal, 50)
            
            Button("RECORDS") {
                HapticService.shared.playPenStrike()
                showLeaderboard = true
            }
            .doodleButtonStyle()
            .opacity(0.8)
            .padding(.horizontal, 50)
            .sheet(isPresented: $showLeaderboard) {
                LeaderboardView()
            }
            
            Spacer()
        }
        .sketchbookBackground()
    }
}

// MARK: - Setup Coordinator Wrapper
public struct GameSetupCoordinator: View {
    @Binding var path: NavigationPath
    @Binding var chosenLanguage: Language
    @Binding var chosenDifficulty: Difficulty
    
    // Internal state to manage rendering resets cleanly
    @State private var internalIsSetupComplete: Bool = false
    
    public var body: some View {
        GameSetupView(
            isSetupComplete: $internalIsSetupComplete,
            chosenLanguage: $chosenLanguage,
            chosenDifficulty: $chosenDifficulty
        )
        .onAppear { internalIsSetupComplete = false }
        .onChange(of: internalIsSetupComplete) { complete in
            if complete {
                // Pop the Setup View silently so the backstack remains cleanly maintained
                path.removeLast()
                
                Task {
                    // Pull a rigorously localized word dynamically from the JSON repositories mapped to user difficulty
                    let targetWord = await WordRepository.shared.fetchRandomWord(language: chosenLanguage, difficulty: chosenDifficulty)
                    
                    await MainActor.run {
                        path.append(AppRoute.game(difficulty: chosenDifficulty, language: chosenLanguage, wordText: targetWord.text))
                    }
                }
            }
        }
    }
}
