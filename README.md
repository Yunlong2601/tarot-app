# tarot-app (working name: ShenTarot)

Tarot card scan + AI reading subscription app for iOS and Android. The user scans a physical Rider-Waite-Smith card with the phone camera, the app identifies it on device, and a backend returns an AI-written reflection. Entertainment and self-reflection only.

Stack: Flutter (app), Cloudflare Workers (backend, `backend/`), Claude Haiku 5.5 (readings), RevenueCat (subscriptions), SQLite (history).

This repository is meant to be self-contained: any developer or AI coding tool can pick it up from these files.

| Read this | For |
|---|---|
| [CLAUDE.md](CLAUDE.md) | App and backend rules, decisions, conventions (Claude works here) |
| [AGENTS.md](AGENTS.md) | Website rules, state and to-dos (Codex works here) |
| [SHARED-FACTS.md](SHARED-FACTS.md) | Names, links, prices, brand and API shape the app and site share |
| [PROGRESS.md](PROGRESS.md) | What is done, what is next, open to-dos, known issues |
| [docs/step1-plan.md](docs/step1-plan.md) | Architecture, data model, roadmap, cost model, break-even, store and Singapore notes |
| [app/README.md](app/README.md) | App-specific commands and layout |

## Set up from zero (macOS)
1. Install Xcode from the App Store, open it once, then `sudo xcode-select --switch /Applications/Xcode.app` and `sudo xcodebuild -license accept`.
2. Install Android Studio (with Android SDK + an emulator) and CocoaPods (`brew install cocoapods`).
3. Install Flutter (https://docs.flutter.dev/get-started/install/macos). The app was developed on Flutter 3.47.7 stable.
4. Run `flutter doctor` and fix everything it flags.

## Run
```bash
git clone https://github.com/Yunlong2601/tarot-app.git
cd tarot-app/app
flutter pub get
flutter run          # choose an iOS Simulator, Android emulator, or a connected phone
```

## Check and test
```bash
cd app
flutter analyze
flutter test
```
All should pass with no issues. If something fails, record it in PROGRESS.md under Known issues.

## Dependency audit (before every release)
```bash
cd app && flutter pub outdated && flutter pub deps --no-dev | head -50   # review new/changed packages and their licences
cd backend && npm audit --omit=dev                                         # must report 0 vulnerabilities
```
Check each new dependency's licence and what data it touches. Backend dependencies are pinned to exact versions; app versions are locked by `pubspec.lock`.

## Backend, store setup and release
See [backend/README.md](backend/README.md), [docs/phase-e-subscriptions-setup.md](docs/phase-e-subscriptions-setup.md), [docs/app-store-checklist.md](docs/app-store-checklist.md), [docs/play-store-checklist.md](docs/play-store-checklist.md), [docs/test-plan.md](docs/test-plan.md), [docs/data-inventory.md](docs/data-inventory.md), and the legal drafts [privacy](docs/privacy-policy-draft.md) and [terms](docs/terms-draft.md).

## Not in the repo on purpose
No API keys or secrets, ever. The Anthropic key lives only in the backend as a Cloudflare secret (`wrangler secret put`). Card art (public domain scans) is not committed yet; see `app/README.md` for how to fetch and verify it.

## Working on it with any tool
The app and backend follow CLAUDE.md, the website (`web/`) follows AGENTS.md, and both keep SHARED-FACTS.md current. Keep to those conventions, make small commits on a branch per phase, and update PROGRESS.md when you finish something. The remaining roadmap (Phases C to G, with hour estimates) is in docs/step1-plan.md.
