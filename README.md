# Flutter Settings Framework

A state-management agnostic settings framework for Flutter apps with multi-language search support.

## Features

- **Declarative Settings**: Define settings in ~5 lines instead of ~25
- **Multi-Language Search**: Search settings in any language, not just the displayed one
- **State Management Agnostic**: Core uses streams/callbacks, adapters for Riverpod/Provider/Bloc
- **Responsive UI Components**: Pre-built tiles for switches, sliders, colors, selections
- **easy_localization Support**: Built-in integration with easy_localization package
- **Minimal Boilerplate**: Register once, use everywhere

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_settings_framework:
    git:
      url: https://github.com/Zyzto/edadat.git
      ref: main
    # Or from pub.dev when published:
    # flutter_settings_framework: ^1.0.0
```

## Quick Start

### 1. Define Your Settings

```dart
// settings_definitions.dart
import 'package:flutter/material.dart';
import 'package:flutter_settings_framework/flutter_settings_framework.dart';

// Define sections
const generalSection = SettingSection(
  key: 'general',
  titleKey: 'general',
  icon: Icons.settings,
  order: 0,
);

// Define settings
const themeModeSetting = EnumSetting(
  'theme_mode',
  defaultValue: 'system',
  titleKey: 'theme',
  options: ['system', 'light', 'dark'],
  section: 'general',
  searchTerms: {
    'en': ['theme', 'dark', 'light', 'mode'],
    'ar': ['المظهر', 'داكن', 'فاتح'],
  },
);

const notificationsSetting = BoolSetting(
  'notifications_enabled',
  defaultValue: true,
  titleKey: 'notifications',
  icon: Icons.notifications,
  section: 'general',
);

// Create registry
SettingsRegistry createMyRegistry() {
  return SettingsRegistry.withSettings(
    sections: [generalSection],
    settings: [themeModeSetting, notificationsSetting],
  );
}
```

### 2. Initialize in main.dart

Override all three providers so that `ref.settings`, `ref.watchSetting(setting)`, and `settingsSearchResultsProvider(query)` work:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final settings = await initializeSettings(
    registry: createMyRegistry(),
    storage: SharedPreferencesStorage(),
  );
  
  runApp(
    ProviderScope(
      overrides: [
        settingsControllerProvider.overrideWithValue(settings.controller),
        settingsSearchIndexProvider.overrideWithValue(settings.searchIndex),
        settingsProvidersProvider.overrideWithValue(settings),
      ],
      child: MyApp(),
    ),
  );
}
```

### 3. Use in Widgets

With the overrides above you can use the ref extension:

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.settings gives you the SettingsProviders container
    final theme = ref.watchSetting(themeModeSetting);
    // Or when you already have a SettingsProviders instance:
    final theme2 = ref.watchSettingWith(settings, themeModeSetting);
    
    return Scaffold(
      body: ListView(
        children: [
          SwitchSettingsTile.fromSetting(
            setting: notificationsSetting,
            title: 'notifications'.tr(),
            value: ref.watchSetting(notificationsSetting),
            onChanged: (value) => ref.updateSetting(notificationsSetting, value),
          ),
        ],
      ),
    );
  }
}
```

### 4. Convention-based settings page

Use `RegistrySettingsPage` to build a full settings UI from your registry (sections, tiles by type, search, split layout on landscape). Pass `sectionTitleBuilder` (e.g. `(key) => key.tr()`) and optionally `sectionContentBuilder` for custom sections (Tags, About, etc.):

```dart
RegistrySettingsPage(
  registry: myRegistry,
  settings: ref.settings,
  title: 'settings'.tr(),
  searchHint: 'search_settings'.tr(),
  sectionTitleBuilder: (key) => key.tr(),
  enumLabelBuilder: (key) => key.tr(),
  sectionContentBuilder: (sectionKey, defaultChildren) {
    if (sectionKey == 'about') return [AboutSectionContent()];
    return defaultChildren;
  },
)
```

Search results use the built-in provider: `ref.watch(settingsSearchResultsProvider(query))`.

## Setting Types

| Type | Class | Example |
|------|-------|---------|
| String | `StringSetting` | User names, paths |
| Boolean | `BoolSetting` | Toggle features |
| Integer | `IntSetting` | Counts, days |
| Double | `DoubleSetting` | Scales, spacing |
| Color | `ColorSetting` | Theme colors |
| Enum | `EnumSetting` | Limited options |
| String List | `StringListSetting` | Tags, filters |

## Multi-Language Search

The framework supports searching settings in any language:

```dart
// Define search terms for each language
const languageSetting = EnumSetting(
  'language',
  defaultValue: 'en',
  titleKey: 'language',
  options: ['en', 'ar'],
  searchTerms: {
    'en': ['language', 'english', 'arabic', 'locale'],
    'ar': ['اللغة', 'إنجليزي', 'عربي'],
  },
);

