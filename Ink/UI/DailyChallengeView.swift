//
//  DailyChallengeView.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI

public struct DailyChallengeView: View {
    @Binding var path: NavigationPath
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var scoreManager = ScoreManager.shared
    
    @State private var dailyWord: Word?
    @State private var alreadyCompleted: Bool = false
    @State private var completedResult: DailyResult? = nil
    @State private var showGame: Bool = false
    
    private var lang: Language { scoreManager.uiLanguage }
    private var accentRed: Color { ThemeManager.Colors.accentRed(for: colorScheme) }
    private var inkColor: Color { ThemeManager.Colors.inkPrimary(for: colorScheme) }
    
    private var dateString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: Date())
    }
    
    private var localizedDate: String {
        let fmt = DateFormatter()
        fmt.locale = Locale.current
        fmt.dateFormat = "MMM dd"
        return fmt.string(from: Date()).uppercased()
    }
    
    private var storageKey: String { "daily_\(lang.rawValue)_\(dateString)" }
    
    public init(path: Binding<NavigationPath>) {
        self._path = path
    }
    
    public var body: some View {
        VStack(spacing: ThemeManager.Layout.spacingLG) {
            
            // ── Daily badge header ──
            HStack {
                Button(action: {
                    HapticService.shared.playPenStrike()
                    path.removeLast(path.count)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2.bold())
                        .foregroundColor(inkColor)
                        .padding()
                }
                Spacer()
            }
            
            VStack(spacing: ThemeManager.Layout.spacingMD) {
                // ⏰ DAILY EXAM badge
                HStack(spacing: 6) {
                    Text("⏰")
                    Text(LocalizationService.t("DAILY EXAM", lang: lang))
                        .font(ThemeManager.Typography.micro(for: colorScheme).bold())
                        .foregroundColor(accentRed)
                }
                .padding(.horizontal, ThemeManager.Layout.spacingMD)
                .padding(.vertical, ThemeManager.Layout.spacingSM)
                .background(
                    RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerSM)
                        .stroke(accentRed, style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                )
                
                // Date
                Text(localizedDate)
                    .font(.custom("Caveat-Bold", size: 32))
                    .foregroundColor(accentRed)
                
                // Subtitle
                Text(LocalizationService.t("One word. All players. Same chance.", lang: lang))
                    .font(ThemeManager.Typography.body(for: colorScheme))
                    .foregroundColor(inkColor.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, ThemeManager.Layout.spacingXL)
            }
            
            Spacer()
            
            if alreadyCompleted, let result = completedResult {
                // Already played today — show result summary
                CompletedResultView(result: result, language: lang, colorScheme: colorScheme)
            } else if showGame, let word = dailyWord {
                // Show the daily game
                DailyGameView(word: word, language: lang) { isWin, lives, time in
                    let result = DailyResult(isWin: isWin, livesLeft: lives, timeTaken: time, dateString: dateString)
                    saveResult(result)
                    withAnimation {
                        completedResult = result
                        alreadyCompleted = true
                        showGame = false
                    }
                    
                    // Submit to "leaderboard"
                    submitToLeaderboard(result)
                }
            } else {
                // Not yet played today
                VStack(spacing: ThemeManager.Layout.spacingMD) {
                    Text("📖")
                        .font(.system(size: 64))
                    
                    Button(action: {
                        HapticService.shared.playPenStrike()
                        AudioService.shared.play(.penScratch)
                        withAnimation { showGame = true }
                    }) {
                        Text(LocalizationService.t("START EXAM", lang: lang))
                            .frame(maxWidth: .infinity)
                    }
                    .doodleButtonStyle()
                    .padding(.horizontal, ThemeManager.Layout.spacingXL)
                }
            }
            
            Spacer()
            
            // ── Leaderboard ──
            DailyLeaderboardView(dateString: dateString, language: lang, colorScheme: colorScheme)
                .frame(maxHeight: 280)
        }
        .sketchbookBackground()
        .onAppear { loadState() }
    }
    
    private func loadState() {
        // Load daily word
        Task {
            let word = await WordRepository.shared.fetchDailyWord(language: lang, dateString: dateString)
            await MainActor.run { dailyWord = word }
        }
        
        // Check if already completed
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let result = try? JSONDecoder().decode(DailyResult.self, from: data) {
            completedResult = result
            alreadyCompleted = true
        }
    }
    
    private func saveResult(_ result: DailyResult) {
        if let data = try? JSONEncoder().encode(result) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func submitToLeaderboard(_ result: DailyResult) {
        let username = UserDefaults.standard.string(forKey: "username") ?? generateDefaultUsername()
        UserDefaults.standard.set(username, forKey: "username")
        
        let lbKey = "dlb_\(lang.rawValue)_\(dateString)_\(username)"
        let entry = LeaderboardEntry(username: username, isWin: result.isWin, timeTaken: result.timeTaken, livesLeft: result.livesLeft)
        if let data = try? JSONEncoder().encode(entry) {
            UserDefaults.standard.set(data, forKey: lbKey)
        }
    }
    
    private func generateDefaultUsername() -> String {
        let digits = String(format: "%04d", Int.random(in: 1000...9999))
        return "Student_\(digits)"
    }
}

