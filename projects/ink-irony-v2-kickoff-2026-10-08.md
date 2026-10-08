# Ink & Irony v2 - Kickoff session (2026-10-08)

Participants: Marry (design), Canan (product, facilitator), Sid (iOS). Victoria, Hasan and Nicolas named as owners of follow-ups. Founder joined during the design review.
Topic: v2 of the live App Store app: full redesign, more fun, better mechanics; then new features, then a development roadmap.

---

## 1. Marry - design audit and direction
The concept (sarcastic teacher, notebook, red pen) is the brand and stays. The execution does not show it yet: the fonts and sounds are not in the bundle, so players see the system font and hear nothing, and the teacher repeats the same lines in the same order. Main menu is four equal buttons; three choices stand between the player and the first letter.

Three directions: A Detention Notebook, B Red Pen Riso, C Chalkboard. Recommended A, with C as the dark theme and B on the watch list. One new idea: ghost-to-ink gallows (remaining lives drawn in faint pencil, inked in red per mistake; the Doodle reacts, escapes on a win).

Founder: liked it, asked whether it could look more iOS-like. Marry tried an iOS-native chrome on Home and Game (SF Pro, large titles, grouped lists, glass tab bar, iOS keyboard). Founder: "looked terrible, continue with the previous design." Reverted the same day (D-11). iOS-native stays in behaviour, not in chrome.

Files: `design/audit.md`, `design/v2-direction.md`, `design/kit/tokens.json`, canvas https://claude.ai/artifact/UpERModhD4kW3BpRjSGyVD

## 2. Canan - vision and features
Problem: one session is one word with no progression; the daily is not the same for everyone; the score is opaque. Vision: the teacher grades you live; you climb semesters; you come back for the Daily.
P0 for v2.0: redesign, core loop 2.0 (combo, grades, ink drops, Eraser / Reveal / Hint), Semesters (6 × 10 words, final exams, GPA), Teacher 2.0 (context-aware lines, Strict and Gentle), Daily 2.0 (deterministic word, spoiler-free share, Game Center, hall pass), content (600 + 365 words per language), migration.
P1 (v2.1): Blitz, Duel pass-and-play, widget and reminder, Word notebook, iCloud sync. Not in v2: online multiplayer, monetisation, accounts, new languages, AI-generated taunts.

Sid challenged: Semesters and the Teacher are cheap in code but expensive in content; content is the long pole, not Swift. Canan agreed and added the cut order to the roadmap.

Files: `product/v2-vision.md`, `product/stories/v2-epics.md`

## 3. Sid - technical audit and plan
18 findings. The one that decides the plan: v1 deletes its SwiftData store on a schema change, so a careless v2 update would wipe every player's history. Migration is MR-2 and a release gate. Others: daily word uses a per-launch random hash; Easy games time out at 60 s; achievements do not match their descriptions; three copies of the score formula; no tests.
Architecture: same stack (SwiftUI, SwiftData, iOS 17+), split into local packages (DesignSystem, Engine, Content, Data, Services) with one `GameEngine` → `GameResult` → `ResultRecorder` path for every mode.

Files: `analysis/ios-v2-tech-audit.md`, `product/roadmap.md`

---

## Decision
v2.0 = Detention Notebook redesign + core loop 2.0 + Semesters + Teacher 2.0 + Daily 2.0 + content + migration. Submit Jan 5, 2027; release Jan 12, 2027. Open for the founder: D-1 budget, D-10 analytics, sound budget.

## Action items

| Owner | Action | Due | Visible in |
|---|---|---|---|
| Founder | Confirm D-1 budget, decide D-10 analytics and the sound budget | 2026-10-10 | `projects/ink-irony.md` |
| Founder | Export App Store Connect numbers (90 days) | 2026-10-10 | `product/v2-vision.md` |
| Sid | MR-1 project cleanup + packages; MR-2 migration with v1.2 fixture; MR-3 fonts and sound resources | 2026-10-16 | MRs |
| Marry | Glyph check, icon set, Doodle and Teacher paths, motion review plan | 2026-10-16 | `design/kit/` |
| Canan | Stories accepted by Hasan and Sid; decision log current | 2026-10-16 | `product/stories/v2-epics.md` |
| Victoria | Content schema, validator, first 100 words per language, copy rules for the teacher | 2026-10-16 | `Ink/Resources/v2/` |
| Hasan | v2 test plan and release gate checklist | 2026-10-30 | `qa/v2/` |
| Nicolas | Store listing plan for v2 (screenshots, preview video, "What's new") | 2026-11-27 | `marketing/v2/` |

## Risks raised
- Content volume (Canan, Sid) - cut order and minimum content set in the roadmap
- Data loss on update (Sid) - migration first, part of the gate
- Single developer capacity (Canan) - cut order
- Gallows imagery and roast tone across five markets (Marry) - Doodle escapes, Gentle tone, Victoria review

## Innovation items
- Ghost-to-ink gallows - `experiment` (Marry) - lives at a glance; exit: add the text caption back
- Spoiler-free Daily share card - `safe` (Canan) - virality
- DEBUG date machine for the Daily - `safe` (Sid) - tests rollover and DST without waiting
- Red Pen Riso theme pack - `watch` (Marry)
- On-device teacher lines with Apple Foundation Models - `watch` (Sid)
- Async duels via Game Center turn-based - `watch` (Canan)
