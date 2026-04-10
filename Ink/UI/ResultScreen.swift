//
//  ResultScreen.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI
import SwiftData

// MARK: - Result Screen (Victory + Defeat)
public struct ResultScreen: View {
    let isWin: Bool
    let wordText: String
    let difficulty: Difficulty
    let language: Language
    let remainingLives: Int
    let timeTaken: Int
    let category: GameCategory
    let definition: String
    let hintsUsed: Int
    let wrongGuesses: Int
    
    let actionPlayAgain: () -> Void
    let actionMenu: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var scoreManager = ScoreManager.shared
    
    // Animation states
    @State private var lettersVisible: [Bool] = []
    @State private var screenShake: CGFloat = 0
    @State private var defeatQuote: String = ""
    @State private var newAchievements: [String] = []
    @State private var showAchievementBadge: Bool = false
    @State private var achievementBadgeOffset: CGFloat = 200
    
    private var score: Int {
        max(0, Int((100.0 + Double(remainingLives) * 20.0 - Double(timeTaken) * 0.5).rounded()))
    }
    
    private var accentRed: Color { ThemeManager.Colors.accentRed(for: colorScheme) }
    private var inkColor: Color { ThemeManager.Colors.inkPrimary(for: colorScheme) }
    private var victoryGreen: Color { ThemeManager.Colors.victoryGreen(for: colorScheme) }
    
    public init(
        isWin: Bool,
        wordText: String,
        difficulty: Difficulty,
        language: Language,
        remainingLives: Int,
        timeTaken: Int = 0,
        category: GameCategory = .random,
        definition: String = "",
        hintsUsed: Int = 0,
        wrongGuesses: Int = 0,
        actionPlayAgain: @escaping () -> Void,
        actionMenu: @escaping () -> Void
    ) {
        self.isWin = isWin
        self.wordText = wordText
        self.difficulty = difficulty
        self.language = language
        self.remainingLives = remainingLives
        self.timeTaken = timeTaken
        self.category = category
        self.definition = definition
        self.hintsUsed = hintsUsed
        self.wrongGuesses = wrongGuesses
        self.actionPlayAgain = actionPlayAgain
        self.actionMenu = actionMenu
    }
    
    public var body: some View {
        ZStack {
            if isWin {
                VictoryBody()
            } else {
                DefeatBody(defeatQuote: defeatQuote)
            }
            
            // Achievement badge popup
            if showAchievementBadge, let achievementId = newAchievements.first,
               let achievement = AchievementManager.all.first(where: { $0.id == achievementId }) {
                VStack {
                    Spacer()
                    AchievementBadgePopup(achievement: achievement, language: scoreManager.uiLanguage, colorScheme: colorScheme)
                        .padding(.bottom, ThemeManager.Layout.spacingMajor)
                        .offset(y: achievementBadgeOffset)
                }
                .ignoresSafeArea()
            }
        }
        .sketchbookBackground()
        .offset(x: screenShake)
        .onAppear { handleAppear() }
    }
    
