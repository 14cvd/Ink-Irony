//
//  FreePlaySheet.swift
//  Ink
//
//  v1's setup screen, kept for players who want to choose: topic and level.
//  The language is the app language (Settings).
//

import SwiftUI

struct FreePlaySheet: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    @AppStorage("freePlayCategory") private var categoryRaw = GameCategory.random.rawValue
    @AppStorage("freePlayLevel") private var levelRaw = Difficulty.medium.rawValue

    private var category: GameCategory { GameCategory(rawValue: categoryRaw) ?? .random }
    private var level: Difficulty { Difficulty(rawValue: levelRaw) ?? .medium }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(L10n.t("mode.free"))
                    .font(.inkDisplay(34, relativeTo: .largeTitle))
                    .foregroundStyle(InkColor.ink)
                Spacer()
                InkIconButton(systemName: "xmark", label: L10n.t("common.close"), identifier: "free.close") { dismiss() }
            }
            Overline(text: L10n.t("free.topic"))
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                ForEach(GameCategory.allCases) { item in
                    choice(selected: item == category, identifier: "free.topic.\(item.rawValue)") {
                        categoryRaw = item.rawValue
                    } label: {
                        Label(item.displayName(for: L10n.language), systemImage: item.symbol)
                    }
                }
            }
            Overline(text: L10n.t("free.level"))
            VStack(spacing: 8) {
                ForEach(Difficulty.allCases) { item in
                    choice(selected: item == level, identifier: "free.level.\(item.rawValue)") {
                        levelRaw = item.rawValue
                    } label: {
                        HStack {
                            Text(L10n.t("level.\(item.rawValue)"))
                            Spacer()
                            Text(L10n.t("free.lives", item.lives))
                                .foregroundStyle(InkColor.secondary)
                        }
                    }
                }
            }
            Spacer(minLength: 0)
            Button {
                dismiss()
                app.play(.free(level: level, category: category))
            } label: {
                Label(L10n.t("free.start"), systemImage: "pencil")
            }
            .buttonStyle(.inkPrimary)
            .accessibilityIdentifier("free.start")
        }
        .padding(InkSpace.screenMargin)
        .notebookPaper(ruled: false)
        .presentationDetents([.large])
    }

    private func choice<L: View>(selected: Bool, identifier: String, action: @escaping () -> Void, @ViewBuilder label: () -> L) -> some View {
        Button(action: action) {
            label()
                .font(.inkUI(14, weight: selected ? .bold : .regular, relativeTo: .callout))
                .foregroundStyle(selected ? InkColor.teacher : InkColor.ink)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: InkRadius.key)
                        .fill(selected ? InkColor.teacher.opacity(0.08) : InkColor.sheet)
                        .overlay(
                            RoundedRectangle(cornerRadius: InkRadius.key)
                                .strokeBorder(selected ? InkColor.teacher : InkColor.ink.opacity(0.35), style: StrokeStyle(lineWidth: 2, dash: selected ? [] : [5, 3]))
                        )
                )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
