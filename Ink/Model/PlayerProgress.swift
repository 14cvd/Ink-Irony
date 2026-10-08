//
//  PlayerProgress.swift
//  Ink
//
//  v2 progress that is not a played session: ink drops, semesters per
//  language, Daily Exam results. Saved as one JSON file next to the
//  SwiftData store; sessions stay in SwiftData (SchemaV1, unchanged).
//

import Foundation
import InkEngine

struct LanguageProgress: Codable, Equatable {
    var current = SemesterProgress(semester: 1)
    /// How many times the current semester was retaken; changes its word picks.
    var attempt = 0
    /// Grades of passed semesters, keyed by semester number.
    var passed: [Int: [Grade]] = [:]

    var allGrades: [Grade] {
        passed.keys.sorted().flatMap { passed[$0] ?? [] } + current.grades
    }

    var gpa: Double? { Grade.gpa(of: allGrades) }

    /// Every semester up to and including the current one is open.
    var highestOpen: Int { current.semester }
    var isFinishedPhD: Bool { current.semester == SemesterPlan.count && current.passed }
}

struct DailyRecord: Codable, Equatable {
    let won: Bool
    let mistakes: Int
    let seconds: Int
    /// One entry per guess, true for a hit. Shared without the word.
    let pattern: [Bool]
}

struct PlayerProgress: Codable, Equatable {
    var ink = Rules.startingInk
    var languages: [String: LanguageProgress] = [:]
    /// language code -> Daily Exam number -> result
    var daily: [String: [Int: DailyRecord]] = [:]
    var wordsSolved = 0
    var lastSeen: Date?

    func language(_ language: Language) -> LanguageProgress {
        languages[language.code] ?? LanguageProgress()
    }

    mutating func update(_ language: Language, _ change: (inout LanguageProgress) -> Void) {
        var value = self.language(language)
        change(&value)
        languages[language.code] = value
    }

    func dailyRecord(_ language: Language, number: Int) -> DailyRecord? {
        daily[language.code]?[number]
    }

    func dailyNumbersPlayed(_ language: Language) -> Set<Int> {
        Set(daily[language.code]?.keys.map { $0 } ?? [])
    }
}

/// Reads and writes `progress.json`. A damaged file is kept aside, never deleted.
enum ProgressStore {
    static var url: URL {
        URL.applicationSupportDirectory.appending(path: "progress.json")
    }

    static func load(from url: URL = url) -> PlayerProgress {
        guard let data = try? Data(contentsOf: url) else { return PlayerProgress() }
        do {
            return try JSONDecoder().decode(PlayerProgress.self, from: data)
        } catch {
            let aside = url.deletingLastPathComponent().appending(path: "progress.unreadable-\(Int(Date().timeIntervalSince1970)).json")
            try? FileManager.default.moveItem(at: url, to: aside)
            return PlayerProgress()
        }
    }

    static func save(_ progress: PlayerProgress, to url: URL = url) {
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        guard let data = try? JSONEncoder().encode(progress) else { return }
        try? data.write(to: url, options: .atomic)
    }
}
