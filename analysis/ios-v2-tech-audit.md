# iOS technical audit and v2 plan (Sid, 2026-10-08)

Scope: `master` at 9f87a14, v1.2.0 build 1, 26 Swift files, about 4,700 lines. SwiftUI + SwiftData, iOS 17+, iPhone only, portrait.

## 1. What I found

The founder said the bugs are not the point, and I agree: most of them disappear in the v2 rewrite. They are listed because some of them decide how v2 must be built. Severity: **blocker** (would hurt v2 users), **high** (a promise the app breaks), **medium**, **low**.

| # | Finding | Where | Severity | v2 handling |
|---|---|---|---|---|
| 1 | The SwiftData store is **deleted** when the schema changes. Shipping v2 with new model fields would wipe every player's history on update. | `ScoreManager.makeContainer` | blocker | `VersionedSchema` V1 (exactly today's `GameSession`) + V2 + `SchemaMigrationPlan`; never delete, move a failed store aside. Migration test with a real v1.2 store file. |
| 2 | Custom fonts are not bundled and not registered (`UIAppFonts` missing). Everything renders in the system font. | project, `ThemeManager.Typography` | high | Bundle Caveat, Special Elite, Courier Prime; register; a unit test asserts `UIFont(name:)` is non-nil for each. |
| 3 | Sound files are not bundled. `AudioService` finds nothing and plays nothing. | `AudioService` | high | Ship 8 `.caf` files; test asserts each resource exists. |
| 4 | Daily word uses `String.hashValue`, which Swift randomises per process launch. The daily word changes every time the app is opened. | `WordRepository.fetchDailyWord` | high | Pre-ordered `daily_<lang>.json`, index = days since epoch date. |
| 5 | Daily "leaderboard" reads only local `UserDefaults`; it can only ever show the player. Also scans the whole `UserDefaults` dictionary on every render. | `DailyChallengeView` | high | Game Center leaderboard. |
| 6 | Easy has no timer by design, but the timer falls back to 60 s and never resets for Easy, so Easy games end after 60 s. | `GameViewModel.setupTimer` | high | No timer outside Blitz. |
| 7 | Taunts cycle in a fixed order and reset each game; `wrongCount` and `difficulty` are ignored, so the "context-aware" teacher is not. | `TauntService.fetchTaunt` | high | Trigger-based line picker with a no-repeat window (story IV2-40). |
| 8 | Daily games are not saved as sessions and do not update stats or achievements. | `DailyChallengeView` | medium | One `GameEngine` result path for every mode. |
| 9 | Achievement thresholds do not match their descriptions: Speed Run 15 s vs "under 30 s", Top Score 200 vs "over 140", Bookworm 10 vs "5 games". "3-Streak" uses the daily-play streak, not 3 wins in a row. | `StatsManager.updateAfterGame` | medium | Stickers defined in data with the rule next to the copy; tests per sticker. |
| 10 | Two different "streaks" (daily play in `UserDefaults`, consecutive wins in `ScoreManager`) shown in different places. | `ScoreManager`, `StatsManager` | medium | One streak: Daily Exam days, with hall pass. |
| 11 | Score formula is copied in three places and rewards fewer lives (Nightmare scores less than Easy). | `ContentView`, `GameViewModel`, `ResultScreen` | medium | One `Scoring` type in the engine, rules from `product/stories/v2-epics.md`. |
| 12 | Word banks: 72 to 124 words per language (README says thousands). Turkish has 0 Nightmare words, Azerbaijani 1, so Nightmare silently falls back to any length. Difficulty is by length only. | `Resources/words_*.json` | medium | Content epic E7, `tier` field. |
| 13 | `CGFloat.random` inside `path(in:)` and `body` (speech bubble, selected buttons) re-randomises on every layout pass, so shapes shimmer. | `TauntBubbleView`, `GameSetupView` | low | Seeded wobble per shape. |
| 14 | Keyboard is off-centre (leading padding only) and wraps 26 letters as 6/6/6/6/2. | `GameView`, `DynamicKeyboardView` | low | Fixed rows per alphabet. |
| 15 | "Achievement Unlocked!" is hard-coded English. | `ResultScreen` | low | String Catalog. |
| 16 | Project-level `IPHONEOS_DEPLOYMENT_TARGET = 26.0`, target-level 17.0; two different `DEVELOPMENT_TEAM` ids. | `project.pbxproj` | low | Clean up in the first MR; one team, one min OS. |
| 17 | Singletons wrapped in `@StateObject` (`ScoreManager.shared`, `ThemeManager.shared`) in several views; old `onChange(of:) { value in }` form. | several | low | `@Observable` models injected through the environment. |
| 18 | No tests at all. | project | medium | Engine unit tests from day one, one UI smoke test. |