// MARK: - Models
struct DailyResult: Codable {
    let isWin: Bool
    let livesLeft: Int
    let timeTaken: Int
    let dateString: String
}

struct LeaderboardEntry: Codable {
    let username: String
    let isWin: Bool
    let timeTaken: Int
    let livesLeft: Int
}

// MARK: - Completed Result View
private struct CompletedResultView: View {
    let result: DailyResult
    let language: Language
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: ThemeManager.Layout.spacingMD) {
            Text(result.isWin ? "🎓" : "📕")
                .font(.system(size: 48))
            
            Text(result.isWin
                ? LocalizationService.t("PASSED!", lang: language)
                : LocalizationService.t("FAILED.", lang: language))
                .font(.custom("Caveat-Bold", size: 36))
                .foregroundColor(result.isWin
                    ? ThemeManager.Colors.victoryGreen(for: colorScheme)
                    : ThemeManager.Colors.accentRed(for: colorScheme))
            
            HStack(spacing: ThemeManager.Layout.spacingMD) {
                VStack {
                    Text("\(result.timeTaken)s")
                        .font(.custom("Caveat-Bold", size: 24))
                        .foregroundColor(ThemeManager.Colors.statNumber(for: colorScheme))
                    Text(LocalizationService.t("Time", lang: language))
                        .font(ThemeManager.Typography.micro(for: colorScheme))
                        .foregroundColor(ThemeManager.Colors.inkPrimary(for: colorScheme).opacity(0.6))
                }
                VStack {
                    Text("\(result.livesLeft)")
                        .font(.custom("Caveat-Bold", size: 24))
                        .foregroundColor(ThemeManager.Colors.statNumber(for: colorScheme))
                    Text(LocalizationService.t("Lives", lang: language))
                        .font(ThemeManager.Typography.micro(for: colorScheme))
                        .foregroundColor(ThemeManager.Colors.inkPrimary(for: colorScheme).opacity(0.6))
                }
            }
            
            Text(LocalizationService.t("Come back tomorrow!", lang: language))
                .font(ThemeManager.Typography.body(for: colorScheme))
                .foregroundColor(ThemeManager.Colors.inkPrimary(for: colorScheme).opacity(0.6))
        }
    }
}

// MARK: - Daily Leaderboard View
private struct DailyLeaderboardView: View {
    let dateString: String
    let language: Language
    let colorScheme: ColorScheme
    
    @ObservedObject private var scoreManager = ScoreManager.shared
    
