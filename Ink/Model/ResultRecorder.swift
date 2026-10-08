//
//  ResultRecorder.swift
//  Ink
//
//  The one place a finished word is recorded, for every mode: the SwiftData
//  session, v1 stats and stickers, ink, the semester grade and the Daily.
//  (v1 recorded games in three different places; Daily games were lost.)
//

import Foundation
import SwiftData
import InkData
import InkEngine

enum SemesterOutcome: Equatable {
    case continuing
    case passed(unlocked: Int?)
    case failed
}

struct ResultSummary {
    let request: PlayRequest
    let word: Word
    let result: GameResult
    let seconds: Int
    let gpaBefore: Double?
    let gpaAfter: Double?
    let inkEarned: Int
    let newStickers: [AchievementManager.Achievement]
    let semesterOutcome: SemesterOutcome
    let comment: String
    let pattern: [Bool]
}

@MainActor
enum ResultRecorder {

    static func record(_ game: GameModel, app: AppState, context: ModelContext) -> ResultSummary? {
        guard let result = game.engine.result else { return nil }
        let request = game.request
        let gpaBefore = app.progress.language(request.language).gpa

        // Session history (unchanged SchemaV1, so v1 history and v2 games sit together).
        context.insert(GameSession(
            word: game.word.text,
            language: request.language.rawValue,
            difficulty: modeLabel(request.mode),
            category: game.word.category.rawValue,
            score: result.score,
            isWin: result.won,
            timeTaken: game.seconds,
            hintsUsed: result.powerUpsUsed.count,
            wrongGuesses: result.mistakes
        ))
        try? context.save()

        // v1 stats and achievements, now fed by every mode.
        let newIDs = StatsManager.updateAfterGame(
            isWin: result.won,
            category: game.word.category,
            difficulty: difficultyBand(lives: result.lives),
            language: request.language,
            timeTaken: game.seconds,
            hintsUsed: result.powerUpsUsed.count,
            wrongGuesses: result.mistakes,
            score: result.score
        )
        ScoreManager.shared.recalculateStats()

        var inkEarned = result.inkEarned
        var outcome = SemesterOutcome.continuing
        var progress = app.progress
        progress.ink = result.inkAfter
        if result.won { progress.wordsSolved += 1 }

        switch request.mode {
        case .semester(let number, _):
            progress.update(request.language) { lang in
                guard lang.current.semester == number, !lang.current.isComplete else { return }
                lang.current.record(result.grade)
                guard lang.current.isComplete else { return }
                if lang.current.passed {
                    lang.passed[number] = lang.current.grades
                    let next = lang.current.unlocks
                    outcome = .passed(unlocked: next)
                    if let next {
                        lang.current = SemesterProgress(semester: next)
                        lang.attempt = 0
                    }
                } else {
                    outcome = .failed
                    lang.current = lang.current.retake()
                    lang.attempt += 1
                }
            }
            if case .passed = outcome {
                progress.ink += Rules.inkPerSemesterPassed
                inkEarned += Rules.inkPerSemesterPassed
            }
        case .daily(let number):
            var days = progress.daily[request.language.code] ?? [:]
            if days[number] == nil {
                days[number] = DailyRecord(won: result.won, mistakes: result.mistakes, seconds: game.seconds, pattern: game.pattern)
                progress.daily[request.language.code] = days
                if result.won {
                    progress.ink += Rules.inkPerDaily
                    inkEarned += Rules.inkPerDaily
                }
            }
        case .free:
            break
        }
        app.progress = progress

        let gpaAfter: Double? = if case .semester = request.mode { progress.language(request.language).gpa } else { gpaBefore }
        let stickers = newIDs.compactMap { id in AchievementManager.all.first { $0.id == id } }
        return ResultSummary(
            request: request,
            word: game.word,
            result: result,
            seconds: game.seconds,
            gpaBefore: gpaBefore,
            gpaAfter: gpaAfter,
            inkEarned: inkEarned,
            newStickers: stickers,
            semesterOutcome: outcome,
            comment: app.teacherLine(trigger(for: result.grade)),
            pattern: game.pattern
        )
    }

    static func trigger(for grade: Grade) -> TeacherTrigger {
        switch grade {
        case .aPlus: .gradeAPlus
        case .a: .gradeA
        case .aMinus: .gradeAMinus
        case .b: .gradeB
        case .c: .gradeC
        case .d: .gradeD
        case .f: .gradeF
        }
    }

    /// Stored in GameSession.difficulty, readable in the Report card.
    static func modeLabel(_ mode: PlayMode) -> String {
        switch mode {
        case .semester(let number, let word): "Semester \(number) · \(word)"
        case .free(let level, _): level.rawValue
        case .daily(let number): "Daily #\(number)"
        }
    }

    /// v1 achievements (Nightmare, per-difficulty win rates) still think in four levels.
    static func difficultyBand(lives: Int) -> Difficulty {
        switch lives {
        case 8...: .easy
        case 6...7: .medium
        case 4...5: .hard
        default: .nightmare
        }
    }
}
