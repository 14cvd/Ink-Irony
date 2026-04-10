//
//  OnboardingFlow.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI

public struct OnboardingFlow: View {
    @Binding var onboardingComplete: Bool
    @State private var titleRotation: Double = Double.random(in: -3...3)
    @ObservedObject private var scoreManager = ScoreManager.shared
    
    public init(onboardingComplete: Binding<Bool>) {
        self._onboardingComplete = onboardingComplete
    }
    
    public var body: some View {
        VStack {
            Spacer()
            
            // Title Graphic
            Text(LocalizationService.t("INK & IRONY", lang: scoreManager.uiLanguage))
                .font(.custom("Caveat-Bold", size: 32))
                .sketchbookInkText(isError: true)
                .padding(.bottom, ThemeManager.Layout.spacingLG)
                .rotationEffect(.degrees(titleRotation))
            
            // Single onboarding message — "The Teacher is waiting..."
            Text(LocalizationService.t("The Teacher is waiting...\nDon't fail.", lang: scoreManager.uiLanguage))
                .font(ThemeManager.Typography.h2(for: .light))
                .sketchbookInkText()
                .multilineTextAlignment(.center)
                .padding(.horizontal, ThemeManager.Layout.spacingXL)
            
            Spacer()
            
            // Single ENTER button
            Button(action: {
                HapticService.shared.playPenStrike()
                AudioService.shared.play(.penScratch)
                
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                
                withAnimation(.easeInOut(duration: 0.4)) {
                    onboardingComplete = true
                }
            }) {
                Text(LocalizationService.t("ENTER", lang: scoreManager.uiLanguage))
                    .frame(width: 120)
            }
            .doodleButtonStyle()
            .padding(.bottom, ThemeManager.Layout.spacingMajor)
        }
        .sketchbookBackground()
    }
}
