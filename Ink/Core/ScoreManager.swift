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

// MARK: - Achievement Manager
public struct AchievementManager {
    
    public struct Achievement {
        public let id: String
        public let emoji: String
        public let nameEN: String
        public let nameTR: String
        public let nameAZ: String
        public let nameES: String
        public let nameRU: String
        
        public func name(for lang: Language) -> String {
            switch lang {
            case .english: return nameEN
            case .turkish: return nameTR
            case .azerbaijani: return nameAZ
            case .spanish: return nameES
            case .russian: return nameRU
            }
        }
    }
    
    public static let all: [Achievement] = [
        Achievement(id: "firstWin", emoji: "🏆", nameEN: "First Win", nameTR: "İlk Galibiyet", nameAZ: "İlk Qələbə", nameES: "Primera victoria", nameRU: "Первая победа"),
        Achievement(id: "streak3", emoji: "🔥", nameEN: "3-Streak", nameTR: "3 Seri", nameAZ: "3 Seriya", nameES: "Racha de 3", nameRU: "Серия 3"),
        Achievement(id: "speedRun", emoji: "⚡", nameEN: "Speed Run", nameTR: "Hız Koşusu", nameAZ: "Sürət qaçışı", nameES: "Carrera veloz", nameRU: "Спринт"),
        Achievement(id: "nightmare", emoji: "💀", nameEN: "Nightmare", nameTR: "Kabus", nameAZ: "Kabus", nameES: "Pesadilla", nameRU: "Кошмар"),
        Achievement(id: "polyglot", emoji: "🌍", nameEN: "Polyglot", nameTR: "Çok Dilli", nameAZ: "Çoxdilli", nameES: "Políglota", nameRU: "Полиглот"),
        Achievement(id: "scholar", emoji: "📖", nameEN: "Scholar", nameTR: "Akademisyen", nameAZ: "Alim", nameES: "Erudito", nameRU: "Учёный"),
        Achievement(id: "noHints", emoji: "🎯", nameEN: "No Hints", nameTR: "İpucusuz", nameAZ: "İpucusuz", nameES: "Sin pistas", nameRU: "Без подсказок"),
        Achievement(id: "streak30", emoji: "🗓️", nameEN: "30-Day", nameTR: "30 Gün", nameAZ: "30 Gün", nameES: "30 días", nameRU: "30 дней"),
        Achievement(id: "topScore", emoji: "👑", nameEN: "Top Score", nameTR: "En Yüksek", nameAZ: "Ən Yüksək", nameES: "Puntuación máx", nameRU: "Топ балл"),
        Achievement(id: "silent", emoji: "🤐", nameEN: "Silent", nameTR: "Sessiz", nameAZ: "Səssiz", nameES: "Silencioso", nameRU: "Молчун"),
        Achievement(id: "bookworm", emoji: "📚", nameEN: "Bookworm", nameTR: "Kitap Kurdu", nameAZ: "Kitabxanəçi", nameES: "Ratón de biblioteca", nameRU: "Книжный червь"),
        Achievement(id: "nightOwl", emoji: "🌙", nameEN: "Night Owl", nameTR: "Gece Kuşu", nameAZ: "Gecə Quşu", nameES: "Noctámbulo", nameRU: "Ночная сова")
    ]
    
    private static let key = "achievements"
    
    public static func earnedIds() -> Set<String> {
        let arr = UserDefaults.standard.stringArray(forKey: key) ?? []
        return Set(arr)
    }
    
    @discardableResult
    public static func unlock(id: String) -> Bool {
        var earned = earnedIds()
        guard !earned.contains(id) else { return false }
        earned.insert(id)
        UserDefaults.standard.set(Array(earned), forKey: key)
        return true
    }
    
    public static func isUnlocked(_ id: String) -> Bool {
        earnedIds().contains(id)
    }
    
    public static func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - Stats Manager
public struct StatsManager {
    
    static func wins(lang: Language) -> Int {
        UserDefaults.standard.integer(forKey: "stats_\(lang.rawValue)_wins")
    }
    
    static func losses(lang: Language) -> Int {
        UserDefaults.standard.integer(forKey: "stats_\(lang.rawValue)_losses")
    }
    
    static func bestScore(lang: Language) -> Int {
        UserDefaults.standard.integer(forKey: "stats_\(lang.rawValue)_bestScore")
    }
    
    static func streak() -> Int {
        UserDefaults.standard.integer(forKey: "stats_streak")
    }
    
