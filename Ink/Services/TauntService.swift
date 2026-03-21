//
//  TauntService.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import Foundation

// MARK: - Taunt Service
public actor TauntService {
    public static let shared = TauntService()
    
    // Securely pull from Info.plist to avoid hardcoded secrets in the repo
    private static var hasWarnedMissingKey = false
    
    private var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "ANTHROPIC_API_KEY") as? String, !key.isEmpty else {
            if !Self.hasWarnedMissingKey {
                print("Warning: ANTHROPIC_API_KEY not found in Info.plist")
                Self.hasWarnedMissingKey = true
            }
            return ""
        }
        return key
    }
    
    private let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!
    
    // Rate Limiting & Offline Handling
    private var lastRequestTime: Date = .distantPast
    private let rateLimitInterval: TimeInterval = 2.0 // Minimum seconds between API calls
    
    // Cache for generated taunts to reuse when offline/rate-limited
    private var cachedTaunts: [String: [String]] = [:]
    
    // Offline Fallback Arrays - Exactly 10 taunts per language
    private let fallbackTauntsEN: [String] = [
        "Are you even trying?", "My grandmother guesses better.", "That was pathetic.",
        "Drawing the noose tighter...", "Did you skip school?", "A step closer to the gallows.",
        "Is that your best?", "You're embarrassing yourself.", "Truly abysmal.", "Hopeless."
    ]
    
    private let fallbackTauntsES: [String] = [
        "¿Siquiera lo intentas?", "Mi abuela adivina mejor.", "Eso fue patético.",
        "Apretando el nudo...", "¿Faltaste a la escuela?", "Un paso hacia la soga.",
        "¿Es lo mejor que tienes?", "Estás dando vergüenza.", "Verdaderamente abismal.", "Sin esperanza."
    ]
    
    private let fallbackTauntsRU: [String] = [
        "Ты вообще стараешься?", "Моя бабушка лучше угадывает.", "Это было жалко.",
        "Петля затягивается...", "Ты прогуливал школу?", "Шаг к виселице.",
        "Это твой максимум?", "Ты позоришься.", "Просто ужасно.", "Безнадежно."
    ]
    
    private let fallbackTauntsTR: [String] = [
        "Hiç çabalıyor musun?", "Ninem bile daha iyi bilir.", "Bu çok acınasıydı.",
        "İlmek daralıyor...", "Okulu mu astın?", "Darağacına bir adım daha.",
        "En iyisi bu mu?", "Kendini utandırıyorsun.", "Gerçekten berbat.", "Umutsuz vaka."
    ]
    
    private let fallbackTauntsAZ: [String] = [
        "Heç cəhd edirsən?", "Nənəm daha yaxşı tapır.", "Bu çox acınacaqlı idi.",
        "İlmək daralır...", "Məktəbdən qaçmısan?", "Dar ağacına bir addım.",
        "Ən yaxşın budur?", "Özünü biabır edirsən.", "Həqiqətən bərbat.", "Ümidsiz vəziyyət."
    ]
    
    private init() {}
    
    // MARK: - Public Fetch Method
    
    /// Fetches a snarky taunt dynamically contextualized by the player state
    public func fetchTaunt(language: Language, wrongCount: Int, difficulty: Difficulty) async -> String {
        // Enforce rate limiting strictly, and drop safely to fallback if no key is supplied
        let now = Date()
        if now.timeIntervalSince(lastRequestTime) < rateLimitInterval || apiKey.isEmpty {
            return getOfflineTaunt(for: language)
        }
        
        lastRequestTime = now
        
        do {
            let apiTaunt = try await fetchTauntFromClaude(language: language, wrongCount: wrongCount, difficulty: difficulty)
            cacheTaunt(apiTaunt, for: language)
            return apiTaunt
        } catch {
            print("Claude API Failed/Offline: \(error.localizedDescription). Using fallback.")
            return getOfflineTaunt(for: language)
        }
    }
    
    // MARK: - API Call & Fallbacks
    
    private func fetchTauntFromClaude(language: Language, wrongCount: Int, difficulty: Difficulty) async throws -> String {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        let systemPrompt = "You are the 'Savage AI', a snarky, merciless hangman game announcer. Your goal is to mock the player for guessing wrong. Keep your response under 20 words. No emojis. Match the requested language perfectly. Sound like a harsh teacher."
        let userPrompt = "The player made wrong guess number \(wrongCount) on \(difficulty.rawValue) difficulty. Taunt them in \(language.rawValue)."
        
        // Claude Haiku is explicitly fast and cheap for this real-time gaming scenario
        let body: [String: Any] = [
            "model": "claude-3-5-haiku-20241022",
            "max_tokens": 50,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": userPrompt]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let json = try JSONDecoder().decode(ClaudeResponse.self, from: data)
        guard let tauntText = json.content.first?.text else {
            throw URLError(.cannotParseResponse)
        }
        
        return tauntText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func getOfflineTaunt(for language: Language) -> String {
        // Option to draw securely from the cache to keep taunts varied without pinging the API repeatedly
        if let cached = cachedTaunts[language.id], !cached.isEmpty, Bool.random() {
            return cached.randomElement()!
        }
        
        switch language {
        case .english: return fallbackTauntsEN.randomElement()!
        case .spanish: return fallbackTauntsES.randomElement()!
        case .russian: return fallbackTauntsRU.randomElement()!
        case .turkish: return fallbackTauntsTR.randomElement()!
        case .azerbaijani: return fallbackTauntsAZ.randomElement()!
        }
    }
    
    private func cacheTaunt(_ taunt: String, for language: Language) {
        var tauntsForLang = cachedTaunts[language.id] ?? []
        // Cap cache limit gracefully to prevent memory leaks over thousands of games
        if tauntsForLang.count >= 100 {
            tauntsForLang.removeFirst()
        }
        tauntsForLang.append(taunt)
        cachedTaunts[language.id] = tauntsForLang
    }
}

// MARK: - API Response Models
fileprivate struct ClaudeResponse: Decodable {
    let content: [ClaudeContent]
}

fileprivate struct ClaudeContent: Decodable {
    let type: String
    let text: String
}
