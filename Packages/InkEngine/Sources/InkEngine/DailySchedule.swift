//
//  DailySchedule.swift
//  InkEngine
//
//  Maps a local calendar day to the Daily Exam number and word.
//  v1.2 used String.hashValue, which Swift randomises per launch, so the
//  daily word changed every time the app opened. This is deterministic:
//  the same local date gives the same exam on every device.
//

import Foundation

public struct DailySchedule: Sendable {
    /// The local day of Exam #1.
    public let epoch: DateComponents
    public let calendar: Calendar

    /// Default epoch is the planned v2.0 release day, so the first Daily is #1.
    public init(epoch: DateComponents = DateComponents(year: 2027, month: 1, day: 12), calendar: Calendar = .current) {
        self.epoch = epoch
        var calendar = calendar
        calendar.firstWeekday = 2 // Monday, for the weekly hall pass
        self.calendar = calendar
    }

    /// Exam number for the day that contains `date` in the calendar's time zone. #1 on the epoch day.
    /// Days before the epoch give 0 or negative numbers.
    public func number(for date: Date) -> Int {
        let start = calendar.startOfDay(for: epochDate)
        let day = calendar.startOfDay(for: date)
        return (calendar.dateComponents([.day], from: start, to: day).day ?? 0) + 1
    }

    /// Index into a daily word list of `count` words. Cycles when the list runs out.
    public func wordIndex(for date: Date, count: Int) -> Int {
        precondition(count > 0, "The daily list is empty")
        let zeroBased = number(for: date) - 1
        return ((zeroBased % count) + count) % count
    }

    /// Identifies the Monday-to-Sunday week that contains exam `number`.
    public func weekKey(forNumber number: Int) -> Int {
        let date = calendar.date(byAdding: .day, value: number - 1, to: calendar.startOfDay(for: epochDate))!
        let parts = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return (parts.yearForWeekOfYear ?? 0) * 100 + (parts.weekOfYear ?? 0)
    }

    private var epochDate: Date {
        calendar.date(from: epoch)!
    }
}

public enum DailyStreak {
    /// Consecutive Daily Exams played up to `today`, where one missed day per week is forgiven
    /// (the hall pass) and a second miss in the same week ends the streak.
    /// Today not played yet does not break anything: the day is still open.
    public static func current(played: Set<Int>, today: Int, schedule: DailySchedule) -> Int {
        var streak = 0
        var missesByWeek: [Int: Int] = [:]
        var day = played.contains(today) ? today : today - 1
        let earliest = played.min() ?? today

        while day >= earliest {
            if played.contains(day) {
                streak += 1
            } else {
                let week = schedule.weekKey(forNumber: day)
                missesByWeek[week, default: 0] += 1
                if missesByWeek[week]! > 1 { break }
            }
            day -= 1
        }
        return streak
    }
}
