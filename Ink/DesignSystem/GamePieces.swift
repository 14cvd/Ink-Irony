//
//  GamePieces.swift
//  Ink
//
//  Power-ups, stamps, the combo badge and the notebook tab bar.
//

import SwiftUI
import InkEngine

extension PowerUp {
    var symbol: String {
        switch self {
        case .eraser: "eraser.fill"
        case .reveal: "highlighter"
        case .hint: "magnifyingglass"
        }
    }

    var titleKey: String {
        switch self {
        case .eraser: "power.eraser"
        case .reveal: "power.reveal"
        case .hint: "power.hint"
        }
    }
}

struct PowerUpButton: View {
    let powerUp: PowerUp
    let enabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: powerUp.symbol)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(powerUp == .reveal ? InkColor.ink : InkColor.inkDrop)
                    .padding(4)
                    .background(Circle().fill(powerUp == .reveal ? InkColor.reward : .clear))
                VStack(alignment: .leading, spacing: 0) {
                    Text(L10n.t(powerUp.titleKey))
                        .font(.inkUI(13, weight: .bold, relativeTo: .footnote))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(L10n.t("power.cost", powerUp.inkCost))
                        .font(.inkUI(11, relativeTo: .caption2))
                        .foregroundStyle(InkColor.secondary)
                }
            }
            .foregroundStyle(InkColor.ink)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: InkRadius.chip, style: .continuous)
                    .fill(InkColor.sheet)
                    .overlay(RoundedRectangle(cornerRadius: InkRadius.chip, style: .continuous).strokeBorder(InkColor.ink, lineWidth: 2))
            )
            .opacity(enabled ? 1 : 0.4)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .accessibilityIdentifier("power.\(powerUp.rawValue)")
    }
}

/// "ESCAPED!" / "DETENTION." rubber stamp.
struct RubberStamp: View {
    let text: String
    let color: Color
    @State private var landed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Text(text)
            .font(.inkVoice(32, relativeTo: .largeTitle))
            .tracking(2)
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 4)
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(color, lineWidth: 3))
            .rotationEffect(.degrees(-6))
            .scaleEffect(landed || reduceMotion ? 1 : 1.6)
            .opacity(landed || reduceMotion ? 1 : 0)
            .onAppear {
                withAnimation(.easeIn(duration: 0.18)) { landed = true }
            }
            .accessibilityAddTraits(.isHeader)
    }
}

/// The red circled grade on the exam paper.
struct GradeStamp: View {
    let grade: Grade
    var size: CGFloat = 92

    var body: some View {
        Text(grade.rawValue)
            .font(.inkDisplay(size * 0.62, relativeTo: .largeTitle))
            .foregroundStyle(InkColor.teacher)
            .minimumScaleFactor(0.5)
            .frame(width: size, height: size)
            .overlay(Circle().strokeBorder(InkColor.teacher, lineWidth: 4))
            .rotationEffect(.degrees(-10))
            .accessibilityLabel(L10n.t("a11y.grade", grade.rawValue))
            .accessibilityIdentifier("result.grade")
    }
}

struct ComboBadge: View {
    let multiplier: Int

    var body: some View {
        Text(L10n.t("game.combo", multiplier))
            .font(.inkDisplay(24, relativeTo: .title3))
            .foregroundStyle(InkColor.onReward)
            .padding(.horizontal, 10)
            .padding(.vertical, 1)
            .background(RoundedRectangle(cornerRadius: 10).fill(InkColor.reward))
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(InkColor.ink, lineWidth: 2))
            .rotationEffect(.degrees(6))
            .transition(.scale(scale: 1.25).combined(with: .opacity))
            .id(multiplier)
            .accessibilityIdentifier("game.combo")
    }
}

/// Small filled circle with a grade, used on semester progress.
struct GradeDot: View {
    let grade: Grade?
    var size: CGFloat = 24

    var body: some View {
        Group {
            if let grade {
                Text(grade.rawValue)
                    .font(.inkUI(size * 0.42, weight: .bold, relativeTo: .caption2))
                    .foregroundStyle(grade == .f ? InkColor.onPrimary : InkColor.onCorrect)
                    .frame(width: size, height: size)
                    .background(Circle().fill(grade == .f ? InkColor.teacher : InkColor.correct))
            } else {
                Circle().strokeBorder(InkColor.secondary, lineWidth: 1.5).frame(width: size * 0.5, height: size * 0.5)
                    .frame(width: size, height: size)
            }
        }
        .accessibilityLabel(grade.map { L10n.t("a11y.grade", $0.rawValue) } ?? L10n.t("a11y.notPlayed"))
    }
}

enum MainTab: String, CaseIterable, Identifiable {
    case desk, semesters, stickers, report
    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .desk: "house"
        case .semesters: "graduationcap"
        case .stickers: "star"
        case .report: "doc.text"
        }
    }
}

/// Paper tab bar with an ink top rule; the selected tab is in red pen.
struct NotebookTabBar: View {
    @Binding var selection: MainTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases) { tab in
                Button {
                    selection = tab
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: selection == tab ? tab.symbol + ".fill" : tab.symbol)
                            .font(.system(size: 20, weight: selection == tab ? .bold : .regular))
                        Text(L10n.t("tab.\(tab.rawValue)"))
                            .font(.inkUI(11, weight: selection == tab ? .bold : .regular, relativeTo: .caption2))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(selection == tab ? InkColor.teacher : InkColor.ink)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("tab.\(tab.rawValue)")
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
            }
        }
        .padding(.top, 6)
        .background(
            InkColor.desk
                .overlay(alignment: .top) { Rectangle().fill(InkColor.ink).frame(height: 2) }
                .ignoresSafeArea(edges: .bottom)
        )
    }
}
