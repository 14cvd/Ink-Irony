//
//  InkApp.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI
import SwiftData

@main
struct InkApp: App {
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(scoreManager.modelContainer)
                // Theme driven by user preference — no hardcoded .dark
                .preferredColorScheme(themeManager.preferredColorScheme)
                .animation(.easeInOut(duration: 0.25), value: themeManager.appThemeRaw)
        }
    }
}
