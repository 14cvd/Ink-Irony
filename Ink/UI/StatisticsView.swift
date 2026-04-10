//
//  StatisticsView.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI

public struct StatisticsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var scoreManager = ScoreManager.shared
    
    private var lang: Language { scoreManager.uiLanguage }
    
    private var streak: Int { StatsManager.streak() }
    private var wins: Int { StatsManager.wins(lang: lang) }
    private var losses: Int { StatsManager.losses(lang: lang) }
    private var winRate: Double { StatsManager.winRate(lang: lang) }
    private var bestScore: Int { StatsManager.bestScore(lang: lang) }
    private var difficultyRates: [Difficulty: Double] { StatsManager.winRateByDifficulty() }
    private var bestCategory: (GameCategory, Double)? { StatsManager.bestCategoryForCurrentLanguage(lang: lang) }
    
    private var accentRed: Color { ThemeManager.Colors.accentRed(for: colorScheme) }
    private var inkColor: Color { ThemeManager.Colors.inkPrimary(for: colorScheme) }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: ThemeManager.Layout.spacingLG) {
                
                // 🔥 Streak Box
                VStack(spacing: 4) {
                    Text("\(streak)")
                        .font(.custom("Caveat-Bold", size: 64))
                        .foregroundColor(accentRed)
                    Text(LocalizationService.t("Day Streak", lang: lang))
                        .font(ThemeManager.Typography.body(for: colorScheme))
                        .foregroundColor(accentRed.opacity(0.75))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, ThemeManager.Layout.spacingMD)
                .background(
                    RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerMD)
                        .stroke(accentRed, style: StrokeStyle(lineWidth: 2, dash: [6, 3]))
                        .background(
                            RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerMD)
                                .fill(accentRed.opacity(0.06))
                        )
                )
                .padding(.horizontal, ThemeManager.Layout.spacingXL)
                .padding(.top, ThemeManager.Layout.spacingMD)
                
                // Three stat chips
                HStack(spacing: ThemeManager.Layout.spacingSM) {
                    StatsChip(label: LocalizationService.t("Total Wins", lang: lang), value: "\(wins)", colorScheme: colorScheme)
                    StatsChip(label: LocalizationService.t("Total Losses", lang: lang), value: "\(losses)", colorScheme: colorScheme)
                    StatsChip(label: LocalizationService.t("Win Rate", lang: lang), value: "\(Int(winRate * 100))%", colorScheme: colorScheme)
                }
                .padding(.horizontal, ThemeManager.Layout.spacingXL)
                
                // Best Category row
                if let (cat, rate) = bestCategory {
                    HStack {
                        Text(cat.emoji)
                            .font(.system(size: 22))
                        Text(cat.displayName(for: lang))
                            .font(ThemeManager.Typography.body(for: colorScheme))
                            .foregroundColor(inkColor)
                        Spacer()
                        Text("\(Int(rate * 100))%")
                            .font(.custom("Caveat-Bold", size: 24))
                            .foregroundColor(accentRed)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerKey)
                            .handDrawnStroke(color: inkColor.opacity(0.25), lineWidth: 1, jitter: 0.5)
                    )
                    .overlay(
                        HStack {
                            Text(LocalizationService.t("Best Category", lang: lang))
                                .font(ThemeManager.Typography.micro(for: colorScheme))
                                .foregroundColor(accentRed)
                                .padding(.horizontal, ThemeManager.Layout.spacingSM)
                                .background(ThemeManager.Colors.bgPrimary(for: colorScheme))
                            Spacer()
                        }.offset(y: -22),
                        alignment: .top
                    )
                    .padding(.horizontal, ThemeManager.Layout.spacingXL)
                }
                
                // Win rate by difficulty
                VStack(alignment: .leading, spacing: ThemeManager.Layout.spacingMD) {
                    Text(LocalizationService.t("Win rate by difficulty", lang: lang))
                        .font(ThemeManager.Typography.micro(for: colorScheme).bold())
                        .foregroundColor(ThemeManager.Colors.sectionLabel(for: colorScheme))
                    
                    ForEach(Difficulty.allCases) { diff in
                        let rate = difficultyRates[diff] ?? 0
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(LocalizationService.t(diff.rawValue.uppercased(), lang: lang))
                                    .font(ThemeManager.Typography.micro(for: colorScheme))
                                    .foregroundColor(inkColor.opacity(0.7))
                                Spacer()
                                Text("\(Int(rate * 100))%")
                                    .font(ThemeManager.Typography.micro(for: colorScheme).bold())
                                    .foregroundColor(accentRed)
                            }
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(ThemeManager.Colors.progressBarBg(for: colorScheme))
                                        .frame(height: 8)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(ThemeManager.Colors.progressBarFill(for: colorScheme))
                                        .frame(width: geo.size.width * rate, height: 8)
                                }
                            }
                            .frame(height: 8)
                        }
                    }
                }
                .padding(.horizontal, ThemeManager.Layout.spacingXL)
                
                // Best score
                HStack {
                    Text(LocalizationService.t("Best Score", lang: lang))
                        .font(ThemeManager.Typography.body(for: colorScheme))
                        .foregroundColor(inkColor)
                    Spacer()
                    Text("\(bestScore)")
                        .font(.custom("Caveat-Bold", size: 28))
                        .foregroundColor(accentRed)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerKey)
                        .handDrawnStroke(color: inkColor.opacity(0.2), lineWidth: 1, jitter: 0.5)
                )
                .padding(.horizontal, ThemeManager.Layout.spacingXL)
                .padding(.bottom, ThemeManager.Layout.spacingLG)
            }
        }
    }
}

// MARK: - Stats Chip
private struct StatsChip: View {
    let label: String
    let value: String
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.custom("Caveat-Bold", size: 26))
                .foregroundColor(ThemeManager.Colors.statNumber(for: colorScheme))
            Text(label)
                .font(ThemeManager.Typography.micro(for: colorScheme))
                .foregroundColor(ThemeManager.Colors.inkPrimary(for: colorScheme).opacity(0.55))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, ThemeManager.Layout.spacingSM)
        .padding(.horizontal, ThemeManager.Layout.spacingXS)
        .background(
            RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerKey)
                .stroke(ThemeManager.Colors.inkPrimary(for: colorScheme).opacity(0.15), lineWidth: 1)
        )
    }
}
