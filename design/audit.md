# Design audit: Ink & Irony v1.2 (Marry, 2026-10-08)

Source: the shipped code on `master` (v1.2.0, build 1), read screen by screen. No device recording yet; the founder should send one 30-second screen recording of a full game so the motion review in step 7 has a baseline.

## Headline

The concept is strong and worth keeping: a strict, sarcastic teacher, a notebook, a red pen. The execution does not reach it yet. Three of the four brand pillars are not actually on screen:

1. **The custom fonts are not in the app.** `Caveat`, `Special Elite` and `Courier Prime` are referenced in code, but no font file and no `UIAppFonts` entry exist. Every screen renders in the system font. The "handwritten sketchbook" look the README describes is not what players see.
2. **The sounds are not in the app.** `AudioService` loads six `.mp3` files that are not in the bundle. The game is silent.
3. **The teacher is not context-aware.** `TauntService` cycles 20 lines in a fixed order and resets each game, so every game opens with the same first line. Players see the same roast after the first two games.

## Keep / fix / drop

| Element | Where it lives | Verdict | Reason | Owner |
|---|---|---|---|---|
| Teacher persona and dry, academic sarcasm | `TauntService`, copy | keep | It is the brand. Nothing in the category has it. | Marry, Victoria |
| Notebook paper: ruled lines, red margin | `PaperBackgroundModifier` | keep | Instantly readable metaphor. Evolve the colors, keep the idea. | Marry |
| Hand-drawn stroke (`handDrawnStroke`) | `ThemeManager` | fix | Today it is a dashed triple stroke that reads as "dashed border", not "pen". Replace with a pre-rendered wobble path (seeded, not random per frame). | Sid |
| Scratched-out wrong keys | `DynamicKeyboardView` | keep | Good, honest feedback. Add strike-through so it is not colour-only. | Marry |
| Speech bubble with jagged outline | `TauntBubbleView` | fix | `CGFloat.random` inside `path(in:)` re-shapes the bubble on every layout pass, so it shimmers. Seed the randomness per line. | Sid |
| Fonts | code only | fix | Bundle the three OFL / Apache fonts, check glyph coverage for az, tr, ru, es. | Sid |
| Sound | code only | fix | Commission or license 8 short sounds (pen tick, scratch, stamp, page flip, paper tear, thud, chime, chalk). | Marry, founder (budget) |
| Gallows: 8 equal parts scaled from lives | `SketchGallowsView` | fix | Lives are only readable through the "LIVES: 6" text. Becomes the ghost-to-ink gallows (one new idea, below). | Marry, Sid |
| Main menu: four stacked identical buttons | `ContentView.MainMenu` | drop | No hierarchy; "Start exam" and "Settings" look equally important. Replaced by the Desk (home) with one primary action. | Marry |
| Setup form: language, 8 topics, 4 levels before every game | `GameSetupView` | drop as the default path | Three decisions before the first letter. Becomes Quick Play from the Desk; the form survives as "Free play". | Marry, Canan |
| Emoji as icons (🎓 📕 💡 ⏰ 🔬) | Result, Daily, Game | drop | Emoji break the hand-drawn style and render differently per iOS version. Replace with a 24-icon stroke set. | Marry |
| Dark theme as default, blue ink on charcoal | `ThemeManager` | fix | Reads as a generic dark app, not a notebook. Default follows the system; dark becomes the Chalkboard theme. | Marry |
| Native segmented `Picker` in Records | `RecordsView`, `LeaderboardView` | fix | Only native control in an otherwise custom world; restyle as notebook tabs. | Sid |
| Keyboard grid `adaptive(40–50)` with left padding only | `GameView` | fix | Keyboard is off-centre (32 pt left, 16 pt right) and wraps 26 letters into 6/6/6/6/2. Replace with fixed rows per alphabet. | Sid |
| Result screen: emoji + stat chips | `ResultScreen` | fix | Becomes a graded exam paper with the score math written in red pen. | Marry |
| "Achievement Unlocked!" | `ResultScreen` | fix | Hard-coded English in a 5-language app. | Sid, Victoria |
| Daily "Today's class" leaderboard | `DailyChallengeView` | drop | Reads the local `UserDefaults` only, so it only ever lists the player. Replaced by Game Center friends. | Sid |

## Trust moments in a word game

For this app, "trust" means the player believes the game is fair and the teacher is funny, not mean.

| Moment | Today | v2 target |
|---|---|---|
| First 10 seconds | Onboarding says "Don't fail." then a menu of four equal buttons | Teacher greets, one button plays a word |
| A wrong guess | Gallows part appears, same roast order every game | Red pen inks one ghost part, Doodle reacts, a line that fits the moment |
| How many lives are left | Read the text "LIVES: 6" | See the remaining ghost parts at a glance |
| Score | Formula hidden; slower = lower; Nightmare scores less than Easy | Score math written on the exam paper |
| Daily | Word changes on every app launch, "everyone" is only you | One word per day for everyone, shareable without spoilers |

## Accessibility (measured on the v2 palette)

| Pair | Ratio | Result |
|---|---|---|
| ink #1F2A44 on paper #F7F0E3 | 12.6:1 | AAA |
| red pen #C2362F on paper | 4.8:1 | AA |
| pencil green #2C7A51 on paper | 4.6:1 | AA |
| graphite #5E5A54 on paper | 6.0:1 | AA |
| chalk #EDEAE2 on board #1F2B27 | 12.2:1 | AAA |
| chalk red #FF8A7A on board | 6.4:1 | AA |
| v1 dark ink #6B9FE8 on #1C1C1E (for reference) | 6.3:1 | AA |

Dynamic Type: v1 uses `relativeTo:` correctly for the four type roles, but many views pass a fixed `.font(.custom(..., size:))` (word display 48, title 36, emoji 72). v2 maps every style to a text style.
