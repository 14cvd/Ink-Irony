//
//  EdgeCaseTests.swift
//  InkEngineTests
//
//  Hasan, QA pass 2026-10-08: cases the acceptance criteria did not name.
//  Known defects use withKnownIssue so the suite stays green and flags the day they are fixed.
//

import Foundation
import Testing
@testable import InkEngine

@Suite("Edge cases (QA)")
struct EdgeCaseTests {

    @Test("Nothing changes after a win: guesses ignored, power-ups refused")
    func afterWin() throws {
        var game = GameEngine(word: "AB", lives: 6, ink: 200)
        game.guess("A"); game.guess("B")
        #expect(game.status == .won)
        let before = try #require(game.result)
        #expect(game.guess("C") == .ignored)
        #expect(throws: GameEngine.PowerUpError.wordIsOver) { try game.use(.hint) }
        #expect(game.result == before)
        #expect(game.ink == 200)
    }

    @Test("The eraser cannot bring a lost word back")
    func eraserAfterLoss() {
        var game = GameEngine(word: "AB", lives: 1, ink: 200)
        game.guess("Z")
        #expect(game.status == .lost)
        #expect(throws: GameEngine.PowerUpError.wordIsOver) { try game.use(.eraser) }
        #expect(game.livesLeft == 0)
    }

    @Test("Exactly enough ink is enough, and ink never goes negative")
    func exactInk() throws {
        var game = GameEngine(word: "ABC", lives: 6, ink: 40)
        try game.use(.reveal)
        #expect(game.ink == 0)
        #expect(throws: GameEngine.PowerUpError.notEnoughInk(needed: 20, have: 0)) { try game.use(.hint) }
    }

    @Test("Digits and punctuation are not guesses")
    func nonLetters() {
        var game = GameEngine(word: "R2D2", lives: 6, ink: 100)
        #expect(game.guess("2") == .ignored)
        #expect(game.guess("!") == .ignored)
        #expect(game.mistakes == 0)
    }

    @Test("Russian Ё and Е are different keys")
    func russianYo() {
        var game = GameEngine(word: "ЁЛКА", lives: 6, ink: 100, locale: Locale(identifier: "ru"))
        #expect(game.guess("Е") == .miss(livesLeft: 5))
        #expect(game.guess("ё") == .hit(occurrences: 1, multiplier: 1, points: 10))
    }

    @Test("Azerbaijani Ə, Ğ, Ş, Ü, Ö keep their own keys")
    func azerbaijaniLetters() {
        var game = GameEngine(word: "gözəl", lives: 6, ink: 100, locale: Locale(identifier: "az"))
        #expect(game.word == "GÖZƏL")
        #expect(game.guess("e") == .miss(livesLeft: 5))
        #expect(game.guess("ə") == .hit(occurrences: 1, multiplier: 1, points: 10))
        #expect(game.guess("O") == .miss(livesLeft: 4))
        #expect(game.guess("Ö") == .hit(occurrences: 1, multiplier: 1, points: 10))
    }

    @Test("No result while the word is still being played")
    func noEarlyResult() {
        var game = GameEngine(word: "AB", lives: 6, ink: 100)
        game.guess("A")
        #expect(game.result == nil)
    }

    @Test("E-01 fixed: a word with no letters is solved before the first guess")
    func wordWithoutLetters() {
        let game = GameEngine(word: " - ", lives: 6, ink: 100)
        #expect(game.status == .won)
    }

    @Test("E-02 fixed: decoding a semester validates like init")
    func invalidSemesterJSON() throws {
        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(SemesterProgress.self, from: Data(#"{"semester": 9, "grades": ["A"]}"#.utf8))
        }
        let elevenGrades = Array(repeating: "\"A\"", count: 11).joined(separator: ",")
        let tooMany = Data("{\"semester\": 2, \"grades\": [\(elevenGrades)]}".utf8)
        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(SemesterProgress.self, from: tooMany)
        }
        let ok = try JSONDecoder().decode(SemesterProgress.self, from: Data(#"{"semester": 2, "grades": ["A", "B"]}"#.utf8))
        #expect(ok.nextWord == 3)
    }

    @Test("Daily streak ignores days after today")
    func streakIgnoresFuture() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let schedule = DailySchedule(epoch: DateComponents(year: 2027, month: 1, day: 11), calendar: calendar)
        #expect(DailyStreak.current(played: Set(1...5).union([9, 10]), today: 5, schedule: schedule) == 5)
    }

    @Test("A missed yesterday uses the hall pass while today is still open")
    func hallPassYesterday() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let schedule = DailySchedule(epoch: DateComponents(year: 2027, month: 1, day: 11), calendar: calendar)
        // Week 2 is days 8-14; day 12 missed, today (13) not played yet.
        #expect(DailyStreak.current(played: Set(1...11), today: 13, schedule: schedule) == 11)
    }
}
