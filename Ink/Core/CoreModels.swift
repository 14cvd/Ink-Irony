//
//  CoreModels.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import Foundation

// MARK: - Game State
public enum GameState: Equatable {
    case idle
    case inProgress
    case won
    case lost
}

// MARK: - Difficulty
public enum Difficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case nightmare = "Nightmare"
    
    public var id: String { self.rawValue }
    
    public var lives: Int {
        switch self {
        case .easy: return 8
        case .medium: return 6
        case .hard: return 4
        case .nightmare: return 3
        }
    }
    
    public var timerSeconds: Int? {
        switch self {
        case .easy: return nil
        case .medium: return 90
        case .hard: return 60
        case .nightmare: return 45
        }
    }
}

// MARK: - Language
public enum Language: String, CaseIterable, Identifiable {
    case english = "EN"
    case turkish = "TR"
    case azerbaijani = "AZ"
    case spanish = "ES"
    case russian = "RU"
    
    public var id: String { self.rawValue }
    
    /// Lower-case code used for content files (`words_en.json`, `teacher_en.json`).
    public var code: String { rawValue.lowercased() }

    /// Locale for case mapping, so Turkish and Azerbaijani i/İ and ı/I stay distinct.
    public var locale: Locale { Locale(identifier: code) }

    /// The language's own name, shown in pickers.
    public var nativeName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        case .azerbaijani: return "Azərbaycanca"
        case .spanish: return "Español"
        case .russian: return "Русский"
        }
    }

    /// The device language if the game supports it, English otherwise.
    public static var deviceDefault: Language {
        let code = Locale.preferredLanguages.first.map { String($0.prefix(2)).uppercased() } ?? "EN"
        return Language(rawValue: code) ?? .english
    }

    public var alphabet: [Character] {
        switch self {
        case .english:
            return Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        case .turkish:
            return Array("ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ")
        case .azerbaijani:
            return Array("ABCÇDEƏFGĞHXIİJKQLMNOÖPRSŞTUÜVYZ")
        case .spanish:
            return Array("ABCDEFGHIJKLMNÑOPQRSTUVWXYZ")
        case .russian:
            return Array("АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ")
        }
    }
}

// MARK: - Game Category
public enum GameCategory: String, CaseIterable, Identifiable {
    case movies = "movies"
    case science = "science"
    case geography = "geography"
    case food = "food"
    case literature = "literature"
    case sports = "sports"
    case music = "music"
    case random = "random"
    
    public var id: String { self.rawValue }
    
    /// Ink icon for the topic (v2 does not use the emoji).
    public var symbol: String {
        switch self {
        case .movies: return "film"
        case .science: return "atom"
        case .geography: return "globe.europe.africa"
        case .food: return "fork.knife"
        case .literature: return "book"
        case .sports: return "figure.run"
        case .music: return "music.note"
        case .random: return "dice"
        }
    }

    public var emoji: String {
        switch self {
        case .movies: return "🎬"
        case .science: return "🔬"
        case .geography: return "🌍"
        case .food: return "🍕"
        case .literature: return "📚"
        case .sports: return "⚽"
        case .music: return "🎵"
        case .random: return "🎲"
        }
    }
    
    /// Localized display name
    public func displayName(for language: Language) -> String {
        switch self {
        case .movies:
            switch language {
            case .english: return "Movies"
            case .turkish: return "Filmler"
            case .azerbaijani: return "Filmlər"
            case .spanish: return "Películas"
            case .russian: return "Фильмы"
            }
        case .science:
            switch language {
            case .english: return "Science"
            case .turkish: return "Bilim"
            case .azerbaijani: return "Elm"
            case .spanish: return "Ciencia"
            case .russian: return "Наука"
            }
        case .geography:
            switch language {
            case .english: return "Geography"
            case .turkish: return "Coğrafya"
            case .azerbaijani: return "Coğrafiya"
            case .spanish: return "Geografía"
            case .russian: return "География"
            }
        case .food:
            switch language {
            case .english: return "Food"
            case .turkish: return "Yemek"
            case .azerbaijani: return "Yemək"
            case .spanish: return "Comida"
            case .russian: return "Еда"
            }
        case .literature:
            switch language {
            case .english: return "Literature"
            case .turkish: return "Edebiyat"
            case .azerbaijani: return "Ədəbiyyat"
            case .spanish: return "Literatura"
            case .russian: return "Литература"
            }
        case .sports:
            switch language {
            case .english: return "Sports"
            case .turkish: return "Spor"
            case .azerbaijani: return "İdman"
            case .spanish: return "Deportes"
            case .russian: return "Спорт"
            }
        case .music:
            switch language {
            case .english: return "Music"
            case .turkish: return "Müzik"
            case .azerbaijani: return "Musiqi"
            case .spanish: return "Música"
            case .russian: return "Музыка"
            }
        case .random:
            switch language {
            case .english: return "Random"
            case .turkish: return "Karışık"
            case .azerbaijani: return "Qarışıq"
            case .spanish: return "Aleatorio"
            case .russian: return "Случайно"
            }
        }
    }
}

// MARK: - Word
public struct Word: Identifiable, Equatable {
    public let id: UUID
    public let text: String
    public let language: Language
    public let category: GameCategory
    public let hint: String
    public let definition: String
    
    public init(
        id: UUID = UUID(),
        text: String,
        language: Language,
        category: GameCategory = .random,
        hint: String = "",
        definition: String = ""
    ) {
        self.id = id
        self.text = text.uppercased(with: language.locale)
        self.language = language
        self.category = category
        self.hint = hint
        self.definition = definition
    }
}
