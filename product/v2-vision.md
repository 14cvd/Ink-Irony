# Ink & Irony v2 Vision (Canan, 2026-10-08)

## Kickoff checklist
| Item | Answer | Status |
|---|---|---|
| Budget | Assumed zero: no paid services, no backend. Fonts are open-licensed. Sounds are the one possible cost. | Founder to confirm (D-1) |
| Languages | Keep all five: en, tr, az, ru, es, for UI and words. No new language in v2. | Assumed (D-2) |
| Existing assets to keep | Name, icon, the teacher persona, notebook concept, word banks, players' saved history and stats | Decided by audit (D-3) |
| Release channel | App Store update of the existing app (id 6760973464), v1.2.0 → v2.0.0, after a TestFlight round | Assumed (D-4) |
| Decision owner | Canan decides product and design first and logs it; the founder has the final word | (D-5) |

## Problem
v1 is a well-dressed classic hangman. One session is one word, then a form, then another word. There is no reason to come back tomorrow except a Daily Exam whose word changes every time the app is opened, and whose "leaderboard" only lists the player. The teacher, the best idea in the app, says the same lines in the same order every game. Score is opaque and punishes thinking time.

Evidence: the code (see `design/audit.md` and `analysis/ios-v2-tech-audit.md`). Missing: real numbers. **Founder, please export from App Store Connect:** downloads, sessions per active device, D1/D7 retention, crash rate, rating count and average, for the last 90 days. Without them the v2 targets below are guesses.

## Vision
Ink & Irony is the word game where a sarcastic teacher grades you live in red pen. You play a few words a day, climb from Kindergarten to PhD in five languages, and you come back because the teacher remembers how you did yesterday and has something to say about it.

## Target players
1. Casual word-game players (Wordle, crosswords) who want a 3-minute daily ritual with personality.
2. Multilingual players in the five language markets, especially az, tr and ru speakers, who rarely get a polished word game in their own language.
3. Learners who play in a second language and like seeing the definition after each word.

## UX principles
1. One tap to a letter. From the Desk, the first letter is one tap away; settings never block play.
2. The teacher roasts the guess, never the person. Sarcasm about letters, effort and odds; nothing about intelligence, looks, origin or language skill. A Gentle tone exists for anyone who wants it.
3. Fair and visible. Lives, score math and the daily word are the same for everyone and readable at a glance.
4. Every word teaches something. Definition on the result, saved to the Word notebook.
5. The game is offline first. Everything except Game Center works on a plane.

## In v2.0 / Not in v2.0
**In v2.0 (P0):**
- Detention Notebook redesign with the Chalkboard dark theme (Marry's direction)
- Quick Play from the Desk; the old setup form survives as Free play
- Core loop 2.0: ghost-to-ink gallows, combo scoring, letter grades, power-ups paid in ink drops
- Semesters: 6 semesters × 10 words, final exam at word 10, GPA
- Teacher 2.0: context-aware lines, Strict and Gentle tones
- Daily Exam 2.0: one deterministic word per day per language, spoiler-free share, Game Center leaderboard, weekly hall pass for the streak
- Content: 600 graded words per language, 365 daily words per language
- Data migration: every v1 player keeps their history, stats and achievements (as stickers)

**Not in v2.0:**
- Blitz, Duel, widget, Word notebook screen, iCloud sync: v2.1, to keep v2.0 shippable this year
- Real-time or async online multiplayer: needs a backend or Game Center turn-based work; v2.2 at the earliest
- In-app purchases, ads, subscriptions: no monetisation until retention is proven (decision D-9)
- Accounts and any backend: Game Center is the identity
- New languages: content quality in five beats quantity in eight
- AI-generated taunts: tone risk in five languages; on Tom's watch list (Apple Foundation Models)
- iPad layout: the app stays iPhone-only (as today)

## Metric tree
North star: **words solved per weekly active player** (depth of play, moves with every P0 epic).

| Branch | Definition | Owner | Source | Today | v2.0 target (8 weeks after release) |
|---|---|---|---|---|---|
| Activation | New players who solve a word in their first session | Canan | analytics event `word_solved` with `session_index = 1` | unknown | 80% |
| Habit | Daily active players who finish the Daily Exam | Canan | `daily_completed` / DAU | unknown | 45% |
| Retention | D1 / D7 / D30 | Canan | App Store Connect | founder to export | D1 35%, D7 15%, D30 6% |
| Virality | Daily shares per 100 daily completions | Nicolas | `daily_shared` | 0 (no share) | 8 |
| Quality | Crash-free sessions; App Store rating | Sid / Hasan | Xcode Organizer, App Store Connect | unknown | 99.5%; 4.6+ |

Analytics today: none. Decision needed (D-10): App Store Connect only (free, zero code, no per-event data), or add TelemetryDeck (privacy-first, free tier, needs an App Privacy update). My recommendation: TelemetryDeck with 8 events, no personal data, so we can read activation and habit, which App Store Connect cannot show.

## Risks and assumptions
- The hanging theme. Apple has accepted v1; the redesign keeps the gallows but softens it (the Doodle escapes, the books tumble, no body hangs). Victoria to confirm the imagery and roast tone are fine in all five markets.
- Content is the long pole: 3,000 graded words plus about 800 teacher lines across five languages. Native review per language is required.
- Data migration: v1 wipes its database when the schema changes. If v2 ships without a migration, every player loses their history on update. P0 and blocking.
- Solo developer capacity: the roadmap assumes one iOS developer full-time with Claude Code. If that is not true, v2.0 slips or loses Semesters.
- Assumption: players want progression more than more modes. Semesters are first; Blitz and Duel wait for v2.1.

New: spoiler-free Daily share card (safe) - proven by Wordle, reversible in one MR, costs a day of work - virality branch.
