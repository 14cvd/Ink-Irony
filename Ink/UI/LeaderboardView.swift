//
//  LeaderboardView.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI
import SwiftData

public struct LeaderboardView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var scoreManager = ScoreManager.shared
    
    @State private var filterLanguage: Language = .english
    
    // Uses @Query to natively fetch and sort GameSession records by score (iOS 17 standard)
    @Query(sort: \GameSession.score, order: .reverse) private var allSessions: [GameSession]
    
    public init() {}
    
    private var filteredSessions: [GameSession] {
        allSessions.filter { $0.language == filterLanguage.rawValue && $0.score > 0 }
    }
    
    private var inkColor: Color {
        ThemeManager.Colors.inkPrimary(for: colorScheme)
    }
    
    public var body: some View {
        VStack {
            // Header mapped to the notebook setup
            HStack {
                Button(action: {
                    HapticService.shared.playPenStrike()
                    AudioService.shared.play(.penScratch)
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2.bold())
                        .foregroundColor(inkColor)
                        .padding()
                }
                Spacer()
                Text(LocalizationService.t("LEADERBOARD", lang: scoreManager.uiLanguage))
                    .font(ThemeManager.Typography.h1(for: colorScheme))
                    .sketchbookInkText()
                Spacer()
                // Placeholder balancing spacer
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.top, 20)
            
            // Language Filter Native Segmented Picker
            Picker("Language", selection: $filterLanguage) {
                ForEach(Language.allCases) { lang in
                    Text(lang.rawValue).tag(lang)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, ThemeManager.Layout.spacingXL)
            .padding(.bottom, ThemeManager.Layout.spacingLG)
            
            // Results List Frame
            if filteredSessions.isEmpty {
                Spacer()
                Text(LocalizationService.t("No victorious records found\nfor this language.", lang: scoreManager.uiLanguage))
                    .font(ThemeManager.Typography.h2(for: colorScheme))
                    .sketchbookInkText(isError: true)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, ThemeManager.Layout.spacingXL)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: ThemeManager.Layout.spacingMD) {
                        ForEach(Array(filteredSessions.enumerated()), id: \.element.id) { index, session in
                            LeaderboardRow(rank: index + 1, session: session, inkColor: inkColor)
                        }
                    }
                    .padding(.horizontal, ThemeManager.Layout.spacingLG)
                }
            }
        }
        .sketchbookBackground()
    }
}

fileprivate struct LeaderboardRow: View {
    let rank: Int
    let session: GameSession
    let inkColor: Color
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            Text("#\(rank)")
                .font(ThemeManager.Typography.h2(for: colorScheme).bold())
                .foregroundColor(ThemeManager.Colors.accentRed(for: colorScheme))
                .frame(width: 50, alignment: .leading)
            
            VStack(alignment: .leading) {
                Text(session.word)
                    .font(ThemeManager.Typography.body(for: colorScheme).bold())
                    .sketchbookInkText()
                
                Text("\(session.difficulty) · \(session.date.formatted(date: .numeric, time: .shortened))")
                    .font(ThemeManager.Typography.micro(for: colorScheme))
                    .sketchbookInkText()
                    .opacity(0.7)
            }
            
            Spacer()
            
            Text("\(session.score) pts")
                .font(ThemeManager.Typography.body(for: colorScheme))
                .sketchbookInkText()
        }
        .padding(ThemeManager.Layout.spacingMD)
        .background(
            RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerKey)
                .handDrawnStroke(color: inkColor, lineWidth: ThemeManager.Layout.strokeHair * 1.5, jitter: 1.0)
        )
    }
}
