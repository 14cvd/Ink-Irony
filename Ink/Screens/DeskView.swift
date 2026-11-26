//
//  DeskView.swift
//  Ink
//
//  Home. One obvious next step (the Continue card), then the Daily, then the rest.
//

import SwiftUI
import InkEngine

struct DeskView: View {
    @Environment(AppState.self) private var app
    @State private var greeting = ""
    @State private var showFreePlay = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    TeacherRow(text: greeting, avatarSize: 56)
                    ContinueCard()
                        .padding(.top, 8)
                    NavigationLink {
                        DailyView()
                    } label: {
                        DailyCard()
                    }
                    .buttonStyle(.paperPress)
                    .accessibilityIdentifier("desk.daily")
                    modes
                }
                .padding(.horizontal, InkSpace.screenMargin)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .notebookPaper()
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showFreePlay) { FreePlaySheet() }
        }
        .onAppear {
            if greeting.isEmpty {
                greeting = app.teacherLine(app.daysAway >= 3 ? .deskReturning : .desk)
            }
        }
        .onChange(of: app.language) { greeting = app.teacherLine(.desk) }
        .onChange(of: app.tone) { greeting = app.teacherLine(.desk) }
    }

    private var header: some View {
        HStack(alignment: .center) {
            InkLogo()
            Spacer()
            Button {
                app.selectedTab = .report
            } label: {
                InkChip(systemName: "graduationcap.fill", symbolColor: InkColor.ink, text: L10n.t("desk.gpa", app.gpaText), fill: InkColor.reward, onReward: true)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("desk.gpa")
            InkIconButton(systemName: "gearshape", label: L10n.t("settings.title"), identifier: "desk.settings") {
                app.showSettings = true
            }
        }
    }

    private var modes: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ModeTile(symbol: "slider.horizontal.3", title: L10n.t("mode.free"), subtitle: L10n.t("mode.free.sub"), identifier: "desk.free") {
                showFreePlay = true
            }
            ModeTile(symbol: "timer", title: L10n.t("mode.blitz"), subtitle: nil, identifier: "desk.blitz", locked: true) {}
            ModeTile(symbol: "person.2", title: L10n.t("mode.duel"), subtitle: nil, identifier: "desk.duel", locked: true) {}
            ModeTile(symbol: "book.closed", title: L10n.t("mode.notebook"), subtitle: L10n.t("mode.notebook.sub", app.progress.wordsSolved), identifier: "desk.notebook", locked: true) {}
        }
    }
}

/// The current semester with its ten words and the one big button.
private struct ContinueCard: View {
    @Environment(AppState.self) private var app

    var body: some View {
        let lang = app.languageProgress
        let current = lang.current
        VStack(alignment: .leading, spacing: 10) {
            Overline(text: L10n.t("desk.continue"))
            Text(handwritten: L10n.semesterTitle(current.semester))
                .font(.inkDisplay(32, relativeTo: .title))
                .foregroundStyle(InkColor.ink)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 6) {
                ForEach(0..<Rules.wordsPerSemester, id: \.self) { index in
                    if index < current.grades.count {
                        GradeDot(grade: current.grades[index])
                    } else if index == current.grades.count {
                        Circle()
                            .strokeBorder(InkColor.teacher, style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                            .frame(width: 22, height: 22)
                            .accessibilityLabel(L10n.t("a11y.nextWord"))
                    } else {
                        GradeDot(grade: nil, size: 14)
                    }
                }
            }
            .accessibilityElement(children: .combine)
            if let next = app.nextSemesterWord {
                Button {
                    app.playNextSemesterWord()
                } label: {
                    Label(handwritten:
                        SemesterPlan.isFinalExam(word: next.word) ? L10n.t("desk.playFinal") : L10n.t("desk.playWord", next.word),
                        systemImage: "pencil"
                    )
                }
                .buttonStyle(.inkPrimary)
                .padding(.top, 4)
                .accessibilityIdentifier("desk.play")
            } else {
                Text(L10n.t("desk.allPassed"))
                    .font(.inkUI(14, relativeTo: .callout))
                    .foregroundStyle(InkColor.secondary)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 22)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .inkCard(raised: true, tilt: -0.8)
        .overlay(alignment: .top) { Tape().offset(y: -12) }
    }
}

private struct DailyCard: View {
    @Environment(AppState.self) private var app

