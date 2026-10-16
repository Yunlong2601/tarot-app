# ShenTarot (working name): Flutter app

Phases A-B: navigation, mock data, and the full 78-card deck. No camera, backend or purchases yet.

## Run
```bash
# one-time: install Flutter (https://docs.flutter.dev/get-started/install/macos), then
flutter doctor            # fix whatever it flags (Xcode, Android Studio)
cd app
flutter pub get
flutter run               # pick an iOS Simulator or Android emulator/device
```

## Test
```bash
flutter analyze
flutter test
```

## Try by hand
1. Swipe through 3 onboarding screens, tap **Get started**.
2. **Scan** tab: tap **Simulate scan** to get a single-card reading (the free daily reading).
3. Tap Simulate scan again: the paywall opens (free limit reached).
4. Tap a locked spread (Three cards): the paywall opens.
5. Paywall: pick a plan, tap the button. This is a mock and sets Premium on.
6. **Cards**, **History**, **Settings** tabs; Settings > Delete all my data.

## Card data and art (Phase B)
- `assets/cards/cards.json`: 78 cards, original wording (keywords, upright, reversed, element, major-arcana association). Regenerate with `python3 tools/make_cards.py assets/cards/cards.json`.
- `assets/cards/art/<card_id>.jpg`: card images. Included: 78 public-domain scans of the original Pamela Colman Smith deck (dated 1910 on Wikimedia Commons, licence "Public domain"), fetched by `python3 -I tools/fetch_art.py` and shrunk to 600 px tall with `sips` to keep the app small. Sources are in `assets/cards/art/CREDITS.md`. If a card has no image the app shows a text placeholder. Re-verify each Commons file page before release (see PROGRESS.md).
- All meaning text should be read through once by you before release.

## Layout
```
lib/app/       router (go_router), theme, app state (mock)
lib/data/      models, deck loader + search, mock history
lib/features/  onboarding, home (tab shell), scan, cards, reading, history, paywall, settings
test/          deck data, search, free-tier rules, navigation tests
tools/         make_cards.py, fetch_art.py
```
Bundle ID is the placeholder `com.shentech.shentarot`; set the real one before any store work.

## Dependency audit (run before each release)
```bash
flutter pub outdated
flutter pub upgrade --major-versions   # review the diff
# check advisories for each direct dependency at https://osv.dev
```
