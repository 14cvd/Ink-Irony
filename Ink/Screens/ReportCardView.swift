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
                Text(L10n.t("tab.report"))
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

    private var totals: some View {
        let wins = sessions.filter(\.isWin).count
        let rate = sessions.isEmpty ? 0 : Int((Double(wins) / Double(sessions.count) * 100).rounded())
        return LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            StatTile(value: "\(wins)", label: L10n.t("report.solved"))
            StatTile(value: "\(rate)%", label: L10n.t("report.rate"))
            StatTile(value: "\(sessions.map(\.score).max() ?? 0)", label: L10n.t("report.best"))
            StatTile(value: "\(app.dailyStreak)", label: L10n.t("report.streak"))
            StatTile(value: "\(app.progress.ink)", label: L10n.t("report.ink"))
            StatTile(value: "\(sessions.count)", label: L10n.t("report.played"))
        }
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
                        Text(language.nativeName)
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
                                Text(session.word)
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

private struct StatTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.inkDisplay(28, relativeTo: .title2))
                .foregroundStyle(InkColor.teacher)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.inkUI(11, relativeTo: .caption2))
                .foregroundStyle(InkColor.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 74)
        .padding(.horizontal, 4)
        .inkCard(radius: 12)
        .accessibilityElement(children: .combine)
    }
}
