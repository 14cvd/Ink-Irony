//
//  StoreScreenshotTests.swift
//  InkUITests
//
//  Drives the DEBUG store demo to the screens used on the App Store and saves a
//  full-resolution screenshot of each as an attachment named "shot-<LANG>-<n>-<screen>".
//  Skipped unless SHOT_LANG is set, e.g.
//  TEST_RUNNER_SHOT_LANG=EN xcodebuild test -only-testing:InkUITests/StoreScreenshotTests ...
//

import XCTest

final class StoreScreenshotTests: XCTestCase {

    private var app: XCUIApplication!

    private struct Plan {
        let name: String
        let misses: [String]
        let firstHits: [String]
        let restHits: [String]
        let darkMisses: [String]
    }

    private let plans: [String: Plan] = [
        "EN": Plan(name: "Alex", misses: ["Q", "X"], firstHits: ["T", "E", "L"], restHits: ["S", "C", "O", "P"], darkMisses: ["Q", "X", "Z"]),
        "TR": Plan(name: "Elif", misses: ["Z", "Ç"], firstHits: ["T", "E", "L"], restHits: ["S", "K", "O", "P"], darkMisses: ["Z", "Ç", "Ğ"]),
        "RU": Plan(name: "Аня", misses: ["Ж", "Щ"], firstHits: ["Т", "Е", "Л"], restHits: ["С", "К", "О", "П"], darkMisses: ["Ж", "Щ", "Ф"]),
        "ES": Plan(name: "Lucía", misses: ["Q", "X"], firstHits: ["T", "E", "L"], restHits: ["S", "C", "O", "P", "I"], darkMisses: ["Q", "X", "Z"]),
        "AZ": Plan(name: "Nigar", misses: ["Z", "Ç"], firstHits: ["T", "E", "L"], restHits: ["S", "K", "O", "P"], darkMisses: ["Z", "Ç", "Ğ"]),
    ]

    private func element(_ id: String) -> XCUIElement {
        app.descendants(matching: .any)[id]
    }

    private func tap(_ id: String, until expected: String, file: StaticString = #filePath, line: UInt = #line) {
        let target = element(id)
        XCTAssertTrue(target.waitForExistence(timeout: 6), "\(id) not found", file: file, line: line)
        for _ in 1...2 {
            if target.exists && target.isHittable { target.tap() }
            if element(expected).waitForExistence(timeout: 6) { return }
        }
        XCTFail("Tapping \(id) did not show \(expected)", file: file, line: line)
    }

    private func keys(_ letters: [String]) {
        for letter in letters {
            let key = element("key.\(letter)")
            XCTAssertTrue(key.waitForExistence(timeout: 4), "key \(letter) missing")
            key.tap()
            usleep(350_000)
        }
    }

    private func shot(_ language: String, _ index: Int, _ screen: String) {
        sleep(2) // let springs, stamps and the teacher's bubble settle
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "shot-\(language)-\(String(format: "%02d", index))-\(screen)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func launch(_ language: String, theme: String, onboarded: Bool, name: String) {
        app = XCUIApplication()
        app.launchArguments = [
            "-storeDemo", "YES", "-onboardedV2", onboarded ? "YES" : "NO",
            "-uiLanguage", language, "-appTheme", theme, "-username", name,
            "-teacherTone", "strict",
        ]
        app.launch()
    }

    func testStoreScreenshots() throws {
        let language = ProcessInfo.processInfo.environment["SHOT_LANG"] ?? ""
        try XCTSkipIf(language.isEmpty, "Set TEST_RUNNER_SHOT_LANG to capture store screenshots")
        let plan = try XCTUnwrap(plans[language], "No plan for \(language)")
        continueAfterFailure = false

        // 1. A word in progress: two inked parts, a nervous Doodle, combo ×3.
        launch(language, theme: "light", onboarded: true, name: plan.name)
        tap("desk.play", until: "game.stage")
        keys(plan.misses + plan.firstHits)
        shot(language, 1, "game")

        // 2. The graded exam.
        keys(plan.restHits)
        tap("over.seeExam", until: "result.grade")
        shot(language, 2, "result")

        // 3. Semesters.
        tap("result.close", until: "desk.daily")
        tap("tab.semesters", until: "semesters.current")
        shot(language, 3, "semesters")

        // 4. The Daily Exam, solved, with the streak.
        tap("tab.desk", until: "desk.daily")
        tap("desk.daily", until: "daily.streak")
        tap("daily.start", until: "game.stage")
        keys([plan.misses[0]] + plan.firstHits + plan.restHits)
        tap("over.seeExam", until: "result.grade")
        tap("result.close", until: "daily.done")
        shot(language, 4, "daily")

        // 5. The enrollment form on first launch.
        app.terminate()
        launch(language, theme: "light", onboarded: false, name: plan.name)
        tap("intro.skip", until: "onboarding.sign")
        shot(language, 5, "enroll")

        // 6. Chalkboard theme, a tense moment.
        app.terminate()
        launch(language, theme: "dark", onboarded: true, name: plan.name)
        tap("desk.play", until: "game.stage")
        keys(plan.darkMisses + Array(plan.firstHits.prefix(2)))
        shot(language, 6, "dark")

        // 7. Desk and stickers, as spares.
        app.terminate()
        launch(language, theme: "light", onboarded: true, name: plan.name)
        XCTAssertTrue(element("desk.play").waitForExistence(timeout: 6))
        shot(language, 7, "desk")
        tap("tab.stickers", until: "sticker.firstWin")
        shot(language, 8, "stickers")
    }
}
