//
//  DailyView.swift
//  Ink
//
//  One word per day, the same for everyone in a language. No power-ups.
//

import SwiftUI
import InkEngine

struct DailyView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    InkIconButton(systemName: "chevron.left", label: L10n.t("common.back"), identifier: "daily.back") { dismiss() }
                    Text(L10n.t("daily.title"))
                        .font(.inkDisplay(32, relativeTo: .largeTitle))
                        .foregroundStyle(InkColor.ink)
                        .accessibilityAddTraits(.isHeader)
                }
                calendarPage
                todayCard
                week
                Text(L10n.t("daily.next", nextExamText))
                    .font(.inkUI(13, relativeTo: .footnote))
                    .foregroundStyle(InkColor.secondary)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, InkSpace.screenMargin)
            .padding(.vertical, 8)
        }
        .notebookPaper()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var calendarPage: some View {
        HStack(spacing: 16) {
            DateBlock(date: Date())
            VStack(alignment: .leading, spacing: 4) {
                Text(Date().formatted(.dateTime.month(.wide).weekday(.abbreviated).locale(L10n.locale)).uppercased(with: L10n.locale))
                    .font(.inkUI(13, weight: .bold, relativeTo: .caption))
                    .tracking(2)
                    .foregroundStyle(InkColor.ink)
                Text(L10n.dailyTitle(app.todayNumber))
                    .font(.inkDisplay(28, relativeTo: .title2))
                    .foregroundStyle(InkColor.ink)
                Text(L10n.t("daily.rules"))
                    .font(.inkUI(12, relativeTo: .caption))
                    .foregroundStyle(InkColor.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.top, 24)
        .padding(.bottom, 14)
        .inkCard(radius: 14, raised: true)
        .overlay(alignment: .top) {
            HStack {
                ForEach(0..<4, id: \.self) { _ in
                    Capsule().fill(InkColor.paper).overlay(Capsule().strokeBorder(InkColor.secondary, lineWidth: 2.5))
                        .frame(width: 12, height: 18)
                        .frame(maxWidth: .infinity)
                }
            }
            .offset(y: -9)
            .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private var todayCard: some View {
        if let record = app.todaysDaily {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(L10n.t(record.won ? "daily.passed" : "daily.failed"))
                        .font(.inkVoice(22, relativeTo: .title3))
                        .foregroundStyle(record.won ? InkColor.correct : InkColor.teacher)
                        .padding(.horizontal, 8)
                        .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(record.won ? InkColor.correct : InkColor.teacher, lineWidth: 2.5))
                        .rotationEffect(.degrees(-4))
                    Spacer()
                    Text(L10n.t("daily.stats", record.mistakes, record.seconds))
                        .font(.inkUI(13, relativeTo: .footnote))
                        .foregroundStyle(InkColor.secondary)
                }
                PatternRow(pattern: record.pattern)
                Text(app.teacherLine(.dailyDone))
                    .font(.inkVoice(14))
                    .foregroundStyle(InkColor.teacher)
                ShareLink(item: L10n.dailyShare(number: app.todayNumber, won: record.won, mistakes: record.mistakes, pattern: record.pattern)) {
                    Label(L10n.t("daily.share"), systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.inkPrimary)
                .accessibilityIdentifier("daily.share")
            }
            .padding(14)
            .inkCard(radius: 14)
            .accessibilityIdentifier("daily.done")
        } else {
            Button {
                app.play(.daily(number: app.todayNumber))
            } label: {
                Label(L10n.t("daily.start"), systemImage: "pencil")
            }
            .buttonStyle(.inkPrimary)
            .accessibilityIdentifier("daily.start")
        }
    }

    private var week: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Overline(text: L10n.t("daily.thisWeek"))
                Spacer()
                Text(L10n.t("daily.streak", app.dailyStreak))
                    .font(.inkUI(12, weight: .bold, relativeTo: .caption))
                    .foregroundStyle(InkColor.teacher)
                    .accessibilityIdentifier("daily.streak")
            }
            HStack(spacing: 6) {
                ForEach(weekDays, id: \.number) { day in
                    VStack(spacing: 4) {
                        Text(day.letter)
                            .font(.inkUI(11, weight: day.isToday ? .bold : .regular, relativeTo: .caption2))
                            .foregroundStyle(day.isToday ? InkColor.teacher : InkColor.ink)
                        ZStack {
                            if let won = day.won {
                                Circle().fill(won ? InkColor.correct : InkColor.teacher)
                                Image(systemName: won ? "checkmark" : "xmark")
                                    .font(.system(size: 12, weight: .heavy))
                                    .foregroundStyle(InkColor.onCorrect)
                            } else {
                                Circle().strokeBorder(InkColor.ghost, style: StrokeStyle(lineWidth: 2, dash: [3, 3]))
                            }
                        }
                        .frame(width: 30, height: 30)
                        .overlay {
                            if day.isToday { Circle().strokeBorder(InkColor.teacher, lineWidth: 2.5).frame(width: 36, height: 36) }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(L10n.t("daily.streak", app.dailyStreak))
            Text(L10n.t("daily.hallPass"))
                .font(.inkUI(12, relativeTo: .caption))
                .foregroundStyle(InkColor.secondary)
        }
    }

    private struct WeekDay { let number: Int; let letter: String; let won: Bool?; let isToday: Bool }

    private var weekDays: [WeekDay] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let today = Date()
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }
        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: interval.start) else { return nil }
            let number = app.schedule.number(for: date)
            let letter = String(date.formatted(.dateTime.weekday(.narrow).locale(L10n.locale)))
            return WeekDay(number: number, letter: letter, won: app.progress.dailyRecord(app.language, number: number)?.won, isToday: calendar.isDate(date, inSameDayAs: today))
        }
    }

    private var nextExamText: String {
        let tomorrow = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86_400)
        return tomorrow.formatted(.relative(presentation: .named).locale(L10n.locale))
    }
}

/// Green squares for hits, red crosses for misses, in guess order. Never the word.
struct PatternRow: View {
    let pattern: [Bool]

    var body: some View {
        FlowRow(spacing: 6) {
            ForEach(pattern.indices, id: \.self) { index in
                if pattern[index] {
                    RoundedRectangle(cornerRadius: 6).fill(InkColor.correct).frame(width: 26, height: 26)
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(InkColor.teacher, style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                        .frame(width: 26, height: 26)
                        .overlay(Image(systemName: "xmark").font(.system(size: 11, weight: .heavy)).foregroundStyle(InkColor.teacher))
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(L10n.t("a11y.pattern", pattern.filter { $0 }.count, pattern.filter { !$0 }.count))
    }
}