    static func winRate(lang: Language) -> Double {
        let w = wins(lang: lang)
        let l = losses(lang: lang)
        guard w + l > 0 else { return 0 }
        return Double(w) / Double(w + l)
    }
    
    static func winRateByDifficulty() -> [Difficulty: Double] {
        var result: [Difficulty: Double] = [:]
        for diff in Difficulty.allCases {
            let w = UserDefaults.standard.integer(forKey: "stats_diff_\(diff.rawValue)_wins")
            let l = UserDefaults.standard.integer(forKey: "stats_diff_\(diff.rawValue)_losses")
            result[diff] = (w + l > 0) ? Double(w) / Double(w + l) : 0
        }
        return result
    }
    
    static func bestCategoryForCurrentLanguage(lang: Language) -> (GameCategory, Double)? {
        var best: (GameCategory, Double)? = nil
        for cat in GameCategory.allCases where cat != .random {
            let w = UserDefaults.standard.integer(forKey: "stats_\(lang.rawValue)_cat_\(cat.rawValue)_wins")
            let l = UserDefaults.standard.integer(forKey: "stats_\(lang.rawValue)_cat_\(cat.rawValue)_losses")
            let rate = (w + l > 0) ? Double(w) / Double(w + l) : 0
            if best == nil || rate > best!.1 {
                best = (cat, rate)
            }
        }
        return best
    }
    
    static func literaturesWins() -> Int {
        var total = 0
        for lang in Language.allCases {
            total += UserDefaults.standard.integer(forKey: "stats_\(lang.rawValue)_cat_literature_wins")
        }
        return total
    }
    
    /// Call this after each game ends
    @discardableResult
    static func updateAfterGame(
        isWin: Bool,
        category: GameCategory,
        difficulty: Difficulty,
        language: Language,
        timeTaken: Int,
        hintsUsed: Int,
        wrongGuesses: Int,
        score: Int
    ) -> [String] { // returns newly unlocked achievement IDs
        let ud = UserDefaults.standard
        var newAchievements: [String] = []
        
        func ach(_ id: String) {
            if AchievementManager.unlock(id: id) {
                newAchievements.append(id)
            }
        }
        
        // wins/losses per language
        let wKey = "stats_\(language.rawValue)_wins"
        let lKey = "stats_\(language.rawValue)_losses"
        if isWin { ud.set(ud.integer(forKey: wKey) + 1, forKey: wKey) }
        else      { ud.set(ud.integer(forKey: lKey) + 1, forKey: lKey) }
        
        // best score per language
        let bKey = "stats_\(language.rawValue)_bestScore"
        if score > ud.integer(forKey: bKey) { ud.set(score, forKey: bKey) }
        
        // per-difficulty
        let diffWKey = "stats_diff_\(difficulty.rawValue)_wins"
        let diffLKey = "stats_diff_\(difficulty.rawValue)_losses"
        if isWin { ud.set(ud.integer(forKey: diffWKey) + 1, forKey: diffWKey) }
        else      { ud.set(ud.integer(forKey: diffLKey) + 1, forKey: diffLKey) }
        
        // per-category per-language
        if category != .random {
            let catWKey = "stats_\(language.rawValue)_cat_\(category.rawValue)_wins"
            let catLKey = "stats_\(language.rawValue)_cat_\(category.rawValue)_losses"
            if isWin { ud.set(ud.integer(forKey: catWKey) + 1, forKey: catWKey) }
            else      { ud.set(ud.integer(forKey: catLKey) + 1, forKey: catLKey) }
        }
        
        // streak
        let today = Calendar.current.startOfDay(for: Date())
        let lastKey = "stats_lastPlayedDate"
        let streakKey = "stats_streak"
        let currentStreak = ud.integer(forKey: streakKey)
        if let lastDate = ud.object(forKey: lastKey) as? Date {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 1 {
                ud.set(currentStreak + 1, forKey: streakKey)
            } else if diff > 1 {
                ud.set(1, forKey: streakKey)
            }
        } else {
            ud.set(1, forKey: streakKey)
        }
        ud.set(today, forKey: lastKey)
        
        // track languages played
        var langsPlayed = Set(ud.stringArray(forKey: "stats_langsPlayed") ?? [])
        langsPlayed.insert(language.rawValue)
        ud.set(Array(langsPlayed), forKey: "stats_langsPlayed")
        
        // track won categories
        if isWin {
            var wonCats = Set(ud.stringArray(forKey: "stats_wonCategories") ?? [])
            wonCats.insert(category.rawValue)
            ud.set(Array(wonCats), forKey: "stats_wonCategories")
        }
        
        // ─── Achievements ───
        if isWin {
            let totalWins = Language.allCases.reduce(0) { $0 + wins(lang: $1) }
            if totalWins >= 1 { ach("firstWin") }
            
            let streakNow = ud.integer(forKey: streakKey)
            if streakNow >= 3 { ach("streak3") }
            if streakNow >= 30 { ach("streak30") }
            
            if timeTaken <= 15 { ach("speedRun") }
            if difficulty == .nightmare { ach("nightmare") }
            if hintsUsed == 0 { ach("noHints") }
            if wrongGuesses == 0 { ach("silent") }
            if score >= 200 { ach("topScore") }
            
            if langsPlayed.count >= 5 { ach("polyglot") }
            
            let wonCats = Set(ud.stringArray(forKey: "stats_wonCategories") ?? [])
            let allRealCats = GameCategory.allCases.filter { $0 != .random }.map { $0.rawValue }
            if allRealCats.allSatisfy({ wonCats.contains($0) }) { ach("scholar") }
            
            if literaturesWins() >= 10 { ach("bookworm") }
            
            let hour = Calendar.current.component(.hour, from: Date())
            if hour >= 0 && hour < 4 { ach("nightOwl") }
        }
        
        return newAchievements
    }
    
