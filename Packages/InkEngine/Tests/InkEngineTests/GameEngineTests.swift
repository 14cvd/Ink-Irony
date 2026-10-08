//
//  GameEngineTests.swift
//  InkEngineTests
//

import Foundation
import Testing
@testable import InkEngine

@Suite("GameEngine")
struct GameEngineTests {

    private func engine(_ word: String = "TELESCOPE", lives: Int = 6, ink: Int = 120, finalExam: Bool = false) -> GameEngine {
        GameEngine(word: word, lives: lives, ink: ink, isFinalExam: finalExam)
    }

    @Test("Combo multiplies each hit and resets on a miss")
    func combo() {
        var game = engine()
        #expect(game.guess("T") == .hit(occurrences: 1, multiplier: 1, points: 10))
        #expect(game.guess("E") == .hit(occurrences: 3, multiplier: 2, points: 60))
        #expect(game.guess("L") == .hit(occurrences: 1, multiplier: 3, points: 30))
        #expect(game.guess("Z") == .miss(livesLeft: 5))
        #expect(game.combo == 0)
        #expect(game.guess("S") == .hit(occurrences: 1, multiplier: 1, points: 10))
        #expect(game.letterPoints == 110)
        #expect(game.bestCombo == 3)
    }

    @Test("The multiplier stops at x5")
    func comboCap() {
        var game = engine("ABCDEFG")
        for letter in "ABCDEF" { game.guess(letter) }
        #expect(game.guess("G") == .hit(occurrences: 1, multiplier: 5, points: 50))
        #expect(game.status == .won)
    }

    @Test("Repeated, lower-case and non-letter guesses")
    func repeatedAndLowercase() {
        var game = engine()
        #expect(game.guess("t") == .hit(occurrences: 1, multiplier: 1, points: 10))
        #expect(game.guess("T") == .ignored)
        #expect(game.guess("Q") == .miss(livesLeft: 5))
        #expect(game.guess("q") == .ignored)
        #expect(game.guess("-") == .ignored)
        #expect(game.mistakes == 1)
    }

    @Test("Spaces and hyphens are shown from the start")
    func multiWord() {
        var game = engine("STAR-WARS GO")
        #expect(game.slots.compactMap { $0 } == ["-", " "])
        for letter in "STARWGO" { game.guess(letter) }
        #expect(game.status == .won)
    }

    @Test("Running out of lives loses the word and nothing more is accepted")
    func losing() throws {
        var game = engine(lives: 3)
        game.guess("Q"); game.guess("X")
        #expect(game.guess("Z") == .miss(livesLeft: 0))
        #expect(game.status == .lost)
        #expect(game.guess("T") == .ignored)
        let result = try #require(game.result)
        #expect(!result.won)
        #expect(result.grade == .f)
        #expect(result.livesBonus == 0)
        #expect(result.inkEarned == 0)
    }

    @Test("Score of the graded-exam example: 2 mistakes, best combo x4, one hint")
    func designExample() throws {
        var game = engine()
        game.guess("Q")                 // miss
        game.guess("T")                 // x1: 10
        game.guess("E")                 // x2: 3 x 20 = 60
        game.guess("L")                 // x3: 30
        game.guess("S")                 // x4: 40
        game.guess("X")                 // miss
        try game.use(.hint)             // -20 ink, resets combo
        game.guess("C")                 // x1: 10
        game.guess("O")                 // x2: 20
        game.guess("P")                 // x3: 30, solves the word
        let result = try #require(game.result)
        #expect(result.won)
        #expect(result.letterPoints == 200)
        #expect(result.livesBonus == 40)
        #expect(result.powerUpPenalty == 20)
        #expect(result.score == 220)
        #expect(result.bestCombo == 4)
        #expect(result.grade == .aMinus)
        #expect(result.inkEarned == 15 + 2 * 4)
        #expect(result.inkAfter == 120 - 20 + 23)
    }

    @Test("Eraser gives a life back and keeps the letter used")
    func eraser() throws {
        var game = engine()
        game.guess("Q"); game.guess("X")
        #expect(game.livesLeft == 4)
        try game.use(.eraser)
        #expect(game.livesLeft == 5)
        #expect(game.ink == 90)
        #expect(game.isUsed("X"))
        #expect(game.guess("X") == .ignored)
        #expect(game.misses == ["Q"])
    }

    @Test("Eraser with no mistakes fails and costs nothing")
    func eraserNothing() {
        var game = engine()
        #expect(throws: GameEngine.PowerUpError.nothingToErase) { try game.use(.eraser) }
        #expect(game.ink == 120)
        #expect(game.powerUpsUsed.isEmpty)
    }

    @Test("Reveal opens the first missing letter everywhere and can finish the word")
    func reveal() throws {
        var game = engine("ABBA", ink: 200)
        game.guess("A")
        let opened = try game.use(.reveal)
        #expect(opened == "B")
        #expect(game.slots == ["A", "B", "B", "A"])
        #expect(game.status == .won)
        let result = try #require(game.result)
        #expect(result.letterPoints == 20)   // revealed letters score nothing
        #expect(result.grade == .aMinus)
    }

    @Test("Hint can be shown once")
    func hintOnce() throws {
        var game = engine()
        try game.use(.hint)
        #expect(game.isHintShown)
        #expect(throws: GameEngine.PowerUpError.hintAlreadyShown) { try game.use(.hint) }
        #expect(game.ink == 100)
    }

    @Test("Not enough ink")
    func notEnoughInk() {
        var game = engine(ink: 35)
        game.guess("Q")
        #expect(throws: GameEngine.PowerUpError.notEnoughInk(needed: 40, have: 35)) { try game.use(.reveal) }
        #expect(throws: Never.self) { try game.use(.eraser) }
        #expect(game.ink == 5)
    }

    @Test("Final exams allow no power-ups")
    func finalExam() {
        var game = engine(finalExam: true)
        game.guess("Q")
        #expect(throws: GameEngine.PowerUpError.notAllowedInFinalExam) { try game.use(.eraser) }
    }

    @Test("Turkish and Azerbaijani dotted i", arguments: ["tr", "az"])
    func dottedI(language: String) {
        var game = GameEngine(word: "biber", lives: 6, ink: 100, locale: Locale(identifier: language))
        #expect(game.word == "BİBER")
        #expect(game.guess("i") == .hit(occurrences: 1, multiplier: 1, points: 10))
        #expect(game.guess("I") == .miss(livesLeft: 5))
    }

    @Test("Score never goes below zero")
    func scoreFloor() throws {
        var game = engine("AB", ink: 500)
        try game.use(.hint)
        game.guess("Q")
        try game.use(.eraser)
        try game.use(.reveal)   // opens A
        game.guess("B")
        let result = try #require(game.result)
        #expect(result.letterPoints == 10)
        #expect(result.powerUpPenalty == 60)
        #expect(result.score == 0 + 0 + max(0, 10 + 60 - 60))
    }
}
