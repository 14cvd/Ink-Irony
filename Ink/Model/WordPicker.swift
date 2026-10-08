//
//  WordPicker.swift
//  Ink
//
//  Deterministic word choice: the same semester attempt always gets the same
//  ten words, and the same Daily number gets the same word on every device.
//  Until the graded word bank (E7) lands, a word's level comes from its
//  length and each semester prefers the topics it is named after.
//

import Foundation

/// Stable across launches and devices (unlike String.hashValue, see B-04).
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: String) {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in seed.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x100000001b3
        }
        state = hash
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

struct SemesterTheme {
    let lengths: ClosedRange<Int>
    let categories: [GameCategory]

    static func forSemester(_ semester: Int) -> SemesterTheme {
        switch semester {
        case 1: SemesterTheme(lengths: 3...5, categories: [.food, .sports, .music])
        case 2: SemesterTheme(lengths: 4...6, categories: [.food, .sports, .music, .geography])
        case 3: SemesterTheme(lengths: 5...8, categories: [.science, .geography])
        case 4: SemesterTheme(lengths: 6...9, categories: [.literature, .movies])
        case 5: SemesterTheme(lengths: 7...10, categories: [])
        default: SemesterTheme(lengths: 9...30, categories: [])
        }
    }
}

extension WordRepository {

    /// Ten words for a semester attempt, never repeating within it.
    public func semesterWords(language: Language, semester: Int, attempt: Int) -> [Word] {
        let entries = allEntries(language)
        let theme = SemesterTheme.forSemester(semester)
        let letters: (WordEntry) -> Int = { $0.word.filter(\.isLetter).count }
        let inTopic: (WordEntry) -> Bool = { theme.categories.isEmpty || theme.categories.map(\.rawValue).contains($0.category.lowercased()) }

        var pool = entries.filter { theme.lengths.contains(letters($0)) && inTopic($0) }
        if pool.count < 10 { pool = entries.filter { theme.lengths.contains(letters($0)) } }
        if pool.count < 10 {
            // Small banks: take the words closest to the semester's lengths.
            let mid = Double(theme.lengths.lowerBound + theme.lengths.upperBound) / 2
            pool = entries.sorted { abs(Double(letters($0)) - mid) < abs(Double(letters($1)) - mid) }
        }
        var generator = SeededGenerator(seed: "semester-\(language.code)-\(semester)-\(attempt)")
        return pool.shuffled(using: &generator).prefix(10).map { word(from: $0, language: language) }
    }

    /// The Daily Exam word for an index from DailySchedule.wordIndex.
    public func dailyWord(language: Language, index: Int) -> Word {
        let entries = allEntries(language)
        var generator = SeededGenerator(seed: "daily-\(language.code)")
        let order = entries.shuffled(using: &generator)
        return word(from: order[index % max(order.count, 1)], language: language)
    }

    public func dailyListCount(language: Language) -> Int {
        max(allEntries(language).count, 1)
    }

    private func word(from entry: WordEntry, language: Language) -> Word {
        Word(
            text: entry.word.uppercased(with: language.locale),
            language: language,
            category: GameCategory(rawValue: entry.category.lowercased()) ?? .random,
            hint: entry.hint,
            definition: entry.definition
        )
    }
}
