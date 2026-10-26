//
//  StoreDemo.swift
//  Ink
//
//  DEBUG only. Launch with `-storeDemo YES` to get the state used for App
//  Store screenshots: Semester 3 in progress, a 12-day Daily streak, some
//  stickers, and the same word (telescope) in every mode, so the screenshot
//  test knows which letters to tap. Never compiled into Release builds.
//

#if DEBUG
import Foundation
import InkEngine

enum StoreDemo {
    static var isOn: Bool {
        UserDefaults.standard.bool(forKey: "storeDemo")
    }

    static func seed(_ progress: inout PlayerProgress, language: Language, today: Int) {
        progress.ink = 135
        progress.wordsSolved = 148
        progress.languages[language.code] = LanguageProgress(
            current: SemesterProgress(semester: 3, grades: [.a, .aMinus, .aPlus]),
            attempt: 0,
            passed: [
                1: [.aPlus, .a, .a, .aPlus, .aMinus, .a, .aPlus, .a, .b, .a],
                2: [.a, .b, .aMinus, .a, .aPlus, .b, .a, .aMinus, .a, .c],
            ]
        )
        var days: [Int: DailyRecord] = [:]
        for number in (today - 11)..<today {
            days[number] = DailyRecord(won: true, mistakes: number % 3, seconds: 40 + number % 20, pattern: [true, true, false, true, true, true])
        }
        progress.daily[language.code] = days
        UserDefaults.standard.set(["firstWin", "streak3", "polyglot", "noHints", "speedRun", "nightOwl", "scholar"], forKey: "achievements")
    }

    /// The same word in every mode, so the screenshot test can play it.
    static func word(for language: Language) -> Word {
        let (text, hint, definition): (String, String, String) = switch language {
        case .english: ("TELESCOPE", "Helps you see far-away things.", "An optical instrument that makes distant objects appear nearer, using lenses or curved mirrors.")
        case .turkish: ("TELESKOP", "Uzaktakileri görmeye yarar.", "Uzaktaki cisimleri mercek veya aynalarla yakın gösteren optik alet.")
        case .azerbaijani: ("TELESKOP", "Uzaqdakıları görməyə kömək edir.", "Uzaq cisimləri linza və ya güzgülərlə yaxın göstərən optik cihaz.")
        case .russian: ("ТЕЛЕСКОП", "Помогает видеть далёкое.", "Оптический прибор, который с помощью линз или зеркал приближает далёкие объекты.")
        case .spanish: ("TELESCOPIO", "Ayuda a ver lo lejano.", "Instrumento óptico que acerca los objetos lejanos con lentes o espejos.")
        }
        return Word(text: text, language: language, category: .science, hint: hint, definition: definition)
    }
}
#endif
