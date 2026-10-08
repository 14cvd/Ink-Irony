# Ink & Irony

Hangman-style word game for iPhone with a sarcastic teacher who grades you live in red pen. Five languages (en, tr, az, ru, es). Live on the App Store (id 6760973464) as v1.2.0. v2.0 is a full redesign with new mechanics.

## Vision
See `product/v2-vision.md`. One line: the word game where a sarcastic teacher grades you live in red pen; a few words a day, from Kindergarten to PhD, in five languages.

## Big picture map
Business (who pays) -> nobody in v2.0; no IAP, ads or subscriptions until retention is proven (D-9)
-> Product (what the player does in one tap) -> opens the Desk, taps "Play word N", guesses letters while the teacher reacts, gets a graded exam
-> Technology -> SwiftUI, SwiftData, GameKit, all content on device, no backend (Sid)
-> Players -> casual word-game players and multilingual players in the five language markets

## Decisions
- D-1 Budget assumed zero; sounds are the one possible cost (founder to confirm)
- D-2 Keep all five languages; no new language in v2
- D-3 Keep name, icon, teacher persona, notebook concept, word banks and players' data
- D-4 Release as an App Store update v1.2.0 → v2.0.0 after TestFlight
- D-5 Canan decides product and design first; the founder has the final word
- D-6 Min iOS stays 17; iPhone only, portrait
- D-7 v2.0 scope: redesign, core loop 2.0, Semesters, Teacher 2.0, Daily 2.0, content, migration. Blitz, Duel, widget, Word notebook, iCloud move to v2.1
- D-8 Data migration is a release blocker; nothing is ever deleted
- D-9 No monetisation in v2.0
- D-10 Analytics: App Store Connect only, or TelemetryDeck (Canan recommends TelemetryDeck) - **founder to decide**
- D-11 Visual direction: Detention Notebook (light) + Chalkboard (dark). An iOS-native chrome variant was tried and rejected by the founder on 2026-10-08 ("looked terrible"); iOS-native applies to behaviour only (founder decided)

## Metric tree
North star: words solved per weekly active player. Branches: activation, habit (Daily), retention (D1/D7/D30), virality (shares), quality (crash-free, rating). Targets in `product/v2-vision.md`; baselines pending the founder's App Store Connect export.

## Status (2026-10-08)
- Kickoff held: `projects/ink-irony-v2-kickoff-2026-10-08.md`
- Design audit and direction (Marry): `design/audit.md`, `design/v2-direction.md`, `design/kit/tokens.json`, canvas https://claude.ai/artifact/UpERModhD4kW3BpRjSGyVD (Game artboard is playable)
- Vision, epics and stories (Canan): `product/v2-vision.md`, `product/stories/v2-epics.md`
- Tech audit and architecture (Sid): `analysis/ios-v2-tech-audit.md`
- Roadmap: `product/roadmap.md` (v2.0 submit Jan 5, 2027, release Jan 12, 2027)
- No code changed yet. Work is on branch `v2/planning`, not committed.
- Next: founder decisions (D-1, D-10, sound budget, App Store Connect export); Sid MR-1 to MR-3 by Oct 16

## Languages
UI and words: en, tr, az, ru, es. v1 strings live in `LocalizationService.swift`; v2 moves them to a String Catalog. Victoria reviews tone and translation.

## Technical map
- Xcode project `Ink.xcodeproj`, one app target, bundle id `com.id.ink.irony`, v1.2.0 build 1
- SwiftUI, SwiftData, Combine, AVFoundation, CoreHaptics; Swift 5 mode today, Swift 6 in v2
- Min iOS 17 (target), project-level setting says 26.0 (to clean up); iPhone only, portrait
- Content: `Ink/Resources/words_<lang>.json` (72–124 words each); no fonts or sounds bundled yet
- v2 plan: local packages InkDesignSystem, InkEngine, InkContent, InkData, InkServices + feature modules

## Design evolution log
- 2026-10-08 - v2 redesign - before: v1.2 - after: Detention Notebook + Chalkboard dark - new idea: ghost-to-ink gallows (experiment, lives at a glance) - founder: liked it, asked for more iOS style
- 2026-10-08 - iOS-native chrome variant - founder: "looked terrible, continue with the previous design" - reverted, D-11

## Weekly review
First review due Monday 2026-10-12.
