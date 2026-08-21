import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_settings_framework/flutter_settings_framework.dart';

import 'catalog.dart';

class ExampleApp extends ConsumerWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watchSetting(languageSetting);
    final themeMode = themeModeFor(ref.watchSetting(themeModeSetting));
    final seed = Color(ref.watchSetting(themeColorSetting));
    final textScale = fontScaleFor(ref.watchSetting(fontSizeScaleSetting));
    final locale = Locale(language);
    final light = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seed),
      useMaterial3: true,
      fontFamily: 'Roboto',
      fontFamilyFallback: const ['Baz'],
    );
    final dark = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
      fontFamilyFallback: const ['Baz'],
    );

    return MaterialApp(
      title: translateExample('app_title', language),
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: light,
      darkTheme: dark,
      themeMode: themeMode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: ExampleSettingsPage(localeCode: language),
    );
  }
}

class ExampleSettingsPage extends ConsumerWidget {
  const ExampleSettingsPage({super.key, required this.localeCode});

  final String localeCode;

  String t(String key) => translateExample(key, localeCode);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvidersProvider);
    final registry = settings.registry;
    final tags = ref.watchSetting(tagsSetting);

    return RegistrySettingsPage(
      registry: registry,
      settings: settings,
      title: t('app_title'),
      searchHint: t('search_hint'),
      sectionTitleBuilder: t,
      enumLabelBuilder: t,
      emptySearchMessageBuilder: (query) =>
          t('empty_search').replaceAll('{query}', query),
      tileBuilder: (setting, defaultTile) {
        if (setting.key == displayNameSetting.key) {
          final value = ref.watchSetting(displayNameSetting);
          return SettingsTile.fromSetting(
            setting: setting,
            title: t(setting.titleKey),
            subtitle: value,
            onTap: () => _editDisplayName(context, ref, value),
          );
        }
        if (setting.key == exportSetting.key) {
          return ActionSettingsTile(
            leading: Icon(setting.icon),
            title: Text(t(setting.titleKey)),
            subtitle: Text(t(setting.subtitleKey!)),
            onTap: () => _export(context, ref),
          );
        }
        if (setting.key == resetSetting.key) {
          return ActionSettingsTile(
            leading: Icon(setting.icon),
            title: Text(t(setting.titleKey)),
            subtitle: Text(t(setting.subtitleKey!)),
            isDangerous: true,
            onTap: () => _reset(context, ref),
          );
        }
        if (setting.key == versionSetting.key) {
          return InfoSettingsTile(
            leading: Icon(setting.icon),
            title: Text(t(setting.titleKey)),
            value: const Text('0.6.0'),
            copyable: true,
            copyValue: '0.6.0',
          );
        }
        if (setting.key == licenseSetting.key) {
          return InfoSettingsTile(
            leading: Icon(setting.icon),
            title: Text(t(setting.titleKey)),
            value: const Text('MPL-2.0'),
            copyable: true,
            copyValue: 'MPL-2.0',
          );
        }
        return defaultTile;
      },
      sectionContentBuilder: (sectionKey, children) {
        if (sectionKey != 'data') return children;
        return [
          ...children,
          NavigationSettingsTile(
            leading: Icon(tagsSetting.icon),
            title: Text(t(tagsSetting.titleKey)),
            subtitle: Text(tags.join(' · ')),
          ),
        ];
      },
    );
  }

  Future<void> _editDisplayName(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final controller = TextEditingController(text: current);
    final next = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t('name_dialog')),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: displayNameSetting.maxLength,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(t('confirm')),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (next != null && next.isNotEmpty) {
      await ref.updateSetting(displayNameSetting, next);
    }
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final payload = jsonEncode(ref.settings.controller.exportAll());
    await Clipboard.setData(ClipboardData(text: payload));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('copied'))),
      );
    }
  }

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    await ref.settings.controller.resetAll();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('reset_done'))),
      );
    }
  }
}
