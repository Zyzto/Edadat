# Changelog

All notable changes to this project will be documented in this file.

## [0.2.0] - 2026-02-13

### Fixed
- **Global change stream now fires for undo/import operations**:
  `_notifyChangeUntyped` was silently skipping the global change stream,
  causing `controller.changes` listeners to miss events from `undo()`,
  `importAll()`, and `resetAll()`.

### Improved
- Removed `VoidCallback` typedef that shadowed Flutter's built-in
  `VoidCallback`. The `addListener` method now returns `void Function()`
  directly, avoiding potential import conflicts in consumer apps.

### Deprecated
- `EasyLocalizationAdapter` in `search_index.dart` — use
  `EasyLocalizationAdapterImpl` from the localization adapter instead.
- `MapLocalizationProvider` in `search_index.dart` — use
  `PreIndexedLocalizationProvider` from the localization adapter instead.
- `createAutoDisposeSettingProvider` — delegates to `createSettingProvider`
  with no actual auto-dispose behavior; use `createSettingProvider` directly.
- `SettingsProviderFactory.createAutoDispose` — same reason; use `create`.

### Documentation
- Updated doc comments for `LocalizationProvider` to reference the correct
  implementation classes.
- Improved inline documentation throughout the codebase.

## [0.1.0+1] - 2025-01-15

### Added
- Initial release of flutter_settings_framework package
- Declarative setting definitions with minimal boilerplate
- Multi-language search across all supported locales
- State management agnostic core with Riverpod adapter
- Reusable UI components for settings pages
- SharedPreferences storage implementation
- Easy localization adapter for multi-language support
- Responsive UI helpers for different screen sizes

### Features
- Setting types: String, Bool, Int, Double, Color, Enum, StringList
- Settings registry for organizing settings
- Settings controller with reactive streams
- Search index with multi-language support
- Pre-built UI tiles: Switch, Select, Slider, Color picker
- Settings sections and subsections
- Setting dependencies and conditional enabling
- Value validation and formatting
- Undo/redo support for setting changes
