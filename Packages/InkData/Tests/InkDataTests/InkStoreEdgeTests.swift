//
//  InkStoreEdgeTests.swift
//  InkDataTests
//
//  Hasan, QA pass 2026-10-08.
//

import Foundation
import SwiftData
import Testing
@testable import InkData

@Suite("InkStore edge cases (QA)")
struct InkStoreEdgeTests {

    @Test("A location that cannot be written falls back to memory instead of crashing")
    func unwritableLocation() throws {
        let url = URL(fileURLWithPath: "/dev/null/ink/default.store")
        let (container, outcome) = InkStore.makeContainer(at: url)
        // SwiftData itself silently switches to an in-memory store here, so the app keeps working...
        #expect(container.configurations.first?.isStoredInMemoryOnly == true)
        // ...and InkStore says so (D-01), so the app can warn instead of silently losing games.
        #expect(outcome == .inMemory)

        let context = ModelContext(container)
        context.insert(GameSession(word: "COMET", language: "EN", difficulty: "Easy", score: 100, isWin: true))
        try context.save()
        #expect(try context.fetchCount(FetchDescriptor<GameSession>()) == 1)
    }

    @Test("Two bad opens on the same day keep both backups")
    func twoBackups() throws {
        let dir = FileManager.default.temporaryDirectory.appending(path: "InkStoreEdge-\(UUID().uuidString)", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let url = dir.appending(path: "default.store")

        try Data("broken one".utf8).write(to: url)
        let first = InkStore.makeContainer(at: url, now: Date(timeIntervalSince1970: 1_000))
        _ = first

        // Simulate a second corruption later.
        for suffix in ["", "-shm", "-wal"] {
            try? FileManager.default.removeItem(atPath: url.path + suffix)
        }
        try Data("broken two".utf8).write(to: url)
        let second = InkStore.makeContainer(at: url, now: Date(timeIntervalSince1970: 2_000))

        guard case .movedAside(let backup) = second.outcome else {
            Issue.record("Expected movedAside, got \(second.outcome)")
            return
        }
        #expect(backup.lastPathComponent == "default.store.unreadable-2000")
        let backups = try FileManager.default.contentsOfDirectory(atPath: dir.path).filter { $0.contains("unreadable") }.sorted()
        #expect(backups == ["default.store.unreadable-1000", "default.store.unreadable-2000"])
    }
}
