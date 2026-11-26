//
//  ReportCardView.swift
//  Ink
//
//  The player's report card: GPA per language, totals from every session
//  (v1 history included) and the recent exams.
//

import SwiftUI
import SwiftData
import InkData
import InkEngine

struct ReportCardView: View {
    @Environment(AppState.self) private var app
    @Query(sort: \GameSession.date, order: .reverse) private var sessions: [GameSession]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(handwritten: L10n.t("tab.report"))
                    .font(.inkDisplay(36, relativeTo: .largeTitle))
                    .foregroundStyle(InkColor.ink)
                    .accessibilityAddTraits(.isHeader)
                totals
                languages
                recent
            }
            .padding(.horizontal, InkSpace.screenMargin)
            .padding(.vertical, 12)
        }
        .notebookPaper()
        .toolbar(.hidden, for: .navigationBar)
    }

    /// The totals as a real report card: one ruled sheet, a label, dotted leaders, the mark in red pen.
    private var totals: some View {
        let wins = sessions.filter(\.isWin).count
        let rate = sessions.isEmpty ? 0 : Int((Double(wins) / Double(sessions.count) * 100).rounded())
        let name = UserDefaults.standard.string(forKey: "username")?.trimmingCharacters(in: .whitespaces) ?? ""
        return VStack(alignment: .leading, spacing: 2) {
            if !name.isEmpty {
                Overline(text: L10n.t("onboarding.nameLabel"))
                Text(handwritten: name)
                    .font(.inkDisplay(28, relativeTo: .title2))
                    .foregroundStyle(InkColor.inkDrop)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.bottom, 6)
            }
            MarkRow(label: L10n.t("report.solved"), value: "\(wins)")
            MarkRow(label: L10n.t("report.rate"), value: "\(rate)%")
            MarkRow(label: L10n.t("report.best"), value: "\(sessions.map(\.score).max() ?? 0)")
            MarkRow(label: L10n.t("report.streak"), value: "\(app.dailyStreak)")
            MarkRow(label: L10n.t("report.ink"), value: "\(app.progress.ink)")
            MarkRow(label: L10n.t("report.played"), value: "\(sessions.count)")
        }
        .padding(.horizontal, 18)
        .padding(.top, 20)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .inkCard(raised: true, tilt: -0.5)
        .overlay(alignment: .topTrailing) {
            // Overall GPA, circled in red as the teacher would.
            Text(handwrittenCentered: app.gpaText)
                .font(.inkDisplayFixed(26))
                .foregroundStyle(InkColor.teacher)
                .fixedSize()
                .frame(width: 66, height: 50)
                .overlay { PenCircle().stroke(InkColor.teacher, style: StrokeStyle(lineWidth: 2, lineCap: .round)) }
                .rotationEffect(.degrees(-8))
                .offset(x: -12, y: -16)
                .accessibilityLabel(L10n.t("desk.gpa", app.gpaText))
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("report.totals")
    }

    private var languages: some View {
        VStack(alignment: .leading, spacing: 8) {
            Overline(text: L10n.t("report.byLanguage"))
            VStack(spacing: 0) {
                ForEach(Language.allCases) { language in
                    let progress = app.progress.language(language)
                    let played = sessions.filter { $0.language == language.rawValue }
                    HStack {
                        Text(handwritten: language.nativeName)
                            .font(.inkDisplay(22, relativeTo: .body))
                        Spacer()
                        Text(L10n.t("report.langLine", played.filter(\.isWin).count, L10n.semesterName(progress.current.semester)))
                            .font(.inkUI(12, relativeTo: .caption))
                            .foregroundStyle(InkColor.secondary)
                        Text(progress.gpa.map { String(format: "%.1f", $0) } ?? "—")
                            .font(.inkUI(15, weight: .bold, relativeTo: .body))
                            .frame(width: 40, alignment: .trailing)
                    }
                    .foregroundStyle(InkColor.ink)
                    .padding(.vertical, 10)
                    .overlay(alignment: .bottom) {
                        if language != Language.allCases.last { Rectangle().fill(InkColor.ruledLine).frame(height: 1) }
                    }
                    .accessibilityElement(children: .combine)
                }
            }
            .padding(.horizontal, 14)
            .inkCard(radius: 14)
        }
    }

    private var recent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Overline(text: L10n.t("report.recent"))
            if sessions.isEmpty {
                Text(L10n.t("report.empty"))
                    .font(.inkVoice(14))
                    .foregroundStyle(InkColor.secondary)
            } else {
                VStack(spacing: 0) {
                    ForEach(sessions.prefix(12)) { session in
                        HStack {
                            Image(systemName: session.isWin ? "checkmark.circle.fill" : "xmark.circle")
                                .foregroundStyle(session.isWin ? InkColor.correct : InkColor.teacher)
                            VStack(alignment: .leading, spacing: 0) {
                                Text(handwritten: session.word)
                                    .font(.inkDisplay(20, relativeTo: .body))
                                Text("\(session.language) · \(session.difficulty) · \(session.date.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.inkUI(11, relativeTo: .caption2))
                                    .foregroundStyle(InkColor.secondary)
                            }
                            Spacer()
                            Text("\(session.score)")
                                .font(.inkUI(15, weight: .bold, relativeTo: .body))
                                .monospacedDigit()
                        }
                        .foregroundStyle(InkColor.ink)
                        .padding(.vertical, 8)
                        .accessibilityElement(children: .combine)
                    }
                }
                .padding(.horizontal, 14)
                .inkCard(radius: 14)
            }
        }
    }
}

/// One line of the report card: "Words solved ........ 30".
private struct MarkRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(label)
                .font(.inkUI(14, relativeTo: .callout))
                .foregroundStyle(InkColor.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .layoutPriority(1)
            DottedLeader()
                .stroke(InkColor.ghost, style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [0.1, 6]))
                .frame(minWidth: 12, maxWidth: .infinity)
                .frame(height: 2)
                .alignmentGuide(.firstTextBaseline) { $0[.bottom] }
            Text(handwritten: value)
                .font(.inkDisplay(26, relativeTo: .title3))
                .foregroundStyle(InkColor.teacher)
                .lineLimit(1)
                .layoutPriority(1)
        }
        .frame(minHeight: 32)
        .accessibilityElement(children: .combine)
    }
}

private struct DottedLeader: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