## 2. Feasibility notes for Canan's P0 epics

| Feature | Frameworks | Min OS | Permissions | Effort | Label | What Canan can promise |
|---|---|---|---|---|---|---|
| Data migration (IV2-01) | SwiftData `VersionedSchema` | 17 | none | M | safe | Nobody loses history |
| Fonts and sounds (IV2-02) | CoreText registration, AVAudioEngine | 17 | none | S | safe | Look and sound as designed |
| Ghost gallows + Doodle (IV2-11) | SwiftUI `Shape`, `trim`, `PhaseAnimator` | 17 | none | M | experiment (design) | Yes |
| Combo, grades, ink, power-ups (E3) | pure Swift engine | 17 | none | M | safe in code, values are the experiment | Yes |
| Semesters (E4) | SwiftData models | 17 | none | M | safe | Yes |
| Teacher 2.0 (E5) | JSON content + picker | 17 | none | S code, L content | safe | Yes, if content is on time |
| Daily 2.0 + share (E6) | ShareLink, GameKit leaderboards | 17 | Game Center sign-in (not a permission prompt) | M | safe | Yes; leaderboard needs App Store Connect setup |
| String Catalogs for 5 languages | Xcode `.xcstrings` | 17 | none | S | safe | Same languages, easier review for Victoria |
| Widget (P1) | WidgetKit, App Group | 17 | none | S | safe | v2.1 |
| Daily reminder (P1) | UserNotifications | 17 | notifications, asked after the 3rd Daily with a pre-permission card | S | safe | v2.1 |
| iCloud sync (P1) | SwiftData + CloudKit | 17 | iCloud capability | M | safe | v2.1; models must stay CloudKit-compatible from v2.0 (optional fields, no unique constraints) |
| On-device teacher lines (watch) | Foundation Models | 26 | none | M | watch | Not in 2026 |

Min OS stays **iOS 17**: v1 users on 17 keep getting updates, and nothing in P0 needs 18 or 26. On iOS 26 the system bars and sheets pick up the new look automatically; our custom chrome stays as designed (D-11).

## 3. v2 architecture

Same stack, cleaner structure. Rewrite the UI, keep the content files and the data.

```
Ink.xcodeproj                 app target: composition root only (InkApp, AppContainer, routing)
Packages/
  InkDesignSystem             tokens (colors with Paper/Chalkboard appearances), fonts, wobble shapes,
                              buttons, cards, keyboard, teacher bubble, Doodle and gallows shapes, icons
  InkEngine                   pure Swift, no UI: GameEngine (state machine), Scoring, Grades, Combo,
                              InkWallet, PowerUps, SemesterProgress, DailySchedule. 100% unit-tested.
  InkContent                  word banks v2, daily lists, teacher lines, String Catalog; loader + validator
  InkData                     SwiftData schemas V1 and V2, migration plan, repositories, v1 UserDefaults importer
  InkServices                 Audio, Haptics, GameCenter, Share, Analytics (protocol, no-op by default)
  Features/                   Desk, Game, Result, Daily, Semesters, FreePlay, Stickers, ReportCard, Settings, Onboarding
```

- Swift 6 language mode, strict concurrency. `@Observable` view models, `@MainActor` UI, engine types are value types and `Sendable`.
- Navigation: one `NavigationStack` per tab with typed routes. The result is a route carrying a `GameResult` value, not ten loose parameters.
- Every mode goes through `GameEngine` → `GameResult` → `ResultRecorder` (persist session, update stats, stickers, ink, GPA). This removes bugs 8–11 by construction.
- Content is data: adding a language or a word pack is a JSON file plus a String Catalog column, not code.
- Tests: `InkEngine` unit tests (every grade boundary, combo, ink, daily index across time zones and DST), migration test with a checked-in v1.2 store, one XCUITest smoke: launch → Desk → play a word with a fixed seed → result.
- Debug menu (DEBUG builds only): pick word, set lives, jump semester, simulate date for the Daily. Hasan needs this to test without luck.

## 4. Release checklist (every TestFlight and store upload)
- Archive from the `Ink-Release` scheme; paste version, build number, bundle id and min OS read from the archived Info.plist into the MR and `docs/ios/releases.md`.
- Migration test passes against the v1.2 store fixture.
- Fonts and sounds resource test passes.
- Game Center leaderboards exist in App Store Connect for every language before the build that uses them.
- App Privacy answers updated if analytics is added (decision D-10).
- Hasan's smoke checklist signed in the MR.

New: a DEBUG "date machine" that sets the Daily date and time zone (safe) - lets Hasan test the daily rollover, DST and the hall pass in minutes - judged by the daily test cases running without waiting for midnight.
