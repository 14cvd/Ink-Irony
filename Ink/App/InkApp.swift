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
    @State private var app: AppState

    init() {
        InkFonts.registerBundled()
        HapticService.shared.syncWithSettings()
        _app = State(initialValue: AppState())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(app)
                .modelContainer(ScoreManager.shared.modelContainer)
                .preferredColorScheme(app.theme.colorScheme)
                .tint(InkColor.ink)
        }
    }
}

struct RootView: View {
    @Environment(AppState.self) private var app
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    // UI tests launch with `-skipSplash YES` so their first tap reaches the app.
    @State private var showSplash = !UserDefaults.standard.bool(forKey: "skipSplash")

    var body: some View {
        @Bindable var app = app
        ZStack {
            Group {
                if app.hasOnboarded {
                    MainTabsView()
                } else {
                    FirstLaunchView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: app.hasOnboarded)

            if showSplash {
                SplashView {
                    withAnimation(.easeOut(duration: 0.22)) { showSplash = false }
                }
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 1.02)))
                .zIndex(1)
            }
        }
        .fullScreenCover(item: $app.playRequest) { request in
            PlayFlowView(request: request)
        }
    }
}

struct MainTabsView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        @Bindable var app = app
        VStack(spacing: 0) {
            Group {
                switch app.selectedTab {
                case .desk: DeskView()
                case .semesters: NavigationStack { SemestersView() }
                case .stickers: NavigationStack { StickersView() }
                case .report: NavigationStack { ReportCardView() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Rebuild the screens when the language changes, so every string follows it.
            .id(app.language)
            NotebookTabBar(selection: $app.selectedTab)
                .id(app.language)
        }
        .sheet(isPresented: $app.showSettings) { SettingsView() }
    }
}