    private var entries: [LeaderboardEntry] {
        let prefix = "dlb_\(language.rawValue)_\(dateString)_"
        let ud = UserDefaults.standard
        return ud.dictionaryRepresentation().keys
            .filter { $0.hasPrefix(prefix) }
            .compactMap { key -> LeaderboardEntry? in
                guard let data = ud.data(forKey: key),
                      let entry = try? JSONDecoder().decode(LeaderboardEntry.self, from: data)
                else { return nil }
                return entry
            }
            .filter { $0.isWin }
            .sorted { $0.timeTaken < $1.timeTaken }
            .prefix(10)
            .map { $0 }
    }
    
    private var currentUsername: String {
        UserDefaults.standard.string(forKey: "username") ?? ""
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: ThemeManager.Layout.spacingSM) {
            Text(LocalizationService.t("TODAY'S CLASS", lang: language))
                .font(ThemeManager.Typography.micro(for: colorScheme).bold())
                .foregroundColor(ThemeManager.Colors.sectionLabel(for: colorScheme))
                .padding(.horizontal, ThemeManager.Layout.spacingXL)
            
            if entries.isEmpty {
                Text(LocalizationService.t("No classmates yet.", lang: language))
                    .font(ThemeManager.Typography.body(for: colorScheme))
                    .foregroundColor(ThemeManager.Colors.inkPrimary(for: colorScheme).opacity(0.5))
                    .padding(.horizontal, ThemeManager.Layout.spacingXL)
            } else {
                ScrollView {
                    VStack(spacing: ThemeManager.Layout.spacingXS) {
                        ForEach(Array(entries.enumerated()), id: \.offset) { idx, entry in
                            let isCurrent = entry.username == currentUsername
                            HStack {
                                Text("#\(idx + 1)")
                                    .font(ThemeManager.Typography.micro(for: colorScheme).bold())
                                    .foregroundColor(ThemeManager.Colors.accentRed(for: colorScheme))
                                    .frame(width: 30, alignment: .leading)
                                Text(entry.username)
                                    .font(ThemeManager.Typography.micro(for: colorScheme))
                                    .foregroundColor(ThemeManager.Colors.inkPrimary(for: colorScheme))
                                Spacer()
                                Text("\(entry.timeTaken)s")
                                    .font(ThemeManager.Typography.micro(for: colorScheme).bold())
                                    .foregroundColor(ThemeManager.Colors.accentRed(for: colorScheme))
                                Text("❤️×\(entry.livesLeft)")
                                    .font(ThemeManager.Typography.micro(for: colorScheme))
                                    .foregroundColor(ThemeManager.Colors.inkPrimary(for: colorScheme).opacity(0.6))
                            }
                            .padding(.horizontal, ThemeManager.Layout.spacingXL)
                            .padding(.vertical, ThemeManager.Layout.spacingXS)
                            .background(isCurrent ? ThemeManager.Colors.accentRed(for: colorScheme).opacity(0.08) : Color.clear)
                        }
                    }
                }
            }
        }
        .padding(.bottom, ThemeManager.Layout.spacingMD)
    }
}

// MARK: - Daily Game View (wraps a standard game but with daily badge)
private struct DailyGameView: View {
    let word: Word
    let language: Language
    let onComplete: (Bool, Int, Int) -> Void
    
    @StateObject private var viewModel = GameViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var scoreManager = ScoreManager.shared
    
    var body: some View {
        VStack {
            // Daily badge
            HStack(spacing: 4) {
                Text("⏰")
                Text(LocalizationService.t("DAILY EXAM", lang: language))
                    .font(ThemeManager.Typography.micro(for: colorScheme).bold())
                    .foregroundColor(ThemeManager.Colors.accentRed(for: colorScheme))
            }
            .padding(.horizontal, ThemeManager.Layout.spacingMD)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerSM)
                    .stroke(ThemeManager.Colors.accentRed(for: colorScheme), style: StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
            )
            .padding(.top, ThemeManager.Layout.spacingMD)
            
            // Standard game area reuse
            GameView(word: word, difficulty: .medium) { won, lives, time, hints, wrongs in
                onComplete(won, lives, time)
            }
        }
        .sketchbookBackground()
    }
}
