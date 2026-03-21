//
//  ResultScreen.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI
import SwiftData

public struct ResultScreen: View {
    let isWin: Bool
    let wordText: String
    let difficulty: Difficulty
    let remainingLives: Int
    
    // Natively requested properties for SwiftData saving
    let language: Language
    
    // Callbacks to route the user within App/Coordinator layers
    let actionPlayAgain: () -> Void
    let actionMenu: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var scoreManager = ScoreManager.shared
    
    // Internal animation state for the giant rigid teacher grade stamp
    @State private var stampScale: CGFloat = 3.0
    @State private var stampOpacity: Double = 0.0
    
    public init(isWin: Bool, wordText: String, difficulty: Difficulty, language: Language, remainingLives: Int, actionPlayAgain: @escaping () -> Void, actionMenu: @escaping () -> Void) {
        self.isWin = isWin
        self.wordText = wordText
        self.difficulty = difficulty
        self.language = language
        self.remainingLives = remainingLives
        self.actionPlayAgain = actionPlayAgain
        self.actionMenu = actionMenu
    }
    
    private var inkColor: Color {
        colorScheme == .dark ? ThemeManager.Colors.graphiteGray : ThemeManager.Colors.ballpointBlue
    }
    
    // The grade stamp is unconditionally red (A+ or F) to maintain the teacher aesthetic
    private var gradeColor: Color {
        ThemeManager.Colors.teacherRed
    }
    
    public var body: some View {
        VStack(spacing: 30) {
            
            Spacer().frame(height: 30)
            
            // "Graded Paper" Identification Area
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(LocalizationService.t("NAME: ", lang: scoreManager.uiLanguage)) + Text(LocalizationService.t("Player 1", lang: scoreManager.uiLanguage)).font(.custom("Noteworthy", size: 24))
                    Text(LocalizationService.t("SUBJECT: ", lang: scoreManager.uiLanguage)) + Text(LocalizationService.t("Execution", lang: scoreManager.uiLanguage)).font(.custom("Noteworthy", size: 24))
                    Text(LocalizationService.t("DIFFICULTY: ", lang: scoreManager.uiLanguage)) + Text(LocalizationService.t(difficulty.rawValue.uppercased(), lang: scoreManager.uiLanguage)).font(.custom("Noteworthy", size: 24))
                }
                .font(.custom("Courier", size: 16).bold())
                .sketchbookInkText()
                
                Spacer()
                
                // Giant Teacher Stamp / Grade
                ZStack {
                    if isWin {
                        Text("A+")
                            .font(.custom("Marker Felt", size: 90).bold())
                            .foregroundColor(gradeColor)
                            .rotationEffect(.degrees(-12))
                    } else {
                        Text("F")
                            .font(.custom("Marker Felt", size: 100).bold())
                            .foregroundColor(gradeColor)
                            .rotationEffect(.degrees(10))
                        
                        // Circle drawn rapidly and aggressively around the F
                        Circle()
                            .handDrawnStroke(color: gradeColor, lineWidth: 5, jitter: 3.0)
                            .frame(width: 120, height: 120)
                    }
                }
                .scaleEffect(stampScale)
                .opacity(stampOpacity)
                .padding(.trailing, 20)
            }
            .padding(.horizontal, 40)
            
            Divider()
                .background(inkColor.opacity(0.3))
                .padding(.horizontal, 40)
            
            // Truth / Word Reveal Area
            VStack(spacing: 15) {
                Text(LocalizationService.t(isWin ? "VOCABULARY MASTERED:" : "FATAL ERROR. CORRECT WORD:", lang: scoreManager.uiLanguage))
                    .font(.custom("Courier", size: 18).bold())
                    .sketchbookInkText(isError: !isWin)
                
                // The actual word, displayed large
                Text(wordText)
                    .font(.custom("Courier", size: 40).bold())
                    .sketchbookInkText()
                    .tracking(6)
                    .overlay(
                        // Aggressively scratch out the word if they failed the execution
                        Group {
                            if !isWin {
                                GeometryReader { geometry in
                                    Path { path in
                                        path.move(to: CGPoint(x: -10, y: geometry.size.height * 0.4))
                                        path.addLine(to: CGPoint(x: geometry.size.width + 10, y: geometry.size.height * 0.6))
                                        path.move(to: CGPoint(x: -10, y: geometry.size.height * 0.6))
                                        path.addLine(to: CGPoint(x: geometry.size.width + 10, y: geometry.size.height * 0.4))
                                    }
                                    .handDrawnStroke(color: gradeColor, lineWidth: 4, jitter: 2.0)
                                }
                            }
                        }
                    )
            }
            .padding(.top, 20)
            
            // SwiftData Analytics / Streak Summary
            VStack(spacing: 15) {
                Text(LocalizationService.t("CURRENT STREAK: ", lang: scoreManager.uiLanguage) + "\(scoreManager.currentStreak)")
                    .font(.custom("Noteworthy", size: 24).bold())
                    .sketchbookInkText()
                
                Text(LocalizationService.t("HIGH SCORE STREAK: ", lang: scoreManager.uiLanguage) + "\(scoreManager.highestStreak)")
                    .font(.custom("Noteworthy", size: 20))
                    // Highlight in red if they just tied or beat their all-time record
                    .sketchbookInkText(isError: scoreManager.highestStreak == scoreManager.currentStreak && scoreManager.highestStreak > 0)
            }
            .padding(.top, 20)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 20) {
                Button(action: {
                    HapticService.shared.playPenStrike()
                    AudioService.shared.play(.penScratch)
                    actionPlayAgain()
                }) {
                    Text(LocalizationService.t(isWin ? "CONTINUE STREAK" : "TRY AGAIN", lang: scoreManager.uiLanguage))
                        .frame(maxWidth: .infinity)
                }
                .doodleButtonStyle()
                
                Button(action: {
                    HapticService.shared.playPenStrike()
                    AudioService.shared.play(.pencilSnap)
                    actionMenu()
                }) {
                    Text(LocalizationService.t("RETURN TO MAIN MENU", lang: scoreManager.uiLanguage))
                        .frame(maxWidth: .infinity)
                }
                .doodleButtonStyle(isDestructive: true) // Draws an angry red button border
            }
            .padding(.horizontal, 50)
            .padding(.bottom, 50)
            
        }
        .sketchbookBackground()
        .onAppear {
            // STEP 15: Save the game outcome solidly into SwiftData ModelContext on appearance
            let scoreValue = isWin ? (remainingLives * 100) : 0
            let session = GameSession(
                word: wordText,
                language: language.rawValue,
                difficulty: difficulty.rawValue,
                score: scoreValue,
                isWin: isWin
            )
            modelContext.insert(session)
            
            // Request the ScoreManager singleton to quickly update the streak integers for the UI
            ScoreManager.shared.recalculateStats()
            
            // Smash the stamp onto the simulated paper
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.2)) {
                stampScale = 1.0
                stampOpacity = 1.0
            }
            
            // Play corresponding sound and physical jolt immediately when the stamp visually connects
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                if isWin {
                    HapticService.shared.playSuccessPulse()
                    AudioService.shared.play(.checkmark)
                } else {
                    HapticService.shared.playErrorPulse()
                    AudioService.shared.play(.pencilSnap) // Sharp snap for the F grade stamp
                }
            }
        }
    }
}
