# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**DaPoint** is a cross-platform app for counting points across various board games and card games, targeting both the Apple App Store and Google Play Store.

```
DaPoint/
├── ios/        — iOS/iPadOS app (SwiftUI + SwiftData)
└── flutter/    — Android + iOS app (Flutter) — à venir
```

## iOS App

**Stack:** SwiftUI + SwiftData — no UIKit, no third-party dependencies.  
Supported platforms: iPhone, iPad, visionOS  
Minimum deployment: iOS 26.5 / xrOS 26.5  
Bundle ID: `lamphilippe.com.DaPoint`

### Build & Test

```bash
cd ios

# Build (simulator)
xcodebuild -project DaPoint.xcodeproj -scheme DaPoint -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run unit tests
xcodebuild -project DaPoint.xcodeproj -scheme DaPoint -destination 'platform=iOS Simulator,name=iPhone 16' test
```

Open `ios/DaPoint.xcodeproj` in Xcode to run on a real device or use SwiftUI Previews.

### Architecture

- `DaPointApp.swift` — entry point; sets up `ModelContainer` (schema: `GameSession`, `SessionPlayer`, `RoundScore`). Includes error recovery: deletes old SQLite store on schema migration failure.
- `SplashScreenView.swift` — animated splash, then pushes `HomeView`
- `HomeView.swift` — favorite games list (`@AppStorage("favoriteGameIds")`)
- `SessionListView.swift` — sessions filtered by game; first row = "Nouvelle partie"; DisclosureGroup filter
- `NewSessionView.swift` — creates session + players, then navigates to `SessionDetailView`
- `SessionDetailView.swift` — score table (players as rows, rounds as columns newest-first, pinned Total column)
- `EnterRoundScoresView.swift` — per-player score entry (digits only)
- `GamesRegistry.swift` — static list of games (`Game` struct with id, displayName, rulesURL)
- `AppIconView.swift` — brand gradient + LogoMark; `IconExporterView` for generating the 1024×1024 icon PNG

Data flow: SwiftData `ModelContainer` → `modelContext` (environment) → views via `@Query`. All mutations via `modelContext.insert` / `modelContext.delete`.

### App Store Compliance

- Native controls, system fonts, SF Symbols only. No private APIs.
- All user-facing strings must be localizable.
- Storage is local on-device (no iCloud sync currently).
- Support portrait + landscape on iPhone; all orientations on iPad.

## Flutter App

À implémenter — même fonctionnalité que l'app iOS, ciblant Android (et iOS en bonus).