// Search works in any language
final results = searchIndex.search('عربي'); // Finds language setting
final results2 = searchIndex.search('arabic'); // Also finds it
```

## UI Components

### Tiles
- `SettingsTile` - Basic tile
- `SwitchSettingsTile` - Boolean toggle
- `SelectSettingsTile<T>` - Dialog picker
- `SliderSettingsTile` - Numeric slider
- `ColorSettingsTile` - Color picker
- `NavigationSettingsTile` - Links to screens
- `ActionSettingsTile` - Trigger actions
- `InfoSettingsTile` - Read-only info

### Layout
- `SettingsSectionWidget` - Collapsible section
- `SettingsSubsectionHeader` - Section dividers
- `SettingsSearchBar` - Expandable search
- `SplitScreenLayout` - List/detail for tablets
- `RegistrySettingsPage` - Full settings page from registry (sections, default tiles by type, search, landscape split). Use `sectionContentBuilder` for custom sections (e.g. About, Data).
- `CardSettingsSection` - Card-style collapsible section with optional landscape selection

### Helpers
- `ref.settings` - Access [SettingsProviders] when [settingsProvidersProvider] is overridden
- `ref.watchSetting(setting)` / `ref.readSetting(setting)` / `ref.updateSetting(setting, value)` / `ref.resetSetting(setting)` - Convenience methods using `ref.settings`
- `settingsSearchResultsProvider(query)` - Built-in family provider for search results
- `isSettingEnabled(settings, setting, ref)` - Whether a setting is enabled (respects `dependsOn` / `enabledWhen`)

### Dialogs
- `SettingsDialog.show()` - Generic dialog
- `SettingsDialog.confirm()` - Confirmation
- `SettingsDialog.select()` - Selection picker
- `SettingsDialog.slider()` - Slider input
- `SettingsDialog.colorPicker()` - Color picker

## Responsive Design

```dart
// Check screen size
if (ResponsiveLayout.isPhone(context)) { ... }
if (ResponsiveLayout.isTablet(context)) { ... }
if (ResponsiveLayout.isDesktop(context)) { ... }

// Adaptive values
final padding = ResponsiveLayout.value(
  context,
  phone: 16.0,
  tablet: 24.0,
  desktop: 32.0,
);

// Split-screen for tablets
if (ResponsiveLayout.shouldUseSplitScreen(context)) {
  return SplitScreenLayout(
    listPane: SettingsList(),
    detailPane: SettingDetail(),
  );
}
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Your App (Widgets)                       │
└─────────────────────────────┬───────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────┐
│                    Riverpod Adapter                         │
│   • SettingNotifier<T>                                      │
│   • SettingsProviders                                       │
│   • Provider helpers                                        │
└─────────────────────────────┬───────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────┐
│                  Core (State Agnostic)                      │
│   • SettingsController (streams, callbacks)                 │
│   • SettingsRegistry (definitions)                          │
│   • SearchIndex (multi-language)                            │
│   • SettingsStorage (abstraction)                           │
└─────────────────────────────┬───────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────┐
│                  Storage Implementation                     │
│   • SharedPreferencesStorage                                │
│   • MemoryStorage (testing)                                 │
│   • Custom implementations                                  │
└─────────────────────────────────────────────────────────────┘
```

## Comparison: Before vs After

### Before (~25 lines per setting)

```dart
class ThemeModeNotifier {
  String _mode;
  ThemeModeNotifier() : _mode = PreferencesService.getThemeMode() ?? 'system';
  String get mode => _mode;
  Future<void> setThemeMode(String mode) async {
    _mode = mode;
    await PreferencesService.setThemeMode(mode);
  }
}

final themeModeNotifierProvider = Provider<ThemeModeNotifier>((ref) {
  return ThemeModeNotifier();
});

final themeModeProvider = Provider<String>((ref) {
  return ref.watch(themeModeNotifierProvider).mode;
});
```

### After (~5 lines per setting)

```dart
const themeModeSetting = EnumSetting(
  'theme_mode',
  defaultValue: 'system',
  titleKey: 'theme',
  options: ['system', 'light', 'dark'],
);

// Usage
final theme = ref.watch(settings.provider(themeModeSetting));
ref.read(settings.provider(themeModeSetting).notifier).set('dark');
```

## Migration Guide

1. Create setting definitions for all settings
2. Initialize the framework in main.dart
3. Replace individual provider usage with `settings.provider(settingDef)`
4. Update UI to use framework tiles
5. Remove old notifier classes and providers

