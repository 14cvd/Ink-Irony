//
//  PlayFlowView.swift
//  Ink
//
//  Full-screen flow for one word: pick the word, play it, record it the moment
//  it ends, show the graded exam, then the next word or back to the desk.
//

import SwiftUI
import SwiftData
import InkEngine

struct PlayFlowView: View {
    @Environment(AppState.self) private var app
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var request: PlayRequest
    @State private var model: GameModel?
    @State private var summary: ResultSummary?
    @State private var showingResult = false
    @State private var recentWords: Set<String> = []

    init(request: PlayRequest) {
        _request = State(initialValue: request)
    }

    var body: some View {
        ZStack {
            NotebookPaper()
            if let model {
                if showingResult, let summary {
                    ResultView(summary: summary, next: nextAction, close: close)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    GameScreen(model: model, close: close)
                        .overlay {
                            if model.isOver, let summary {
                                GameOverOverlay(model: model, summary: summary) {
                                    withAnimation(.easeInOut(duration: 0.35)) { showingResult = true }
                                } close: {
                                    close()
                                }
                            }
                        }
                        .onChange(of: model.isOver) { _, over in
                            if over { summary = ResultRecorder.record(model, app: app, context: context) }
                        }
                }
            } else {
                ProgressView().tint(InkColor.ink)
            }
        }
        .task(id: request.id) { await load() }
    }

    // MARK: Flow

    private func load() async {
        let word = await pickWord(for: request)
        recentWords.insert(word.text)
        summary = nil
        showingResult = false
        model = GameModel(request: request, word: word, app: app)
    }

    private func pickWord(for request: PlayRequest) async -> Word {
        let repo = WordRepository.shared
        switch request.mode {
        case .semester(let number, let word):
            let attempt = app.progress.language(request.language).attempt
            let words = await repo.semesterWords(language: request.language, semester: number, attempt: attempt)
            return words[(word - 1) % max(words.count, 1)]
        case .free(let level, let category):
            return await repo.fetchRandomWord(language: request.language, difficulty: level, category: category, excluding: recentWords)
        case .daily(let number):
            let count = await repo.dailyListCount(language: request.language)
            let index = ((number - 1) % count + count) % count
            return await repo.dailyWord(language: request.language, index: index)
        }
    }

    /// What "Next word" does on the result screen, or nil when there is no next word here.
    private var nextAction: (() -> Void)? {
        switch request.mode {
        case .semester:
            guard let next = app.nextSemesterWord else { return nil }
            return { advance(to: .semester(number: next.semester, word: next.word)) }
        case .free(let level, let category):
            return { advance(to: .free(level: level, category: category)) }
        case .daily:
            return nil
        }
    }

    private func advance(to mode: PlayMode) {
        model = nil
        request = PlayRequest(language: request.language, mode: mode)
    }

    private func close() {
        model?.abandon()
        dismiss()
    }
}

/// Bottom card the moment the word ends: the stamp, one line, two ways out.
private struct GameOverOverlay: View {
    let model: GameModel
    let summary: ResultSummary
    let showResult: () -> Void
    let close: () -> Void
    @State private var visible = false

    var body: some View {
        ZStack(alignment: .bottom) {
            InkColor.scrim.ignoresSafeArea()
                .opacity(visible ? 1 : 0)
            VStack(spacing: 12) {
                RubberStamp(
                    text: L10n.t(model.won ? "over.escaped" : "over.detention"),
                    color: model.won ? InkColor.correct : InkColor.teacher
                )
                Text(model.won
                     ? L10n.t("over.wonNote", summary.result.score, summary.result.mistakes)
                     : L10n.t("over.lostNote", model.word.text))
                    .font(.inkVoice(15))
                    .foregroundStyle(InkColor.secondary)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier("over.note")
                Button(L10n.t("over.seeExam"), action: showResult)
                    .buttonStyle(.inkPrimary)
                    .accessibilityIdentifier("over.seeExam")
                Button(L10n.t("result.backToDesk"), action: close)
                    .buttonStyle(.inkSecondary)
                    .accessibilityIdentifier("over.close")
            }
            .padding(22)
            .inkCard(raised: true, tilt: -1.2)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            .offset(y: visible ? 0 : 400)
        }
        .onAppear {
            // Let the last stroke and the Doodle's reaction play first.
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.9)) { visible = true }
        }
    }
}
