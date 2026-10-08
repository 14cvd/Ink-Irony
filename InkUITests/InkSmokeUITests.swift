//
//  InkSmokeUITests.swift
//  InkUITests
//
//  Hasan's smoke suite for the v1.2 screens on top of the Phase 0 changes.
//  Labels are the localized button titles, because the v1 views have no
//  accessibility identifiers yet.
//
//  Known bugs are written as the behaviour we want, wrapped in XCTExpectFailure,
//  so the suite stays green today and turns red the day a fix lands without
//  the expectation being removed.
//

import XCTest

final class InkSmokeUITests: XCTestCase {

    private var app: XCUIApplication!

    private struct Strings {
        let startExam: String, startSketching: String, nightmare: String, easy: String
        let passed: String, failed: String, mainMenu: String, hint: String
    }

    private let strings: [String: Strings] = [
        "EN": Strings(startExam: "START EXAM", startSketching: "START SKETCHING", nightmare: "NIGHTMARE", easy: "EASY",
                      passed: "PASSED!", failed: "FAILED.", mainMenu: "MAIN MENU", hint: "HINT"),
        "TR": Strings(startExam: "SINAVA BAŞLA", startSketching: "ÇİZİME BAŞLA", nightmare: "KABUS", easy: "KOLAY",
                      passed: "GEÇTİN!", failed: "KALDI.", mainMenu: "ANA MENÜ", hint: "İPUCU"),
        "AZ": Strings(startExam: "İMTAHANA BAŞLA", startSketching: "ÇƏKMƏYƏ BAŞLA", nightmare: "KABUS", easy: "ASAN",
                      passed: "KEÇDİN!", failed: "QALDI.", mainMenu: "ANA MENYU", hint: "İPUCU"),
        "ES": Strings(startExam: "INICIAR EXAMEN", startSketching: "COMENZAR A DIBUJAR", nightmare: "PESADILLA", easy: "FÁCIL",
                      passed: "¡APROBADO!", failed: "SUSPENSO.", mainMenu: "MENÚ PRINCIPAL", hint: "PISTA"),
        "RU": Strings(startExam: "НАЧАТЬ ЭКЗАМЕН", startSketching: "НАЧАТЬ РИСОВАТЬ", nightmare: "КОШМАР", easy: "ЛЕГКО",
                      passed: "СДАЛ!", failed: "ПРОВАЛ.", mainMenu: "ГЛАВНОЕ МЕНЮ", hint: "ПОДСКАЗКА"),
    ]

    private let alphabets: [String: String] = [
        "EN": "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
        "TR": "ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ",
        "AZ": "ABCÇDEƏFGĞHXİIJKQLMNOÖPRSŞTUÜVYZ",
        "ES": "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ",
        "RU": "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ",
    ]

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    // MARK: Helpers

    private func launch(onboardingSeen: Bool = true) {
        app.launchArguments = ["-hasSeenOnboarding", onboardingSeen ? "YES" : "NO", "-uiLanguage", "EN", "-appTheme", "dark"]
        app.launch()
    }

    private func button(labelBeginsWith prefix: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", prefix)).firstMatch
    }

    private func button(labelContains text: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    }

    private func scrollTo(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        var attempts = 0
        while !(element.exists && element.isHittable) && attempts < 6 {
            app.swipeUp(velocity: .slow)
            attempts += 1
        }
        XCTAssertTrue(element.isHittable, "Could not scroll to \(element)", file: file, line: line)
    }

    /// The first tap after a navigation transition is sometimes swallowed on the simulator.
    /// Retry once before failing, and say so in the log so a real dead button still fails.
    private func tap(_ element: XCUIElement, until expected: XCUIElement, timeout: TimeInterval = 4) -> Bool {
        for attempt in 1...2 {
            element.tap()
            if expected.waitForExistence(timeout: timeout) { return true }
            if attempt == 1 { print("Retrying tap on \(element) (first tap swallowed)") }
        }
        return false
    }

    /// SwiftUI on iOS 26 exposes each Toggle twice (the row and its inner switch); keep one per row, top to bottom.
    private func settingsSwitches() -> [XCUIElement] {
        var rows: [Int: XCUIElement] = [:]
        for element in app.switches.allElementsBoundByIndex {
            rows[Int(element.frame.midY.rounded())] = rows[Int(element.frame.midY.rounded())] ?? element
        }
        return rows.keys.sorted().map { rows[$0]! }
    }

