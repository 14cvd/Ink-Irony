//
//  GameModel.swift
//  Ink
//
//  One word on screen: wraps InkEngine.GameEngine and adds the teacher's
//  reactions, haptics, sound and timing. No rules live here.
//

import Foundation
import Observation
import InkEngine

@MainActor
@Observable
final class GameModel {
    let request: PlayRequest
    let word: Word
    private(set) var engine: GameEngine
    private(set) var line: String
    private(set) var mood: TeacherMood = .calm
    /// Short message under the power-ups, e.g. "30 ink needed".
    private(set) var notice: String?
    /// Hit (true) or miss (false) per guess, for the spoiler-free Daily share.
    private(set) var pattern: [Bool] = []

    private let startedAt = Date()
    private(set) var seconds = 0
    private unowned let app: AppState

    init(request: PlayRequest, word: Word, app: AppState) {
        self.request = request
        self.word = word
        self.app = app
        engine = GameEngine(
            word: word.text,
            lives: Self.lives(for: request.mode),
            ink: app.progress.ink,
            powerUpsAllowed: Self.powerUpsAllowed(for: request.mode),
            locale: request.language.locale
        )
        let isFinal: Bool = if case .semester(_, let w) = request.mode { SemesterPlan.isFinalExam(word: w) } else { false }
        line = app.teacherLine(isFinal ? .finalExamStart : .wordStart)
    }

    static func lives(for mode: PlayMode) -> Int {
        switch mode {
        case .semester(let number, let word): SemesterPlan.lives(semester: number, word: word)
        case .free(let level, _): level.lives
        case .daily: 6
        }
    }

    static func powerUpsAllowed(for mode: PlayMode) -> Bool {
        switch mode {
        case .semester(_, let word): !SemesterPlan.isFinalExam(word: word)
        case .free: true
        case .daily: false
        }
    }

    // MARK: Derived

    var isOver: Bool { engine.status != .playing }
    var won: Bool { engine.status == .won }

    var doodleMood: DoodleMood {
        DoodleMood.forState(livesLeft: engine.livesLeft, lives: engine.lives, won: engine.status == .won, lost: engine.status == .lost)
    }

    func keyState(_ letter: Character) -> KeyState {
        if engine.hits.contains(letter) || engine.revealed.contains(letter) { return .hit }
        if engine.misses.contains(letter) || engine.erased.contains(letter) { return .miss }
        return isOver ? .locked : .idle
    }

    func canUse(_ powerUp: PowerUp) -> Bool {
        guard !isOver, engine.powerUpsAllowed, engine.ink >= powerUp.inkCost else { return false }
        switch powerUp {
        case .eraser: return !engine.misses.isEmpty
        case .reveal: return true
        case .hint: return !engine.isHintShown
        }
    }

    // MARK: Actions

    func tap(_ letter: Character) {
        notice = nil
        let outcome = engine.guess(letter)
        switch outcome {
        case .ignored:
            return
        case .hit:
            pattern.append(true)
            HapticService.shared.playPenStrike()
            AudioService.shared.play(.sfxCorrect)
            if engine.status == .won {
                finish()
            } else if engine.combo >= 3 {
                say(.combo, mood: .calm)
            } else {
                say(.correct, mood: .calm)
            }
        case .miss:
            pattern.append(false)
            HapticService.shared.playErrorPulse()
            AudioService.shared.play(.sfxWrong)
            if engine.status == .lost {
                finish()
            } else if engine.mistakes == 1 {
                say(.firstMistake, mood: .annoyed)
            } else if engine.livesLeft == 1 {
                say(.lowLives, mood: .annoyed)
            } else {
                say(.mistake, mood: .annoyed)
            }
        }
    }

    func use(_ powerUp: PowerUp) {
        do {
            try engine.use(powerUp)
            notice = nil
            HapticService.shared.playPenStrike()
            AudioService.shared.play(.penScratch)
            if engine.status == .won {
                finish()
            } else {
                switch powerUp {
                case .eraser: say(.eraser, mood: .annoyed)
                case .reveal: say(.reveal, mood: .annoyed)
                case .hint: say(.hint, mood: .calm)
                }
            }
        } catch let error as GameEngine.PowerUpError {
            switch error {
            case .notEnoughInk(let needed, _): notice = L10n.t("power.needInk", needed)
            case .notAllowed: notice = L10n.t("power.notAllowed")
            default: break
            }
        } catch {}
    }

    /// Ink spent on power-ups is kept even if the player leaves mid-word.
    func abandon() {
        guard !isOver else { return }
        app.progress.ink = engine.ink
    }

    // MARK: Private

    private func finish() {
        seconds = Int(Date().timeIntervalSince(startedAt))
        if engine.status == .won {
            HapticService.shared.playSuccessPulse()
            AudioService.shared.play(.checkmark)
            let trigger: TeacherTrigger = engine.mistakes == 0 ? .wonFlawless : (engine.livesLeft == 1 ? .wonNarrow : .won)
            say(trigger, mood: .pleased)
        } else {
            HapticService.shared.playErrorPulse()
            AudioService.shared.play(.pencilSnap)
            say(.lost, mood: .annoyed)
        }
    }

    private func say(_ trigger: TeacherTrigger, mood: TeacherMood) {
        line = app.teacherLine(trigger, word: word.text)
        self.mood = mood
    }
}
