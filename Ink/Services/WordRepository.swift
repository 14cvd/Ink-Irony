//
//  WordRepository.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import Foundation

public struct WordCategory: Decodable {
    public let name: String
    public let words: [String]
}

public struct LocalizedWordBank: Decodable {
    // Top-level key is the target Difficulty: "Easy", "Medium", "Hard", "Nightmare"
    public let difficulties: [String: [WordCategory]]
}

// MARK: - Word Repository
public actor WordRepository {
    public static let shared = WordRepository()
    
    // In-memory cache to prevent repeatedly decoding massive localized JSON files
    private var wordCache: [String: LocalizedWordBank] = [:]
    
    private init() {}
    
    /// Loads a dynamically localized word mathematically bound to the selected Difficulty
    public func fetchRandomWord(language: Language, difficulty: Difficulty) -> Word {
        let bank = getBank(for: language)
        
        // Find the dictionary mapping strictly associated with the current tier (or safely fallback)
        let difficultyCategories = bank.difficulties[difficulty.rawValue] ?? bank.difficulties["Medium"]!
        
        // Securely pick a randomized subject category out of the available ones for this specific tier
        let randomCategory = difficultyCategories.randomElement()!
        
        // Roll for a localized term
        let randomWordText = randomCategory.words.randomElement()!
        
        return Word(
            text: randomWordText.uppercased(), // Ensures visual consistency
            language: language,
            category: randomCategory.name
        )
    }
    
    // Parses and securely caches the JSON payload synchronously in-memory
    private func getBank(for language: Language) -> LocalizedWordBank {
        let fileKey = language.rawValue.lowercased() // "en", "tr", "az", "es", "ru"
        
        if let cached = wordCache[fileKey] {
            return cached
        }
        
        // Retrieve JSON payload exactly matching the bundle resource structure
        guard let url = Bundle.main.url(forResource: "words_\(fileKey)", withExtension: "json") else {
            print("Warning: words_\(fileKey).json not found strictly. Using emergency fallback.")
            return generateEmergencyFallback(for: language)
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(LocalizedWordBank.self, from: data)
            wordCache[fileKey] = decoded
            return decoded
        } catch {
            print("Failed to decode JSON cleanly words_\(fileKey).json: \(error.localizedDescription)")
            return generateEmergencyFallback(for: language)
        }
    }
    
    // Fail-safe mechanism ensures the hangman flow never completely breaks if localization files go missing
    private func generateEmergencyFallback(for language: Language) -> LocalizedWordBank {
        return LocalizedWordBank(difficulties: [
            "Easy": [WordCategory(name: "Fallback", words: ["CAT", "DOG"])],
            "Medium": [WordCategory(name: "Emergency", words: ["SKETCHBOOK", "HANGMAN", "PUNISHMENT", "ERASER"])],
            "Hard": [WordCategory(name: "Fallback", words: ["ASTRONOMY", "PHYSICS"])],
            "Nightmare": [WordCategory(name: "Fallback", words: ["SYCOPHANT", "OBFUSCATE"])]
        ])
    }
}
