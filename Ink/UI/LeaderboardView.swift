//
//  LeaderboardView.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI
import SwiftData

public struct LeaderboardView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @State private var filterLanguage: Language = .english
    
    // Uses @Query to natively fetch and sort GameSession records by score (iOS 17 standard)
    @Query(sort: \GameSession.score, order: .reverse) private var allSessions: [GameSession]
    
    public init() {}
    
    private var filteredSessions: [GameSession] {
        allSessions.filter { $0.language == filterLanguage.rawValue && $0.score > 0 }
    }
    
    private var inkColor: Color {
        colorScheme == .dark ? ThemeManager.Colors.graphiteGray : ThemeManager.Colors.ballpointBlue
    }
    
    public var body: some View {
        VStack {
            // Header mapped to the notebook setup
            HStack {
                Button(action: {
                    HapticService.shared.playPenStrike()
                    AudioService.shared.play(.penScratch)
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2.bold())
                        .foregroundColor(inkColor)
                        .padding()
                }
                Spacer()
                Text("LEADERBOARD")
                    .font(.custom("Marker Felt", size: 32).bold())
                    .sketchbookInkText()
                Spacer()
                // Placeholder balancing spacer
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.top, 20)
            
            // Language Filter Native Segmented Picker
            Picker("Language", selection: $filterLanguage) {
                ForEach(Language.allCases) { lang in
                    Text(lang.rawValue).tag(lang)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
            
            // Results List Frame
            if filteredSessions.isEmpty {
                Spacer()
                Text("No victorious records found\nfor this language.")
                    .font(.custom("Noteworthy", size: 24))
                    .sketchbookInkText(isError: true)
                    .multilineTextAlignment(.center)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(Array(filteredSessions.enumerated()), id: \.element.id) { index, session in
                            LeaderboardRow(rank: index + 1, session: session, inkColor: inkColor)
                        }
                    }
                    .padding(.horizontal, 30)
                }
            }
        }
        .sketchbookBackground()
    }
}

fileprivate struct LeaderboardRow: View {
    let rank: Int
    let session: GameSession
    let inkColor: Color
    
    var body: some View {
        HStack {
            Text("#\(rank)")
                .font(.custom("Noteworthy", size: 24).bold())
                .foregroundColor(ThemeManager.Colors.teacherRed)
                .frame(width: 50, alignment: .leading)
            
            VStack(alignment: .leading) {
                Text(session.word)
                    .font(.custom("Courier", size: 20).bold())
                    .sketchbookInkText()
                
                Text("\(session.difficulty) - \(session.date.formatted(date: .numeric, time: .shortened))")
                    .font(.custom("Noteworthy", size: 14))
                    .sketchbookInkText()
                    .opacity(0.7)
            }
            
            Spacer()
            
            Text("\(session.score) pts")
                .font(.custom("Marker Felt", size: 22))
                .sketchbookInkText()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .handDrawnStroke(color: inkColor, lineWidth: 1.5, jitter: 1.0)
        )
    }
}
