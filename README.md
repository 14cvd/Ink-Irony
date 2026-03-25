[🇬🇧 English](README.md) • [🇹🇷 Türkçe](README_tr.md) • [🇦🇿 Azərbaycanca](README_az.md) • [🇷🇺 Русский](README_ru.md) • [🇪🇸 Español](README_es.md)

---

<p align="center">
  <img width="256" height="256" alt="Ink Irony" src="https://github.com/user-attachments/assets/033c1824-d6fc-4184-8d34-ca439122fcd5" />
</p>

# Ink & Irony (Savage Sketchbook) 🖋️📓

**Ink & Irony** is a premium, beautifully crafted iOS word-guessing game (Hangman-style) built entirely with **SwiftUI** and **SwiftData**. It offers a unique "hand-drawn sketchbook" aesthetic, complete with dynamic jittery ink animations, immersive haptics, and a brutal offline taunting system that reacts to every mistake you make.

[**Download on the App Store**](https://apps.apple.com/app/id6760973464)

---

## 🎨 Features & Highlights

### 1. Hand-Drawn Sketchbook Aesthetic
- **Dynamic UI:** Custom `Shape` extensions create jittery, layered stroke animations that simulate real pen-on-paper drawing.
- **Theme Engine:** Advanced `ThemeManager` supporting both Light Mode ("Aged Parchment") and Dark Mode ("Charcoal Sketch") with semantic design tokens (`inkPrimary`, `errorInk`, etc.).
- **Custom Typography:** Integrated tailored fonts (`Caveat`, `Special Elite`, `Courier Prime`) to mimic handwriting and typewriter stamps.

### 2. Deep Localization (5 Languages)
The game is fully localized using a custom `LocalizationService`, allowing players to experience the UI and the gameplay in:
- 🇺🇸 English
- 🇹🇷 Turkish
- 🇦🇿 Azerbaijani
- 🇷🇺 Russian
- 🇪🇸 Spanish

### 3. Massive Word Dictionaries
A robust `WordRepository` manages thousands of localized words split across specific offline JSON dictionaries.
- **Difficulty Levels:** Easy, Medium, Hard, Nightmare.
- **Categories:** Animals, Science, History, Technology, Anatomy, Abstract Vocabulary, and more.

### 4. Interactive & Immersive Gameplay
- **Savage Taunts:** A mock offline AI (`TauntService`) delivers brutal, context-aware insults based on your language, difficulty, and the number of mistakes you've made.
- **AVFoundation & CoreHaptics:** Every action is accompanied by realistic paper tears, pencil snaps, pen scratches, and precise tactile pulses.

### 5. Leaderboard & Analytics (SwiftData)
- **Game Sessions:** Every win or loss is persistently stored using iOS 17's **SwiftData**.
- **Leaderboard View:** Filter your past performances by language to see your highest scores, filtered dynamically using `@Query`.
- **Streak Tracking:** Tracks current and all-time highest winning streaks.

---

## 🛠 Tech Stack & Architecture

- **Framework:** SwiftUI
- **Database:** SwiftData
- **Architecture Pattern:** MVVM (Model-View-ViewModel) + Services (`AudioService`, `HapticService`, `TauntService`, `WordRepository`).
- **Data Format:** Decodable JSON for dictionaries and taunts.
- **Minimum iOS Version:** iOS 17.0+ (Due to SwiftData and Observation frameworks).

## 📂 Project Structure

```
Ink/
├── App/                # App entry point, Main Menu (ContentView)
├── Core/               # Models (Language, Difficulty, Word, GameSession) & LocalizationService
├── UI/                 # SwiftUI Views (GameView, Setup, Leaderboard, ResultScreen, Sub-components)
├── Services/           # Business Logic (Audio, Haptics, Taunts, Word Repository, ScoreManager)
└── Resources/          # Locale-specific JSON dictionaries and Audio/Font assets
```

---

## 🚀 How to Run the Project

1. Clone or download the repository to your local machine.
2. Open `Ink.xcodeproj` in **Xcode 15** or later.
3. Select an iOS Simulator or a physical device running **iOS 17.0+**.
4. Hit **Cmd + R** to build and run the application.

*Note: If you are running on a simulator, CoreHaptics feedback will be silently ignored, but audio and visual animations will still function perfectly.*

## 📫 Contact & Support

Created by **Cavid Abbasaliyev**

If you have any questions, feedback, or just want to say hi, feel free to reach out:
- **Email:** [abbas3liyev@gmail.com](mailto:abbas3liyev@gmail.com)
- **LinkedIn:** [Cavid Abbasaliyev](https://www.linkedin.com/in/abbas3liyev/)
