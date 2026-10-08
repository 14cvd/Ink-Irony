//
//  IntroView.swift
//  Ink
//
//  First launch of v2: three notebook pages that explain the game before the
//  enrollment form. Shown once, to new players and to v1 players updating.
//

import SwiftUI
import InkEngine

struct IntroView: View {
    let finish: () -> Void
    @State private var page = 0
    private let pageCount = 3

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                InkLogo(size: 30)
                Spacer()
                Button(L10n.t("intro.skip"), action: finish)
                    .font(.inkUI(14, weight: .bold, relativeTo: .callout))
                    .foregroundStyle(InkColor.secondary)
                    .frame(minWidth: 44, minHeight: 44)
                    .accessibilityIdentifier("intro.skip")
            }
            .padding(.horizontal, InkSpace.screenMargin)

            TabView(selection: $page) {
                IntroPage(index: 0, title: L10n.t("intro.1.title"), text: L10n.t("intro.1.text")) {
                    VStack(spacing: 12) {
                        TeacherAvatar(mood: .pleased, size: 120)
                        TeacherBubble(text: L10n.t("intro.1.quote"), tilt: -1)
                    }
                }
                .tag(0)
                IntroPage(index: 1, title: L10n.t("intro.2.title"), text: L10n.t("intro.2.text")) {
                    GallowsStage(lives: 6, mistakes: 2, mood: .nervous)
                        .frame(height: 170)
                        .padding(.top, 12)
                        .inkCard()
                }
                .tag(1)
                IntroPage(index: 2, title: L10n.t("intro.3.title"), text: L10n.t("intro.3.text")) {
                    VStack(spacing: 14) {
                        HStack(spacing: 14) {
                            ComboBadge(multiplier: 3)
                            GradeStamp(grade: .aMinus, size: 72)
                        }
                        FlowRow {
                            InkChip(systemName: "drop.fill", text: L10n.t("power.eraser"))
                            InkChip(systemName: "drop.fill", text: L10n.t("power.reveal"))
                            InkChip(systemName: "drop.fill", text: L10n.t("power.hint"))
                            InkChip(systemName: "graduationcap.fill", symbolColor: InkColor.ink, text: L10n.semesterName(1) + " → " + L10n.semesterName(6))
                            InkChip(systemName: "calendar", symbolColor: InkColor.teacher, text: L10n.t("daily.title"))
                        }
                    }
                }
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: page)

            HStack(spacing: 8) {
                ForEach(0..<pageCount, id: \.self) { index in
                    Capsule()
                        .fill(index == page ? InkColor.teacher : InkColor.ghost)
                        .frame(width: index == page ? 22 : 8, height: 8)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(L10n.t("intro.page", page + 1, pageCount))

            Button {
                if page < pageCount - 1 {
                    page += 1
                } else {
                    finish()
                }
            } label: {
                Text(page < pageCount - 1 ? L10n.t("intro.next") : L10n.t("intro.toForm"))
            }
            .buttonStyle(.inkPrimary)
            .padding(.horizontal, InkSpace.screenMargin)
            .padding(.bottom, 10)
            .accessibilityIdentifier("intro.next")
        }
        .padding(.top, 8)
        .notebookPaper()
    }
}

/// One page: an illustration on top, a handwritten title and a short paragraph.
private struct IntroPage<Art: View>: View {
    let index: Int
    let title: String
    let text: String
    @ViewBuilder let art: () -> Art

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                art()
                    .frame(maxWidth: .infinity)
                Text("\(index + 1).")
                    .font(.inkDisplay(26, relativeTo: .title2))
                    .foregroundStyle(InkColor.teacher)
                    + Text(" " + title)
                    .font(.inkDisplay(32, relativeTo: .title))
                    .foregroundStyle(InkColor.ink)
                Text(text)
                    .font(.inkUI(15, relativeTo: .body))
                    .foregroundStyle(InkColor.ink)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            // Text starts right of the red margin line, as in a real notebook.
            .padding(.leading, InkSpace.marginLineX + 16)
            .padding(.trailing, InkSpace.screenMargin + 4)
            .padding(.vertical, 8)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("intro.page.\(index + 1)")
    }
}
