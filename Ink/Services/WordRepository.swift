//
//  WordRepository.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import Foundation

// MARK: - JSON Models (new flat format)

public struct WordEntry: Decodable {
    public let word: String
    public let category: String
    public let hint: String
    public let definition: String
}

public struct WordBank: Decodable {
    public let words: [WordEntry]
}

// MARK: - Word Repository
public actor WordRepository {
    public static let shared = WordRepository()
    
    private var bankCache: [String: [WordEntry]] = [:]
    
    private init() {}
    
    // MARK: - Fetch for Regular Game
    
    /// Fetch a random word. If category == .random, picks any category.
    /// Difficulty is derived from word length:
    ///   ≤5 chars = Easy, 6-7 = Medium, 8-9 = Hard, ≥10 = Nightmare
    public func fetchRandomWord(language: Language, difficulty: Difficulty, category: GameCategory = .random) -> Word {
        let entries = loadEntries(for: language)
        
        // Filter by category
        var pool: [WordEntry]
        if category == .random {
            pool = entries
        } else {
            pool = entries.filter { $0.category.lowercased() == category.rawValue }
            if pool.isEmpty { pool = entries } // fallback
        }
        
        // Filter by difficulty (word length)
        let filtered = pool.filter { matchesDifficulty($0.word, difficulty: difficulty) }
        let finalPool = filtered.isEmpty ? pool : filtered
        
        let entry = finalPool.randomElement() ?? WordEntry(word: "HANGMAN", category: "random", hint: "A classic word game.", definition: "A guessing game played with letters.")
        let resolvedCategory = GameCategory(rawValue: entry.category.lowercased()) ?? .random
        
        return Word(text: entry.word, language: language, category: resolvedCategory, hint: entry.hint, definition: entry.definition)
    }
    
    // MARK: - Fetch for Daily Challenge (deterministic)
    
    public func fetchDailyWord(language: Language, dateString: String) -> Word {
        let entries = loadEntries(for: language)
        guard !entries.isEmpty else {
            return Word(text: "HANGMAN", language: language, category: .random, hint: "A classic.", definition: "A word guessing game.")
        }
        let hash = abs((dateString + language.rawValue).hashValue)
        let entry = entries[hash % entries.count]
        let resolvedCategory = GameCategory(rawValue: entry.category.lowercased()) ?? .random
        return Word(text: entry.word, language: language, category: resolvedCategory, hint: entry.hint, definition: entry.definition)
    }
    
    // MARK: - Private Helpers
    
    private func matchesDifficulty(_ word: String, difficulty: Difficulty) -> Bool {
        let len = word.count
        switch difficulty {
        case .easy:      return len <= 5
        case .medium:    return len >= 6 && len <= 7
        case .hard:      return len >= 8 && len <= 9
        case .nightmare: return len >= 10
        }
    }
    
    private func loadEntries(for language: Language) -> [WordEntry] {
        let key = language.rawValue.lowercased()
        if let cached = bankCache[key] { return cached }
        
        guard let url = Bundle.main.url(forResource: "words_\(key)", withExtension: "json") else {
            print("Warning: words_\(key).json not found. Using emergency fallback.")
            return emergencyFallback()
        }
        
        do {
            let data = try Data(contentsOf: url)
            let bank = try JSONDecoder().decode(WordBank.self, from: data)
            bankCache[key] = bank.words
            return bank.words
        } catch {
            print("Failed to decode words_\(key).json: \(error.localizedDescription)")
            return emergencyFallback()
        }
    }
    
    private func emergencyFallback() -> [WordEntry] {
        return [
            WordEntry(word: "HANGMAN", category: "random", hint: "It's a classic word guessing game.", definition: "A word game where players guess letters to reveal a hidden word."),
            WordEntry(word: "SKETCHBOOK", category: "random", hint: "Artists use this to draw.", definition: "A book of blank paper for sketching or drawing."),
            WordEntry(word: "TEACHER", category: "random", hint: "Someone who educates students.", definition: "A professional who instructs students in an educational setting."),
            WordEntry(word: "PENCIL", category: "random", hint: "You write with this.", definition: "A writing instrument made of graphite enclosed in wood."),
            WordEntry(word: "LIBRARY", category: "literature", hint: "A place full of books.", definition: "A building or room containing collections of books for reading or borrowing.")
        ]
    }
}
