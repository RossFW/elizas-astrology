# Eliza's Astro App

## Project Overview
A personalized astrology iOS app built with SwiftUI + SwiftData. Calculates natal charts (Placidus houses), weekly transits, retrogrades, friend profiles, and compatibility — all on-device with no API dependencies.

## Architecture

### Source Files
All app source files live in:
```
AstroApp/Eliza's Astro App/Eliza's Astro App/
```

### Xcode Project
```
AstroApp/Eliza's Astro App/Eliza's Astro App.xcodeproj
```
- Bundle ID: `com.rossfw.Eliza-s-Astro-App`
- Team: ROSS FANTUS WILLIAMS (4G5NXC547A)
- Deployment target: iOS 26.4
- Uses `PBXFileSystemSynchronizedRootGroup` — files placed in the source dir are auto-picked up by Xcode

### Key Layers
- **Ephemeris.swift** — Astronomical calculations (Meeus algorithms, Kepler equation, Placidus houses). Pure math, no external deps.
- **ChartEngine.swift** — Natal chart, aspect detection, transit engine, synastry calculator.
- **Models.swift** — Data types: ZodiacSign, CelestialBody, AspectType, CelestialPosition, NatalChart, Transit.
- **Profile.swift** — SwiftData `@Model` for birth profiles.
- **ChartCache.swift** — `@Observable` `@MainActor` singleton cache for charts and reports.
- **Interpretations.swift** — Human-readable transit/sign/retrograde text.
- **Views** — HomeView, ChartDetailView, ProfileSetupView, FriendsView, CompatibilityView, ChartWheelView, Components.

### Concurrency
- Chart calculations run on `Task.detached` to avoid blocking the main thread.
- Views use `@State` + `.task(id:)` pattern for async loading.

## Chart validation
Use synthetic profiles for shared examples and test fixtures. Keep personal charts outside the repository.

## Testing
```bash
cd "AstroApp/Eliza's Astro App"
xcodebuild test -scheme "Eliza's Astro App" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:"Eliza's Astro AppTests"
```

## Build & Run
```bash
xcodebuild -scheme "Eliza's Astro App" -destination 'platform=iOS Simulator,name=iPhone 17' build
```

## MCP Tools Available
- **xcode** — XcodeBuildMCP via `xcrun mcpbridge`. Build, test, previews, logs.
- **ios-simulator** — iOS Simulator MCP. Screenshots, taps, typing, UI hierarchy inspection.

## Important Notes
- App name: "Eliza's Astro App" — this is a gift for Ross's girlfriend Eliza
- House system: **Placidus** (implemented via iterative RA method in Ephemeris.swift)
- No external API dependencies. All calculations are deterministic and run on-device.
- Avoid engagement trap patterns (no daily horoscopes designed to drive daily opens)
- Always `try? modelContext.save()` before `dismiss()` in save flows