    private func attachScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Menu -> setup -> language -> difficulty -> start. `menuLanguage` is the language the menu is currently shown in.
    private func startGame(language: String, difficulty: KeyPath<Strings, String>, menuLanguage: String = "EN") {
        let menu = strings[menuLanguage]!
        let languageButton = app.buttons[language]
        XCTAssertTrue(tap(button(labelBeginsWith: menu.startExam), until: languageButton), "Setup screen did not open")
        languageButton.tap()

        let s = strings[language]!
        let level = button(labelBeginsWith: s[keyPath: difficulty])
        scrollTo(level)
        level.tap()

        let start = button(labelBeginsWith: s.startSketching)
        scrollTo(start)
        start.tap()

        let firstKey = app.buttons[String(alphabets[language]!.first!)]
        XCTAssertTrue(firstKey.waitForExistence(timeout: 5), "Game screen did not open for \(language)")
    }

    /// Taps keys in alphabet order until the result screen shows. Returns true on a win.
    @discardableResult
    private func playToResult(language: String) -> Bool {
        let s = strings[language]!
        let passed = app.staticTexts[s.passed]
        let failed = app.staticTexts[s.failed]
        for letter in alphabets[language]! {
            if passed.exists || failed.exists { break }
            let key = app.buttons[String(letter)]
            if key.exists && key.isEnabled && key.isHittable { key.tap() }
        }
        let deadline = Date().addingTimeInterval(8)
        while Date() < deadline && !(passed.exists || failed.exists) { usleep(200_000) }
        XCTAssertTrue(passed.exists || failed.exists, "No result screen for \(language)")
        return passed.exists
    }

    // MARK: Smoke

    func testS01_OnboardingAppearsOnFirstLaunchAndOpensTheMenu() {
        launch(onboardingSeen: false)
        let enter = app.buttons["ENTER"]
        XCTAssertTrue(enter.waitForExistence(timeout: 5))
        attachScreenshot("S01 onboarding")
        enter.tap()
        XCTAssertTrue(button(labelBeginsWith: "START EXAM").waitForExistence(timeout: 5))
        for title in ["DAILY CHALLENGE", "RECORDS", "SETTINGS"] {
            XCTAssertTrue(button(labelBeginsWith: title).exists, "\(title) missing from the menu")
        }
    }

    func testS02_ReturningPlayerSkipsOnboarding() {
        launch(onboardingSeen: true)
        XCTAssertTrue(button(labelBeginsWith: "START EXAM").waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["ENTER"].exists)
    }

    func testS03_FullGameInEveryLanguageWithItsWholeAlphabet() {
        continueAfterFailure = true // report every language, not only the first broken one
        launch()
        var menuLanguage = "EN"
        for language in ["EN", "TR", "AZ", "ES", "RU"] {
            startGame(language: language, difficulty: \.nightmare, menuLanguage: menuLanguage)

            attachScreenshot("S03 \(language) keyboard")
            // A key that exists but sits outside the screen cannot be tapped by a player either.
            let unreachable = alphabets[language]!.filter {
                let key = app.buttons[String($0)]
                return !(key.exists && key.isHittable)
            }
            XCTAssertTrue(unreachable.isEmpty, "\(language) keyboard keys not reachable on this screen: \(String(unreachable))")

            playToResult(language: language)
            attachScreenshot("S03 \(language) result")

            let mainMenu = button(labelBeginsWith: strings[language]!.mainMenu)
            scrollTo(mainMenu)
            mainMenu.tap()
            menuLanguage = language
            XCTAssertTrue(button(labelBeginsWith: strings[language]!.startExam).waitForExistence(timeout: 5),
                          "Menu did not come back after a \(language) game")
        }
    }

    func testS04_HintCountsDownAndDisables() {
        launch()
        startGame(language: "EN", difficulty: \.easy)
        let hint = button(labelContains: "HINT")
        XCTAssertTrue(hint.label.contains("2 left"), "Hint label was \(hint.label)")
        let textsBefore = Set(app.staticTexts.allElementsBoundByIndex.map(\.label))

        hint.tap()
        XCTAssertTrue(button(labelContains: "1 left").waitForExistence(timeout: 2))
        let textsAfter = Set(app.staticTexts.allElementsBoundByIndex.map(\.label))
        XCTAssertFalse(textsAfter.subtracting(textsBefore).isEmpty, "No hint text appeared")

        button(labelContains: "HINT").tap()
        let exhausted = button(labelContains: "0 left")
        XCTAssertTrue(exhausted.waitForExistence(timeout: 2))
        XCTAssertFalse(exhausted.isEnabled, "Hint button should be disabled at 0")
        attachScreenshot("S04 hints used")
    }

