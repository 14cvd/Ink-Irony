//
//  GameSession.swift
//  InkDataV1Fixture
//
//  Exact copy of the model shipped in v1.2 (Ink/Core/ScoreManager.swift at 9f87a14),
//  declared top-level as it was in the app. Tests use it to write a store the way
//  the App Store build does, then open that store with InkStore.
//

import Foundation
import SwiftData

@Model
public final class GameSession {
    public var id: UUID
    public var date: Date
    public var word: String
    public var language: String
    public var difficulty: String
    public var category: String
    public var score: Int
    public var isWin: Bool
    public var timeTaken: Int
    public var hintsUsed: Int
    public var wrongGuesses: Int

    public init(
        word: String,
        language: String,
        difficulty: String,
        category: String = "random",
        score: Int,
        isWin: Bool,
        timeTaken: Int = 0,
        hintsUsed: Int = 0,
        wrongGuesses: Int = 0
    ) {
        self.id = UUID()
        self.date = Date()
        self.word = word
        self.language = language
        self.difficulty = difficulty
        self.category = category
        self.score = score
        self.isWin = isWin
        self.timeTaken = timeTaken
        self.hintsUsed = hintsUsed
        self.wrongGuesses = wrongGuesses
    }
}
