//
//  OnboardingView.swift
//  Ink
//
//  First day: an enrollment form on notebook paper. Name, language of
//  instruction and the teacher's manner, then a signature and the ENROLLED
//  stamp, and the player lands straight in Kindergarten word 1.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var app
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("username") private var username = ""
    @State private var signed = false
    @FocusState private var nameFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    InkLogo(size: 30)
                    Spacer()
                    Overline(text: L10n.t("onboarding.firstDay"))
                }
                TeacherRow(text: bubble, mood: signed || app.tone == .gentle ? .pleased : .calm, avatarSize: 52)
                form
                    .padding(.top, 10)
            }
            .padding(.horizontal, InkSpace.screenMargin)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            Button(action: sign) {
                Label(L10n.t("onboarding.sign"), systemImage: "signature")
            }
            .buttonStyle(.inkPrimary)
            .disabled(signed)
            .padding(.horizontal, InkSpace.screenMargin)
            .padding(.vertical, 10)
            .background(InkColor.paper.opacity(0.95))
            .accessibilityIdentifier("onboarding.sign")
        }
        .notebookPaper()
        .onAppear {
            // First launch ever: follow the device language. v1 players keep theirs.
            if UserDefaults.standard.string(forKey: "uiLanguage") == nil {
                app.language = Language.deviceDefault
            }
        }
    }

    // MARK: Form

    private var form: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(L10n.t("onboarding.form"))
                    .font(.inkDisplay(32, relativeTo: .title))
                    .foregroundStyle(InkColor.ink)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Text("No. 0001")
                    .font(.inkUI(11, relativeTo: .caption2))
                    .foregroundStyle(InkColor.secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Overline(text: L10n.t("onboarding.nameLabel"))
                TextField(L10n.t("onboarding.namePlaceholder"), text: $username)
                    .font(.inkDisplay(28, relativeTo: .title2))
                    .foregroundStyle(InkColor.inkDrop)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .focused($nameFocused)
                    .frame(minHeight: 40)
                    .overlay(alignment: .bottom) { Rectangle().fill(InkColor.ink).frame(height: 2) }
                    .disabled(signed)
                    .accessibilityIdentifier("onboarding.name")
            }

            VStack(alignment: .leading, spacing: 6) {
                Overline(text: L10n.t("onboarding.langLabel"))
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], alignment: .leading, spacing: 4) {
                    ForEach(Language.allCases) { language in
                        CheckRow(title: language.nativeName, checked: app.language == language, identifier: "onboarding.lang.\(language.rawValue)") {
                            app.language = language
                        }
                        .disabled(signed)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Overline(text: L10n.t("onboarding.toneLabel"))
                HStack(spacing: 8) {
                    ToneCard(title: L10n.t("settings.strict"), subtitle: L10n.t("onboarding.strictSub"), selected: app.tone == .strict, identifier: "onboarding.tone.strict") {
                        app.tone = .strict
                    }
                    ToneCard(title: L10n.t("settings.gentle"), subtitle: L10n.t("onboarding.gentleSub"), selected: app.tone == .gentle, identifier: "onboarding.tone.gentle") {
                        app.tone = .gentle
                    }
                }
                .disabled(signed)
            }

            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    SignatureShape()
                        .trim(from: 0, to: signed ? 1 : 0)
                        .stroke(InkColor.inkDrop, style: StrokeStyle(lineWidth: 2.6, lineCap: .round, lineJoin: .round))
                        .frame(height: 40)
                        .animation(reduceMotion ? nil : .easeOut(duration: 0.6), value: signed)
                    Rectangle().fill(InkColor.ink).frame(height: 2)
                    Text(L10n.t("onboarding.signature"))
                        .font(.inkUI(11, relativeTo: .caption2))
                        .foregroundStyle(InkColor.secondary)
                }
                VStack(alignment: .trailing, spacing: 2) {
                    Text(Date().formatted(.dateTime.day(.twoDigits).month(.twoDigits).year(.twoDigits)))
                        .font(.inkDisplay(22, relativeTo: .body))
                        .foregroundStyle(InkColor.inkDrop)
                    Text(L10n.t("onboarding.date"))
                        .font(.inkUI(11, relativeTo: .caption2))
                        .foregroundStyle(InkColor.secondary)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(L10n.t("onboarding.signature"))
        }
        .padding(.leading, 40)
        .padding(.trailing, 16)
        .padding(.vertical, 18)
        .background(alignment: .leading) {
            ZStack(alignment: .leading) {
                InkColor.sheet
                Rectangle().fill(InkColor.marginLine).frame(width: 2).padding(.leading, 26)
                VStack {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle().fill(InkColor.paper).overlay(Circle().strokeBorder(InkColor.secondary, lineWidth: 1.5))
                            .frame(width: 10, height: 10)
                            .frame(maxHeight: .infinity)
                    }
                }
                .padding(.vertical, 28)
                .padding(.leading, 8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .inkCard(radius: 6, raised: true, tilt: -0.6, fill: .clear)
        .overlay(alignment: .top) { Tape().offset(y: -12) }
        .overlay {
            if signed {
                RubberStamp(text: L10n.t("onboarding.enrolled"), color: InkColor.teacher)
                    .rotationEffect(.degrees(-6))
                    .accessibilityIdentifier("onboarding.enrolled")
            }
        }
    }

    // MARK: Behaviour

    private var bubble: String {
        let name = username.trimmingCharacters(in: .whitespaces)
        if signed {
            if app.tone == .gentle { return L10n.t("onboarding.signed.gentle") }
            return name.isEmpty ? L10n.t("onboarding.signed.noName") : L10n.t("onboarding.signed.strict", name)
        }
        return L10n.t(app.tone == .gentle ? "onboarding.bubble.gentle" : "onboarding.bubble.strict")
    }

    private func sign() {
        nameFocused = false
        username = username.trimmingCharacters(in: .whitespaces)
        HapticService.shared.playSuccessPulse()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { signed = true }
        // Let the signature and the stamp land, then straight to Kindergarten word 1.
        DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0.4 : 1.4)) {
            app.hasOnboarded = true
            app.playNextSemesterWord()
        }
    }
}

