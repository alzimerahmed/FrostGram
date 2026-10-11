# FrostGram — a native Mastodon client for Apple platforms

<div align="center">

[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20iPadOS%20%7C%20macOS%20%7C%20visionOS-blue?logo=apple)](https://github.com/alzimerahmed/FrostGram)
[![Swift](https://img.shields.io/badge/Swift-5-orange?logo=swift)](https://www.swift.org)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-007AFF?logo=swift)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/license-AGPL--3.0-green)](LICENSE)

*A fast, open-source, privacy-first Mastodon client built entirely in SwiftUI.*

[Features](#features) • [Tech Stack](#tech-stack) • [Project Structure](#project-structure) • [Building](#building) • [Roadmap](#roadmap)

</div>

---

FrostGram is a standalone fork of [IceCubesApp](https://github.com/Dimillian/IceCubesApp) by Thomas Ricouard, rebranded and extended with a privacy-first focus: no analytics or telemetry by default, no monetization, and a growing set of power-user features. It ships as a single Xcode project with feature modules as local Swift packages.

## Features

**Core (inherited from upstream IceCubesApp)**
- Native SwiftUI app for iOS, iPadOS, macOS (Catalyst), and visionOS
- Full Mastodon support: timelines, lists, explore, conversations, notifications
- Multi-account support with secure keychain storage
- Extensive theming with 40+ alternate app icons
- Post composition with media uploads, polls, alt text, and AI-assisted descriptions (opt-in)
- Translation via DeepL or instance-provided services
- Home screen widgets, share extension, action extension, notification service, and App Intents

**FrostGram additions (Phases 3–7)**
- **Account-free browsing** — explore and read timelines without logging in, with a server-picker onboarding wizard when you're ready to sign in
- **Multi-column layout** (opt-in) — add a selectable timeline column (home / local / federated / trending) on iPad and Mac
- **Keyboard shortcuts** — a "Go" command menu (⌘1–⌘5 tabs, ⌘⇧B/V collections, ⌘⇧S scheduled posts)
- **Scheduled posts** — compose with `scheduled_at`, manage upcoming posts (Settings → General)
- **Alt-text reminder** — local-only soft prompt (banner + pre-post confirmation) when media is posted without a description
- **Media previews off mode** — disable image previews and video autoplay for lighter, faster timelines
- **Follower management** — follow-requests screen and a "remove from followers" quick action
- **Push proxy self-host option** — end-to-end-encrypted push notifications with an overridable relay URL; see [docs/push-proxy-selfhost.md](docs/push-proxy-selfhost.md)
- **Privacy-first**: no analytics or telemetry collected by the app (telemetry is compiled out by default)

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI (no ViewModels — native data flow, `@Observable`) |
| Language | Swift 5, Swift Concurrency |
| Architecture | Feature modules as local Swift Packages |
| Networking | `URLSession` async/await Mastodon client |
| Persistence | SwiftData, Bodega, KeychainSwift |
| Media | Nuke |
| Extensions | Widgets, Share, Action, Notifications Service |

## Project Structure

```
FrostGram.xcodeproj/        Single Xcode project (main scheme: FrostGram)
FrostGram/                  Main app target (pure SwiftUI)
FrostGramNotifications/     Notification service extension
FrostGramShareExtension/    Share extension
FrostGramActionExtension/   Action extension
FrostGramWidgetsExtension/  Home screen widgets
FrostGramAppIntents/        App Intents (Siri/Shortcuts)
Packages/
  Models/                   Mastodon API entities
  NetworkClient/            Mastodon client
  Env/                      App-wide state, environment, preferences, onboarding
  DesignSystem/             Theming, fonts, reusable UI
  Timeline/                 Timelines, filtering, unread tracking
  StatusKit/                Post composition, display, scheduled posts
  Account/                  Profiles and account management
  Notifications/            Notification views
  Conversations/            Direct messages
  Explore/                  Discovery and search
  Lists/                    User lists
  MediaUI/                  Media viewer (zoom, video, sharing)
  AppAccount/               Account model and storage
```

## Building

1. Clone the repository and open `FrostGram.xcodeproj` in Xcode (latest Xcode required).
2. Select the `FrostGram` scheme and an iOS simulator, then Run.
3. To sign for device builds, copy `FrostGram.xcconfig.template` to `FrostGram.xcconfig` and fill in your team ID and bundle ID prefix.

CI builds and tests run on GitHub Actions (macOS runners): SwiftFormat lint, package test schemes (Models, NetworkClient, Timeline, Env, Account), and an unsigned build of the `FrostGram` scheme. No local build is required to contribute.

## Contributing

Fork the repo, create a feature branch, and open a PR against `main`. Commits follow [Conventional Commits](https://www.conventionalcommits.org). CI must pass (SwiftFormat lint + package tests + build) before merge.

## Roadmap

- [x] FrostGram identity rollout (icons, assets, full project/target/scheme rename)
- [x] Onboarding polish and account-free browsing
- [x] Power features: multi-column layout, keyboard shortcuts, scheduled posts
- [x] Accessibility & safety: alt-text reminder, follower management
- [x] Push reliability: self-host proxy option documented
- [ ] v1.0.0 release and App Store submission
- [ ] Self-hosted push proxy as the default relay
- [ ] Community governance and contribution guidelines

## Changelog

**v1.0.0 (upcoming)** — first FrostGram release: FrostGram identity rollout, account-free browsing with onboarding wizard, multi-column layout, keyboard shortcuts, scheduled posts, alt-text reminder, media previews off mode, and a self-hostable push proxy option. See [GitHub Releases](https://github.com/alzimerahmed/FrostGram/releases).

## License

[AGPL-3.0](LICENSE) — © 2026 Alzimer Ahmed. Based on [IceCubesApp](https://github.com/Dimillian/IceCubesApp) by Thomas Ricouard.
