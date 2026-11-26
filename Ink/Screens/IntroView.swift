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
                        TeacherAvatar(mood: .pleased, size: 104)
                        TeacherBubble(text: L10n.t("intro.1.quote"), tilt: -1)
                    }
                }
                .tag(0)
                IntroPage(index: 1, title: L10n.t("intro.2.title"), text: L10n.t("intro.2.text")) {
                    GallowsStage(lives: 6, mistakes: 2, mood: .nervous)
                        .frame(height: 160)
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
                        }
                    }
                }
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: page)

            // The current page is marked with a drop of ink, the rest with empty pencil rings.
            HStack(spacing: 6) {
                ForEach(0..<pageCount, id: \.self) { index in
                    ZStack {
                        if index == page {
                            InkBlot()
                                .fill(InkColor.inkDrop)
                                .frame(width: 18, height: 18)
                                .transition(.scale(scale: 0.5).combined(with: .opacity))
                        } else {
                            Circle()
                                .strokeBorder(InkColor.ghost, lineWidth: 1.5)
                                .frame(width: 9, height: 9)
                        }
                    }
                    .frame(width: 22, height: 22)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: page)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(L10n.t("intro.page", page + 1, pageCount))

            Button {
                if page < pageCount - 1 {
                    page += 1
                } else {
                    finish()
                }
            } label: {
                Text(handwritten: page < pageCount - 1 ? L10n.t("intro.next") : L10n.t("intro.toForm"))
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

/// One page: the illustration taped to the page as an exhibit, a circled page
/// number with a handwritten title, and a short paragraph.
private struct IntroPage<Art: View>: View {
    let index: Int
    let title: String
    let text: String
    @ViewBuilder let art: () -> Art

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var settled = false
    private static var tilts: [Double] { [-1.4, 1.1, -0.8] }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                art()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 14)
                    .padding(.top, 22)
                    .padding(.bottom, 16)
                    .inkCard(raised: true, tilt: settled ? Self.tilts[index % 3] : 0)
                    .overlay(alignment: .top) { Tape().offset(y: -11) }
                    .scaleEffect(settled ? 1 : 0.96)
                    .opacity(settled ? 1 : 0)
                    .padding(.top, 14)
                    .padding(.trailing, 4)
                HStack(alignment: .center, spacing: 10) {
                    Text(handwrittenCentered: "\(index + 1)")
                        .font(.inkDisplayFixed(26))
                        .foregroundStyle(InkColor.teacher)
                        .fixedSize()
                        .frame(width: 42, height: 38)
                        .overlay {
                            PenCircle()
                                .stroke(InkColor.teacher, style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
                        }
                        .accessibilityHidden(true)
                    Text(handwritten: title)
                        .font(.inkDisplay(32, relativeTo: .title))
                        .foregroundStyle(InkColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityAddTraits(.isHeader)
                }
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
        .scrollBounceBehavior(.basedOnSize)
        .onAppear {
            // First-run moment: the exhibit is laid down and taped when its page opens.
            if reduceMotion { settled = true } else {
                withAnimation(.timingCurve(0.32, 0.72, 0, 1, duration: 0.35)) { settled = true }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("intro.page.\(index + 1)")
    }
}
