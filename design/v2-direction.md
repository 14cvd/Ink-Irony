# Ink & Irony v2: design direction (Marry, 2026-10-08)

Canvas with every screen (the Game artboard is playable): https://claude.ai/artifact/UpERModhD4kW3BpRjSGyVD
Tokens: `design/kit/tokens.json`. Audit this builds on: `design/audit.md`.

## Three directions

### A. Detention Notebook (recommended)
- Mood: a school notebook in a strict teacher's class; you are the student, the teacher is grading you in red pen, live.
- Palette: paper #F7F0E3, sheet #FFFDF7, ink #1F2A44, red pen #C2362F, pencil green #2C7A51, highlighter #FFE45C, blue ink #2F5DA8, graphite #5E5A54.
- Type: Caveat 700 (words, titles, buttons), Special Elite (the teacher's voice only), Courier Prime (UI, numbers).
- Motion sample: a gallows part goes from faint pencil to red ink, 450 ms, trim 0→1, easeOut.
- Keeps from v1: notebook paper, red margin, the teacher, scratched-out keys, the three font families (now actually bundled).
- Risk: paper textures can look busy; mitigated by flat colors plus one offset ink shadow (4 pt) on raised cards only.

### B. Red Pen Riso
- Mood: a two-colour risograph poster, slightly misregistered, loud.
- Palette: cream, fluorescent red, federal blue, nothing else; halftone fills.
- Type: a condensed grotesk for UI, Caveat for the word.
- Risk: drifts away from the notebook the brand and the App Store screenshots are built on. Good for a seasonal theme pack later (`watch`).

### C. Chalkboard
- Mood: the same classroom at night: board green, chalk white, chalk yellow and red.
- Palette: board #1F2B27, slate #26352F, chalk #EDEAE2, chalk red #FF8A7A, chalk green #7FD8A6, chalk yellow #F4D35E, chalk blue #9CC8FF.
- Risk: on its own it loses the "red pen grading you" joke.

**Recommendation:** A as the app, C as its dark theme (follows the system setting, can be forced in Settings), B to Tom's watch list as a theme pack. Same layout and tokens in both themes; only colour tokens swap.

## Screens in v2.0

| Screen | Purpose | Primary action | States |
|---|---|---|---|
| Desk (home) | One obvious next step | Continue semester (Quick Play) | first launch, semester in progress, semester finished, daily done / not done |
| Game | Guess the word | Tap a letter | playing, combo, low lives (2 left), won, lost, paused (app backgrounded), power-up not affordable |
| Result: graded exam | Explain the score, reward, next | Next word | win, loss, new sticker, semester completed, final exam passed / failed |
| Daily Exam | Same word for everyone today | Play, then share | not played, played (win / loss), offline, Game Center signed out |
| Semesters | Progression map | Play current word | locked, current, completed with grade, final exam |
| Free play | v1 setup, kept for players who want control | Start | — |
| Stickers | Achievements as a sticker book | — | earned, locked with hint |
| Report card | Stats, GPA, streaks, words per language | — | empty (new player), with data |
| Settings | Language, theme, sound, haptics, teacher's savage level | — | — |

## Layout rules
- 20 pt side margins; the red margin line sits at x = 28 behind cards.
- Raised cards: sheet colour, 2 pt ink border, radius 14–18, one 4 pt offset shadow in ink. Never more than one raised card per screen region.
- Primary button: ink fill, Caveat 28, height 56, 3 pt offset shadow in red pen. One primary button per screen.
- Keyboard: fixed rows per alphabet, centred, key height 52, 5 pt gaps. en 9/9/8, es 9/9/9, tr 10/10/9, az 11/11/11, ru 11/11/11. Keys never shrink below 29 pt wide; the gap belongs to the hit area so every target is at least 44 pt.
- Word slots: one slot per letter, Caveat 42, slot width shrinks with word length down to 22 pt, then the word wraps to two lines at a space (multi-word answers in movies and literature).

## The one new idea for this batch
**Ghost-to-ink gallows** (`experiment`).
- Before: lives are a number ("LIVES: 6") and the gallows draws equal parts scaled from 8.
- After: every remaining life is a faint dashed pencil part; each mistake, the teacher's red pen inks one in (450 ms). The Doodle stands on a stack of books and reacts: calm, then sweating at 2 mistakes, panicking at 4. Win: the Doodle jumps and runs off the page. Loss: the books tumble.
- Number of parts equals the lives of the level (Kindergarten 8 ... Final exam 3), so the drawing always shows exactly what is left.
- Usability reason: the player reads remaining lives in peripheral vision while looking at the word, without reading text.
- Measure: in the TestFlight round, players answer "how many lives did you have left?" right after a loss; target 90% correct. Exit: if under 70%, add the small "4 of 6 lives left" caption back above the stage (already in the design as a secondary label, so the exit costs nothing).

## Motion spec
In the System artboard on the canvas: 8 motions, each with duration, curve, reduced-motion fallback and the paired haptic and sound. To be reviewed on a real iPhone at real speed with Sid before sign-off; nothing is approved from the desktop preview.

## Handoff notes for Sid
- Tokens in `design/kit/tokens.json`, mapped 1:1 to an `InkDesignSystem` Swift package (colour assets with Any / Dark appearances, so the theme switch is free).
- Fonts: Caveat (OFL), Special Elite (Apache 2.0), Courier Prime (OFL). Check glyph coverage for Ə, Ğ, İ, Ş, Ñ and Cyrillic before handoff is signed; name a fallback for any script a face misses.
- The Doodle and Teacher are vector shapes (SwiftUI `Shape`), not images, so expressions are path swaps and the theme recolours them.
- Wobble: pre-compute one seeded jitter per shape; never call `random` in `path(in:)` or `body`.
- Icons: 24 pt stroke set, 2 pt line, round caps; I deliver them as SF Symbols-compatible SVG templates.

## Design evolution log
- 2026-10-08 - v2 redesign - before: v1.2 (system font, silent, four-button menu, text lives) - after: Detention Notebook + Chalkboard dark - new idea: ghost-to-ink gallows - reason: lives at a glance - label: experiment - founder: "beautiful", asked whether it could be more iOS-style.
- 2026-10-08 - iOS-native variant tried - before: Detention Notebook - after: same brand on iOS chrome (SF Pro, large titles, inset-grouped lists, floating glass tab bar, iOS keyboard keys, bottom sheet) on Home and Game - founder: "looked terrible, continue with the previous design". Reverted the same day. **Decision D-11: Detention Notebook is the v2 look.**
  - Lesson: the personality of this app lives in its chrome (ink borders, offset shadows, handwritten buttons). Swapping the chrome for system components made it look like every other app. iOS-native stays in behaviour only: navigation gestures, haptics, Dynamic Type, VoiceOver, safe areas, sheet and swipe-back behaviour, system share sheet.
