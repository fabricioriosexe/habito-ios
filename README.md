# Habito 🔥

A clean, minimal habit tracker for iOS built with SwiftUI, SwiftData, and MVVM architecture. Track your daily habits, maintain streaks, reflect in your private journal, and chat with an AI companion for support.

## Features

- **Habit Tracking** — Create habits, mark them complete daily, and watch your streak grow
- **Streak System** — Individual 🔥 per habit + a daily trophy when you complete everything  
- **Monthly Calendar** — GitHub-style intensity heatmap showing your consistency over time
- **Private Journal** — Write daily entries with mood tracking
- **AI Companion** — Chat with an empathetic AI that reads your journal entries for context
- **Dark Mode** — Full support via semantic system colors

## Screenshots

> Coming soon

## Tech Stack

| Layer | Technology |
|-------|------------|
| Language | Swift 5.9+ |
| UI Framework | SwiftUI |
| Architecture | MVVM |
| Persistence | SwiftData |
| AI | Groq API — llama-3.3-70b-versatile |
| Minimum iOS | iOS 17.0 |

## Project Structure
Habito/
├── App/
│   └── HabitoApp.swift          # Entry point + SwiftData container + TabView
├── Model/
│   ├── Habit.swift              # @Model — habit entity
│   └── JournalEntry.swift       # @Model — journal entry with mood
├── ViewModel/
│   └── HabitViewModel.swift     # @Observable — all business logic
├── Views/
│   ├── HabitListView.swift      # Tab 1 — habit list + daily fire banner
│   ├── HabitRowView.swift       # Individual habit row with animation
│   ├── AddHabitView.swift       # New habit sheet with color picker
│   ├── CalendarView.swift       # Tab 2 — monthly heatmap calendar
│   ├── JournalView.swift        # Tab 3 — journal entries list
│   └── AICompanionView.swift    # AI chat interface
├── Components/
│   └── StreakBadge.swift        # Reusable flame streak badge
└── Extensions/
├── Date+Extensions.swift    # isSameDay, startOfDay helpers
├── Color+Extensions.swift   # Color from hex string
└── Config.swift             # Secure API key loader


## Architecture

This project strictly follows **MVVM**:

- **Model** — `@Model` classes managed by SwiftData. Pure data, no UI logic.
- **ViewModel** — `@Observable` class with all business logic. Never imports SwiftUI.
- **View** — SwiftUI views that observe the ViewModel and react to changes. Never write data directly.

Data flows in one direction:
View → ViewModel → ModelContext → SwiftData (SQLite)
SwiftData → @Query → View (automatic reactivity)
## Getting Started

### Prerequisites

- Xcode 15+
- iOS 17.0+ simulator or device
- A free [Groq API key](https://console.groq.com)

### Installation

1. Clone the repository

```bash
git clone https://github.com/fabricioriosexe/habito-ios.git
cd habito-ios
```

2. Create your secrets file from the example

```bash
cp Secrets.xcconfig.example Secrets.xcconfig
```

3. Open `Secrets.xcconfig` and add your Groq API key
GROQ_API_KEY = your_key_here
4. In Xcode, assign `Secrets.xcconfig` to the project configurations:
   - Click the project (blue icon) → Info tab
   - Under Configurations → Debug → select `Secrets`
   - Repeat for Release

5. Open `Habito.xcodeproj` and run with `⌘+R`

### API Key

The app uses `Secrets.xcconfig` for API key management. This file is git-ignored — a template is provided in `Secrets.xcconfig.example`. Never commit your actual key.

## Roadmap

- [ ] Face ID / Touch ID for journal privacy
- [ ] Daily reminder notifications  
- [ ] Photo attachments in journal entries
- [ ] Journal full-text search
- [ ] iCloud sync across devices
- [ ] Weekly AI mood and habits summary
- [ ] Android version with Kotlin + Jetpack Compose

## What I Learned

This project was built as a personal portfolio piece to go deep on:

- **SwiftUI** declarative UI patterns and view composition
- **SwiftData** as a modern replacement for Core Data with `@Model` and `@Query`
- **MVVM architecture** with strict separation of concerns
- **Swift Concurrency** — async/await for API calls without blocking the UI
- **REST API integration** — calling Groq's OpenAI-compatible endpoint from iOS
- **Secure configuration** — managing API keys with xcconfig outside of version control

