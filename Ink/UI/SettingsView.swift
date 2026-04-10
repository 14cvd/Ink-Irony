//
//  SettingsView.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI

public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var scoreManager = ScoreManager.shared
    
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    @AppStorage("hapticEnabled") private var hapticEnabled: Bool = true
    @AppStorage("showTimer") private var showTimer: Bool = true
    @AppStorage("teacherQuotes") private var teacherQuotes: Bool = true
    @AppStorage("username") private var username: String = ""
    
    @State private var showResetAlert: Bool = false
    
    private var lang: Language { scoreManager.uiLanguage }
    private var inkColor: Color { ThemeManager.Colors.inkPrimary(for: colorScheme) }
    private var accentRed: Color { ThemeManager.Colors.accentRed(for: colorScheme) }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    HapticService.shared.playPenStrike()
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2.bold())
                        .foregroundColor(inkColor)
                        .padding()
                }
                Spacer()
                Text(LocalizationService.t("SETTINGS", lang: lang))
                    .font(ThemeManager.Typography.h1(for: colorScheme))
                    .sketchbookInkText()
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.top, 12)
            
            ScrollView {
                VStack(spacing: ThemeManager.Layout.spacingLG) {
                    
                    // ── APPEARANCE ──
                    SettingsSection(title: LocalizationService.t("APPEARANCE", lang: lang)) {
                        SettingsToggleRow(
                            label: LocalizationService.t("Dark Mode", lang: lang),
                            isOn: Binding(
                                get: { themeManager.appTheme == .dark },
                                set: { _ in
                                    HapticService.shared.playPenStrike()
                                    themeManager.toggleTheme()
                                }
                            )
                        )
                    }
                    
                    // ── SOUND & HAPTICS ──
                    SettingsSection(title: LocalizationService.t("SOUND & HAPTICS", lang: lang)) {
                        SettingsToggleRow(
                            label: LocalizationService.t("Sound FX", lang: lang),
                            isOn: $soundEnabled
                        )
                        
                        Divider()
                            .background(ThemeManager.Colors.divider(for: colorScheme))
                            .padding(.horizontal, ThemeManager.Layout.spacingMD)
                        
                        SettingsToggleRow(
                            label: LocalizationService.t("Haptic Feedback", lang: lang),
                            isOn: $hapticEnabled
                        )
                    }
                    
                    // ── GAME ──
                    SettingsSection(title: LocalizationService.t("GAME", lang: lang)) {
                        SettingsToggleRow(
                            label: LocalizationService.t("Show Timer", lang: lang),
                            isOn: $showTimer
                        )
                        
                        Divider()
                            .background(ThemeManager.Colors.divider(for: colorScheme))
                            .padding(.horizontal, ThemeManager.Layout.spacingMD)
                        
                        SettingsToggleRow(
                            label: LocalizationService.t("Teacher Quotes", lang: lang),
                            isOn: $teacherQuotes
                        )
                    }
                    
                    // ── ACCOUNT ──
                    SettingsSection(title: LocalizationService.t("ACCOUNT", lang: lang)) {
                        HStack {
                            Text(LocalizationService.t("Username", lang: lang))
                                .font(ThemeManager.Typography.body(for: colorScheme))
                                .foregroundColor(inkColor)
                            Spacer()
                            TextField("Student_...", text: $username)
                                .font(ThemeManager.Typography.body(for: colorScheme))
                                .foregroundColor(accentRed)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: 150)
                                .submitLabel(.done)
                        }
                        .padding(ThemeManager.Layout.spacingMD)
                    }
                    
                    // ── DANGER ZONE ──
                    SettingsSection(title: LocalizationService.t("DANGER ZONE", lang: lang)) {
                        Button(action: {
                            HapticService.shared.playErrorPulse()
                            showResetAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(accentRed)
                                Text(LocalizationService.t("RESET PROGRESS", lang: lang))
                                    .font(ThemeManager.Typography.body(for: colorScheme))
                                    .foregroundColor(accentRed)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(accentRed.opacity(0.6))
                            }
                            .padding(ThemeManager.Layout.spacingMD)
                        }
                    }
                    .padding(.bottom, ThemeManager.Layout.spacingMajor)
                }
                .padding(.horizontal, ThemeManager.Layout.spacingXL)
                .padding(.top, ThemeManager.Layout.spacingMD)
            }
        }
        .sketchbookBackground()
        .alert(
            LocalizationService.t("RESET PROGRESS", lang: lang),
            isPresented: $showResetAlert,
            actions: {
                Button(LocalizationService.t("Reset", lang: lang), role: .destructive) {
                    StatsManager.resetAll()
                    ScoreManager.shared.recalculateStats()
                }
                Button(LocalizationService.t("Cancel", lang: lang), role: .cancel) {}
            },
            message: {
                Text(LocalizationService.t("Reset all progress? This cannot be undone.", lang: lang))
            }
        )
    }
}

// MARK: - Settings Section
private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(ThemeManager.Typography.micro(for: colorScheme).bold())
                .foregroundColor(ThemeManager.Colors.sectionLabel(for: colorScheme))
                .padding(.horizontal, ThemeManager.Layout.spacingMD)
                .padding(.bottom, ThemeManager.Layout.spacingXS)
            
            VStack(spacing: 0) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: ThemeManager.Layout.cornerMD)
                    .handDrawnStroke(color: ThemeManager.Colors.inkPrimary(for: colorScheme).opacity(0.2), lineWidth: 1.5, jitter: 0.5)
            )
        }
    }
}

// MARK: - Settings Toggle Row
private struct SettingsToggleRow: View {
    let label: String
    @Binding var isOn: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            Text(label)
                .font(ThemeManager.Typography.body(for: colorScheme))
                .foregroundColor(ThemeManager.Colors.inkPrimary(for: colorScheme))
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(ThemeManager.Colors.toggleOnColor(for: colorScheme))
        }
        .padding(ThemeManager.Layout.spacingMD)
    }
}
