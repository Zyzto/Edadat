# Settings Framework Example

Bilingual `RegistrySettingsPage` catalog for `flutter_settings_framework`
(definitions, Riverpod wiring, tiles, EN/AR search, `dependsOn`).

Live: [zyzto.github.io/Edadat](https://zyzto.github.io/Edadat/)

`web/` is in-tree for GitHub Pages. Other platforms are not generated, so
`flutter run` on a device needs `flutter create .` first.

## Analyze

```bash
cd example
flutter pub get
dart analyze --fatal-infos
```

## Tests and screenshots

```bash
cd example
flutter test
```

`test/screenshots_test.dart` renders the catalog and writes PNGs to
[`../screenshots/`](../screenshots/) for the package READMEs.

## Web

```bash
cd example
flutter pub get
flutter build web --release --base-href /Edadat/
```

## Run on a device (optional)

Generate the other platforms first, then run:

```bash
cd example
flutter create . --project-name settings_example --platforms=android,ios
flutter pub get
flutter run
```

## What it shows

1. **Setting definitions** — Bool, Enum, Color, Double, Int, String, StringList, Action
2. **Registry** — sections + settings, including `dependsOn`
3. **Initialization** — Riverpod overrides via `initializeSettings` + `PreIndexedLocalizationProvider`
4. **UI** — `RegistrySettingsPage` tiles, search, info/action rows
5. **Search** — English and Arabic terms against the same index
6. **Reactive updates** — language, theme mode, and accent color drive `MaterialApp`