    var body: some View {
        HStack(spacing: 14) {
            DateBlock(date: Date(), compact: true)
            VStack(alignment: .leading, spacing: 2) {
                Text(handwritten: L10n.dailyTitle(app.todayNumber))
                    .font(.inkDisplay(25, relativeTo: .title2))
                    .foregroundStyle(InkColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(app.todaysDaily == nil ? L10n.t("daily.sub") : L10n.t("daily.doneShort"))
                    .font(.inkUI(12, relativeTo: .caption))
                    .foregroundStyle(InkColor.secondary)
            }
            Spacer(minLength: 0)
            VStack(spacing: 0) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(InkColor.teacher)
                Text(L10n.t("daily.streakShort", app.dailyStreak))
                    .font(.inkUI(13, weight: .bold, relativeTo: .caption))
                    .foregroundStyle(InkColor.teacher)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .inkCard(radius: 16, tilt: 0.5)
        .contentShape(Rectangle())
    }
}

/// Red month/day block, as on a tear-off calendar.
struct DateBlock: View {
    let date: Date
    var compact = false

    var body: some View {
        VStack(spacing: 0) {
            Text(date.formatted(.dateTime.month(.abbreviated).locale(L10n.locale)).uppercased(with: L10n.locale))
                .font(.inkUI(compact ? 11 : 13, weight: .bold, relativeTo: .caption))
            // Small: centred in its box. Large: next to the title, so only the tail needs room.
            (compact ? Text(handwrittenCentered: date.formatted(.dateTime.day(.twoDigits))) : Text(handwritten: date.formatted(.dateTime.day(.twoDigits))))
                .font(.inkDisplay(compact ? 30 : 96, relativeTo: .title))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .foregroundStyle(InkColor.teacher)
        .frame(width: compact ? 54 : nil, height: compact ? 58 : nil)
        .overlay {
            if compact { RoundedRectangle(cornerRadius: 8).strokeBorder(InkColor.teacher, lineWidth: 2) }
        }
        .accessibilityElement(children: .combine)
    }
}

/// A mode on the Desk. Open modes are inked cards; the ones still to come are
/// only sketched in pencil, with the teacher's "coming soon" stamp on them.
private struct ModeTile: View {
    let symbol: String
    let title: String
    let subtitle: String?
    let identifier: String
    var locked = false
    let action: () -> Void

    private var pencil: Color { InkColor.secondary }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Image(systemName: symbol)
                        .font(.system(size: 22, weight: locked ? .regular : .semibold))
                        .foregroundStyle(locked ? pencil : InkColor.ink)
                    Spacer(minLength: 4)
                    if locked {
                        Text(L10n.t("mode.soon").uppercased(with: L10n.locale))
                            .font(.inkVoice(11, relativeTo: .caption2))
                            .foregroundStyle(InkColor.teacher)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(InkColor.teacher, lineWidth: 1.5))
                            .rotationEffect(.degrees(-7))
                    }
                }
                Text(handwritten: title)
                    .font(.inkDisplay(24, relativeTo: .title3))
                    .foregroundStyle(locked ? pencil : InkColor.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if let subtitle {
                    Text(subtitle)
                        .font(.inkUI(11, relativeTo: .caption2))
                        .foregroundStyle(InkColor.secondary)
                        .lineLimit(2)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 96, alignment: .topLeading)
            .background {
                if locked {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(pencil.opacity(0.7), style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [5, 4]))
                }
            }
            .modifier(OpenTile(open: !locked))
        }
        .buttonStyle(.paperPress)
        .disabled(locked)
        .accessibilityIdentifier(identifier)
    }
}

private struct OpenTile: ViewModifier {
    let open: Bool

    func body(content: Content) -> some View {
        if open {
            content.inkCard(radius: 14, raised: true)
        } else {
            content
        }
    }
}