/// A hand-drawn tick box with a red pen check.
private struct CheckRow: View {
    let title: String
    let checked: Bool
    let identifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 3)
                    .strokeBorder(InkColor.ink, lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .overlay {
                        if checked {
                            Image(systemName: "checkmark")
                                .font(.system(size: 15, weight: .heavy))
                                .foregroundStyle(InkColor.teacher)
                                .offset(x: 2, y: -3)
                        }
                    }
                Text(title)
                    .font(.inkUI(14, weight: checked ? .bold : .regular, relativeTo: .callout))
                    .foregroundStyle(checked ? InkColor.teacher : InkColor.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(checked ? .isSelected : [])
        .accessibilityIdentifier(identifier)
    }
}

private struct ToneCard: View {
    let title: String
    let subtitle: String
    let selected: Bool
    let identifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.inkDisplay(22, relativeTo: .headline))
                Text(subtitle)
                    .font(.inkUI(11, relativeTo: .caption2))
                    .foregroundStyle(InkColor.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(selected ? InkColor.teacher : InkColor.ink)
            .padding(10)
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selected ? InkColor.teacher.opacity(0.08) : .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(selected ? InkColor.teacher : InkColor.ink.opacity(0.35), style: StrokeStyle(lineWidth: 2, dash: selected ? [] : [5, 3]))
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
        .accessibilityIdentifier(identifier)
    }
}

/// A quick looping signature, drawn on with `trim`.
private struct SignatureShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = min(rect.width, 180) / 180, sy = rect.height / 40
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy) }
        var path = Path()
        path.move(to: p(4, 30))
        path.addCurve(to: p(24, 22), control1: p(14, 6), control2: p(22, 6))
        path.addCurve(to: p(44, 14), control1: p(26, 36), control2: p(34, 10))
        path.addCurve(to: p(58, 26), control1: p(52, 18), control2: p(46, 32))
        path.addCurve(to: p(84, 20), control1: p(70, 18), control2: p(74, 8))
        path.addCurve(to: p(112, 18), control1: p(92, 30), control2: p(100, 14))
        path.addCurve(to: p(150, 16), control1: p(126, 22), control2: p(132, 30))
        path.addCurve(to: p(176, 10), control1: p(160, 8), control2: p(168, 14))
        return path
    }
}
