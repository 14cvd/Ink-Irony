//
//  LetterKeyboard.swift
//  Ink
//
//  Fixed, centred rows per alphabet (fixes B-24: v1 wrapped an adaptive grid
//  that ran off 4.7" screens in az and ru). Key width comes from the available
//  width, so every key of a 33-letter alphabet stays on screen.
//

import SwiftUI

enum KeyState: Equatable {
    case idle, hit, miss, locked
}

struct LetterKeyboard: View {
    let alphabet: [Character]
    let state: (Character) -> KeyState
    var keyHeight: CGFloat = 50
    let onTap: (Character) -> Void

    private let gap: CGFloat = 5
    private let rowGap: CGFloat = 8

    /// Three rows, earlier rows one key longer when the alphabet does not split evenly.
    static func rows(for alphabet: [Character]) -> [[Character]] {
        let count = 3
        var rows: [[Character]] = []
        var index = 0
        for row in 0..<count {
            let size = alphabet.count / count + (row < alphabet.count % count ? 1 : 0)
            rows.append(Array(alphabet[index..<index + size]))
            index += size
        }
        return rows
    }

    var body: some View {
        let rows = Self.rows(for: alphabet)
        let widest = rows.map(\.count).max() ?? 1
        GeometryReader { proxy in
            let keyWidth = min(44, (proxy.size.width - gap * CGFloat(widest - 1)) / CGFloat(widest))
            VStack(spacing: rowGap) {
                ForEach(rows.indices, id: \.self) { rowIndex in
                    HStack(spacing: gap) {
                        ForEach(rows[rowIndex], id: \.self) { letter in
                            LetterKey(letter: letter, state: state(letter), width: keyWidth, height: keyHeight) {
                                onTap(letter)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: keyHeight * 3 + rowGap * 2 + 3)
    }
}

private struct LetterKey: View {
    let letter: Character
    let state: KeyState
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(String(letter))
                .font(.inkUI(width < 32 ? 17 : 19, weight: .bold, relativeTo: .title3))
                .strikethrough(state == .miss, color: InkColor.teacher)
                .foregroundStyle(foreground)
                .minimumScaleFactor(0.6)
                .frame(width: width, height: height)
                .background(background)
                .offset(y: 0)
        }
        .buttonStyle(KeyPressStyle(raised: state == .idle))
        .disabled(state != .idle)
        .accessibilityLabel(Text(accessibilityText))
        .accessibilityIdentifier("key.\(letter)")
        // The gap belongs to the hit area, so narrow keys still meet 44 pt.
        .contentShape(Rectangle().inset(by: -2.5))
    }

    private var foreground: Color {
        switch state {
        case .idle: InkColor.ink
        case .hit: InkColor.onCorrect
        case .miss: InkColor.teacher.opacity(0.65)
        case .locked: InkColor.ink.opacity(0.35)
        }
    }

    @ViewBuilder
    private var background: some View {
        let shape = RoundedRectangle(cornerRadius: InkRadius.key, style: .continuous)
        switch state {
        case .idle:
            shape.fill(InkColor.sheet).overlay(shape.strokeBorder(InkColor.ink, lineWidth: 2))
        case .hit:
            shape.fill(InkColor.correct)
        case .miss:
            shape.strokeBorder(InkColor.teacher.opacity(0.55), style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
        case .locked:
            shape.strokeBorder(InkColor.ink.opacity(0.25), lineWidth: 2)
        }
    }

    private var accessibilityText: String {
        switch state {
        case .idle, .locked: String(letter)
        case .hit: L10n.t("a11y.correct", String(letter))
        case .miss: L10n.t("a11y.wrong", String(letter))
        }
    }
}

/// Idle keys sit on a 3 pt ink ledge and drop onto it when pressed.
private struct KeyPressStyle: ButtonStyle {
    let raised: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: InkRadius.key, style: .continuous)
                    .fill(raised ? InkColor.ink : .clear)
                    .offset(y: raised && !configuration.isPressed ? 3 : 0)
            )
            .offset(y: configuration.isPressed ? 3 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// One slot per character; spaces and hyphens show from the start. Long answers wrap at spaces.
struct WordSlots: View {
    /// nil = not found yet.
    let slots: [Character?]
    /// Letters to reveal in red after a loss.
    var answer: [Character]? = nil

    var body: some View {
        GeometryReader { proxy in
            let lines = Self.lines(slots: slots, answer: answer, width: proxy.size.width)
            VStack(spacing: 6) {
                ForEach(lines.indices, id: \.self) { lineIndex in
                    let line = lines[lineIndex]
                    let slotWidth = min(32, max(18, (proxy.size.width - CGFloat(line.items.count - 1) * 5) / CGFloat(max(line.items.count, 1))))
                    HStack(spacing: 5) {
                        ForEach(line.items.indices, id: \.self) { i in
                            slot(line.items[i], width: slotWidth, lineCount: lines.count)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(accessibilityText))
        .accessibilityIdentifier("game.word")
    }

    private struct Item { let shown: Character?; let missed: Character?; let isGap: Bool }
    private struct Line { var items: [Item] }

    private static func lines(slots: [Character?], answer: [Character]?, width: CGFloat) -> [Line] {
        var items: [Item] = []
        for (i, slot) in slots.enumerated() {
            let original = answer?[i]
            let isGap = slot == " "
            items.append(Item(shown: slot, missed: slot == nil ? original : nil, isGap: isGap))
        }
        // One line if it fits at the minimum slot width, otherwise break at spaces.
        if CGFloat(items.count) * 23 <= width || !items.contains(where: \.isGap) {
            return [Line(items: items)]
        }
        var lines: [Line] = [Line(items: [])]
        for item in items {
            if item.isGap { lines.append(Line(items: [])); continue }
            lines[lines.count - 1].items.append(item)
        }
        return lines.filter { !$0.items.isEmpty }
    }

    @ViewBuilder
    private func slot(_ item: Item, width: CGFloat, lineCount: Int) -> some View {
        if item.isGap {
            Color.clear.frame(width: width * 0.6, height: 10)
        } else {
            VStack(spacing: 2) {
                Text(item.shown.map(String.init) ?? item.missed.map(String.init) ?? " ")
                    .font(.inkDisplay(min(42, width * 1.35) / (lineCount > 1 ? 1.15 : 1), relativeTo: .largeTitle))
                    .foregroundStyle(item.shown == nil ? InkColor.teacher : InkColor.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(width: width)
                if item.shown?.isLetter ?? true {
                    Capsule().fill(InkColor.ink).frame(width: width - 2, height: 3)
                }
            }
        }
    }

    private var accessibilityText: String {
        let spelled = slots.map { $0.map(String.init) ?? L10n.t("a11y.blank") }.joined(separator: " ")
        return L10n.t("a11y.word", spelled)
    }
}
