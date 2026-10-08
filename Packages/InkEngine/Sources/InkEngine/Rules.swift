//
//  Rules.swift
//  InkEngine
//
//  The v2 game rules in one place. Every tuning number lives here.
//

import Foundation

public enum Rules {
    // Scoring
    public static let pointsPerLetter = 10
    public static let maxComboMultiplier = 5
    public static let livesBonusPerLife = 10
    public static let powerUpScorePenalty = 20

    // Ink drops
    public static let startingInk = 100
    public static let inkPerWin = 15
    public static let inkPerLifeLeft = 2
    public static let inkPerDaily = 25
    public static let inkPerSemesterPassed = 100

    // Semesters
    public static let wordsPerSemester = 10
    public static let semesterLives = [8, 7, 6, 5, 4, 3]
    public static let passingGPA = 2.0
}

public enum PowerUp: String, CaseIterable, Sendable {
    /// Undo the last mistake: one life back, the letter stays used.
    case eraser
    /// Show one missing letter in every position.
    case reveal
    /// Show the word's hint line.
    case hint

    public var inkCost: Int {
        switch self {
        case .eraser: 30
        case .reveal: 40
        case .hint: 20
        }
    }
}

public enum Grade: String, CaseIterable, Codable, Sendable, Comparable {
    case aPlus = "A+"
    case a = "A"
    case aMinus = "A-"
    case b = "B"
    case c = "C"
    case d = "D"
    case f = "F"

    public var gpaPoints: Double {
        switch self {
        case .aPlus: 4.3
        case .a: 4.0
        case .aMinus: 3.7
        case .b: 3.0
        case .c: 2.0
        case .d: 1.0
        case .f: 0
        }
    }

    /// Grades get worse along `allCases`, so a "lower" grade is a better one.
    public static func < (lhs: Grade, rhs: Grade) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }

    /// Grade from the share of lives spent. Boundaries are exact fractions:
    /// A up to 1/6, A- up to 1/3, B up to 1/2, C up to 2/3, D above that.
    /// Any power-up caps the grade at A-.
    public static func forWord(won: Bool, mistakes: Int, lives: Int, powerUpsUsed: Int) -> Grade {
        guard won else { return .f }
        precondition(lives > 0, "A word needs at least one life")

        let grade: Grade
        if mistakes == 0 {
            grade = .aPlus
        } else if mistakes * 6 <= lives {
            grade = .a
        } else if mistakes * 3 <= lives {
            grade = .aMinus
        } else if mistakes * 2 <= lives {
            grade = .b
        } else if mistakes * 3 <= lives * 2 {
            grade = .c
        } else {
            grade = .d
        }
        return powerUpsUsed > 0 ? max(grade, .aMinus) : grade
    }

    /// Mean GPA points of the given grades, or nil when there are none.
    public static func gpa(of grades: [Grade]) -> Double? {
        guard !grades.isEmpty else { return nil }
        return grades.map(\.gpaPoints).reduce(0, +) / Double(grades.count)
    }
}
