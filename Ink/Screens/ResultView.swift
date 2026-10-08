//
//  ResultView.swift
//  Ink
//
//  The graded exam paper: grade, word and definition, the score math written
//  out, the teacher's comment, what was earned, and the next step.
//

import SwiftUI
import InkEngine

struct ResultView: View {
    @Environment(AppState.self) private var app
    let summary: ResultSummary
    let next: (() -> Void)?
    let close: () -> Void

    private var result: GameResult { summary.result }

    var body: some View {
        VStack(spacing: 14) {
            ScrollView {
                paper
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
            }
            buttons
                .padding(.horizontal, 18)
        }
        .padding(.bottom, 8)
        .background(InkColor.desk.ignoresSafeArea())
    }

    // MARK: Paper

    private var paper: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Overline(text: L10n.t("result.exam", summary.word.category.displayName(for: L10n.language)))
                    Text(L10n.modeSubtitle(summary.request.mode))
                        .font(.inkUI(12, relativeTo: .caption))
                        .foregroundStyle(InkColor.secondary)
                    Text(L10n.t("result.name", playerName))
                        .font(.inkDisplay(21, relativeTo: .body))
                        .foregroundStyle(InkColor.inkDrop)
                        .padding(.top, 4)
                }
                Spacer()
                GradeStamp(grade: result.grade)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(summary.word.text)
                    .font(.inkDisplay(44, relativeTo: .largeTitle))
                    .tracking(3)
                    .foregroundStyle(result.won ? InkColor.correct : InkColor.teacher)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .accessibilityIdentifier("result.word")
                if !summary.word.definition.isEmpty {
                    Text(summary.word.definition)
                        .font(.inkUI(13, relativeTo: .footnote))
                        .foregroundStyle(InkColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            scoreMath

            Text(summary.comment)
                .font(.inkDisplay(25, relativeTo: .title3))
                .foregroundStyle(InkColor.teacher)
                .rotationEffect(.degrees(-1.5))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("result.comment")

            rewards
            outcomeBanner
        }
        .padding(.leading, 40)
        .padding(.trailing, 18)
        .padding(.vertical, 18)
        .background(alignment: .leading) {
            ZStack(alignment: .leading) {
                NotebookPaper(lineSpacing: 28)
                    .overlay(InkColor.sheet.opacity(0.55))
                VStack {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle().fill(InkColor.desk).overlay(Circle().strokeBorder(InkColor.secondary, lineWidth: 1.5))
                            .frame(width: 11, height: 11)
                            .frame(maxHeight: .infinity)
                    }
                }
                .padding(.vertical, 30)
                .padding(.leading, 9)
            }
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .inkCard(radius: 6, raised: true, tilt: -1.2, fill: .clear)
    }

    private var scoreMath: some View {
        VStack(spacing: 3) {
            line(L10n.t("result.letters", summary.word.text.filter(\.isLetter).count), "\(result.letterPoints)")
            if result.bestCombo >= 2 {
                line(L10n.t("result.bestCombo", min(result.bestCombo, Rules.maxComboMultiplier)), "")
            }
            if result.won {
                line(L10n.t("result.lives", result.livesLeft, Rules.livesBonusPerLife), "+\(result.livesBonus)")
            }
            if result.powerUpPenalty > 0 {
                line(L10n.t("result.powerUps", result.powerUpsUsed.count), "-\(result.powerUpPenalty)", color: InkColor.teacher)
            }
            Rectangle().fill(InkColor.ink).frame(height: 2).padding(.vertical, 3)
            line(L10n.t("result.total"), "\(result.score)", bold: true)
                .accessibilityIdentifier("result.total")
        }
        .font(.inkUI(14, relativeTo: .callout))
        .foregroundStyle(InkColor.ink)
    }

    private func line(_ label: String, _ value: String, color: Color = InkColor.ink, bold: Bool = false) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).monospacedDigit()
        }
        .foregroundStyle(color)
        .fontWeight(bold ? .bold : .regular)
        .accessibilityElement(children: .combine)
    }

    private var rewards: some View {
        FlowRow {
            if summary.inkEarned > 0 {
                InkChip(systemName: "drop.fill", text: "+\(summary.inkEarned)", fill: InkColor.paper)
            }
            if case .semester = summary.request.mode, let after = summary.gpaAfter {
                InkChip(systemName: "graduationcap.fill", symbolColor: InkColor.ink, text: gpaChange(after), fill: InkColor.paper)
            }
            ForEach(summary.newStickers) { sticker in
                InkChip(systemName: "star.fill", symbolColor: InkColor.ink, text: sticker.name(for: L10n.language), fill: InkColor.reward, onReward: true)
                    .rotationEffect(.degrees(3))
            }
        }
    }

    @ViewBuilder
    private var outcomeBanner: some View {
        switch summary.semesterOutcome {
        case .continuing:
            EmptyView()
        case .passed(let unlocked):
            Text(unlocked.map { L10n.t("result.semesterPassed", L10n.semesterTitle($0)) } ?? L10n.t("result.allPassed"))
                .font(.inkVoice(15))
                .foregroundStyle(InkColor.correct)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(InkColor.correct, lineWidth: 2))
        case .failed:
            Text(L10n.t("result.semesterFailed"))
                .font(.inkVoice(15))
                .foregroundStyle(InkColor.teacher)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(InkColor.teacher, lineWidth: 2))
        }
    }

    private var buttons: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                if let next {
                    Button(L10n.t("result.next"), action: next)
                        .buttonStyle(.inkPrimary)
                        .accessibilityIdentifier("result.next")
                } else {
                    Button(L10n.t("result.backToDesk"), action: close)
                        .buttonStyle(.inkPrimary)
                        .accessibilityIdentifier("result.close")
                }
                ShareLink(item: shareText) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(InkColor.ink)
                        .frame(width: 56, height: 56)
                        .inkCard(radius: InkRadius.button)
                }
                .accessibilityLabel(L10n.t("result.share"))
                .accessibilityIdentifier("result.share")
            }
            if next != nil {
                Button(L10n.t("result.backToDesk"), action: close)
                    .font(.inkUI(14, relativeTo: .callout))
                    .underline()
                    .foregroundStyle(InkColor.ink)
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("result.close")
            }
        }
    }

    // MARK: Helpers

    private var playerName: String {
        let name = UserDefaults.standard.string(forKey: "username") ?? ""
        return name.isEmpty ? L10n.t("result.student") : name
    }

    private func gpaChange(_ after: Double) -> String {
        let afterText = String(format: "%.1f", after)
        guard let before = summary.gpaBefore else { return L10n.t("desk.gpa", afterText) }
        return L10n.t("desk.gpa", String(format: "%.1f → %@", before, afterText))
    }

    private var shareText: String {
        if case .daily(let number) = summary.request.mode {
            return L10n.dailyShare(number: number, won: result.won, mistakes: result.mistakes, pattern: summary.pattern)
        }
        return L10n.t("result.shareText", result.grade.rawValue, summary.word.text, result.score)
    }
}

/// Wraps chips onto as many lines as they need.
struct FlowRow: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0, maxX: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width + 0.5, x > 0 { x = 0; y += rowHeight + spacing; rowHeight = 0 }
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
            rowHeight = max(rowHeight, size.height)
        }
        // Report the offered width, not the widest row: if the row width is handed back and the
        // parent rounds it down to the pixel grid, placement would wrap one more row than measured.
        return CGSize(width: proposal.width ?? maxX, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX + 0.5, x > bounds.minX { x = bounds.minX; y += rowHeight + spacing; rowHeight = 0 }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
