//
//  StickersView.swift
//  Ink
//
//  v1 achievements as a sticker book. Earned ones are stuck on at a slant,
//  locked ones are a dashed outline with the rule as the hint.
//

import SwiftUI

struct StickersView: View {
    @State private var earned = AchievementManager.earnedIds()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    Text(L10n.t("tab.stickers"))
                        .font(.inkDisplay(36, relativeTo: .largeTitle))
                        .foregroundStyle(InkColor.ink)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    Text(L10n.t("stickers.count", earned.count, AchievementManager.all.count))
                        .font(.inkUI(13, weight: .bold, relativeTo: .footnote))
                        .foregroundStyle(InkColor.secondary)
                }
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(Array(AchievementManager.all.enumerated()), id: \.element.id) { index, sticker in
                        StickerCard(sticker: sticker, earned: earned.contains(sticker.id), tilt: index.isMultiple(of: 2) ? -2.5 : 2)
                    }
                }
            }
            .padding(.horizontal, InkSpace.screenMargin)
            .padding(.vertical, 12)
        }
        .notebookPaper()
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { earned = AchievementManager.earnedIds() }
    }
}

private struct StickerCard: View {
    let sticker: AchievementManager.Achievement
    let earned: Bool
    let tilt: Double

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: Self.symbol(for: sticker.id))
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(earned ? InkColor.ink : InkColor.ghost)
                .frame(height: 38)
            Text(sticker.name(for: L10n.language))
                .font(.inkDisplay(20, relativeTo: .headline))
                .foregroundStyle(InkColor.ink)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text(sticker.description(for: L10n.language))
                .font(.inkUI(11, relativeTo: .caption2))
                .foregroundStyle(InkColor.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 150)
        .background {
            if earned {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(InkColor.reward)
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(InkColor.ink, lineWidth: 2))
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(InkColor.cardShadow).offset(x: 3, y: 3))
            } else {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(InkColor.ghost, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
            }
        }
        .rotationEffect(.degrees(earned ? tilt : 0))
        .accessibilityElement(children: .combine)
        .accessibilityValue(earned ? L10n.t("stickers.earned") : L10n.t("stickers.locked"))
        .accessibilityIdentifier("sticker.\(sticker.id)")
    }

    /// Ink symbols instead of v1's emoji, which render inconsistently (B-22).
    static func symbol(for id: String) -> String {
        switch id {
        case "firstWin": "trophy.fill"
        case "streak3": "flame.fill"
        case "speedRun": "bolt.fill"
        case "nightmare": "theatermasks.fill"
        case "polyglot": "globe"
        case "scholar": "graduationcap.fill"
        case "noHints": "scope"
        case "streak30": "calendar"
        case "topScore": "crown.fill"
        case "silent": "speaker.slash.fill"
        case "bookworm": "books.vertical.fill"
        case "nightOwl": "moon.stars.fill"
        default: "star.fill"
        }
    }
}
