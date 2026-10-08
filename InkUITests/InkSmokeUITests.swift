//
//  InkSmokeUITests.swift
//  InkUITests
//
//  Hasan's smoke suite for the v2 screens. Every element is found by its
//  accessibility identifier, so the suite does not depend on the language.
//  Run it on iPhone 17 Pro and on iPhone SE (3rd generation): the SE run is
//  the check for B-24 (keys off screen on 4.7" iPhones).
//

import XCTest

final class InkSmokeUITests: XCTestCase {

    private var app: XCUIApplication!

    private let alphabets: [String: String] = [
        "EN": "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
        "TR": "ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ",
        "AZ": "ABCÇDEƏFGĞHXIİJKQLMNOÖPRSŞTUÜVYZ",
        "ES": "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ",
        "RU": "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ",
    ]

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    // MARK: Helpers

    private func launch(onboarded: Bool = true, language: String = "EN") {
        app.launchArguments = ["-hasSeenOnboarding", onboarded ? "YES" : "NO", "-uiLanguage", language]
        app.launch()
    }

    private func element(_ id: String) -> XCUIElement {
        app.descendants(matching: .any)[id]
    }

    /// The first tap after a transition is sometimes swallowed on the simulator; retry once.
    @discardableResult
    private func tap(_ id: String, until expected: String, timeout: TimeInterval = 5, file: StaticString = #filePath, line: UInt = #line) -> Bool {
        let target = element(id)
        XCTAssertTrue(target.waitForExistence(timeout: timeout), "\(id) not found", file: file, line: line)
        for _ in 1...2 {
            if target.exists && target.isHittable { target.tap() }
            if element(expected).waitForExistence(timeout: timeout) { return true }
        }
        XCTFail("Tapping \(id) did not show \(expected)", file: file, line: line)
        return false
    }

    private func screenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func startFreePlay() {
        tap("desk.free", until: "free.start")
        tap("free.start", until: "game.stage")
    }

    /// Taps keys in alphabet order until the game-over card shows.
    private func playToEnd(language: String) {
        let over = element("over.seeExam")
        for letter in alphabets[language]! {
            if over.exists { break }
            let key = element("key.\(letter)")
            if key.exists && key.isEnabled && key.isHittable { key.tap() }
        }
        XCTAssertTrue(over.waitForExistence(timeout: 6), "No game-over card in \(language)")
    }

    // MARK: Smoke

    func testS01_EnrollmentFormStartsTheFirstWord() {
        launch(onboarded: false)
        XCTAssertTrue(element("onboarding.sign").waitForExistence(timeout: 5))
        for id in ["onboarding.name", "onboarding.lang.EN", "onboarding.lang.AZ", "onboarding.tone.strict", "onboarding.tone.gentle"] {
            XCTAssertTrue(element(id).exists, "\(id) missing on the enrollment form")
        }
        screenshot("S01 enrollment form")
        element("onboarding.tone.gentle").tap()
        tap("onboarding.sign", until: "game.stage", timeout: 8)
        screenshot("S01 first word")
        tap("game.close", until: "desk.play")
        for id in ["desk.daily", "desk.free", "desk.gpa", "desk.settings", "tab.desk", "tab.semesters", "tab.stickers", "tab.report"] {
            XCTAssertTrue(element(id).exists, "\(id) missing on the Desk")
        }
    }

    func testS02_SemesterWordToGradedExam() {
        launch()
        tap("desk.play", until: "game.stage")
        XCTAssertTrue(element("game.lives").exists)
        XCTAssertTrue(element("teacher.line").exists)
        playToEnd(language: "EN")
        screenshot("S02 game over")
        tap("over.seeExam", until: "result.grade")
        XCTAssertTrue(element("result.total").exists)
        XCTAssertTrue(element("result.comment").exists)
        screenshot("S02 graded exam")
        if element("result.next").exists {
            tap("result.next", until: "game.stage")
            element("game.close").tap()
        } else {
            element("result.close").tap()
        }
        XCTAssertTrue(element("desk.daily").waitForExistence(timeout: 5))
    }

