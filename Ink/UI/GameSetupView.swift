//
//  GameSetupView.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI

public struct GameSetupView: View {
    @State private var selectedLanguage: Language = .english
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var selectedCategory: GameCategory = .random
    
    @Binding var isSetupComplete: Bool
    @Binding var chosenLanguage: Language
    @Binding var chosenDifficulty: Difficulty
    @Binding var chosenCategory: GameCategory
    
    @Environment(\.colorScheme) private var colorScheme
    
    public init(
        isSetupComplete: Binding<Bool>,
        chosenLanguage: Binding<Language>,
        chosenDifficulty: Binding<Difficulty>,
        chosenCategory: Binding<GameCategory>
    ) {
        self._isSetupComplete = isSetupComplete
        self._chosenLanguage = chosenLanguage
        self._chosenDifficulty = chosenDifficulty
        self._chosenCategory = chosenCategory
        self._selectedLanguage = State(initialValue: ScoreManager.shared.uiLanguage)
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: ThemeManager.Layout.spacingLG) {
                Text(LocalizationService.t("NEW GAME", lang: selectedLanguage))
                    .font(ThemeManager.Typography.h1(for: colorScheme))
                    .sketchbookInkText(isError: true)
                    .padding(.top, ThemeManager.Layout.spacingMajor)
                
                // ── Language Selector ──
                SectionBlock(title: LocalizationService.t("Select Language:", lang: selectedLanguage)) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80, maximum: 120))], spacing: ThemeManager.Layout.spacingMD) {
                        ForEach(Language.allCases) { lang in
                            SelectionDoodleButton(
                                title: lang.rawValue,
                                isSelected: selectedLanguage == lang,
                                action: {
                                    HapticService.shared.playPenStrike()
                                    AudioService.shared.play(.penScratch)
                                    selectedLanguage = lang
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 40)
                
                // ── Category Selector (NEW) ──
                SectionBlock(title: LocalizationService.t("Choose Topic", lang: selectedLanguage)) {
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: ThemeManager.Layout.spacingMD
                    ) {
                        ForEach(GameCategory.allCases) { cat in
                            CategoryButton(
                                category: cat,
                                language: selectedLanguage,
                                isSelected: selectedCategory == cat,
                                colorScheme: colorScheme,
                                action: {
                                    HapticService.shared.playPenStrike()
                                    AudioService.shared.play(.penScratch)
                                    selectedCategory = cat
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 40)
                
                // ── Difficulty Selector ──
                SectionBlock(title: LocalizationService.t("Select Difficulty:", lang: selectedLanguage)) {
                    VStack(spacing: ThemeManager.Layout.spacingSM) {
                        ForEach(Difficulty.allCases) { diff in
                            SelectionDoodleButton(
                                title: "\(LocalizationService.t(diff.rawValue.uppercased(), lang: selectedLanguage)) (\(diff.lives) \(LocalizationService.t("LIVES", lang: selectedLanguage)))",
                                isSelected: selectedDifficulty == diff,
                                isFullWidth: true,
                                action: {
                                    HapticService.shared.playPenStrike()
                                    AudioService.shared.play(.penScratch)
                                    selectedDifficulty = diff
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 40)
                
                Button(action: {
                    HapticService.shared.playSuccessPulse()
                    AudioService.shared.play(.checkmark)
                    
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        ScoreManager.shared.uiLanguage = selectedLanguage
                        chosenLanguage = selectedLanguage
                        chosenDifficulty = selectedDifficulty
                        chosenCategory = selectedCategory
                        isSetupComplete = true
                    }
                }) {
                    Text(LocalizationService.t("START SKETCHING", lang: selectedLanguage))
                        .frame(maxWidth: .infinity)
                }
                .doodleButtonStyle()
                .padding(.horizontal, ThemeManager.Layout.spacingXL)
                .padding(.bottom, ThemeManager.Layout.spacingMajor)
            }
        }
        .sketchbookBackground()
    }
}

// MARK: - Section Block Helper
fileprivate struct SectionBlock<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: ThemeManager.Layout.spacingMD) {
            Text(title)
                .font(ThemeManager.Typography.h2(for: colorScheme))
                .sketchbookInkText()
                .padding(.leading, ThemeManager.Layout.spacingSM)
            content()
        }
    }
}

// MARK: - Category Button
fileprivate struct CategoryButton: View {
    let category: GameCategory
    let language: Language
    let isSelected: Bool
    let colorScheme: ColorScheme
    let action: () -> Void
    
    private var accentColor: Color {
        ThemeManager.Colors.accentRed(for: colorScheme)
    }
    
    private var inkColor: Color {
        ThemeManager.Colors.inkPrimary(for: colorScheme)
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ThemeManager.Layout.spacingXS) {
                Text(category.emoji)
                    .font(.system(size: 20))
                Text(category.displayName(for: language))
                    .font(ThemeManager.Typography.body(for: colorScheme).bold())
                    .foregroundColor(isSelected ? accentColor : inkColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, ThemeManager.Layout.spacingMD)
            .padding(.vertical, ThemeManager.Layout.spacingSM)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerKey)
                            .stroke(accentColor, style: StrokeStyle(lineWidth: 2, dash: [6, 3]))
                            .background(
                                RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerKey)
                                    .fill(accentColor.opacity(0.08))
                            )
                    } else {
                        RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerKey)
                            .stroke(inkColor.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    }
                }
            )
        }
        .frame(minHeight: 44)
    }
}

// MARK: - Selection Doodle Button
fileprivate struct SelectionDoodleButton: View {
    let title: String
    let isSelected: Bool
    var isFullWidth: Bool = false
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var inkColor: Color {
        isSelected
            ? ThemeManager.Colors.errorInk(for: colorScheme)
            : ThemeManager.Colors.inkPrimary(for: colorScheme)
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(ThemeManager.Typography.body(for: colorScheme).bold())
                .foregroundColor(inkColor)
                .frame(maxWidth: isFullWidth ? .infinity : nil)
                .padding(.horizontal, ThemeManager.Layout.spacingMD)
                .padding(.vertical, ThemeManager.Layout.spacingSM)
                .background(
                    ZStack {
                        if isSelected {
                            RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerKey)
                                .handDrawnStroke(color: inkColor, lineWidth: ThemeManager.Layout.strokeBtn, jitter: 2.0)
                                .rotationEffect(.degrees(CGFloat.random(in: -2...2)))
                        } else {
                            RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerKey)
                                .handDrawnStroke(color: inkColor.opacity(0.3), lineWidth: ThemeManager.Layout.strokeHair, jitter: 1.0)
                        }
                    }
                )
        }
        .frame(minHeight: 44)
    }
}
