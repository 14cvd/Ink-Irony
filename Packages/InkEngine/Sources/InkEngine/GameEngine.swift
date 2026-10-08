//
//  GameEngine.swift
//  InkEngine
//
//  One word, from the first guess to the result. Pure value type: no UI, no
//  timers, no persistence. Every mode (Semesters, Free play, Daily) plays a
//  word through this type and records the GameResult it produces.
//

import Foundation

public struct GameEngine: Sendable {

    public enum Status: Equatable, Sendable {
        case playing
        case won
        case lost
    }

    public enum GuessOutcome: Equatable, Sendable {
        /// The letter is in the word; `occurrences` positions opened, scored with `multiplier`.
        case hit(occurrences: Int, multiplier: Int, points: Int)
        case miss(livesLeft: Int)
        /// Already guessed, not a letter of the alphabet in play, or the word is over.
        case ignored
    }

    public enum PowerUpError: Error, Equatable, Sendable {
        case notAllowedInFinalExam
        case notEnoughInk(needed: Int, have: Int)
        case nothingToErase
        case hintAlreadyShown
        case wordIsOver
    }

    // MARK: Inputs

    /// The answer, uppercased for its language. May contain spaces or hyphens.
    public let word: String
    public let lives: Int
    public let isFinalExam: Bool
    private let locale: Locale

    // MARK: State

    public private(set) var status: Status = .playing
    public private(set) var hits: Set<Character> = []
    /// Wrong letters that still cost a life, in the order they were guessed.
    public private(set) var misses: [Character] = []
    /// Wrong letters whose life was given back by the eraser. They stay used.
    public private(set) var erased: Set<Character> = []
    /// Letters opened by the reveal power-up. They score nothing.
    public private(set) var revealed: Set<Character> = []
    public private(set) var combo = 0
    public private(set) var bestCombo = 0
    public private(set) var letterPoints = 0
    public private(set) var powerUpsUsed: [PowerUp] = []
    public private(set) var isHintShown = false
    public private(set) var ink: Int

    public init(word: String, lives: Int, ink: Int, isFinalExam: Bool = false, locale: Locale = Locale(identifier: "en")) {
        precondition(lives > 0, "A word needs at least one life")
        self.locale = locale
        self.word = word.uppercased(with: locale)
        self.lives = lives
        self.ink = ink
        self.isFinalExam = isFinalExam
    }

    // MARK: Derived

    /// Letters the player has to find. Spaces, hyphens and apostrophes are shown from the start.
    public var lettersToFind: Set<Character> {
        Set(word.filter(\.isLetter))
    }

    public var mistakes: Int { misses.count }
    public var livesLeft: Int { lives - misses.count }
    public var multiplier: Int { min(max(combo, 1), Rules.maxComboMultiplier) }

    public func isUsed(_ letter: Character) -> Bool {
        let letter = normalized(letter)
        return hits.contains(letter) || misses.contains(letter) || erased.contains(letter) || revealed.contains(letter)
    }

    /// The word with unfound letters as nil, one entry per character.
    public var slots: [Character?] {
        word.map { char in
            guard char.isLetter else { return char }
            return (hits.contains(char) || revealed.contains(char)) ? char : nil
        }
    }

    // MARK: Guessing

    @discardableResult
    public mutating func guess(_ letter: Character) -> GuessOutcome {
        let letter = normalized(letter)
        guard status == .playing, letter.isLetter, !isUsed(letter) else { return .ignored }

        let occurrences = word.filter { $0 == letter }.count
        guard occurrences > 0 else {
            misses.append(letter)
            combo = 0
            if livesLeft == 0 { status = .lost }
            return .miss(livesLeft: livesLeft)
        }

        hits.insert(letter)
        combo += 1
        bestCombo = max(bestCombo, combo)
        let applied = multiplier
        let points = Rules.pointsPerLetter * occurrences * applied
        letterPoints += points
        finishIfSolved()
        return .hit(occurrences: occurrences, multiplier: applied, points: points)
    }

    // MARK: Power-ups

    /// Applies a power-up and pays its ink. Returns the letter opened by `.reveal`.
    @discardableResult
    public mutating func use(_ powerUp: PowerUp) throws(PowerUpError) -> Character? {
        guard status == .playing else { throw .wordIsOver }
        guard !isFinalExam else { throw .notAllowedInFinalExam }
        guard ink >= powerUp.inkCost else { throw .notEnoughInk(needed: powerUp.inkCost, have: ink) }

        var opened: Character?
        switch powerUp {
        case .eraser:
            guard let last = misses.popLast() else { throw .nothingToErase }
            erased.insert(last)
        case .reveal:
            // First missing letter in reading order, so the result is predictable for the player and for tests.
            guard let letter = word.first(where: { $0.isLetter && !hits.contains($0) && !revealed.contains($0) }) else {
                throw .wordIsOver
            }
            revealed.insert(letter)
            opened = letter
        case .hint:
            guard !isHintShown else { throw .hintAlreadyShown }
            isHintShown = true
        }

        ink -= powerUp.inkCost
        powerUpsUsed.append(powerUp)
        combo = 0
        finishIfSolved()
        return opened
    }

    // MARK: Result

    /// Available once the word is over.
    public var result: GameResult? {
        guard status != .playing else { return nil }
        let won = status == .won
        let livesBonus = won ? Rules.livesBonusPerLife * livesLeft : 0
        let penalty = Rules.powerUpScorePenalty * powerUpsUsed.count
        let inkEarned = won ? Rules.inkPerWin + Rules.inkPerLifeLeft * livesLeft : 0
        return GameResult(
            word: word,
            won: won,
            lives: lives,
            mistakes: mistakes,
            livesLeft: livesLeft,
            letterPoints: letterPoints,
            livesBonus: livesBonus,
            powerUpPenalty: penalty,
            bestCombo: bestCombo,
            powerUpsUsed: powerUpsUsed,
            grade: Grade.forWord(won: won, mistakes: mistakes, lives: lives, powerUpsUsed: powerUpsUsed.count),
            inkEarned: inkEarned,
            inkAfter: ink + inkEarned
        )
    }

    // MARK: Private

    private func normalized(_ letter: Character) -> Character {
        String(letter).uppercased(with: locale).first ?? letter
    }

    private mutating func finishIfSolved() {
        let found = hits.union(revealed)
        if lettersToFind.isSubset(of: found) {
            status = .won
        }
    }
}

public struct GameResult: Equatable, Sendable {
    public let word: String
    public let won: Bool
    public let lives: Int
    public let mistakes: Int
    public let livesLeft: Int
    public let letterPoints: Int
    public let livesBonus: Int
    public let powerUpPenalty: Int
    public let bestCombo: Int
    public let powerUpsUsed: [PowerUp]
    public let grade: Grade
    public let inkEarned: Int
    public let inkAfter: Int

    /// Never below zero, so a rough word does not show a negative score.
    public var score: Int {
        max(0, letterPoints + livesBonus - powerUpPenalty)
    }
}
