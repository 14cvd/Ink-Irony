//
//  GameScreen.swift
//  Ink
//
//  Top bar, teacher, stage, word, power-ups, keyboard. The stage absorbs the
//  spare height and the keys shrink on short screens, so everything fits on a
//  4.7" iPhone (B-24).
//

import SwiftUI
import InkEngine

struct GameScreen: View {
    let model: GameModel
    let close: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let compact = proxy.size.height < 640
            VStack(spacing: compact ? 8 : 10) {
                topBar
                TeacherRow(text: model.line, mood: model.mood, avatarSize: compact ? 40 : 48)
                stage(compact: compact)
                WordSlots(slots: model.engine.slots, answer: model.engine.status == .lost ? Array(model.word.text) : nil)
                    .frame(height: wordHeight)
                    .padding(.horizontal, 4)
                infoRow
                powerUps
                Spacer(minLength: 0)
                LetterKeyboard(
                    alphabet: model.request.language.alphabet,
                    state: model.keyState,
                    keyHeight: compact ? 40 : 50,
                    onTap: model.tap
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, compact ? 4 : 8)
        }
    }

    private var wordHeight: CGFloat {
        let text = model.word.text
        return text.count > 12 && text.contains(" ") ? 96 : 58
    }

    // MARK: Parts

    private var topBar: some View {
        HStack {
            InkIconButton(systemName: "xmark", label: L10n.t("game.leave"), identifier: "game.close", action: close)
            Spacer()
            VStack(spacing: 1) {
                Text(model.word.category.displayName(for: L10n.language).uppercased(with: L10n.locale))
                    .font(.inkUI(12, weight: .bold, relativeTo: .caption))
                    .tracking(1.5)
                    .foregroundStyle(InkColor.teacher)
                Text(L10n.modeSubtitle(model.request.mode))
                    .font(.inkUI(12, relativeTo: .caption))
                    .foregroundStyle(InkColor.secondary)
            }
            .accessibilityElement(children: .combine)
            Spacer()
            InkChip(systemName: "drop.fill", text: "\(model.engine.ink)")
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(L10n.t("a11y.ink", model.engine.ink))
                .accessibilityIdentifier("game.ink")
        }
    }

    private func stage(compact: Bool) -> some View {
        GallowsStage(lives: model.engine.lives, mistakes: model.engine.mistakes, mood: model.doodleMood)
            .padding(.horizontal, 8)
            .padding(.top, 22)
            .padding(.bottom, 6)
            .frame(maxWidth: .infinity, minHeight: compact ? 96 : 140, maxHeight: 280)
            .inkCard(raised: true)
            .overlay(alignment: .topLeading) {
                Text(L10n.livesLeft(model.engine.livesLeft, of: model.engine.lives))
                    .font(.inkUI(12, weight: .bold, relativeTo: .caption))
                    .foregroundStyle(model.engine.livesLeft <= 1 ? InkColor.teacher : InkColor.secondary)
                    .padding(10)
                    .accessibilityIdentifier("game.lives")
            }
            .overlay(alignment: .topTrailing) {
                if model.engine.combo >= 2 && !model.isOver {
                    ComboBadge(multiplier: model.engine.multiplier)
                        .padding(8)
                }
            }
            .animation(.spring(response: 0.26, dampingFraction: 0.6), value: model.engine.combo)
    }

    private var infoRow: some View {
        VStack(spacing: 2) {
            HStack {
                Text(L10n.t("game.score"))
                    .foregroundStyle(InkColor.secondary)
                + Text(" \(model.engine.letterPoints)")
                    .foregroundStyle(InkColor.ink)
                    .bold()
                Spacer()
                if let notice = model.notice {
                    Text(notice)
                        .foregroundStyle(InkColor.teacher)
                        .accessibilityIdentifier("game.notice")
                }
            }
            .font(.inkUI(14, relativeTo: .footnote))
            if model.engine.isHintShown {
                Text(L10n.t("game.hint", model.word.hint))
                    .font(.inkVoice(13, relativeTo: .footnote))
                    .foregroundStyle(InkColor.inkDrop)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("game.hintText")
            }
        }
    }

    @ViewBuilder
    private var powerUps: some View {
        if model.engine.powerUpsAllowed {
            HStack(spacing: 8) {
                ForEach(PowerUp.allCases, id: \.self) { powerUp in
                    PowerUpButton(powerUp: powerUp, enabled: model.canUse(powerUp)) {
                        model.use(powerUp)
                    }
                }
            }
        } else {
            Text(L10n.t("game.noPowerUps"))
                .font(.inkVoice(13, relativeTo: .footnote))
                .foregroundStyle(InkColor.secondary)
                .frame(maxWidth: .infinity, minHeight: 30)
        }
    }
}
