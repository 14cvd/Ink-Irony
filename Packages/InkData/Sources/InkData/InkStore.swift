//
//  InkStore.swift
//  InkData
//
//  Opens the SwiftData store without ever deleting player data.
//  v1.2 removed the store when it could not open it; v2 moves the files
//  aside instead, so a failed open is recoverable by a later build.
//

import Foundation
import SwiftData

public enum InkMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self]
    }

    public static var stages: [MigrationStage] {
        []
    }
}

public enum InkStore {

    /// What happened while opening the store. The app reports this once at launch.
    public enum OpenOutcome: Equatable, Sendable {
        /// The existing store (or a new one on first launch) opened normally.
        case opened
        /// The store could not be opened; its files were moved to `backupURL` and a new store was created.
        case movedAside(backupURL: URL)
        /// Nothing could be written to disk; the app runs on an in-memory store for this launch.
        case inMemory
    }

    /// The location SwiftData uses for `ModelContainer(for:)` with no configuration,
    /// which is where v1.2 stored its data.
    public static var defaultStoreURL: URL {
        URL.applicationSupportDirectory.appending(path: "default.store")
    }

    public static var schema: Schema {
        Schema(versionedSchema: SchemaV1.self)
    }

    public static func makeContainer(
        at url: URL = defaultStoreURL,
        now: Date = Date()
    ) -> (container: ModelContainer, outcome: OpenOutcome) {
        let fileManager = FileManager.default
        try? fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)

        if let container = try? open(at: url) {
            // SwiftData silently falls back to memory when it cannot write the file; say so.
            return (container, isInMemory(container) ? .inMemory : .opened)
        }

        if let backupURL = try? moveAside(storeAt: url, now: now, fileManager: fileManager),
           let container = try? open(at: url) {
            return (container, isInMemory(container) ? .inMemory : .movedAside(backupURL: backupURL))
        }

        let memory = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        // An in-memory container with a valid schema cannot fail to open.
        let container = try! ModelContainer(for: schema, migrationPlan: InkMigrationPlan.self, configurations: memory)
        return (container, .inMemory)
    }

    static func isInMemory(_ container: ModelContainer) -> Bool {
        container.configurations.contains { $0.isStoredInMemoryOnly }
    }

    static func open(at url: URL) throws -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, url: url)
        return try ModelContainer(for: schema, migrationPlan: InkMigrationPlan.self, configurations: configuration)
    }

    /// Moves the store and its SQLite side files into a timestamped folder next to it.
    /// Returns the folder. Throws only if nothing could be moved.
    static func moveAside(storeAt url: URL, now: Date, fileManager: FileManager) throws -> URL {
        let stamp = Int(now.timeIntervalSince1970)
        let backupURL = url.deletingLastPathComponent()
            .appending(path: "\(url.lastPathComponent).unreadable-\(stamp)", directoryHint: .isDirectory)
        try fileManager.createDirectory(at: backupURL, withIntermediateDirectories: true)

        var moved = 0
        for suffix in ["", "-shm", "-wal"] {
            let source = URL(fileURLWithPath: url.path + suffix)
            guard fileManager.fileExists(atPath: source.path) else { continue }
            try fileManager.moveItem(at: source, to: backupURL.appending(path: source.lastPathComponent))
            moved += 1
        }
        guard moved > 0 else {
            try? fileManager.removeItem(at: backupURL)
            throw CocoaError(.fileNoSuchFile)
        }
        return backupURL
    }
}
