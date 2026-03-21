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
    
    public init(onboardingComplete: Binding<Bool>) {
        self._onboardingComplete = onboardingComplete
    }
    
    public var body: some View {
        VStack {
            Spacer()
            
            // Title Graphic treated like aggressive notebook graffiti
            Text("INK & IRONY")
                .font(.custom("Marker Felt", size: 52).bold())
                .sketchbookInkText(isError: true) // Using teacher red for the main title
                .padding(.bottom, 20)
                .rotationEffect(.degrees(CGFloat.random(in: -3...3)))
            
            // Subtitle / Intro
            Text(currentPage == 0 ? "Welcome to the\nSavage Sketchbook." : "The Teacher is waiting...\nDon't fail.")
                .font(.custom("Noteworthy", size: 28))
                .sketchbookInkText()
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
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
                Text(currentPage == 0 ? "NEXT" : "ENTER")
                    .frame(width: 120)
            }
            .doodleButtonStyle() // Inherits our custom drawing component styles
            .padding(.bottom, 60)
        }
        .sketchbookBackground()
    }
}