    static func resetAll() {
        let ud = UserDefaults.standard

        // Per-language win/loss/best-score keys
        var keys: [String] = Language.allCases.flatMap { lang -> [String] in
            ["stats_\(lang.rawValue)_wins",
             "stats_\(lang.rawValue)_losses",
             "stats_\(lang.rawValue)_bestScore"]
        }

        // Per-language per-category win/loss keys
        for lang in Language.allCases {
            for cat in GameCategory.allCases {
                keys.append("stats_\(lang.rawValue)_cat_\(cat.rawValue)_wins")
                keys.append("stats_\(lang.rawValue)_cat_\(cat.rawValue)_losses")
            }
        }

        // Per-difficulty win/loss keys
        for diff in Difficulty.allCases {
            keys.append("stats_diff_\(diff.rawValue)_wins")
            keys.append("stats_diff_\(diff.rawValue)_losses")
        }

        // Global keys
        let globalKeys: [String] = [
            "stats_streak", "stats_lastPlayedDate", "stats_langsPlayed", "stats_wonCategories",
            "achievements", "hasSeenOnboarding", "soundEnabled", "hapticEnabled",
            "showTimer", "teacherQuotes", "username", "uiLanguage", "appTheme"
        ]
        keys.append(contentsOf: globalKeys)

        for k in keys { ud.removeObject(forKey: k) }
        AchievementManager.reset()
    }
}

// MARK: - Score Manager
@MainActor
public class ScoreManager: ObservableObject {
    public static let shared = ScoreManager()
    
    public let modelContainer: ModelContainer
    
    @Published public var uiLanguage: Language = .english {
        didSet { UserDefaults.standard.set(uiLanguage.rawValue, forKey: "uiLanguage") }
    }
    
    @Published public private(set) var currentStreak: Int = 0
    @Published public private(set) var highestStreak: Int = 0
    @Published public private(set) var totalWins: Int = 0
    @Published public private(set) var totalLosses: Int = 0
    
    private init() {
        if let savedRaw = UserDefaults.standard.string(forKey: "uiLanguage"),
           let savedLang = Language(rawValue: savedRaw) {
            self.uiLanguage = savedLang
        }
        
        modelContainer = Self.makeContainer()
        
        Task { @MainActor in
            self.recalculateStats()
        }
    }
    
    /// Tries to create the ModelContainer. If the schema has changed (e.g. new fields added),
    /// the old SQLite store is deleted and a fresh container is created.
    private static func makeContainer() -> ModelContainer {
        do {
            return try ModelContainer(for: GameSession.self)
        } catch {
            // Schema mismatch — wipe the stale store and start fresh.
            // Game history is lost but the app will not crash.
            let supportDir = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first
            
            if let dir = supportDir {
                let storeFiles = ["default.store", "default.store-shm", "default.store-wal"]
                for file in storeFiles {
                    try? FileManager.default.removeItem(at: dir.appendingPathComponent(file))
                }
            }
            
            do {
                return try ModelContainer(for: GameSession.self)
            } catch {
                fatalError("SwiftData init failed even after store reset: \(error.localizedDescription)")
            }
        }
    }

    
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
                    if currentStreakActive { streak += 1 }
                } else {
                    losses += 1
                    currentStreakActive = false
                }
            }
            
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
            print("Failed to fetch scores: \(error.localizedDescription)")
        }
    }
}
