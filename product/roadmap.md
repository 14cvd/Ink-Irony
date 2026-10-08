# Ink & Irony v2: development roadmap (Canan + Sid, 2026-10-08)

Assumptions: one iOS developer full-time (Sid, with Claude Code), Marry part-time on design, Victoria and native reviewers on content, Hasan on QA from sprint 2. Two-week sprints. Dates are targets; the gates are not negotiable.

## At a glance

| Phase | Dates | Goal | Exit gate |
|---|---|---|---|
| 0. Decisions and foundation | Oct 9 – Oct 16 | Founder decisions, project cleanup, data migration first | Migration test passes on a real v1.2 store |
| Sprint 1. Engine + design system | Oct 19 – Oct 30 | `InkEngine` and `InkDesignSystem` packages | Engine tests green; components reviewed by Marry on a device |
| Sprint 2. Core screens | Nov 2 – Nov 13 | Desk, Game (ghost gallows, combo, power-ups), Result | A full word playable on device with the new look and sound |
| Sprint 3. Progression and daily | Nov 16 – Nov 27 | Semesters, Daily 2.0 + Game Center + share, Teacher 2.0, Stickers, Report card, Settings, Free play, onboarding | Feature complete for v2.0 |
| Content track (parallel) | Oct 12 – Nov 27 | 600 words + 365 daily per language, about 660 teacher lines, native review | Validator script green for all 5 languages |
| Sprint 4. Polish and freeze | Nov 30 – Dec 11 | Motion on device, accessibility, dark theme, localization QA, debug menu | Code freeze Dec 11 |
| TestFlight beta | Dec 14 – Jan 3 | 30–50 external testers incl. az, tr, ru, es speakers | Release gate (below) |
| App Store | Submit Jan 5, 2027; release Jan 12, 2027 (7-day phased release) | v2.0 live | Crash-free sessions 99.5%+ in week 1 |
| v2.1 | Jan 13 – Feb 23, 2027 | Blitz, Duel, widget, reminder, Word notebook, iCloud sync | Decided by v2.0 week-4 numbers |
| v2.2 (candidates) | Mar – Apr 2027 | Async duels, theme or word packs (first monetisation test) | Only if D7 retention target was met |

Why not ship before New Year: Apple's review slows down over the holidays, and a v2 that loses player data or ships with half the content would cost more ratings than a three-week wait.

## Phase 0: decisions and foundation (Oct 9 – Oct 16)

| Item | Owner | Due | Result visible in |
|---|---|---|---|
| Confirm budget (D-1), analytics choice (D-10), sound budget | Founder | Oct 10 | `projects/ink-irony.md` Decisions |
| Export App Store Connect numbers (90 days) | Founder | Oct 10 | `product/v2-vision.md` metric tree |
| MR-1: project cleanup (one team, min iOS 17 everywhere), Swift 6 mode, test targets, package skeleton | Sid | Oct 13 | MR + `analysis/ios-v2-tech-audit.md` §3 |
| MR-2: `InkData` schema V1 + V2, migration plan, v1 `UserDefaults` importer, test with a real v1.2 store fixture | Sid | Oct 16 | MR, test report |
| MR-3: fonts registered + sound placeholders + resource tests | Sid | Oct 16 | MR |
| Glyph check for 3 fonts × 5 languages; icon set (24 icons); Doodle and Teacher shapes as SVG paths | Marry | Oct 16 | `design/kit/` |
| Stories reviewed: testable (Hasan), buildable (Sid), copy rules (Victoria) | Canan | Oct 16 | `product/stories/v2-epics.md` |
| Content pipeline: schema, validator script, first 100 words per language | Victoria, Canan | Oct 16 | `Ink/Resources/v2/`, `tools/validate_content.py` |

