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
    // Inject the ScoreManager immediately to initialize the SwiftData ModelContainer
    @StateObject private var scoreManager = ScoreManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Ensure the SwiftData container is passed to the entire View hierarchy globally
                .modelContainer(scoreManager.modelContainer)
                // Force dark mode to heavily emphasize the spooky "charcoal sketchbook" aesthetic
                .preferredColorScheme(.dark)
        }
    }
}
