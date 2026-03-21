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
    
    public var alphabet: [Character] {
        switch self {
        case .english:
            return Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        case .turkish:
            return Array("ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ")
        case .azerbaijani:
            return Array("ABCÇDEƏFGĞHXİIJKQLMNOÖPRSŞTUÜVYZ")
        case .spanish:
            return Array("ABCDEFGHIJKLMNÑOPQRSTUVWXYZ")
        case .russian:
            return Array("АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ")
        }
    }
}

// MARK: - Word
public struct Word: Identifiable, Equatable {
    public let id: UUID
    public let text: String
    public let language: Language
    public let category: String
    
    public init(id: UUID = UUID(), text: String, language: Language, category: String) {
        self.id = id
        self.text = text.uppercased()
        self.language = language
        self.category = category
    }
}
