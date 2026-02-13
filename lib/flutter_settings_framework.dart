/// A state-management agnostic settings framework for Flutter apps
/// with multi-language search support.
///
/// ## Core concepts
///
/// - [SettingDefinition] — declarative setting with metadata, validation,
///   and multi-language search terms.
/// - [SettingsRegistry] — central registry for all setting definitions.
/// - [SettingsController] — manages values, streams, undo/redo, import/export.
/// - [SettingsStorage] / [SharedPreferencesStorage] — persistence backends.
/// - [SearchIndex] — multi-language search across all registered settings.
///
/// ## Riverpod integration
///
/// Use [initializeSettings] and the [SettingsProviders] container to wire
/// everything up with Riverpod. Extension methods on [WidgetRef] (e.g.
/// `ref.watchSetting`, `ref.updateSetting`) provide convenient widget-level
/// access.
///
/// See README.md for full documentation and usage examples.
library;

// Core
export 'src/core/setting_definition.dart';
export 'src/core/settings_registry.dart';
export 'src/core/settings_storage.dart';
export 'src/core/settings_controller.dart';
export 'src/core/search_index.dart';

// Storage implementations
export 'src/storage/shared_preferences_storage.dart';

// Adapters
export 'src/adapters/riverpod_adapter.dart';

// UI Components
export 'src/ui/responsive_helpers.dart';
export 'src/ui/settings_tile.dart';
export 'src/ui/settings_section.dart';
export 'src/ui/snackbar_helper.dart';
export 'src/ui/registry_settings_page.dart';

// Localization
export 'src/localization/easy_localization_adapter.dart';
