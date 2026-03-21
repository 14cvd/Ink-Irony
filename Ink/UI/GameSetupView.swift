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
    }
    
    public var body: some View {
        VStack(spacing: 30) {
            Text("NEW GAME")
                .font(.custom("Marker Felt", size: 42).bold())
                .sketchbookInkText(isError: true)
                .padding(.top, 50)
            
            // Language Selection
            VStack(alignment: .leading, spacing: 15) {
                Text("Select Language:")
                    .font(.custom("Noteworthy", size: 24).bold())
                    .sketchbookInkText()
                    .padding(.leading, 10)
                
                // Adaptive grid supports languages expanding flexibly
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80, maximum: 120))], spacing: 15) {
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
            VStack(alignment: .leading, spacing: 15) {
                Text("Select Difficulty:")
                    .font(.custom("Noteworthy", size: 24).bold())
                    .sketchbookInkText()
                    .padding(.leading, 10)
                
                VStack(spacing: 12) {
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
                    chosenLanguage = selectedLanguage
                    chosenDifficulty = selectedDifficulty
                    isSetupComplete = true
                }
            }) {
                Text("START SKETCHING")
                    .frame(maxWidth: .infinity)
            }
            .doodleButtonStyle()
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
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
            return colorScheme == .dark ? ThemeManager.Colors.teacherRed.opacity(0.8) : ThemeManager.Colors.teacherRed
        } else {
            return colorScheme == .dark ? ThemeManager.Colors.graphiteGray : ThemeManager.Colors.ballpointBlue
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Noteworthy", size: 18).bold())
                .foregroundColor(inkColor)
                .frame(maxWidth: isFullWidth ? .infinity : nil)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    ZStack {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 8)
                                .handDrawnStroke(color: inkColor, lineWidth: 3, jitter: 2.0)
                                // Slight rotation to signify it's firmly circled manually
                                .rotationEffect(.degrees(CGFloat.random(in: -2...2)))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .handDrawnStroke(color: inkColor, lineWidth: 1.5, jitter: 1.0)
                        }
                    }
                )
        }
    }
}
