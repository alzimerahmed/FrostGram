# FrostGram — a native Mastodon client for Apple platforms

<div align="center">

[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20iPadOS%20%7C%20macOS%20%7C%20visionOS-blue?logo=apple)](https://github.com/alzimerahmed/FrostGram)
[![Swift](https://img.shields.io/badge/Swift-5-orange?logo=swift)](https://www.swift.org)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-007AFF?logo=swift)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/license-AGPL--3.0-green)](LICENSE)

*A fast, open-source Mastodon client built entirely in SwiftUI.*

[Features](#features) • [Tech Stack](#tech-stack) • [Building](#building)

</div>

---

## Features

- Native SwiftUI app for iOS, iPadOS, macOS (Catalyst), and visionOS
- Full Mastodon support: timelines, lists, explore, conversations, notifications
- Multi-account support with secure keychain storage
- Custom push notification proxy — no third-party analytics in the notification path
- Extensive theming with 40+ alternate app icons
- Post composition with media uploads, polls, alt text, and AI-assisted descriptions (opt-in)
- Translation via DeepL or instance-provided services
- Home screen widgets, share extension, action extension, and App Intents
- Privacy-first: no analytics or telemetry collected by the app

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI (no ViewModels — native data flow) |
| Language | Swift 5, Swift Concurrency, `@Observable` |
| Architecture | Feature modules as local Swift Packages |
| Networking | `URLSession` async/await Mastodon client |
| Persistence | SwiftData, Bodega, KeychainSwift |
| Media | Nuke |
| Extensions | Widgets, Share, Action, Notifications Service |

## Project Structure

```
IceCubesApp/            Main app target + extensions (widgets, share, action, notifications)
Packages/
  Models/               Mastodon API entities
  NetworkClient/        Mastodon client
  Env/                  App-wide state, environment, preferences
  DesignSystem/         Theming, fonts, reusable UI
  Timeline/             Timelines, filtering, unread tracking
  StatusKit/            Post composition and display
  Account/              Profiles and account management
  Notifications/        Notification views
  Conversations/        Direct messages
  Explore/              Discovery and search
  Lists/                User lists
  MediaUI/              Media viewer (zoom, video, sharing)
  AppAccount/           Account model and storage
```

## Building

1. Clone the repository and open `IceCubesApp.xcodeproj` in Xcode (latest Xcode required).
2. Select the `IceCubesApp` scheme and an iOS simulator, then Run.
3. To sign for device builds, copy `IceCubesApp.xcconfig.template` to `IceCubesApp.xcconfig` and fill in your team ID and bundle ID prefix.

CI builds and tests run on GitHub Actions (macOS runners); no local build is required to contribute.

## Contributing

Fork the repo, create a feature branch, and open a PR against `main`. Commits follow [Conventional Commits](https://www.conventionalcommits.org). CI must pass (SwiftLint + unit tests) before merge.

## Roadmap

- [ ] FrostGram identity rollout (icons, assets, full module rename)
- [ ] Onboarding polish and account-free browsing
- [ ] Privacy-first telemetry (opt-in, self-hosted)
- [ ] Community governance and contribution guidelines

## Changelog

See [GitHub Releases](https://github.com/alzimerahmed/FrostGram/releases).

## License

[AGPL-3.0](LICENSE) — © 2026 Alzimer Ahmed. Based on [IceCubesApp](https://github.com/Dimillian/IceCubesApp) by Thomas Ricouard.