## Sprint 1: engine and design system (Oct 19 – Oct 30)
- `InkEngine`: `GameEngine` state machine, `Scoring`, `Grades`, `Combo`, `InkWallet`, `PowerUps`, `SemesterProgress`, `DailySchedule` (time zones, DST), full unit tests.
- `InkDesignSystem`: colour tokens with Paper / Chalkboard appearances, type scale with Dynamic Type, wobble shapes (seeded), primary and secondary buttons, cards, keyboard for 5 alphabets, teacher bubble, ghost gallows + Doodle with all expressions, grade stamp.
- Marry and Sid review components on an iPhone at real speed.

## Sprint 2: core screens (Nov 2 – Nov 13)
- Desk, Game, Result (graded exam), routing with typed routes, `ResultRecorder` (one path for every mode).
- Audio and haptics mapped to the motion table.
- Hasan starts the regression checklist; first internal TestFlight build at the end of the sprint.

## Sprint 3: progression and daily (Nov 16 – Nov 27)
- Semesters (6 × 10, final exams, retake), Teacher 2.0 picker with no-repeat window and Gentle tone.
- Daily 2.0: daily lists, share card, Game Center leaderboards (set up in App Store Connect first), hall pass streak.
- Stickers (v1 achievements migrated), Report card, Settings, Free play, one-screen onboarding.
- Analytics events if D-10 says yes.

## Sprint 4: polish and freeze (Nov 30 – Dec 11)
- Motion review on device, Reduce Motion fallbacks, VoiceOver labels, Dynamic Type up to AX3 on the Desk and Result.
- Chalkboard theme pass, localization QA with Victoria in all 5 languages.
- Migration tested on 3 real devices that had v1.2 with data.
- DEBUG menu and the date machine for Hasan.
- Nicolas: store screenshots and preview video from the final build, "What's new" copy, launch posts. Copy may show only what is in the build.

## Release gate for v2.0 (Hasan runs it, before submission)
1. Fresh install and update-from-v1.2 both pass the smoke checklist on iOS 17 and iOS 26.
2. Migration: history, stats and achievements present after update on every test device.
3. Daily: same word on two devices in two time zones for the same local date; rollover at local midnight.
4. Every language: full word playable, all letters of the alphabet on the keyboard, fonts render every glyph.
5. Crash-free sessions in TestFlight ≥ 99.5%; no open blocker.
6. Archive check pasted in the MR (scheme, version 2.0.0, build number, bundle id).
7. Nicolas confirms that screenshots and copy show only shipped features.

## Risks

| Risk | Likelihood | Impact | Mitigation | Owner |
|---|---|---|---|---|
| Content not reviewed in time (4,825 words + 660 lines) | high | release slips | Start Oct 12; ship v2.0 with 300 words per language if needed (Semesters need 120); daily list only needs 90 days at launch | Canan, Victoria |
| Data loss on update | medium | ratings crash | Migration is MR-2, tested with a real store, part of the gate | Sid, Hasan |
| One developer for 9 weeks of build | medium | slip | Cut order if late: Free play polish → Tenure mode → Chalkboard theme (ship light only) → Gentle tone | Canan |
| Hanging imagery or roast tone rejected in a market | low | review or ratings | Doodle escapes, no body hangs; Gentle tone; Victoria checks all 5 languages | Marry, Victoria |
| Game Center leaderboards not configured | low | Daily card empty | Set up in Phase 0; card works signed out | Sid |
| Holiday review delay | medium | release a week later | Submit Jan 5; buffer to Jan 12 | Sid |

## What each role delivers, and where

| Role | Deliverable | Path |
|---|---|---|
| Marry (design) | Canvas, direction, tokens, icon set, motion review notes | https://claude.ai/artifact/UpERModhD4kW3BpRjSGyVD, `design/` |
| Canan (product) | Vision, stories, decision log, weekly review | `product/`, `projects/ink-irony.md` |
| Sid (iOS) | Tech audit, MRs, release log | `analysis/ios-v2-tech-audit.md`, `docs/ios/releases.md` |
| Victoria (language) | Word banks, teacher lines, copy review in 5 languages | `Ink/Resources/v2/` |
| Hasan (QA) | Test cases, smoke checklist, release gate result | `qa/v2/` |
| Nicolas (marketing) | Store listing, screenshots, launch posts | `marketing/v2/` |
