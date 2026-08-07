# Settings Framework Example

Package-style demo for `flutter_settings_framework` (definitions, Riverpod
wiring, tiles, search). There are **no** generated platform folders in this
tree, so `flutter run` is not available out of the box.

## Analyze

```bash
cd example
flutter pub get
dart analyze --fatal-infos
```

## Run (optional)

Generate platforms first, then run:

```bash
cd example
flutter create . --project-name settings_example
flutter pub get
flutter run
```

## What it shows

1. **Setting definitions** — Bool, Enum, Color, Double
2. **Registry** — sections + settings
3. **Initialization** — Riverpod overrides via `initializeSettings`
4. **UI** — pre-built tiles and sections
5. **Search** — multi-language terms
6. **Reactive updates** — `ref.watchSetting` / updates
