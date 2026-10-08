//
//  GradeTests.swift
//  InkEngineTests
//

import Testing
@testable import InkEngine

@Suite("Grades and GPA")
struct GradeTests {

    @Test("Six lives: one grade per mistake count", arguments: [
        (0, Grade.aPlus), (1, .a), (2, .aMinus), (3, .b), (4, .c), (5, .d),
    ])
    func sixLives(mistakes: Int, expected: Grade) {
        #expect(Grade.forWord(won: true, mistakes: mistakes, lives: 6, powerUpsUsed: 0) == expected)
    }

    @Test("Eight lives (Kindergarten)", arguments: [
        (1, Grade.a), (2, .aMinus), (3, .b), (4, .b), (5, .c), (6, .d), (7, .d),
    ])
    func eightLives(mistakes: Int, expected: Grade) {
        #expect(Grade.forWord(won: true, mistakes: mistakes, lives: 8, powerUpsUsed: 0) == expected)
    }

    @Test("Three lives (PhD)", arguments: [
        (0, Grade.aPlus), (1, .aMinus), (2, .c),
    ])
    func threeLives(mistakes: Int, expected: Grade) {
        #expect(Grade.forWord(won: true, mistakes: mistakes, lives: 3, powerUpsUsed: 0) == expected)
    }

    @Test("A lost word is an F whatever else happened")
    func lostIsF() {
        #expect(Grade.forWord(won: false, mistakes: 6, lives: 6, powerUpsUsed: 0) == .f)
        #expect(Grade.forWord(won: false, mistakes: 3, lives: 6, powerUpsUsed: 2) == .f)
    }

    @Test("A power-up caps the grade at A- but never improves a worse one")
    func powerUpCap() {
        #expect(Grade.forWord(won: true, mistakes: 0, lives: 6, powerUpsUsed: 1) == .aMinus)
        #expect(Grade.forWord(won: true, mistakes: 1, lives: 6, powerUpsUsed: 1) == .aMinus)
        #expect(Grade.forWord(won: true, mistakes: 4, lives: 6, powerUpsUsed: 1) == .c)
    }

    @Test("GPA is the mean of grade points")
    func gpa() throws {
        #expect(Grade.gpa(of: []) == nil)
        let value = try #require(Grade.gpa(of: [.a, .b, .aMinus]))
        #expect(abs(value - (4.0 + 3.0 + 3.7) / 3) < 0.000_001)
    }

    @Test("Grades order from best to worst")
    func ordering() {
        #expect(Grade.aPlus < .a)
        #expect(Grade.d < .f)
        #expect(max(Grade.aPlus, .aMinus) == .aMinus)
    }
}