    func testS05_RecordsSheetOpensEveryTab() {
        launch()
        button(labelBeginsWith: "RECORDS").tap()
        for tab in ["MY STATS", "LEADERBOARD", "ACHIEVEMENTS"] {
            let tabButton = app.buttons[tab]
            XCTAssertTrue(tabButton.waitForExistence(timeout: 3), "\(tab) tab missing")
            tabButton.tap()
            attachScreenshot("S05 \(tab)")
        }
        app.swipeDown(velocity: .fast)
        XCTAssertTrue(button(labelBeginsWith: "START EXAM").waitForExistence(timeout: 5))
    }

    func testS06_SettingsTogglesAndShowTimerHidesTheClock() {
        launch()
        XCTAssertTrue(tap(button(labelBeginsWith: "SETTINGS"), until: app.switches.firstMatch))
        let switches = settingsSwitches()
        XCTAssertEqual(switches.count, 5, "Expected Dark Mode, Sound FX, Haptic Feedback, Show Timer, Teacher Quotes")
        attachScreenshot("S06 settings")

        // Dark Mode off and on again must not crash or lose the sheet.
        switches[0].tap()
        settingsSwitches()[0].tap()
        XCTAssertTrue(app.switches.firstMatch.exists, "Settings sheet closed after toggling Dark Mode")

        let showTimer = settingsSwitches()[3]
        let wasOn = (showTimer.value as? String) == "1"
        if wasOn { showTimer.tap() }
        app.swipeDown(velocity: .fast)

        startGame(language: "EN", difficulty: \.nightmare)
        let clock = app.staticTexts.matching(NSPredicate(format: "label MATCHES %@", "^[0-9]{2}:[0-9]{2}$")).firstMatch
        XCTAssertFalse(clock.exists, "Timer is visible although Show Timer is off")
        attachScreenshot("S06 game without timer")

        // Restore the setting for the next run.
        app.terminate()
        launch()
        button(labelBeginsWith: "SETTINGS").tap()
        XCTAssertTrue(app.switches.firstMatch.waitForExistence(timeout: 3))
        let restore = settingsSwitches()[3]
        if (restore.value as? String) != "1" { restore.tap() }
    }

    func testS07_DailyChallengeOpensAndStartsAGame() {
        launch()
        button(labelBeginsWith: "DAILY CHALLENGE").tap()
        let start = button(labelBeginsWith: "START EXAM")
        let done = app.staticTexts["Come back tomorrow!"]
        XCTAssertTrue(start.waitForExistence(timeout: 5) || done.exists, "Daily screen did not open")
        attachScreenshot("S07 daily")
        if start.exists {
            start.tap()
            XCTAssertTrue(app.buttons["A"].waitForExistence(timeout: 5), "Daily game did not start")
        }
    }

    // MARK: Known bugs (expected to fail until fixed)

    /// B-06: Easy promises no timer, but GameViewModel falls back to a 60 s timer that never resets on Easy.
    func testK01_EasyGameIsNotFailedByATimer() {
        launch()
        startGame(language: "EN", difficulty: \.easy)
        sleep(65)
        attachScreenshot("K01 Easy after 65 s")
        XCTExpectFailure("B-06: Easy games end after 60 s without a guess") {
            XCTAssertFalse(app.staticTexts["FAILED."].exists, "An Easy game was failed by a hidden timer")
        }
    }

    /// B-04: the daily word comes from String.hashValue, which Swift seeds differently on every launch.
    func testK02_DailyWordIsTheSameAfterARelaunch() throws {
        func dailyClue() -> Set<String> {
            button(labelBeginsWith: "DAILY CHALLENGE").tap()
            let start = button(labelBeginsWith: "START EXAM")
            guard start.waitForExistence(timeout: 5) else { return [] }
            start.tap()
            XCTAssertTrue(app.buttons["A"].waitForExistence(timeout: 5))
            let before = Set(app.staticTexts.allElementsBoundByIndex.map(\.label))
            button(labelContains: "HINT").tap()
            sleep(1)
            button(labelContains: "HINT").tap()
            sleep(1)
            return Set(app.staticTexts.allElementsBoundByIndex.map(\.label)).subtracting(before)
        }

        launch()
        let first = dailyClue()
        try XCTSkipIf(first.isEmpty, "Today's daily is already played on this simulator")
        attachScreenshot("K02 first launch clue")
        app.terminate()
        launch()
        let second = dailyClue()
        attachScreenshot("K02 second launch clue")

        XCTExpectFailure("B-04: the daily word changes on every launch", options: {
            let options = XCTExpectedFailure.Options()
            options.isStrict = false // 1 in ~100 launches picks the same word by chance
            return options
        }())
        XCTAssertEqual(first, second, "Daily clue differs between launches")
    }
}