    // MARK: - Victory Layout
    @ViewBuilder
    private func VictoryBody() -> some View {
        ScrollView {
            VStack(spacing: ThemeManager.Layout.spacingLG) {
                Spacer().frame(height: ThemeManager.Layout.spacingMajor)
                
                // 🎓 Icon
                Text("🎓")
                    .font(.system(size: 72))
                
                // PASSED!
                Text(LocalizationService.t("PASSED!", lang: scoreManager.uiLanguage))
                    .font(.custom("Caveat-Bold", size: 48))
                    .foregroundColor(victoryGreen)
                
                // Animated word reveal (stagger 0.05s)
                HStack(spacing: 4) {
                    ForEach(Array(wordText.enumerated()), id: \.offset) { index, char in
                        Text(String(char))
                            .font(.custom("Caveat-Bold", size: 40))
                            .foregroundColor(victoryGreen)
                            .tracking(4)
                            .scaleEffect(letterVisible(index: index) ? 1.0 : 0.3)
                            .opacity(letterVisible(index: index) ? 1.0 : 0)
                    }
                }
                
                // Definition box
                if !definition.isEmpty {
                    Text(definition)
                        .font(ThemeManager.Typography.body(for: colorScheme))
                        .foregroundColor(inkColor)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerMD)
                                .stroke(inkColor.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6, 3]))
                        )
                        .padding(.horizontal, ThemeManager.Layout.spacingXL)
                }
                
                // Divider
                Rectangle()
                    .fill(inkColor.opacity(0.2))
                    .frame(height: 1)
                    .padding(.horizontal, ThemeManager.Layout.spacingXL)
                
                // Stat chips
                HStack(spacing: ThemeManager.Layout.spacingMD) {
                    StatChip(label: LocalizationService.t("Time", lang: scoreManager.uiLanguage), value: "\(timeTaken)s", colorScheme: colorScheme)
                    StatChip(label: LocalizationService.t("Lives", lang: scoreManager.uiLanguage), value: "\(remainingLives)", colorScheme: colorScheme)
                    StatChip(label: LocalizationService.t("Score", lang: scoreManager.uiLanguage), value: "\(score)", colorScheme: colorScheme)
                }
                .padding(.horizontal, ThemeManager.Layout.spacingXL)
                
                // Buttons
                VStack(spacing: ThemeManager.Layout.spacingLG) {
                    Button(action: {
                        HapticService.shared.playPenStrike()
                        AudioService.shared.play(.penScratch)
                        actionPlayAgain()
                    }) {
                        Text(LocalizationService.t("NEXT WORD", lang: scoreManager.uiLanguage))
                            .frame(maxWidth: .infinity)
                    }
                    .doodleButtonStyle()
                    
                    Button(action: {
                        HapticService.shared.playPenStrike()
                        AudioService.shared.play(.pencilSnap)
                        actionMenu()
                    }) {
                        Text(LocalizationService.t("MAIN MENU", lang: scoreManager.uiLanguage))
                            .frame(maxWidth: .infinity)
                    }
                    .doodleButtonStyle()
                }
                .padding(.horizontal, ThemeManager.Layout.spacingXL)
                .padding(.bottom, ThemeManager.Layout.spacingMajor)
            }
        }
    }
    
    // MARK: - Defeat Layout
    @ViewBuilder
    private func DefeatBody(defeatQuote: String) -> some View {
        ScrollView {
            VStack(spacing: ThemeManager.Layout.spacingLG) {
                Spacer().frame(height: ThemeManager.Layout.spacingMajor)
                
                // 📕 Icon
                Text("📕")
                    .font(.system(size: 72))
                
                // FAILED.
                Text(LocalizationService.t("FAILED.", lang: scoreManager.uiLanguage))
                    .font(.custom("Caveat-Bold", size: 48))
                    .foregroundColor(accentRed)
                
                // Defeat quote
                if !defeatQuote.isEmpty {
                    Text(defeatQuote)
                        .font(ThemeManager.Typography.body(for: colorScheme).italic())
                        .foregroundColor(inkColor.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, ThemeManager.Layout.spacingXL)
                }
                
                // "The word was:"
                Text(LocalizationService.t("The word was:", lang: scoreManager.uiLanguage))
                    .font(ThemeManager.Typography.micro(for: colorScheme))
                    .foregroundColor(inkColor.opacity(0.6))
                
                // Animated word reveal in red (stagger 0.06s)
                HStack(spacing: 4) {
                    ForEach(Array(wordText.enumerated()), id: \.offset) { index, char in
                        Text(String(char))
                            .font(.custom("Caveat-Bold", size: 40))
                            .foregroundColor(accentRed)
                            .tracking(4)
                            .scaleEffect(letterVisible(index: index) ? 1.0 : 0.3)
                            .opacity(letterVisible(index: index) ? 1.0 : 0)
                    }
                }
                
                // Definition box
                if !definition.isEmpty {
                    Text(definition)
                        .font(ThemeManager.Typography.body(for: colorScheme))
                        .foregroundColor(inkColor)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerMD)
                                .stroke(accentRed.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6, 3]))
                        )
                        .padding(.horizontal, ThemeManager.Layout.spacingXL)
                }
                
                // Buttons
                VStack(spacing: ThemeManager.Layout.spacingLG) {
                    Button(action: {
                        HapticService.shared.playPenStrike()
                        AudioService.shared.play(.penScratch)
                        actionPlayAgain()
                    }) {
                        Text(LocalizationService.t("TRY AGAIN", lang: scoreManager.uiLanguage))
                            .frame(maxWidth: .infinity)
                    }
                    .doodleButtonStyle(isDestructive: true)
                    
                    Button(action: {
                        HapticService.shared.playPenStrike()
                        AudioService.shared.play(.pencilSnap)
                        actionMenu()
                    }) {
                        Text(LocalizationService.t("MAIN MENU", lang: scoreManager.uiLanguage))
                            .frame(maxWidth: .infinity)
                    }
                    .doodleButtonStyle()
                }
                .padding(.horizontal, ThemeManager.Layout.spacingXL)
                .padding(.bottom, ThemeManager.Layout.spacingMajor)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func letterVisible(index: Int) -> Bool {
        guard index < lettersVisible.count else { return false }
        return lettersVisible[index]
    }
    
    private func handleAppear() {
        // Save to SwiftData
        let session = GameSession(
            word: wordText,
            language: language.rawValue,
            difficulty: difficulty.rawValue,
            category: category.rawValue,
            score: isWin ? score : 0,
            isWin: isWin,
            timeTaken: timeTaken,
            hintsUsed: hintsUsed,
            wrongGuesses: wrongGuesses
        )
        modelContext.insert(session)
        ScoreManager.shared.recalculateStats()
        
        // Update UserDefaults stats + check achievements
        let earned = StatsManager.updateAfterGame(
            isWin: isWin,
            category: category,
            difficulty: difficulty,
            language: language,
            timeTaken: timeTaken,
            hintsUsed: hintsUsed,
            wrongGuesses: wrongGuesses,
            score: isWin ? score : 0
        )
        newAchievements = earned
        
        // Defeat shake
        if !isWin {
            withAnimation(.easeInOut(duration: 0.05).repeatCount(6, autoreverses: true)) {
                screenShake = 8
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                screenShake = 0
            }
            
            // Load defeat quote
            Task {
                let quote = await TauntService.shared.fetchDefeatQuote(language: language)
                await MainActor.run { defeatQuote = quote }
            }
        }
        
        // Letter stagger animation
        let count = wordText.count
        lettersVisible = Array(repeating: false, count: count)
        let stagger = isWin ? 0.05 : 0.06
        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * stagger + 0.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    if i < lettersVisible.count {
                        lettersVisible[i] = true
                    }
                }
            }
        }
        
        // Achievement badge if any unlocked
        if !earned.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showAchievementBadge = true
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    achievementBadgeOffset = 0
                }
            }
        }
        
        // Haptics
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if isWin {
                HapticService.shared.playSuccessPulse()
                AudioService.shared.play(.checkmark)
            } else {
                HapticService.shared.playErrorPulse()
                AudioService.shared.play(.pencilSnap)
            }
        }
    }
}

