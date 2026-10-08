//
//  SchemaV1.swift
//  InkData
//
//  The v1.2 data model, frozen. Do not change a property here: the App Store
//  build writes stores with exactly this shape. New fields go into SchemaV2
//  with a migration stage in InkMigrationPlan.
//

import Foundation
import SwiftData

public enum SchemaV1: VersionedSchema {
    public static let versionIdentifier = Schema.Version(1, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [GameSession.self]
    }

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
}

/// The current model version used by the app.
public typealias GameSession = SchemaV1.GameSession