    func testS03_EveryKeyReachableInEveryLanguage() {
        continueAfterFailure = true
        for language in ["EN", "TR", "AZ", "ES", "RU"] {
            launch(language: language)
            startFreePlay()
            screenshot("S03 \(language) keyboard")
            let unreachable = alphabets[language]!.filter {
                let key = element("key.\($0)")
                return !(key.exists && key.isHittable)
            }
            XCTAssertTrue(unreachable.isEmpty, "\(language): keys not reachable: \(String(unreachable))")
            XCTAssertTrue(element("game.lives").isHittable, "\(language): lives counter hidden")
            playToEnd(language: language)
            app.terminate()
        }
    }

    func testS04_PowerUpsSpendInk() {
        launch()
        startFreePlay()
        let ink = element("game.ink")
        let before = Int(ink.label.filter(\.isNumber)) ?? 0
        let hint = element("power.hint")
        if before >= 20 && hint.isEnabled {
            hint.tap()
            XCTAssertTrue(element("game.hintText").waitForExistence(timeout: 3), "Hint text did not appear")
            let after = Int(ink.label.filter(\.isNumber)) ?? 0
            XCTAssertEqual(after, before - 20, "Hint should cost 20 ink")
            XCTAssertFalse(element("power.hint").isEnabled, "Hint can be used once per word")
        } else {
            // Not enough ink: the button is disabled, never a purchase prompt.
            XCTAssertFalse(hint.isEnabled)
        }
        XCTAssertFalse(element("power.eraser").isEnabled, "Eraser needs a mistake first")
        screenshot("S04 power-ups")
    }

    func testS05_TabsOpenTheirScreens() {
        launch()
        tap("tab.semesters", until: "semesters.current")
        tap("tab.stickers", until: "sticker.firstWin")
        tap("tab.report", until: "report.totals")
        screenshot("S05 report card")
        tap("tab.desk", until: "desk.daily")
    }

    func testS06_SettingsOpenAndClose() {
        launch()
        tap("desk.settings", until: "settings.tone")
        for id in ["settings.language", "settings.theme", "settings.sound", "settings.haptics", "settings.name", "settings.reset"] {
            XCTAssertTrue(element(id).exists, "\(id) missing in Settings")
        }
        screenshot("S06 settings")
        tap("settings.close", until: "desk.daily")
    }

    func testS07_DailyIsPlayedOnceAndRemembered() {
        launch()
        tap("desk.daily", until: "daily.streak")
        if element("daily.start").exists {
            tap("daily.start", until: "game.stage")
            XCTAssertFalse(element("power.hint").exists, "The Daily has no power-ups")
            playToEnd(language: "EN")
            tap("over.seeExam", until: "result.grade")
            XCTAssertFalse(element("result.next").exists, "The Daily has no next word")
            element("result.close").tap()
        }
        XCTAssertTrue(element("daily.done").waitForExistence(timeout: 5), "Today's result not shown")
        screenshot("S07 daily done")

        // B-04: after a relaunch the Daily is still done (same exam, saved), not a new word.
        app.terminate()
        launch()
        tap("desk.daily", until: "daily.streak")
        XCTAssertTrue(element("daily.done").exists, "Daily forgot today's result after a relaunch")
        XCTAssertFalse(element("daily.start").exists)
    }

    /// B-06: v1 failed Easy games after 60 s of thinking. v2 has no timer outside Blitz.
    func testS08_NoHiddenTimer() {
        launch()
        tap("desk.free", until: "free.start")
        element("free.level.Easy").tap()
        tap("free.start", until: "game.stage")
        sleep(65)
        XCTAssertFalse(element("over.seeExam").exists, "The word ended without a guess")
        XCTAssertTrue(element("key.Q").isEnabled || element("key.Z").isEnabled, "Keyboard locked without a guess")
        screenshot("S08 after 65 s")
    }
}
