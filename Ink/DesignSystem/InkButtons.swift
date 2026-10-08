//
//  InkButtons.swift
//  Ink
//

import SwiftUI

/// One per screen: ink fill, handwritten title, red offset shadow that the press pushes into.
struct InkPrimaryButtonStyle: ButtonStyle {
    var height: CGFloat = InkSize.primaryButton

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.inkDisplay(28, relativeTo: .title2))
            .foregroundStyle(InkColor.onPrimary)
            .frame(maxWidth: .infinity, minHeight: height)
            .background(
                RoundedRectangle(cornerRadius: InkRadius.button, style: .continuous)
                    .fill(InkColor.primaryFill)
                    .background(
                        RoundedRectangle(cornerRadius: InkRadius.button, style: .continuous)
                            .fill(InkColor.buttonShadow)
                            .offset(x: configuration.isPressed ? 0 : 3, y: configuration.isPressed ? 0 : 3)
                    )
            )
            .offset(x: configuration.isPressed ? 2 : 0, y: configuration.isPressed ? 2 : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct InkSecondaryButtonStyle: ButtonStyle {
    var height: CGFloat = 48

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.inkDisplay(24, relativeTo: .title3))
            .foregroundStyle(InkColor.ink)
            .frame(maxWidth: .infinity, minHeight: height)
            .background(
                RoundedRectangle(cornerRadius: InkRadius.button, style: .continuous)
                    .strokeBorder(InkColor.ink, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: InkRadius.button, style: .continuous)
                            .fill(configuration.isPressed ? InkColor.ink.opacity(0.08) : .clear)
                    )
            )
    }
}

extension ButtonStyle where Self == InkPrimaryButtonStyle {
    static var inkPrimary: InkPrimaryButtonStyle { InkPrimaryButtonStyle() }
}

extension ButtonStyle where Self == InkSecondaryButtonStyle {
    static var inkSecondary: InkSecondaryButtonStyle { InkSecondaryButtonStyle() }
}

/// Round 44 pt button with an SF Symbol in ink.
struct InkIconButton: View {
    let systemName: String
    let label: String
    var identifier: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(InkColor.ink)
                .frame(width: InkSize.minTarget, height: InkSize.minTarget)
                .background(Circle().fill(InkColor.sheet))
                .overlay(Circle().strokeBorder(InkColor.ink, lineWidth: 2))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityIdentifier(identifier ?? label)
    }
}

/// Pill with an optional leading symbol: ink drops, GPA, streak.
struct InkChip: View {
    var systemName: String? = nil
    var symbolColor: Color = InkColor.inkDrop
    let text: String
    var fill: Color = InkColor.sheet
    /// Text on the yellow reward fill stays dark in both themes.
    var onReward = false

    var body: some View {
        HStack(spacing: 6) {
            if let systemName {
                Image(systemName: systemName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(onReward ? InkColor.onReward : symbolColor)
            }
            Text(text)
                .font(.inkUI(14, weight: .bold, relativeTo: .subheadline))
                .foregroundStyle(onReward ? InkColor.onReward : InkColor.ink)
                .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 34)
        .background(Capsule().fill(fill))
        .overlay(Capsule().strokeBorder(InkColor.ink, lineWidth: 2))
    }
}
