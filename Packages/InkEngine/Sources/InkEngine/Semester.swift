//
//  Semester.swift
//  InkEngine
//

import Foundation

public enum SemesterPlan {
    public static var count: Int { Rules.semesterLives.count }

    /// Lives for a word. `semester` and `word` are 1-based. The final exam (word 10) has one life fewer.
    public static func lives(semester: Int, word: Int) -> Int {
        precondition((1...count).contains(semester), "Semester \(semester) does not exist")
        precondition((1...Rules.wordsPerSemester).contains(word), "Word \(word) is outside a semester")
        let base = Rules.semesterLives[semester - 1]
        return isFinalExam(word: word) ? max(1, base - 1) : base
    }

    public static func isFinalExam(word: Int) -> Bool {
        word == Rules.wordsPerSemester
    }
}

public struct SemesterProgress: Equatable, Codable, Sendable {
    public let semester: Int
    public private(set) var grades: [Grade]

    public init(semester: Int, grades: [Grade] = []) {
        precondition((1...SemesterPlan.count).contains(semester), "Semester \(semester) does not exist")
        precondition(grades.count <= Rules.wordsPerSemester, "A semester has \(Rules.wordsPerSemester) words")
        self.semester = semester
        self.grades = grades
    }

    /// 1-based number of the next word, or nil when all ten are graded.
    public var nextWord: Int? {
        grades.count < Rules.wordsPerSemester ? grades.count + 1 : nil
    }

    public var isComplete: Bool { nextWord == nil }
    public var gpa: Double? { Grade.gpa(of: grades) }

    /// Only meaningful once the semester is complete.
    public var passed: Bool {
        guard isComplete, let gpa else { return false }
        return gpa >= Rules.passingGPA
    }

    /// The semester that opens after this one passes, or nil after the last semester or a fail.
    public var unlocks: Int? {
        guard passed, semester < SemesterPlan.count else { return nil }
        return semester + 1
    }

    public mutating func record(_ grade: Grade) {
        precondition(!isComplete, "Semester \(semester) is already complete")
        grades.append(grade)
    }

    /// A failed semester starts over with the same number.
    public func retake() -> SemesterProgress {
        SemesterProgress(semester: semester)
    }
}
