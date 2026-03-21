//
//  ScoreManager.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import Foundation
import SwiftData
import SwiftUI
import Combine
// MARK: - SwiftData Model
@Model
public final class GameSession {
    public var id: UUID
    public var date: Date
    public var word: String
    public var language: String
    public var difficulty: String
    public var score: Int
    public var isWin: Bool
    
    public init(word: String, language: String, difficulty: String, score: Int, isWin: Bool) {
        self.id = UUID()
        self.date = Date()
        self.word = word
        self.language = language
        self.difficulty = difficulty
        self.score = score
        self.isWin = isWin
    }
}

// MARK: - Score Manager
@MainActor
public class ScoreManager: ObservableObject {
    public static let shared = ScoreManager()
    
    // Core SwiftData container encapsulating game results
    public let modelContainer: ModelContainer
    
    // Global language state persisted natively
    @Published public var uiLanguage: Language = .english {
        didSet { UserDefaults.standard.set(uiLanguage.rawValue, forKey: "uiLanguage") }
    }
    
    // Published stats computed on the fly for live UI binding
    @Published public private(set) var currentStreak: Int = 0
    @Published public private(set) var highestStreak: Int = 0
    @Published public private(set) var totalWins: Int = 0
    @Published public private(set) var totalLosses: Int = 0
    
    private init() {
        if let savedRaw = UserDefaults.standard.string(forKey: "uiLanguage"), let savedLang = Language(rawValue: savedRaw) {
            self.uiLanguage = savedLang
        }
        
        do {
            modelContainer = try ModelContainer(for: GameSession.self)
            Task { @MainActor in
                self.recalculateStats()
            }
        } catch {
            fatalError("Could not initialize SwiftData ModelContainer: \(error.localizedDescription)")
        }
    }
    
    /// Scans the database strictly to deduce streaks, max high scores, and absolute win rates
    public func recalculateStats() {
        let descriptor = FetchDescriptor<GameSession>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        
        do {
            let matches = try modelContainer.mainContext.fetch(descriptor)
            
            var wins = 0
            var losses = 0
            var streak = 0
            var maxStreak = 0
            var currentStreakActive = true
            
            for match in matches {
                if match.isWin {
                    wins += 1
                    if currentStreakActive {
                        streak += 1
                    }
                } else {
                    losses += 1
                    currentStreakActive = false // Streak decisively broken
                }
            }
            
            // For highest streak, calculate chronologically (oldest to newest)
            var tempStreak = 0
            for match in matches.reversed() {
                if match.isWin {
                    tempStreak += 1
                    maxStreak = max(maxStreak, tempStreak)
                } else {
                    tempStreak = 0
                }
            }
            
            self.totalWins = wins
            self.totalLosses = losses
            self.currentStreak = streak
            self.highestStreak = maxStreak
            
        } catch {
            print("Failed to fetch scores to recalculate stats: \(error.localizedDescription)")
        }
    }
}