// MARK: - Stat Chip
private struct StatChip: View {
    let label: String
    let value: String
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.custom("Caveat-Bold", size: 24))
                .foregroundColor(ThemeManager.Colors.statNumber(for: colorScheme))
            Text(label)
                .font(ThemeManager.Typography.micro(for: colorScheme))
                .foregroundColor(ThemeManager.Colors.inkPrimary(for: colorScheme).opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, ThemeManager.Layout.spacingSM)
        .background(
            RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerKey)
                .stroke(ThemeManager.Colors.inkPrimary(for: colorScheme).opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Achievement Badge Popup
private struct AchievementBadgePopup: View {
    let achievement: AchievementManager.Achievement
    let language: Language
    let colorScheme: ColorScheme
    
    var body: some View {
        HStack(spacing: ThemeManager.Layout.spacingMD) {
            Text(achievement.emoji)
                .font(.system(size: 32))
            VStack(alignment: .leading) {
                Text(achievement.name(for: language))
                    .font(.custom("Caveat-Bold", size: 20))
                    .foregroundColor(ThemeManager.Colors.accentRed(for: colorScheme))
                Text("Achievement Unlocked!")
                    .font(ThemeManager.Typography.micro(for: colorScheme))
                    .foregroundColor(ThemeManager.Colors.inkPrimary(for: colorScheme).opacity(0.7))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerMD)
                .fill(ThemeManager.Colors.bgSecondary(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerMD)
                        .stroke(ThemeManager.Colors.accentRed(for: colorScheme), lineWidth: 2)
                )
                .shadow(color: ThemeManager.Colors.accentRed(for: colorScheme).opacity(0.4), radius: 12)
        )
        .padding(.horizontal, ThemeManager.Layout.spacingXL)
    }
}
