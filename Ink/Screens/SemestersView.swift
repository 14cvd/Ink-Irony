//
//  SemestersView.swift
//  Ink
//
//  Kindergarten to PhD. Passed semesters show their grade, the current one
//  shows its ten words as a path, the rest are locked.
//

import SwiftUI
import InkEngine

struct SemestersView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        let lang = app.languageProgress
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(L10n.t("tab.semesters"))
                        .font(.inkDisplay(36, relativeTo: .largeTitle))
                        .foregroundStyle(InkColor.ink)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    InkChip(text: L10n.t("desk.gpa", app.gpaText))
                }
                ForEach(1...SemesterPlan.count, id: \.self) { number in
                    if let grades = lang.passed[number], number != lang.current.semester || lang.current.isComplete {
                        PassedRow(number: number, grades: grades)
                    } else if number == lang.current.semester {
                        CurrentSemesterCard(progress: lang.current)
                    } else if number > lang.current.semester {
                        LockedRow(number: number, previous: number - 1)
                    }
                }
            }
            .padding(.horizontal, InkSpace.screenMargin)
            .padding(.vertical, 12)
        }
        .notebookPaper()
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct PassedRow: View {
    let number: Int
    let grades: [Grade]

    var body: some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.inkUI(15, weight: .bold, relativeTo: .body))
                .foregroundStyle(InkColor.onCorrect)
                .frame(width: 34, height: 34)
                .background(Circle().fill(InkColor.correct))
            VStack(alignment: .leading, spacing: 0) {
                Text(L10n.semesterName(number))
                    .font(.inkDisplay(22, relativeTo: .title3))
                    .foregroundStyle(InkColor.ink)
                Text(L10n.t("semester.passedSub", String(format: "%.1f", Grade.gpa(of: grades) ?? 0)))
                    .font(.inkUI(11, relativeTo: .caption2))
                    .foregroundStyle(InkColor.secondary)
            }
            Spacer()
            Text(averageGrade.rawValue)
                .font(.inkDisplay(28, relativeTo: .title2))
                .foregroundStyle(InkColor.correct)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .inkCard(radius: 14)
        .accessibilityElement(children: .combine)
    }

    /// The grade whose points are closest to the semester GPA.
    private var averageGrade: Grade {
        let gpa = Grade.gpa(of: grades) ?? 0
        return Grade.allCases.min { abs($0.gpaPoints - gpa) < abs($1.gpaPoints - gpa) } ?? .c
    }
}

private struct CurrentSemesterCard: View {
    @Environment(AppState.self) private var app
    let progress: SemesterProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text("\(progress.semester)")
                    .font(.inkUI(15, weight: .bold, relativeTo: .body))
                    .foregroundStyle(InkColor.onPrimary)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(InkColor.teacher))
                VStack(alignment: .leading, spacing: 0) {
                    Text(L10n.semesterName(progress.semester))
                        .font(.inkDisplay(26, relativeTo: .title2))
                        .foregroundStyle(InkColor.ink)
                    Text(L10n.t("semester.currentSub", SemesterPlan.lives(semester: progress.semester, word: 1)))
                        .font(.inkUI(11, relativeTo: .caption2))
                        .foregroundStyle(InkColor.secondary)
                }
            }
            path
            Text(L10n.t("semester.finalNote", SemesterPlan.lives(semester: progress.semester, word: Rules.wordsPerSemester)))
                .font(.inkVoice(12, relativeTo: .caption))
                .foregroundStyle(InkColor.teacher)
        }
        .padding(14)
        .inkCard(raised: true)
        .accessibilityIdentifier("semesters.current")
    }

    /// Two rows of five, the second read right to left, joined like a board-game path.
    private var path: some View {
        VStack(spacing: 14) {
            row(Array(1...5))
            row(Array((6...10).reversed()))
        }
        .padding(.vertical, 4)
    }

    private func row(_ words: [Int]) -> some View {
        HStack {
            ForEach(words, id: \.self) { word in
                node(word)
                    .frame(maxWidth: .infinity)
            }
        }
        .background(
            Rectangle()
                .fill(InkColor.ghost)
                .frame(height: 2)
                .padding(.horizontal, 30)
        )
    }

    @ViewBuilder
    private func node(_ word: Int) -> some View {
        let index = word - 1
        if index < progress.grades.count {
            GradeDot(grade: progress.grades[index], size: 38)
        } else if word == progress.nextWord {
            Button {
                app.play(.semester(number: progress.semester, word: word))
            } label: {
                Text(SemesterPlan.isFinalExam(word: word) ? L10n.t("semester.final") : "\(word)")
                    .font(.inkDisplay(SemesterPlan.isFinalExam(word: word) ? 16 : 26, relativeTo: .title3))
                    .foregroundStyle(InkColor.onReward)
                    .frame(width: 52, height: 52)
                    .background(Circle().fill(InkColor.reward))
                    .overlay(Circle().strokeBorder(InkColor.teacher, lineWidth: 3))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.t("desk.playWord", word))
            .accessibilityIdentifier("semesters.play")
        } else {
            Group {
                if SemesterPlan.isFinalExam(word: word) {
                    Image(systemName: "building.columns")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(InkColor.ink)
                        .frame(width: 40, height: 40)
                        .background(RoundedRectangle(cornerRadius: 8).fill(InkColor.desk))
                        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(InkColor.ink, lineWidth: 2))
                        .rotationEffect(.degrees(-4))
                } else {
                    Text("\(word)")
                        .font(.inkUI(13, relativeTo: .caption))
                        .foregroundStyle(InkColor.secondary)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(InkColor.sheet))
                        .overlay(Circle().strokeBorder(InkColor.ghost, lineWidth: 2))
                }
            }
            .accessibilityLabel(L10n.t("a11y.notPlayed"))
        }
    }
}

private struct LockedRow: View {
    let number: Int
    let previous: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock")
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 34, height: 34)
            VStack(alignment: .leading, spacing: 0) {
                Text("\(number) · \(L10n.semesterName(number))")
                    .font(.inkDisplay(22, relativeTo: .title3))
                Text(L10n.t("semester.lockedSub", L10n.semesterName(previous)))
                    .font(.inkUI(11, relativeTo: .caption2))
            }
            Spacer()
        }
        .foregroundStyle(InkColor.secondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 14).strokeBorder(InkColor.ghost, style: StrokeStyle(lineWidth: 2, dash: [6, 4])))
        .accessibilityElement(children: .combine)
    }
}
