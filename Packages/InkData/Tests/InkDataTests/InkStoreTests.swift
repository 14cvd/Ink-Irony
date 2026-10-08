//
//  InkStoreTests.swift
//  InkDataTests
//

import Foundation
import SwiftData
import Testing
@testable import InkData
import InkDataV1Fixture

@Suite("InkStore keeps player data")
struct InkStoreTests {

    private func makeTempStoreURL() throws -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appending(path: "InkStoreTests-\(UUID().uuidString)", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appending(path: "default.store")
    }

    /// Writes a store exactly the way v1.2 does: a top-level GameSession model, no versioned schema.
    private func writeV1Store(at url: URL, sessions: [(word: String, isWin: Bool, score: Int)]) throws {
        let container = try ModelContainer(
            for: InkDataV1Fixture.GameSession.self,
            configurations: ModelConfiguration(url: url)
        )
        let context = ModelContext(container)
        for item in sessions {
            context.insert(InkDataV1Fixture.GameSession(
                word: item.word, language: "EN", difficulty: "Medium", category: "science",
                score: item.score, isWin: item.isWin, timeTaken: 42, hintsUsed: 1, wrongGuesses: 2
            ))
        }
        try context.save()
    }

    @Test("A store written by v1.2 opens with every session intact")
    func opensV1Store() throws {
        let url = try makeTempStoreURL()
        try writeV1Store(at: url, sessions: [("TELESCOPE", true, 155), ("GALAXY", false, 0), ("ORBIT", true, 120)])

        let (container, outcome) = InkStore.makeContainer(at: url)
        #expect(outcome == .opened)

        let sessions = try ModelContext(container).fetch(
            FetchDescriptor<InkData.GameSession>(sortBy: [SortDescriptor(\.word)])
        )
        #expect(sessions.map(\.word) == ["GALAXY", "ORBIT", "TELESCOPE"])
        let telescope = try #require(sessions.last)
        #expect(telescope.isWin)
        #expect(telescope.score == 155)
        #expect(telescope.language == "EN")
        #expect(telescope.difficulty == "Medium")
        #expect(telescope.category == "science")
        #expect(telescope.timeTaken == 42)
        #expect(telescope.hintsUsed == 1)
        #expect(telescope.wrongGuesses == 2)
    }

    @Test("Sessions saved after the upgrade sit next to the v1 ones")
    func writesAfterUpgrade() throws {
        let url = try makeTempStoreURL()
        try writeV1Store(at: url, sessions: [("TELESCOPE", true, 155)])

        do {
            let context = ModelContext(InkStore.makeContainer(at: url).container)
            context.insert(InkData.GameSession(word: "COMET", language: "AZ", difficulty: "Hard", score: 90, isWin: true))
            try context.save()
        }

        let (container, outcome) = InkStore.makeContainer(at: url)
        #expect(outcome == .opened)
        let count = try ModelContext(container).fetchCount(FetchDescriptor<InkData.GameSession>())
        #expect(count == 2)
    }

    @Test("First launch creates an empty store")
    func firstLaunch() throws {
        let url = try makeTempStoreURL()
        let (container, outcome) = InkStore.makeContainer(at: url)
        #expect(outcome == .opened)
        #expect(try ModelContext(container).fetchCount(FetchDescriptor<InkData.GameSession>()) == 0)
        #expect(FileManager.default.fileExists(atPath: url.path))
    }

    @Test("An unreadable store is moved aside, never deleted")
    func unreadableStoreIsMovedAside() throws {
        let url = try makeTempStoreURL()
        let garbage = Data("this is not a sqlite file".utf8)
        try garbage.write(to: url)
        let now = Date(timeIntervalSince1970: 1_800_000_000)

        let (container, outcome) = InkStore.makeContainer(at: url, now: now)

        guard case .movedAside(let backupURL) = outcome else {
            Issue.record("Expected movedAside, got \(outcome)")
            return
        }
        #expect(backupURL.lastPathComponent == "default.store.unreadable-1800000000")
        let preserved = try Data(contentsOf: backupURL.appending(path: "default.store"))
        #expect(preserved == garbage)

        // The app keeps working on a fresh store.
        let context = ModelContext(container)
        context.insert(InkData.GameSession(word: "COMET", language: "EN", difficulty: "Easy", score: 100, isWin: true))
        try context.save()
        #expect(try context.fetchCount(FetchDescriptor<InkData.GameSession>()) == 1)
    }
}
