//
//  SettingsView.swift
//  Ink
//

import SwiftUI
import SwiftData
import InkData

struct SettingsView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage(HapticService.settingKey) private var hapticEnabled = true
    @AppStorage("username") private var username = ""
    @State private var confirmReset = false

    var body: some View {
        @Bindable var app = app
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text(L10n.t("settings.title"))
                        .font(.inkDisplay(34, relativeTo: .largeTitle))
                        .foregroundStyle(InkColor.ink)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    InkIconButton(systemName: "xmark", label: L10n.t("common.close"), identifier: "settings.close") { dismiss() }
                }

                section(L10n.t("settings.language")) {
                    Picker(L10n.t("settings.language"), selection: $app.language) {
                        ForEach(Language.allCases) { Text($0.nativeName).tag($0) }
                    }
                    .pickerStyle(.menu)
                    .tint(InkColor.teacher)
                    .accessibilityIdentifier("settings.language")
                    note(L10n.t("settings.languageNote"))
                }

                section(L10n.t("settings.teacher")) {
                    Picker(L10n.t("settings.teacher"), selection: $app.tone) {
                        Text(L10n.t("settings.strict")).tag(TeacherTone.strict)
                        Text(L10n.t("settings.gentle")).tag(TeacherTone.gentle)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("settings.tone")
                    note(app.teacherLine(.desk))
                }

                section(L10n.t("settings.theme")) {
                    Picker(L10n.t("settings.theme"), selection: $app.theme) {
                        Text(L10n.t("settings.themeSystem")).tag(InkThemeChoice.system)
                        Text(L10n.t("settings.themePaper")).tag(InkThemeChoice.light)
                        Text(L10n.t("settings.themeChalk")).tag(InkThemeChoice.dark)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("settings.theme")
                }

                section(L10n.t("settings.feel")) {
                    Toggle(L10n.t("settings.sound"), isOn: $soundEnabled)
                        .accessibilityIdentifier("settings.sound")
                    Toggle(L10n.t("settings.haptics"), isOn: $hapticEnabled)
                        .accessibilityIdentifier("settings.haptics")
                        .onChange(of: hapticEnabled) { HapticService.shared.syncWithSettings() }
                }
                .tint(InkColor.correct)

                section(L10n.t("settings.name")) {
                    TextField(L10n.t("result.student"), text: $username)
                        .font(.inkDisplay(22, relativeTo: .body))
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                        .accessibilityIdentifier("settings.name")
                }

                Button(role: .destructive) {
                    confirmReset = true
                } label: {
                    Label(L10n.t("settings.reset"), systemImage: "trash")
                        .font(.inkUI(14, weight: .bold, relativeTo: .callout))
                        .foregroundStyle(InkColor.teacher)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(RoundedRectangle(cornerRadius: InkRadius.button).strokeBorder(InkColor.teacher, style: StrokeStyle(lineWidth: 2, dash: [6, 4])))
                }
                .accessibilityIdentifier("settings.reset")
            }
            .font(.inkUI(15, relativeTo: .body))
            .foregroundStyle(InkColor.ink)
            .padding(InkSpace.screenMargin)
        }
        .notebookPaper(ruled: false)
        .preferredColorScheme(app.theme.colorScheme)
        .alert(L10n.t("settings.resetTitle"), isPresented: $confirmReset) {
            Button(L10n.t("settings.resetConfirm"), role: .destructive) {
                try? context.delete(model: GameSession.self)
                try? context.save()
                app.resetProgress()
                ScoreManager.shared.recalculateStats()
            }
            Button(L10n.t("common.cancel"), role: .cancel) {}
        } message: {
            Text(L10n.t("settings.resetMessage"))
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Overline(text: title)
            VStack(alignment: .leading, spacing: 10) { content() }
                .padding(14)
                .inkCard(radius: 14)
        }
    }

    private func note(_ text: String) -> some View {
        Text(text)
            .font(.inkVoice(13, relativeTo: .footnote))
            .foregroundStyle(InkColor.secondary)
    }
}
