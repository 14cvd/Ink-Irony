//
//  RecordsView.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI
import SwiftData

/// 3-tab sheet: MY STATS | LEADERBOARD | ACHIEVEMENTS
public struct RecordsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var scoreManager = ScoreManager.shared
    @State private var selectedTab: Int = 0
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    HapticService.shared.playPenStrike()
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2.bold())
                        .foregroundColor(ThemeManager.Colors.inkPrimary(for: colorScheme))
                        .padding()
                }
                Spacer()
                Text(LocalizationService.t("RECORDS", lang: scoreManager.uiLanguage))
                    .font(ThemeManager.Typography.h1(for: colorScheme))
                    .sketchbookInkText()
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.top, 12)
            
            // Tab Selector
            HStack(spacing: 0) {
                ForEach([(0, "MY STATS"), (1, "LEADERBOARD"), (2, "ACHIEVEMENTS")], id: \.0) { index, key in
                    Button(action: {
                        HapticService.shared.playPenStrike()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = index
                        }
                    }) {
                        Text(LocalizationService.t(key, lang: scoreManager.uiLanguage))
                            .font(ThemeManager.Typography.micro(for: colorScheme).bold())
                            .foregroundColor(selectedTab == index
                                ? ThemeManager.Colors.accentRed(for: colorScheme)
                                : ThemeManager.Colors.inkPrimary(for: colorScheme).opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, ThemeManager.Layout.spacingSM)
                            .overlay(
                                Rectangle()
                                    .fill(selectedTab == index ? ThemeManager.Colors.accentRed(for: colorScheme) : Color.clear)
                                    .frame(height: 2),
                                alignment: .bottom
                            )
                    }
                }
            }
            .padding(.horizontal, ThemeManager.Layout.spacingXL)
            
            Divider()
                .background(ThemeManager.Colors.divider(for: colorScheme))
            
            // Tab Content
            Group {
                switch selectedTab {
                case 0: StatisticsView()
                case 2: AchievementsView()
                default: LeaderboardTabView()
                }
            }
        }
        .sketchbookBackground()
    }
}

// MARK: - Leaderboard (extracted to sub-view)
private struct LeaderboardTabView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var scoreManager = ScoreManager.shared
    @State private var filterLanguage: Language = .english
    
    @Query(sort: \GameSession.score, order: .reverse) private var allSessions: [GameSession]
    
    private var filteredSessions: [GameSession] {
        allSessions.filter { $0.language == filterLanguage.rawValue && $0.score > 0 }
    }
    
    var body: some View {
        VStack {
            Picker("Language", selection: $filterLanguage) {
                ForEach(Language.allCases) { lang in
                    Text(lang.rawValue).tag(lang)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, ThemeManager.Layout.spacingXL)
            .padding(.vertical, ThemeManager.Layout.spacingMD)
            
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
                        ForEach(Array(filteredSessions.prefix(20).enumerated()), id: \.element.id) { index, session in
                            LeaderboardRow(rank: index + 1, session: session, inkColor: ThemeManager.Colors.inkPrimary(for: colorScheme))
                        }
                    }
                    .padding(.horizontal, ThemeManager.Layout.spacingLG)
                    .padding(.bottom, ThemeManager.Layout.spacingLG)
                }
            }
        }
    }
}

private struct LeaderboardRow: View {
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
