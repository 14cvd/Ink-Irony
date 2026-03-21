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
    
    @Binding var isSetupComplete: Bool
    @Binding var chosenLanguage: Language
    @Binding var chosenDifficulty: Difficulty
    
    public init(isSetupComplete: Binding<Bool>, chosenLanguage: Binding<Language>, chosenDifficulty: Binding<Difficulty>) {
        self._isSetupComplete = isSetupComplete
        self._chosenLanguage = chosenLanguage
        self._chosenDifficulty = chosenDifficulty
        self._selectedLanguage = State(initialValue: ScoreManager.shared.uiLanguage)
    }
    
    public var body: some View {
        VStack(spacing: ThemeManager.Layout.spacingLG) {
            Text(LocalizationService.t("NEW GAME", lang: selectedLanguage))
                .font(ThemeManager.Typography.h1(for: selectedLanguage == .english ? .light : .dark)) // Generic theme usage
                .sketchbookInkText(isError: true)
                .padding(.top, ThemeManager.Layout.spacingMajor)
            
            // Language Selection
            VStack(alignment: .leading, spacing: ThemeManager.Layout.spacingMD) {
                Text(LocalizationService.t("Select Language:", lang: selectedLanguage))
                    .font(ThemeManager.Typography.h2(for: .light))
                    .sketchbookInkText()
                    .padding(.leading, ThemeManager.Layout.spacingSM)
                
                // Adaptive grid supports languages expanding flexibly
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
            .padding(.horizontal, 40) // Align inside notebook margins
            
            // Difficulty Selection
            VStack(alignment: .leading, spacing: ThemeManager.Layout.spacingMD) {
                Text(LocalizationService.t("Select Difficulty:", lang: selectedLanguage))
                    .font(ThemeManager.Typography.h2(for: .light))
                    .sketchbookInkText()
                    .padding(.leading, ThemeManager.Layout.spacingSM)
                
                VStack(spacing: ThemeManager.Layout.spacingSM) {
                    ForEach(Difficulty.allCases) { diff in
                        SelectionDoodleButton(
                            title: "\(diff.rawValue.uppercased()) (\(diff.lives) Lives)",
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
            
            Spacer()
            
            Button(action: {
                HapticService.shared.playSuccessPulse()
                AudioService.shared.play(.checkmark)
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    ScoreManager.shared.uiLanguage = selectedLanguage
                    chosenLanguage = selectedLanguage
                    chosenDifficulty = selectedDifficulty
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
        .sketchbookBackground()
    }
}

// MARK: - Local Helper View
// Helper block for radio-button style selection respecting notebook aesthetics
fileprivate struct SelectionDoodleButton: View {
    let title: String
    let isSelected: Bool
    var isFullWidth: Bool = false
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var inkColor: Color {
        // Teacher red when selected to look like a chosen/circled answer, ballpoint pen when unselected
        if isSelected {
            return ThemeManager.Colors.errorInk(for: colorScheme)
        } else {
            return ThemeManager.Colors.inkPrimary(for: colorScheme)
        }
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
                                // Slight rotation to signify it's firmly circled manually
                                .rotationEffect(.degrees(CGFloat.random(in: -2...2)))
                        } else {
                            RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerKey)
                                .handDrawnStroke(color: inkColor.opacity(0.3), lineWidth: ThemeManager.Layout.strokeHair, jitter: 1.0)
                        }
                    }
                )
        }
    }
}
