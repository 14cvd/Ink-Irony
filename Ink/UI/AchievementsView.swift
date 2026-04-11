//
//  AchievementsView.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI

public struct AchievementsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var scoreManager = ScoreManager.shared
    @State private var earnedIds: Set<String> = []
    @State private var selectedAchievement: AchievementManager.Achievement? = nil
    
    private var lang: Language { scoreManager.uiLanguage }
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    private var unlockedCount: Int { AchievementManager.all.filter { earnedIds.contains($0.id) }.count }
    private var totalCount: Int { AchievementManager.all.count }
    private var progress: Double { Double(unlockedCount) / Double(totalCount) }
    
    private var accentRed: Color { ThemeManager.Colors.accentRed(for: colorScheme) }
    private var inkColor: Color { ThemeManager.Colors.inkPrimary(for: colorScheme) }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: ThemeManager.Layout.spacingLG) {
                
                // "N / 12 unlocked" + progress bar
                VStack(spacing: ThemeManager.Layout.spacingSM) {
                    Text("\(unlockedCount) / \(totalCount) \(LocalizationService.t("unlocked", lang: lang))")
                        .font(ThemeManager.Typography.body(for: colorScheme))
                        .foregroundColor(inkColor.opacity(0.7))
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(ThemeManager.Colors.progressBarBg(for: colorScheme))
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(ThemeManager.Colors.progressBarFill(for: colorScheme))
                                .frame(width: geo.size.width * progress, height: 8)
                                .animation(.easeInOut(duration: 0.5), value: progress)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.horizontal, ThemeManager.Layout.spacingXL)
                .padding(.top, ThemeManager.Layout.spacingMD)
                
                // Badge grid (3 columns)
                LazyVGrid(columns: columns, spacing: ThemeManager.Layout.spacingMD) {
                    ForEach(AchievementManager.all, id: \.id) { achievement in
                        let earned = earnedIds.contains(achievement.id)
                        Button(action: {
                            HapticService.shared.playPenStrike()
                            selectedAchievement = achievement
                        }) {
                            BadgeCell(achievement: achievement, earned: earned, language: lang, colorScheme: colorScheme)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, ThemeManager.Layout.spacingLG)
                .padding(.bottom, ThemeManager.Layout.spacingLG)
            }
        }
        .onAppear {
            earnedIds = AchievementManager.earnedIds()
        }
        .alert(item: $selectedAchievement) { achievement in
            Alert(
                title: Text("\(achievement.emoji) \(achievement.name(for: lang))"),
                message: Text(achievement.description(for: lang)),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// MARK: - Badge Cell
private struct BadgeCell: View {
    let achievement: AchievementManager.Achievement
    let earned: Bool
    let language: Language
    let colorScheme: ColorScheme
    
    @State private var glowing: Bool = false
    
    private var borderColor: Color {
        earned
            ? ThemeManager.Colors.achievementEarnedBorder(for: colorScheme)
            : ThemeManager.Colors.achievementLockedBorder(for: colorScheme)
    }
    
    private var bgColor: Color {
        earned
            ? ThemeManager.Colors.achievementEarnedBg(for: colorScheme)
            : Color.clear
    }
    
    var body: some View {
        VStack(spacing: ThemeManager.Layout.spacingXS) {
            Text(achievement.emoji)
                .font(.system(size: 32))
                .grayscale(earned ? 0 : 1)
            Text(achievement.name(for: language))
                .font(ThemeManager.Typography.micro(for: colorScheme).bold())
                .foregroundColor(earned
                    ? ThemeManager.Colors.accentRed(for: colorScheme)
                    : ThemeManager.Colors.inkPrimary(for: colorScheme).opacity(0.4))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(ThemeManager.Layout.spacingMD)
        .background(bgColor)
        .background(
            RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerKey)
                .stroke(borderColor, style: StrokeStyle(lineWidth: earned ? 2 : 1, dash: earned ? [] : [5, 3]))
                .shadow(color: glowing ? ThemeManager.Colors.accentRed(for: colorScheme).opacity(0.6) : Color.clear, radius: 8)
        )
        .onAppear {
            if earned {
                // Brief glow pulse for the earned state
                withAnimation(.easeInOut(duration: 0.8).repeatCount(2, autoreverses: true)) {
                    glowing = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    glowing = false
                }
            }
        }
    }
}
