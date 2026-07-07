# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**DaPoint** is an iOS/iPadOS app for counting points across various board games and card games. It targets the App Store, so all code must comply with Apple's App Store Review Guidelines and Human Interface Guidelines (HIG).

Supported platforms: iPhone, iPad, visionOS  
Minimum deployment: iOS 26.5 / xrOS 26.5  
Bundle ID: `lamphilippe.com.DaPoint`

## Build & Test

All builds and tests go through Xcode or `xcodebuild`. There is no separate package manager (no CocoaPods, no SPM dependencies currently).

```bash
# Build (simulator)
xcodebuild -project DaPoint.xcodeproj -scheme DaPoint -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run unit tests
xcodebuild -project DaPoint.xcodeproj -scheme DaPoint -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run a single test class
xcodebuild -project DaPoint.xcodeproj -scheme DaPoint -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:DaPointTests/DaPointTests test
```

Open `DaPoint.xcodeproj` in Xcode to run on a real device or use SwiftUI Previews during development.

## Architecture

**Stack:** SwiftUI + SwiftData — no UIKit, no third-party dependencies.

- `DaPointApp.swift` — app entry point; sets up the shared `ModelContainer` with persistent storage.
- `ContentView.swift` — root view injected with the SwiftData `modelContext` via `@Environment`.
- `Item.swift` — SwiftData `@Model` class (currently a placeholder to be replaced with game/score models).

Data flows from SwiftData's `ModelContainer` → `modelContext` (environment) → views via `@Query`. All mutations go through `modelContext.insert` / `modelContext.delete` with `withAnimation`.

The `NavigationViewWrapper` in `ContentView.swift` handles the iOS vs macOS layout difference (`NavigationSplitView` on macOS, plain content on iOS).

## App Store Compliance Requirements

- Follow Apple's HIG for all UI: use native controls, system fonts, SF Symbols.
- No private APIs.
- All user-facing strings must be localizable (`String(localized:)` or `.strings` catalogs).
- Privacy: declare only the entitlements and permissions actually used. Current entitlements: `ENABLE_APP_SANDBOX`, `ENABLE_USER_SELECTED_FILES = readonly`.
- SwiftData storage is local on-device (no iCloud sync currently); any future cloud feature requires a Privacy Nutrition Label update.
- Support both portrait and landscape on iPhone; all orientations on iPad.
