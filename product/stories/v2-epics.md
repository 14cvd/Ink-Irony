# Ink & Irony v2: epics and stories (Canan, 2026-10-08)

Priorities: P0 = v2.0 (must ship), P1 = v2.1, P2 = later / watch. Every story needs Hasan's "testable" and Sid's "buildable" before it enters a sprint. Copy status: all strings pending Victoria (en, tr, az, ru, es).

## Game rules v2 (single source of truth for scoring)
- Correct guess: `10 × occurrences × multiplier`. Multiplier = current combo, 1 to 5. A wrong guess or any power-up resets the combo.
- Lives bonus at a win: `10 × lives left`.
- Power-up penalty: `-20` score per power-up used (they also cost ink).
- No time penalty in Semesters, Free play or Daily. Time only matters in Blitz (v2.1).
- Grade from `f = mistakes / lives`: A+ (0 mistakes, no power-ups), A (f ≤ 0.17), A- (f ≤ 0.34, or any power-up used), B (≤ 0.5), C (≤ 0.67), D (won with f > 0.67), F (lost). GPA: A+ 4.3, A 4.0, A- 3.7, B 3.0, C 2.0, D 1.0, F 0.
- Ink drops: start 100. Earn: win `15 + 2 × lives left`, Daily +25, semester passed +100. Spend: Eraser 30 (undo the last mistake), Reveal 40 (show one letter), Hint 20 (show the hint line). Final exams allow no power-ups.
- Lives by semester: 8, 7, 6, 5, 4, 3. Final exam (word 10): one life fewer.

---

## E1 Foundation and honesty fixes (P0) - safe
Goal: v2 runs on a base that keeps players' data and actually shows the fonts and plays the sounds.

**IV2-01** As a v1 player, I want my games, stats and achievements to survive the update, so that v2 feels like a gift, not a reset.
- Given a device with v1.2 data (SwiftData sessions, UserDefaults stats, achievements), when v2 launches for the first time, then all sessions appear in the Report card, totals match v1, and each earned achievement appears as a sticker.
- Edge: v1 store fails to open → v2 keeps the old file aside (renamed), starts a new store, shows nothing broken, and logs `migration_failed`. Never delete.
- Metric: `migration_completed` with counts.

**IV2-02** As a player, I want the handwritten fonts and sounds the app promises.
- Given a fresh install on any supported language, when any screen loads, then Caveat, Special Elite and Courier Prime render (no system fallback) for every letter of that language's alphabet.
- Given sound is on, when I guess, then the pen tick (correct) or scratch (wrong) plays within 50 ms; silent mode switch is respected.

**IV2-03** As a player on Easy / Kindergarten, I want no hidden timer, so I am never failed for thinking. (Fixes the 60 s timeout on Easy.)

## E2 Detention Notebook UI (P0) - safe
Screens per `design/v2-direction.md` and the canvas.

**IV2-10** Desk (home). Given a returning player, when the app opens, then the Desk shows the teacher's line, the Continue card for the current semester and the Daily card, and "Play word N" starts that word in one tap.
- Edge: first launch → Continue card reads "Kindergarten, word 1" and the onboarding is one screen (teacher intro + language pick prefilled from the device locale).

**IV2-11** Game screen with ghost-to-ink gallows. Given a level with L lives, when the word starts, then L ghost parts are drawn; when I make a mistake, then exactly one part turns to red ink (450 ms) and the Doodle's face changes at 2 and 4 mistakes.
- Edge: Reduce Motion on → parts swap instantly, no Doodle run-off.
- Edge: VoiceOver reads "4 of 6 lives left" after each guess.

**IV2-12** Keyboard per alphabet. Given language X, when the game starts, then keys are laid out in fixed centred rows (en 9/9/8, es 9/9/9, tr 10/10/9, az 11/11/11, ru 11/11/11), every hit target is at least 44 pt tall, and wrong keys show dash + strike-through.

**IV2-13** Graded exam result. Given a finished word, when the result appears, then it shows the word, its definition, the letter grade, the score lines from the rules above (adding up to the total), ink earned, GPA change and any new sticker.

**IV2-14** Chalkboard dark theme follows the system setting; Settings can force Paper or Chalkboard.

**IV2-15** Stickers and Report card replace Achievements, Statistics, Records and Leaderboard screens (one tab each).

## E3 Core loop 2.0 (P0) - experiment for the combo and power-up values
**IV2-20** Combo. Given 3 correct guesses in a row, when I guess a 4th correct letter, then the badge shows ×4 and that letter scores ×4; when I miss, then the badge disappears.

