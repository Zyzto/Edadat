import 'package:flutter_settings_framework/flutter_settings_framework.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SettingsRegistry registry;
  late SettingsController controller;

  const theme = EnumSetting(
    'theme_mode',
    defaultValue: 'system',
    titleKey: 'theme',
    options: ['system', 'light', 'dark'],
    section: 'appearance',
  );

  const enabled = BoolSetting(
    'notifications',
    defaultValue: true,
    titleKey: 'notifications',
    section: 'privacy',
  );

  const exportAction = ActionSetting(
    'action_export',
    titleKey: 'export_data',
    section: 'data',
  );

  const hidden = BoolSetting(
    'internal_flag',
    defaultValue: false,
    titleKey: 'internal',
    section: 'appearance',
    visible: false,
  );

  setUp(() async {
    registry = SettingsRegistry.withSettings(
      sections: const [
        SettingSection(key: 'appearance', titleKey: 'appearance'),
        SettingSection(key: 'privacy', titleKey: 'privacy'),
        SettingSection(key: 'data', titleKey: 'data'),
      ],
      settings: const [theme, enabled, exportAction, hidden],
    );
    controller = SettingsController(
      registry: registry,
      storage: MemoryStorage(),
    );
    await controller.init();
  });

  test('returns defaults before any writes', () {
    expect(controller.get(theme), 'system');
    expect(controller.get(enabled), isTrue);
  });

  test('persists typed values and notifies listeners', () async {
    final changes = <String>[];
    controller.changes.listen((e) => changes.add(e.setting.key));

    expect(await controller.set(theme, 'dark'), isTrue);
    expect(controller.get(theme), 'dark');
    expect(await controller.set(enabled, false), isTrue);
    expect(controller.get(enabled), isFalse);

    await Future<void>.delayed(Duration.zero);
    expect(changes, containsAll(['theme_mode', 'notifications']));
  });

  test('ActionSetting is not written to storage', () async {
    final storage = MemoryStorage();
    final c = SettingsController(registry: registry, storage: storage);
    await c.init();

    expect(await c.set(exportAction, true), isTrue);
    expect(storage.containsKey('action_export'), isFalse);
    expect(c.get(exportAction), isFalse); // default; not persisted
  });

  test('undo restores previous value', () async {
    await controller.set(theme, 'dark');
    expect(controller.canUndo, isTrue);
    expect(await controller.undo(), isTrue);
    expect(controller.get(theme), 'system');
  });

  test('registry visibility helpers', () {
    final visible = registry.getVisibleSettingsInSection('appearance');
    expect(visible.map((s) => s.key), contains('theme_mode'));
    expect(visible.map((s) => s.key), isNot(contains('internal_flag')));
    expect(registry.getSortedSections().first.key, 'appearance');
  });

  test('rejects invalid enum values', () async {
    expect(await controller.set(theme, 'neon'), isFalse);
    expect(controller.get(theme), 'system');
  });
}
