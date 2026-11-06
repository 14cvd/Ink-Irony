//
//  UIAuditTests.swift
//  InkUITests
//
//  Walks every screen in every language and saves a screenshot of each, so
//  clipped letters, overlaps and overflow can be reviewed side by side.
//  Skipped unless AUDIT_LANGS is set, e.g.
//  TEST_RUNNER_AUDIT_LANGS=EN,TR,AZ,RU,ES xcodebuild test -only-testing:InkUITests/UIAuditTests ...
//  Optional: TEST_RUNNER_AUDIT_TEXT=UICTContentSizeCategoryXXXL for a large Dynamic Type run.
//

import XCTest

final class UIAuditTests: XCTestCase {

    private var app: XCUIApplication!

    private let alphabets: [String: String] = [
        "EN": "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
        "TR": "ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ",
        "AZ": "ABCÇDEƏFGĞHXIİJKQLMNOÖPRSŞTUÜVYZ",
        "ES": "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ",
        "RU": "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ",
    ]

    /// Letters of the store demo word in each language (TELESCOPE, TELESKOP, ТЕЛЕСКОП, TELESCOPIO).
    private let demoLetters: [String: String] = [
        "EN": "TELSCOP", "TR": "TELSKOP", "AZ": "TELSKOP", "ES": "TELSCOPI", "RU": "ТЕЛСКОП",
    ]

    private func element(_ id: String) -> XCUIElement {
        app.descendants(matching: .any)[id]
    }

    @discardableResult
    private func tap(_ id: String, until expected: String) -> Bool {
        let target = element(id)
        guard target.waitForExistence(timeout: 6) else { XCTFail("\(id) not found"); return false }
        for _ in 1...2 {
            if target.exists && target.isHittable { target.tap() }
            if element(expected).waitForExistence(timeout: 6) { return true }
        }
        XCTFail("Tapping \(id) did not show \(expected)")
        return false
    }

    private func shot(_ language: String, _ name: String) {
        sleep(1)
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "audit-\(language)-\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Names ending in l, whose tail is the widest in Caveat.
    private let names: [String: String] = ["EN": "Kamil", "TR": "Kemal", "AZ": "Nail", "RU": "Павел", "ES": "Raúl"]

    private func launch(_ language: String, onboarded: Bool, demo: Bool, theme: String = "light") {
        app = XCUIApplication()
        var arguments = [
            "-onboardedV2", onboarded ? "YES" : "NO", "-uiLanguage", language,
            "-appTheme", theme, "-storeDemo", demo ? "YES" : "NO", "-teacherTone", "strict",
            "-username", names[language] ?? "Kamil",
        ]
        if let size = ProcessInfo.processInfo.environment["AUDIT_TEXT"], !size.isEmpty {
            arguments += ["-UIPreferredContentSizeCategoryName", size]
        }
        app.launchArguments = arguments
        app.launch()
    }

    private func keys(_ letters: String, untilOver: Bool = false) {
        for letter in letters {
            if untilOver && element("over.seeExam").exists { return }
            let key = element("key.\(letter)")
            if key.exists && key.isEnabled && key.isHittable { key.tap(); usleep(250_000) }
        }
    }

    func testAudit() throws {
        let list = ProcessInfo.processInfo.environment["AUDIT_LANGS"] ?? ""
        try XCTSkipIf(list.isEmpty, "Set TEST_RUNNER_AUDIT_LANGS to run the UI audit")
        continueAfterFailure = true
        for language in list.split(separator: ",").map(String.init) {
            audit(language)
        }
    }

    private func audit(_ language: String) {
        let alphabet = alphabets[language]!
        let misses = String(alphabet.filter { !demoLetters[language]!.contains($0) })

        // First launch: intro pages and the enrollment form.
        launch(language, onboarded: false, demo: false)
        for page in 1...3 {
            XCTAssertTrue(element("intro.page.\(page)").waitForExistence(timeout: 6))
            shot(language, "01-intro\(page)")
            if page < 3 { element("intro.next").tap() }
        }
        tap("intro.next", until: "onboarding.sign")
        shot(language, "02-form")
        app.terminate()

        // A player with history: tabs, settings, Daily.
        launch(language, onboarded: true, demo: true)
        XCTAssertTrue(element("desk.play").waitForExistence(timeout: 6))
        shot(language, "03-desk")
        tap("tab.semesters", until: "semesters.current")
        shot(language, "04-semesters")
        tap("tab.stickers", until: "sticker.firstWin")
        shot(language, "05-stickers")
        tap("tab.report", until: "report.totals")
        shot(language, "06-report")
        tap("tab.desk", until: "desk.settings")
        tap("desk.settings", until: "settings.tone")
        shot(language, "07-settings")
        app.terminate()

        // A lost semester word: every slot revealed, the F exam.
        launch(language, onboarded: true, demo: true)
        tap("desk.play", until: "game.stage")
        keys(String(demoLetters[language]!.prefix(3)))
        shot(language, "08-game")
        keys(misses, untilOver: true)
        XCTAssertTrue(element("over.seeExam").waitForExistence(timeout: 6))
        shot(language, "09-lost")
        tap("over.seeExam", until: "result.grade")
        shot(language, "10-result-lost")
        app.terminate()

        // A won word with power-ups and the Daily screens.
        launch(language, onboarded: true, demo: true)
        tap("desk.daily", until: "daily.streak")
        shot(language, "11-daily")
        tap("daily.start", until: "game.stage")
        keys(demoLetters[language]!, untilOver: true)
        XCTAssertTrue(element("over.seeExam").waitForExistence(timeout: 6))
        shot(language, "12-won")
        tap("over.seeExam", until: "result.grade")
        shot(language, "13-result-won")
        tap("result.close", until: "daily.done")
        shot(language, "14-daily-done")
        app.terminate()

        // Real words from the word lists: free play, long words, hint text.
        launch(language, onboarded: true, demo: false)
        tap("desk.free", until: "free.start")
        shot(language, "15-free-sheet")
        if element("free.level.Hard").exists { element("free.level.Hard").tap() }
        tap("free.start", until: "game.stage")
        if element("power.hint").exists && element("power.hint").isEnabled { element("power.hint").tap() }
        keys(String(alphabet.prefix(6)))
        shot(language, "16-free-game")
        keys(alphabet, untilOver: true)
        shot(language, "17-free-over")
        app.terminate()

        // Chalkboard theme.
        launch(language, onboarded: true, demo: true, theme: "dark")
        XCTAssertTrue(element("desk.play").waitForExistence(timeout: 6))
        shot(language, "18-desk-dark")
        tap("desk.play", until: "game.stage")
        keys(String(demoLetters[language]!.prefix(2)) + String(misses.prefix(3)))
        shot(language, "19-game-dark")
        app.terminate()
    }
}