**IV2-21** Power-ups. Given 120 ink and 2 mistakes, when I tap Eraser, then the last inked part returns to ghost, the wrong key stays disabled, ink becomes 90 and the teacher comments.
- Edge: not enough ink → button disabled, tapping it shows "30 ink needed" (no purchase prompt in v2.0).
- Edge: final exam → power-up row hidden, teacher says why.

**IV2-22** Grades and GPA calculated exactly per the rules table; unit tests cover every grade boundary.

Exit rule for the experiment: if TestFlight players use Reveal on more than 40% of words, raise its price or cap it to one per word before release.

## E4 Semesters (P0) - safe
**IV2-30** As a player, I want to climb from Kindergarten to PhD, so that each session moves me forward.
- Given semester N in progress, when I finish word k, then word k+1 unlocks; word 10 is the final exam.
- Given the final exam is done, when the semester GPA is 2.0 or more, then semester N+1 unlocks with +100 ink; below 2.0, the teacher offers a retake of the semester (words reshuffled from the same pool).
- Edge: progress is per language. Switching language keeps each language's progress.
- Content: 6 semesters × 10 words × 5 languages from the graded word bank (E7), plus a reserve of 10 per semester for retakes.

**IV2-31** After PhD: "Tenure", endless words at PhD level, GPA keeps updating. (P1 if time is short.)

## E5 Teacher 2.0 (P0) - safe
**IV2-40** Context-aware lines. Triggers: word start, first mistake, mistakes 2..5, lost, won flawless, won narrowly, combo 3+, power-up used, final exam start, returning after 3+ days away, daily done. At least 6 lines per trigger per tone per language; never the same line twice within 5 games.
**IV2-41** Tones: Strict (default) and Gentle. Gentle never mentions failure words; Kindergarten uses Gentle unless the player opts in to Strict.
- Copy rule (Victoria): roast the guess, never the person. No lines about intelligence, appearance, nationality or language ability.
- Content size: about 11 triggers × 6 lines × 2 tones × 5 languages = 660 lines.

## E6 Daily Exam 2.0 (P0) - safe
**IV2-50** Deterministic word. Given date D (device local date) and language X, when any player opens the Daily, then they get the same word, chosen from a pre-ordered list (`daily_<lang>.json`, index = days since 2026-01-01), never from `hashValue`.
**IV2-51** Spoiler-free share. When I tap Share, then the system share sheet gets: "Ink & Irony #212 · PASSED · 1 mistake" plus a row of squares (green per hit, red X per miss) and the App Store link; the word is never in the text.
**IV2-52** Game Center leaderboard per language per day (score = mistakes then time). Signed out → the card says "Sign in to Game Center to see your class" and the rest works.
**IV2-53** Streak with hall pass: one missed day per week does not break the streak; the second does.
**IV2-54** Daily results count for stats, GPA is not affected, stickers can unlock.

New: spoiler-free share card (safe) - Wordle proved the loop - virality branch.

## E7 Content (P0) - the long pole
**IV2-60** Word bank v2 schema: `{word, category, tier 1-6, hint, definition, source}` per language; tier is set by a reviewer, not by length.
- Targets per language: 600 words (100 per tier) + 365 daily words. Total 4,825 entries.
- Process: drafted with Claude from frequency lists, reviewed by a native speaker per language (Victoria owns az, ru, tr; external reviewer for es), validated by a script (alphabet, uniqueness, no offensive words, hint does not contain the word).
**IV2-61** Teacher lines (E5) through the same review.

---

## P1 (v2.1, target February 2027)
- **E8 Blitz**: 60 s, as many words as possible, short words, a time bonus per word, own Game Center leaderboard. (`safe`)
- **E9 Duel, pass and play**: player A types a word and a hint, hands the phone to player B, the teacher roasts both; best of 3. (`experiment`: measure share of sessions that are Duels in 2 weeks; exit if under 5%.)
- **E10 Widget + reminder**: Daily Exam widget (streak, done / not done) and an opt-in daily reminder asked after the third Daily, never at launch.
- **E11 Word notebook**: every solved word saved with definition, per language, searchable; "practice these" mode.
- **E12 iCloud sync** of progress via SwiftData + CloudKit.

## P2 / watch (Tom's list)
- Async duels via Game Center turn-based matches
- Theme packs (Red Pen Riso, Chalkboard Neon) and word packs as in-app purchases, after retention is proven
- Apple Foundation Models (on-device) for extra teacher lines, guarded by the copy rule; only on supported devices
- Apple Watch Daily Exam
