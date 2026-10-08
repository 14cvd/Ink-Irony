//
//  ProgressionTests.swift
//  InkEngineTests
//

import Foundation
import Testing
@testable import InkEngine

@Suite("Semesters")
struct SemesterTests {

    @Test("Lives per semester, one fewer in the final exam")
    func lives() {
        #expect(SemesterPlan.lives(semester: 1, word: 1) == 8)
        #expect(SemesterPlan.lives(semester: 1, word: 10) == 7)
        #expect(SemesterPlan.lives(semester: 3, word: 4) == 6)
        #expect(SemesterPlan.lives(semester: 6, word: 9) == 3)
        #expect(SemesterPlan.lives(semester: 6, word: 10) == 2)
    }

    @Test("Ten grades complete a semester; GPA 2.0 passes and unlocks the next")
    func passAndUnlock() {
        var progress = SemesterProgress(semester: 3)
        for _ in 1...9 { progress.record(.c) }
        #expect(progress.nextWord == 10)
        #expect(!progress.passed)
        progress.record(.c)
        #expect(progress.isComplete)
        #expect(progress.gpa == 2.0)
        #expect(progress.passed)
        #expect(progress.unlocks == 4)
    }

    @Test("Below 2.0 fails and the retake starts empty")
    func failAndRetake() {
        var progress = SemesterProgress(semester: 2)
        for _ in 1...5 { progress.record(.c) }
        for _ in 1...5 { progress.record(.d) }
        #expect(!progress.passed)
        #expect(progress.unlocks == nil)
        let retake = progress.retake()
        #expect(retake.semester == 2)
        #expect(retake.grades.isEmpty)
    }

    @Test("PhD unlocks nothing after it")
    func lastSemester() {
        let progress = SemesterProgress(semester: 6, grades: Array(repeating: .a, count: 10))
        #expect(progress.passed)
        #expect(progress.unlocks == nil)
    }
}

@Suite("Daily Exam schedule")
struct DailyScheduleTests {

    private func calendar(_ zone: String) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: zone)!
        return calendar
    }

    private func date(_ y: Int, _ m: Int, _ d: Int, _ h: Int, _ min: Int = 0, in zone: String) -> Date {
        calendar(zone).date(from: DateComponents(year: y, month: m, day: d, hour: h, minute: min))!
    }

    @Test("Exam #1 on the epoch day, counting local days")
    func numbering() {
        let schedule = DailySchedule(calendar: calendar("Asia/Baku"))
        #expect(schedule.number(for: date(2027, 1, 12, 0, 0, in: "Asia/Baku")) == 1)
        #expect(schedule.number(for: date(2027, 1, 12, 23, 59, in: "Asia/Baku")) == 1)
        #expect(schedule.number(for: date(2027, 1, 13, 0, 0, in: "Asia/Baku")) == 2)
        #expect(schedule.number(for: date(2028, 1, 12, 12, in: "Asia/Baku")) == 366)
        #expect(schedule.number(for: date(2027, 1, 11, 12, in: "Asia/Baku")) == 0)
    }

    @Test("Same local date, same exam, in any time zone", arguments: ["Asia/Baku", "Europe/Istanbul", "Europe/Madrid", "America/Los_Angeles", "Pacific/Kiritimati"])
    func sameLocalDate(zone: String) {
        let schedule = DailySchedule(calendar: calendar(zone))
        #expect(schedule.number(for: date(2027, 3, 1, 9, in: zone)) == 49)
    }

    @Test("Daylight saving changes do not skip or repeat a day")
    func daylightSaving() {
        let zone = "Europe/Madrid" // clocks go forward 2027-03-28 and back 2027-10-31
        let schedule = DailySchedule(calendar: calendar(zone))
        let spring = (27...29).map { schedule.number(for: date(2027, 3, $0, 12, in: zone)) }
        let autumn = (30...31).map { schedule.number(for: date(2027, 10, $0, 12, in: zone)) } + [schedule.number(for: date(2027, 11, 1, 12, in: zone))]
        #expect(spring == [spring[0], spring[0] + 1, spring[0] + 2])
        #expect(autumn == [autumn[0], autumn[0] + 1, autumn[0] + 2])
    }

    @Test("Word index cycles through the list, also before the epoch")
    func wordIndex() {
        let schedule = DailySchedule(calendar: calendar("UTC"))
        #expect(schedule.wordIndex(for: date(2027, 1, 12, 8, in: "UTC"), count: 365) == 0)
        #expect(schedule.wordIndex(for: date(2028, 1, 12, 8, in: "UTC"), count: 365) == 0)
        #expect(schedule.wordIndex(for: date(2027, 1, 11, 8, in: "UTC"), count: 365) == 364)
    }
}

@Suite("Daily streak with hall pass")
struct DailyStreakTests {
    // Epoch 2027-01-11 is a Monday, so exams 1-7, 8-14, ... are Monday-to-Sunday weeks.
    private let schedule: DailySchedule = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return DailySchedule(epoch: DateComponents(year: 2027, month: 1, day: 11), calendar: calendar)
    }()

    @Test("Unbroken days count")
    func unbroken() {
        #expect(DailyStreak.current(played: Set(1...10), today: 10, schedule: schedule) == 10)
    }

    @Test("Today not played yet keeps yesterday's streak")
    func todayOpen() {
        #expect(DailyStreak.current(played: Set(1...9), today: 10, schedule: schedule) == 9)
    }

    @Test("One miss in a week is forgiven")
    func oneMiss() {
        let played = Set(1...14).subtracting([10])
        #expect(DailyStreak.current(played: played, today: 14, schedule: schedule) == 13)
    }

    @Test("A second miss in the same week ends the streak")
    func twoMisses() {
        // Week 2 is days 8-14. Day 12 uses the hall pass; day 9 is the second miss, so 14, 13, 11, 10 count.
        let played = Set(1...14).subtracting([9, 12])
        #expect(DailyStreak.current(played: played, today: 14, schedule: schedule) == 4)
    }

    @Test("One miss in each of two weeks is fine")
    func missEachWeek() {
        let played = Set(1...14).subtracting([3, 10])
        #expect(DailyStreak.current(played: played, today: 14, schedule: schedule) == 12)
    }

    @Test("Nothing played")
    func empty() {
        #expect(DailyStreak.current(played: [], today: 5, schedule: schedule) == 0)
    }
}
