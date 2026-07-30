import 'package:flutter/material.dart';
import 'package:flutter_settings_framework/flutter_settings_framework.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SettingsRegistry registry;
  late PreIndexedLocalizationProvider localization;

  setUp(() {
    const appearance = SettingSection(
      key: 'appearance',
      titleKey: 'appearance',
      icon: Icons.palette,
    );
    const about = SettingSection(
      key: 'about',
      titleKey: 'about',
      icon: Icons.info,
    );

    final theme = EnumSetting(
      'theme_mode',
      defaultValue: 'system',
      titleKey: 'theme',
      subtitleKey: 'theme_description',
      options: const ['system', 'light', 'dark'],
      section: 'appearance',
      searchTerms: const {
        'en': ['dark', 'light', 'mode'],
        'ar': ['داكن', 'فاتح'],
      },
    );

    final language = EnumSetting(
      'language',
      defaultValue: 'en',
      titleKey: 'language',
      options: const ['en', 'ar'],
      section: 'appearance',
      searchTerms: const {
        'en': ['locale'],
        'ar': ['لغة'],
      },
    );

    final hidden = BoolSetting(
      'internal_flag',
      defaultValue: false,
      titleKey: 'internal_flag',
      section: 'appearance',
      visible: false,
    );

    final exportAction = ActionSetting(
      'action_export',
      titleKey: 'export_data',
      subtitleKey: 'export_data_description',
      section: 'about',
      icon: Icons.upload,
      searchTerms: const {
        'en': ['backup', 'download'],
        'ar': ['تصدير'],
      },
    );

    registry = SettingsRegistry.withSettings(
      sections: const [appearance, about],
      settings: [theme, language, hidden, exportAction],
    );

    localization = PreIndexedLocalizationProvider({
      'en': {
        'appearance': 'Appearance',
        'about': 'About',
        'theme': 'Theme',
        'theme_description': 'Light or dark mode',
        'language': 'Language',
        'export_data': 'Export data',
        'export_data_description': 'Save a backup file',
        'internal_flag': 'Internal',
      },
      'ar': {
        'appearance': 'المظهر',
        'about': 'حول',
        'theme': 'السمة',
        'theme_description': 'وضع فاتح أو داكن',
        'language': 'اللغة',
        'export_data': 'تصدير البيانات',
        'export_data_description': 'حفظ ملف نسخ احتياطي',
        'internal_flag': 'داخلي',
      },
    });
  });

  test('matches across locales regardless of query language', () async {
    final index = SearchIndex(
      registry: registry,
      localizationProvider: localization,
    );
    await index.build();

    final arTheme = index.search('داكن');
    expect(arTheme.map((r) => r.setting.key), contains('theme_mode'));
    expect(arTheme.firstWhere((r) => r.setting.key == 'theme_mode').matchedLocale,
        'ar');

    final enTheme = index.search('theme');
    expect(enTheme.map((r) => r.setting.key), contains('theme_mode'));

    final arLanguage = index.search('لغة');
    expect(arLanguage.map((r) => r.setting.key), contains('language'));
  });

  test('indexes section titles onto settings in that section', () async {
    final index = SearchIndex(
      registry: registry,
      localizationProvider: localization,
    );
    await index.build();

    final byEnSection = index.search('appearance');
    expect(byEnSection.map((r) => r.setting.key), contains('theme_mode'));
    expect(byEnSection.map((r) => r.setting.key), contains('language'));

    final byArSection = index.search('المظهر');
    expect(byArSection.map((r) => r.setting.key), contains('theme_mode'));
  });

  test('multi-word queries require all words', () async {
    final index = SearchIndex(
      registry: registry,
      localizationProvider: localization,
    );
    await index.build();

    final hit = index.search('dark mode');
    expect(hit.map((r) => r.setting.key), contains('theme_mode'));

    final miss = index.search('dark xylophone');
    expect(miss, isEmpty);
  });

  test('excludes invisible settings from results', () async {
    final index = SearchIndex(
      registry: registry,
      localizationProvider: localization,
    );
    await index.build();

    final results = index.search('internal');
    expect(results, isEmpty);

    // Term is indexed but filtered at search time
    expect(index.getTermsForSetting('internal_flag'), isNotEmpty);
  });

  test('indexes ActionSetting entries', () async {
    final index = SearchIndex(
      registry: registry,
      localizationProvider: localization,
    );
    await index.build();

    final byTitle = index.search('export');
    expect(byTitle.map((r) => r.setting.key), contains('action_export'));
    expect(byTitle.first.setting, isA<ActionSetting>());

    final bySynonym = index.search('backup');
    expect(bySynonym.map((r) => r.setting.key), contains('action_export'));

    final byAr = index.search('تصدير');
    expect(byAr.map((r) => r.setting.key), contains('action_export'));
  });
}
