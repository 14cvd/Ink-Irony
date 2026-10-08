//
//  AppState.swift
//  Ink
//
//  One observable object for the whole app: settings, progress, the teacher
//  and the word being played. Views read it from the environment.
//

import Foundation
import Observation
import SwiftUI
import InkEngine

enum PlayMode: Equatable {
    case semester(number: Int, word: Int)
    case free(level: Difficulty, category: GameCategory)
    case daily(number: Int)
}

struct PlayRequest: Identifiable, Equatable {
    let id = UUID()
    let language: Language
    let mode: PlayMode
}

@MainActor
@Observable
final class AppState {
    var progress: PlayerProgress {
        didSet { ProgressStore.save(progress) }
    }

    var language: Language {
        didSet {
            ScoreManager.shared.uiLanguage = language
            L10n.language = language
        }
    }

    var tone: TeacherTone {
        didSet { UserDefaults.standard.set(tone.rawValue, forKey: Keys.tone) }
    }

    var theme: InkThemeChoice {
        didSet { UserDefaults.standard.set(theme.rawValue, forKey: Keys.theme) }
    }

    var hasOnboarded: Bool {
        didSet { UserDefaults.standard.set(hasOnboarded, forKey: Keys.onboarded) }
    }

    var playRequest: PlayRequest?
    var selectedTab: MainTab = .desk
    var showSettings = false

    let teacher = TeacherVoice()
    let schedule = DailySchedule()

    /// Days since the player last opened the app, measured at launch.
    let daysAway: Int

    enum Keys {
        static let tone = "teacherTone"
        static let theme = "appTheme"
        /// v2 key: v1 players ("hasSeenOnboarding") also see the intro and the form once.
        static let onboarded = "onboardedV2"
    }

    init() {
        let defaults = UserDefaults.standard
        var loaded = ProgressStore.load()
        let now = Date()
        daysAway = loaded.lastSeen.map { Calendar.current.dateComponents([.day], from: $0, to: now).day ?? 0 } ?? 0
        loaded.lastSeen = now
        progress = loaded
        language = ScoreManager.shared.uiLanguage
        tone = TeacherTone(rawValue: defaults.string(forKey: Keys.tone) ?? "") ?? .strict
        theme = InkThemeChoice(rawValue: defaults.string(forKey: Keys.theme) ?? "") ?? .system
        hasOnboarded = defaults.bool(forKey: Keys.onboarded)
        L10n.language = language
        ProgressStore.save(progress)
    }

    // MARK: Derived

    var languageProgress: LanguageProgress { progress.language(language) }

    var gpaText: String {
        languageProgress.gpa.map { String(format: "%.1f", $0) } ?? "—"
    }

    var todayNumber: Int { schedule.number(for: Date()) }

    var todaysDaily: DailyRecord? { progress.dailyRecord(language, number: todayNumber) }

    var dailyStreak: Int {
        DailyStreak.current(played: progress.dailyNumbersPlayed(language), today: todayNumber, schedule: schedule)
    }

    /// The next semester word, or nil when every semester is passed.
    var nextSemesterWord: (semester: Int, word: Int)? {
        let current = languageProgress.current
        guard let word = current.nextWord else { return nil }
        return (current.semester, word)
    }

    func teacherLine(_ trigger: TeacherTrigger, word: String? = nil) -> String {
        teacher.line(trigger, tone: tone, language: language, word: word)
    }

    // MARK: Actions

    func play(_ mode: PlayMode) {
        playRequest = PlayRequest(language: language, mode: mode)
    }

    func playNextSemesterWord() {
        guard let next = nextSemesterWord else { return }
        play(.semester(number: next.semester, word: next.word))
    }

    func resetProgress() {
        progress = PlayerProgress(lastSeen: Date())
        StatsManager.resetAll()
        hasOnboarded = true
    }
}
