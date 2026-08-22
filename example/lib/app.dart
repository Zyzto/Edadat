import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_settings_framework/flutter_settings_framework.dart';

import 'appearance_toggles.dart';
import 'catalog.dart';
import 'profile_demo.dart';
import 'theme_ripple.dart';

enum ExamplePreviewLayout { mobile, desktop }

/// Gold-family surfaces with contrast overrides so outline / secondary
/// copy stay readable. Seed still comes from the accent-color setting.
ThemeData catalogTheme(Brightness brightness, Color seed) {
  final base = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  final scheme = switch (brightness) {
    Brightness.light => base.copyWith(
      onSurface: const Color(0xFF1F1708),
      onSurfaceVariant: const Color(0xFF534A3C),
      outline: const Color(0xFF7A6F5F),
      outlineVariant: const Color(0xFFC9BDAA),
      surface: const Color(0xFFFFF8F0),
      surfaceContainerLow: const Color(0xFFF7EFE3),
      surfaceContainerHigh: const Color(0xFFEDE3D4),
      surfaceContainerHighest: const Color(0xFFE7DCCB),
    ),
    Brightness.dark => base.copyWith(
      onSurface: const Color(0xFFF6EFE2),
      onSurfaceVariant: const Color(0xFFD0C4B4),
      outline: const Color(0xFFA89884),
      outlineVariant: const Color(0xFF5A5146),
      surface: const Color(0xFF16130F),
      surfaceContainerLow: const Color(0xFF221E18),
      surfaceContainerHigh: const Color(0xFF322C24),
      surfaceContainerHighest: const Color(0xFF3C352C),
    ),
  };
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    fontFamily: 'Roboto',
    fontFamilyFallback: const ['Baz'],
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: scheme.onSurface),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
    ),
  );
}

class ExampleApp extends ConsumerStatefulWidget {
  const ExampleApp({super.key});

  @override
  ConsumerState<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends ConsumerState<ExampleApp> {
  var _layout = ExamplePreviewLayout.mobile;

  @override
  Widget build(BuildContext context) {
    final language = ref.watchSetting(languageSetting);
    final themeMode = themeModeFor(ref.watchSetting(themeModeSetting));
    final seed = Color(ref.watchSetting(themeColorSetting));
    final textScale = fontScaleFor(ref.watchSetting(fontSizeScaleSetting));

    return MaterialApp(
      title: translateExample('app_title', language),
      debugShowCheckedModeBanner: false,
      locale: catalogFlutterLocale(language),
      supportedLocales: [for (final item in catalogLocales) item.locale],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: catalogTheme(Brightness.light, seed),
      darkTheme: catalogTheme(Brightness.dark, seed),
      themeMode: themeMode,
      builder: (context, child) {
        final overlayMode = Theme.of(context).brightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light;
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: ThemeRippleHost(
            overlay: CatalogAppearanceToggles(
              localeCode: language,
              themeMode: overlayMode,
              isMobileLayout: _layout == ExamplePreviewLayout.mobile,
              onSelectLocale: (code) =>
                  ref.updateSetting(languageSetting, code),
              onToggleTheme: () async {
                final current = ref.readSetting(themeModeSetting);
                await ref.updateSetting(
                  themeModeSetting,
                  current == 'dark' ? 'light' : 'dark',
                );
              },
              onToggleLayout: () {
                setState(() {
                  _layout = _layout == ExamplePreviewLayout.mobile
                      ? ExamplePreviewLayout.desktop
                      : ExamplePreviewLayout.mobile;
                });
              },
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: ExampleSettingsPage(
        localeCode: language,
        layout: _layout,
      ),
    );
  }
}

class ExampleSettingsPage extends ConsumerStatefulWidget {
  const ExampleSettingsPage({
    super.key,
    required this.localeCode,
    required this.layout,
  });

  final String localeCode;
  final ExamplePreviewLayout layout;

  @override
  ConsumerState<ExampleSettingsPage> createState() =>
      _ExampleSettingsPageState();
}

class _ExampleSettingsPageState extends ConsumerState<ExampleSettingsPage> {
  String t(String key) => translateExample(key, widget.localeCode);

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvidersProvider);
    final registry = settings.registry;
    final tags = ref.watchSetting(tagsSetting);
    final isMobile = widget.layout == ExamplePreviewLayout.mobile;
    final host = MediaQuery.sizeOf(context);

    final page = RegistrySettingsPage(
      splitLayout: !isMobile,
      registry: registry,
      settings: settings,
      title: t('app_title'),
      searchHint: t('search_hint'),
      sectionTitleBuilder: t,
      enumLabelBuilder: t,
      emptySearchMessageBuilder: (query) =>
          t('empty_search').replaceAll('{query}', query),
      emptyDetailMessage: t('empty_detail'),
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
            value: const Directionality(
              textDirection: TextDirection.ltr,
              child: Text('0.7.0'),
            ),
            copyable: true,
            copyValue: '0.7.0',
            copiedMessage: t('copied'),
          );
        }
        if (setting.key == licenseSetting.key) {
          return InfoSettingsTile(
            leading: Icon(setting.icon),
            title: Text(t(setting.titleKey)),
            value: const Directionality(
              textDirection: TextDirection.ltr,
              child: Text('MPL-2.0'),
            ),
            copyable: true,
            copyValue: 'MPL-2.0',
            copiedMessage: t('copied'),
          );
        }
        if (setting.key == openProfileSetting.key) {
          final name = ref.watchSetting(displayNameSetting);
          return ProfileSettingsCard(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              child: Text(name.isEmpty ? '?' : String.fromCharCode(name.runes.first)),
            ),
            title: Text(name),
            subtitle: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(t('profile_email')),
            ),
            onTap: () => _editDisplayName(context, ref, name),
            actions: [
              ProfileSettingsAction(
                icon: Icons.edit_outlined,
                tooltip: t('edit'),
                onPressed: () => _editDisplayName(context, ref, name),
              ),
            ],
          );
        }
        return defaultTile;
      },
      sectionContentBuilder: (sectionKey, children) {
        if (sectionKey == 'account') {
          return [
            ...children,
            ExampleProfileDashboard(translate: t),
          ];
        }
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
      actions: const [
        SizedBox(width: 148),
      ],
    );

    if (!isMobile || host.width <= 420) return page;

    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: FittedBox(
          child: _PhoneFrame(child: page),
        ),
      ),
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

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child});

  static const size = Size(390, 844);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('catalog_phone_frame'),
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outline, width: 8),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            ColoredBox(
              color: scheme.surface,
              child: SizedBox(
                height: 28,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ExcludeSemantics(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          Text(
                            '9:41',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.signal_cellular_alt,
                            size: 14,
                            color: scheme.onSurface,
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.wifi, size: 14, color: scheme.onSurface),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.battery_full,
                            size: 14,
                            color: scheme.onSurface,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: Size(size.width, size.height - 28),
                  padding: EdgeInsets.zero,
                  viewPadding: EdgeInsets.zero,
                ),
                child: ColoredBox(color: scheme.surface, child: child),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
