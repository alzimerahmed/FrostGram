# FrostGram — Rules for AI Agents

## Project

FrostGram = open-source Mastodon client for Apple platforms (standalone fork of Dimillian's IceCubesApp, AGPL-3.0; repo: https://github.com/alzimerahmed/FrostGram, owner: Alzimer Ahmed). Inherits the full IceCubes feature set: timelines, lists, explore, conversations, notifications, multi-account, theming with 40+ icons, widgets/share/action/notification extensions, translation, AI alt-text. Differentiation: privacy-first (no telemetry by default), clean branding, community-driven.

**License:** AGPL-3.0. Upstream copyright notice preserved in `LICENSE` with our added notice. Upstream attribution (Thomas Ricouard / IceCubesApp) must remain in LICENSE and README.

**Scope:** Native Apple-platform app only (iOS + iPadOS + macOS Catalyst + visionOS + extensions). No Android, no web. All verification is CI-only (see Build/Verify).

## How It Works (domain constraints — read before touching the engine)

- **Modules are the architecture** (`Packages/` — local Swift packages: Models, NetworkClient, Env, DesignSystem, Timeline, StatusKit, Account, Notifications, Conversations, Explore, Lists, MediaUI, AppAccount). New reusable logic goes into the right package, not the app target. App code imports packages; packages never import the app.
- **Main app target** is `IceCubesApp/` (pure SwiftUI). Extensions: `IceCubesAppWidgetsExtension`, `IceCubesShareExtension`, `IceCubesActionExtension`, `IceCubesNotifications`.
- **Modern SwiftUI rules (from upstream CLAUDE.md, now our law):** NO ViewModels for new code — use `@State`, `@Observable`, `@Environment`; state flows down, actions flow up; never nest `@Observable` objects inside other `@Observable` objects; async/await over Combine.
- **Data layer**: `MastodonClient` (NetworkClient) for API calls; `AppAccountsManager` for multi-account with keychain; SwiftData for local persistence.
- **Theming**: every screen must work in all themes via `Theme` (`@Environment(Theme.self)`) and DesignSystem tokens; never hardcode colors.
- **Strings**: all user-facing strings in `Localizable.xcstrings` (many languages). Never hardcode.
- **Router**: navigation via `RouterPath` / `AppRegistry` destination cases — add new screens as Router destinations.

## Tech Stack & Conventions (do not fight it)

- **Language**: Swift 5, Xcode latest. Swift Concurrency throughout.
- **Project**: single `IceCubesApp.xcodeproj`; shared schemes in `IceCubesApp.xcodeproj/xcshareddata/xcschemes` (main scheme: `IceCubesApp`); package test schemes (ModelsTests, NetworkClientTests, TimelineTests, EnvTests, AccountTests) are Xcode automatic schemes.
- **Format**: SwiftFormat, 2-space indent, config in `.swiftformat`. CI runs `swiftformat --lint`.
- **Dependencies**: SPM via the xcodeproj (EmojiText, HTML2Markdown, KeychainSwift, LRUCache, Bodega, Nuke, SwiftSoup, TelemetryDeck, SFSafeSymbols). Upstream package URLs are dependencies, not ownership — do not rename.
- **Bundle identity**: `BUNDLE_ID_PREFIX = com.alzimerahmed` in `IceCubesApp-release.xcconfig`; app group `group.$(BUNDLE_ID_PREFIX).FrostGram`; URL scheme `frostgram://`; keychain group `com.alzimerahmed.FrostGram`.

## Build / Verify

```bash
# CI (GitHub Actions, .github/workflows/ci.yml — push/PR to main):
#   1. swiftformat --lint .
#   2. xcodebuild test per package test scheme (Models, NetworkClient, Timeline, Env, Account)
#      -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' CODE_SIGNING_ALLOWED=NO
#   3. xcodebuild build -scheme IceCubesApp CODE_SIGNING_ALLOWED=NO
```

**Remote-first verification (mandatory):** we do NOT build or test locally — this workspace is Windows and all builds/tests run in GitHub Actions (macOS runners). Local work is edit-only: static review while iterating. Push and let CI verify; a CI green check counts as the gate.

**Signing:** `IceCubesApp-release.xcconfig` keeps upstream DEVELOPMENT_TEAM for local builds; CI overrides with `CODE_SIGNING_ALLOWED=NO`. Never hardcode new team IDs.

## Gotchas

- **Windows checkout**: avoid `git clean -fdx`; some upstream asset paths can be Windows-hostile.
- **No local build safety net** — grep all references (Info.plist keys, entitlements, .xcstrings keys, asset names, pbxproj) before deleting or renaming anything.
- **Product/target names are still IceCubes\*** — internal target/package names keep upstream names for build stability; user-facing branding is FrostGram. Full rename is a later CI-verified phase.
- **IceCubesSDK** is a remote SPM dependency (upstream git URL) — do not rename or vendor casually.
- **Keychain/app-group identifiers** must stay consistent between entitlements, `UserPreferences.sharedDefault`, and `AppInfo.keychainGroup`.
- **Telemetry is disabled** (`Packages/Env/Sources/Env/Telemetry.swift` no-ops without an app ID) — do not re-enable upstream's TelemetryDeck app ID.

## Agent Guidelines & Constraints

### Do's
- **Write tests** for new package behavior (XCTest, behavior not implementation).
- **Conventional Commits**: `type(scope): description`.
- **Respect module boundaries** — new reusable logic goes into `Packages/`.
- **Plan discipline** — `docs/plan.md` must contain a Quality Gate phase and a Release phase. Every `idea.md` Feature Gap entry maps to a phase or is explicitly deferred. When a phase answers an open question in `docs/research.md`, close it there in the same change.

### Don'ts
- **NO local builds or test runs** — verification is CI-only (user directive; Windows host has no Xcode).
- **NO secrets in code** — API keys via CI secrets only. Upstream's RevenueCat key and TelemetryDeck app ID were removed.
- **NO new heavy dependencies** without a decision record in `docs/research.md` (license must stay AGPL-compatible).
- **NO deleting resources** without grepping all reference types (plists, entitlements, xcconfigs, .xcstrings, asset catalogs, pbxproj).
- **NO renaming targets/schemes/bundle IDs ad hoc** — that is a planned phase, CI-verified.

## Agent Guidelines & Workflow (this repo's .devin system)

### Resource Discipline (mandatory, non-trivial tasks)
Before any non-trivial task:
1. Read `docs/toolset.md` intent-map (task type → resources)
2. Invoke every skill + sub-agent in that row
3. Read every rule for that task type (`.devin/rules/`)
4. At task end: `code-reviewer` sub-agent on final diff (non-negotiable)
5. Append learnings via `/ce-compound` if durable lesson

Phase implementations (task completes a docs/plan.md row): follow `.devin/prompt/phase.md`.

Skip all this for single-line edits, pure Q&A, reading files.

### Project-Type Filter (Apple-platform Mastodon client)
Per `docs/toolset.md` intent-map:
- **Skip web-only/non-Apple:** pwa-engineer, seo-specialist, css-architect, playwright-design-clone, payment-integrator, email-engineer, monorepo-manager, web-scraper, search-optimization, backend-architect (no server).
- **Keep universal:** code-reviewer, debugger, test-engineer, security-auditor, performance-engineer, git-master, migration-specialist, docs-writer, build-optimizer, caveman-compressor, vibe-coding-auditor, type-safety-engineer, state-manager, i18n-specialist (xcstrings/RTL), media-optimizer, animation-engineer, frontend-designer (SwiftUI taste), content-writer, accessibility.
- **Quality gates:** CI-only — SwiftFormat lint + unsigned build + package tests on GitHub Actions. No local builds.

## Communication Style

Default **caveman-lite** (lightly compressed, readable, technically accurate). `/caveman` skill for full/ultra/wenyan modes.

## Quick Task Flow

Quick tasks: `.devin/prompt/quick.md` (commandments) + `.devin/prompt/rules.md` (scoping, verification, escalation). Phased work: `.devin/prompt/phase.md`.

## Key References

> Note: `docs/*.md` files below are the private knowledge layer (gitignored) — they exist only in the local workspace, not for external cloners.

- `docs/toolset.md` — intent map (task type → skills, sub-agents, rules)
- `docs/plan.md` — phased plan + status
- `docs/project.md` — project state/structure
- `docs/tools-log.md` — .devin resources invoked per session
- `docs/CONCEPTS.md` — project vocabulary
- `docs/research.md` — research, ADRs, gotchas, open questions
- `docs/idea.md` — competitive analysis + Feature Gap List
- `docs/design/design-system.md` — UI tokens + rules
