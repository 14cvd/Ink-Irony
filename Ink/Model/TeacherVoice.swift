//
//  TeacherVoice.swift
//  Ink
//
//  Picks Ms. Irony's line for a moment of the game. Lines live in
//  Resources/teacher_<lang>.json (strict and gentle tones). The same line is
//  not repeated until the others in its trigger have been used.
//

import Foundation

enum TeacherTone: String, CaseIterable, Identifiable {
    case strict, gentle
    var id: String { rawValue }
}

enum TeacherTrigger: String, CaseIterable {
    case wordStart, finalExamStart, correct, combo, firstMistake, mistake, lowLives
    case won, wonFlawless, wonNarrow, lost
    case eraser, reveal, hint
    case desk, deskReturning, dailyDone
    case gradeAPlus, gradeA, gradeAMinus, gradeB, gradeC, gradeD, gradeF
}

private struct TeacherFile: Decodable {
    let strict: [String: [String]]
    let gentle: [String: [String]]
}

@MainActor
final class TeacherVoice {
    private var cache: [Language: TeacherFile] = [:]
    private var recent: [String: [String]] = [:]

    func line(_ trigger: TeacherTrigger, tone: TeacherTone, language: Language, word: String? = nil) -> String {
        let lines = candidates(trigger, tone: tone, language: language)
        let key = "\(language.code).\(tone.rawValue).\(trigger.rawValue)"
        let used = recent[key] ?? []
        let fresh = lines.filter { !used.contains($0) }
        let chosen = (fresh.isEmpty ? lines : fresh).randomElement() ?? ""
        // Remember up to all-but-one lines, so the next pick always has a choice.
        recent[key] = Array((used + [chosen]).suffix(max(lines.count - 1, 0)))
        return chosen.replacingOccurrences(of: "{word}", with: word ?? "")
    }

    private func candidates(_ trigger: TeacherTrigger, tone: TeacherTone, language: Language) -> [String] {
        let file = load(language) ?? load(.english)
        let table = tone == .gentle ? file?.gentle : file?.strict
        if let lines = table?[trigger.rawValue], !lines.isEmpty { return lines }
        return [Self.fallback(trigger)]
    }

    private func load(_ language: Language) -> TeacherFile? {
        if let cached = cache[language] { return cached }
        guard let url = Bundle.main.url(forResource: "teacher_\(language.code)", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(TeacherFile.self, from: data) else { return nil }
        cache[language] = file
        return file
    }

    /// Used only if a content file is missing, so the bubble is never empty.
    private static func fallback(_ trigger: TeacherTrigger) -> String {
        switch trigger {
        case .lost: "{word}. Look it up."
        case .won, .wonFlawless, .wonNarrow: "Escaped. Noted."
        case .firstMistake, .mistake, .lowLives: "Interesting. Wrong, but interesting."
        default: "Impress me."
        }
    }
}
