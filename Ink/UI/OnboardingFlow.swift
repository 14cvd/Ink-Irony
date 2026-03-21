//
//  OnboardingFlow.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI

public struct OnboardingFlow: View {
    @Binding var onboardingComplete: Bool
    @State private var currentPage = 0
    @ObservedObject private var scoreManager = ScoreManager.shared
    
    public init(onboardingComplete: Binding<Bool>) {
        self._onboardingComplete = onboardingComplete
    }
    
    public var body: some View {
        VStack {
            Spacer()
            
            // Title Graphic treated like aggressive notebook graffiti
            Text(LocalizationService.t("INK & IRONY", lang: scoreManager.uiLanguage))
                .font(ThemeManager.Typography.h1(for: .light)) // Token H1 is 40px
                .sketchbookInkText(isError: true) // Using teacher red for the main title
                .padding(.bottom, ThemeManager.Layout.spacingLG)
                .rotationEffect(.degrees(CGFloat.random(in: -3...3)))
            
            // Subtitle / Intro
            Text(LocalizationService.t(currentPage == 0 ? "Welcome to the\nSavage Sketchbook." : "The Teacher is waiting...\nDon't fail.", lang: scoreManager.uiLanguage))
                .font(ThemeManager.Typography.h2(for: .light))
                .sketchbookInkText()
                .multilineTextAlignment(.center)
                .padding(.horizontal, ThemeManager.Layout.spacingXL)
            
            Spacer()
            
            // Action Button
            Button(action: {
                HapticService.shared.playPenStrike()
                AudioService.shared.play(.penScratch)
                
                withAnimation(.easeInOut(duration: 0.4)) {
                    if currentPage == 0 {
                        currentPage = 1
                    } else {
                        onboardingComplete = true
                    }
                }
            }) {
                Text(LocalizationService.t(currentPage == 0 ? "NEXT" : "ENTER", lang: scoreManager.uiLanguage))
                    .frame(width: 120)
            }
            .doodleButtonStyle() // Inherits our custom drawing component styles
            .padding(.bottom, ThemeManager.Layout.spacingMajor)
        }
        .sketchbookBackground()
    }
}
