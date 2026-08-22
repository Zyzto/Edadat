import 'package:flutter/material.dart';
import 'package:flutter_settings_framework/flutter_settings_framework.dart';
import 'package:flutter_test/flutter_test.dart';

import 'screenshot_harness.dart';

Finder get searchField => find.byKey(const ValueKey('settings_search_field'));

/// Account dashboard can push later sections out of the lazy list viewport.
Finder listed(String text) => find.text(text, skipOffstage: false);

Future<void> revealText(WidgetTester tester, String text) async {
  if (find.text(text).evaluate().isNotEmpty) return;
  final list = find.byKey(const ValueKey('settings_list'));
  if (list.evaluate().isEmpty) return;
  final target = find.text(text, skipOffstage: false);
  for (var i = 0; i < 24 && target.evaluate().isEmpty; i++) {
    await tester.drag(list, const Offset(0, -280));
    await tester.pumpAndSettle();
  }
  if (find.text(text).evaluate().isEmpty && target.evaluate().isNotEmpty) {
    await tester.scrollUntilVisible(
      find.text(text, skipOffstage: false),
      280,
      scrollable: find.descendant(
        of: list,
        matching: find.byType(Scrollable),
      ),
    );
  }
}

void main() {
  testWidgets('account section shows profile card and inline dashboard', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    expect(find.text('Account'), findsOneWidget);
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsWidgets);
    expect(find.text('ada@example.com'), findsOneWidget);
    expect(find.text('Plan usage'), findsOneWidget);
    expect(find.byType(ProfileKpiStrip), findsOneWidget);
    expect(
      find.byType(ProfileBudgetCard, skipOffstage: false),
      findsNWidgets(2),
    );
    expect(
      find.byType(ProfileNotificationTile, skipOffstage: false),
      findsWidgets,
    );
    expect(
      find.byType(ProfileStatusBanner, skipOffstage: false),
      findsOneWidget,
    );
    expect(find.byType(ProfilePlanCard, skipOffstage: false), findsOneWidget);
    expect(
      find.byType(ProfileSessionTile, skipOffstage: false),
      findsNWidgets(2),
    );
    expect(
      find.byType(ProfilePlaceholder, skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('see all sessions opens a device sheet', (tester) async {
    await pumpExampleApp(tester);

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    final seeAll = find.text('See all');
    await tester.ensureVisible(seeAll);
    await tester.pumpAndSettle();
    await tester.tap(seeAll);
    await tester.pumpAndSettle();

    expect(find.text('4 devices signed in'), findsOneWidget);
    expect(find.text('Other devices'), findsOneWidget);
    expect(find.text('iPad'), findsOneWidget);
    expect(find.text('Firefox on Windows'), findsOneWidget);
    expect(find.text('Sign out other devices'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('iPad'), findsNothing);
  });

  testWidgets('search profile finds the account action', (tester) async {
    await pumpExampleApp(tester);

    await tester.enterText(searchField, 'profile');
    await tester.pumpAndSettle();
    expect(find.text('Account › Profile'), findsOneWidget);
  });

  testWidgets('example settings page renders tiles and bilingual search', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    expect(find.text('Edadat'), findsOneWidget);
    await revealText(tester, 'General');
    expect(listed('General'), findsOneWidget);
    await revealText(tester, 'Appearance');
    expect(listed('Appearance'), findsOneWidget);
    await revealText(tester, 'Notifications');
    expect(listed('Notifications'), findsOneWidget);
    await revealText(tester, 'Accent color');
    expect(listed('Accent color'), findsOneWidget);

    await tester.enterText(searchField, 'داكن');
    await tester.pumpAndSettle();
    expect(find.text('Theme'), findsWidgets);
  });

  testWidgets('search bar filters, shows empty state, and clears', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    expect(find.text('Search settings...'), findsOneWidget);

    await tester.enterText(searchField, 'zzzznotfound');
    await tester.pumpAndSettle();
    expect(find.textContaining('No settings found'), findsOneWidget);
    expect(find.text('General'), findsNothing);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    expect(searchField, findsOneWidget);
    expect(tester.widget<TextField>(searchField).controller?.text, isEmpty);
    expect(listed('General'), findsOneWidget);
    expect(find.textContaining('No settings found'), findsNothing);
    expect(find.text('Search settings...'), findsOneWidget);
  });

  testWidgets('selecting a search result jumps back to the tile', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    await tester.enterText(searchField, 'theme');
    await tester.pumpAndSettle();
    expect(find.text('General › Theme'), findsOneWidget);

    await tester.tap(find.text('General › Theme'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(tester.widget<TextField>(searchField).controller?.text, isEmpty);
    expect(listed('General'), findsOneWidget);
    expect(listed('Theme'), findsWidgets);
    expect(listed('Light'), findsOneWidget);
  });

  testWidgets('layout toggle switches mobile catalog to desktop split', (
    tester,
  ) async {
    await pumpExampleApp(tester);
    await revealText(tester, 'Accent color');
    expect(listed('Accent color'), findsOneWidget);
    expect(find.text('Select a setting to view details'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('layout_toggle')));
    await tester.pumpAndSettle();

    expect(find.text('Select a setting to view details'), findsOneWidget);
    expect(find.text('Accent color'), findsNothing);

    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();
    expect(find.text('Accent color'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('layout_toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Select a setting to view details'), findsNothing);
    expect(listed('Accent color'), findsOneWidget);
    expect(listed('General'), findsOneWidget);
  });

  testWidgets('phone frame wraps the catalog on a wide mobile host', (
    tester,
  ) async {
    await pumpExampleApp(tester);
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 2;
    await tester.pumpAndSettle();

    expect(find.byType(FittedBox), findsOneWidget);
    expect(find.text('Edadat'), findsOneWidget);
    await revealText(tester, 'General');
    expect(listed('General'), findsOneWidget);
    await revealText(tester, 'Accent color');
    expect(listed('Accent color'), findsOneWidget);
    expect(find.text('Search settings...'), findsOneWidget);
  });

  testWidgets('desktop detail pane rebuilds after language change', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    await tester.tap(find.byKey(const ValueKey('layout_toggle')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('General'));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsWidgets);

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arabic'));
    await tester.pumpAndSettle();

    expect(find.text('اللغة'), findsWidgets);
    expect(find.text('Language'), findsNothing);
    expect(find.text('عام'), findsWidgets);

    await tester.tap(find.text('المظهر'));
    await tester.pumpAndSettle();
    expect(find.text('لون التمييز'), findsOneWidget);
    expect(find.text('Accent color'), findsNothing);
  });

  testWidgets('language menu lists locales and applies Arabic', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    expect(find.byIcon(Icons.language_outlined), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('language_toggle')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('language_menu')), findsOneWidget);
    expect(find.byKey(const ValueKey('language_option_ar')), findsOneWidget);
    expect(find.byKey(const ValueKey('language_option_en')), findsOneWidget);

    final menu = tester.getRect(find.byKey(const ValueKey('language_menu')));
    final globe = tester.getRect(find.byKey(const ValueKey('language_toggle')));
    expect(menu.width, 92);
    expect((menu.center.dx - globe.center.dx).abs(), lessThan(1.5));

    await tester.tap(find.byKey(const ValueKey('language_option_ar')));
    await tester.pumpAndSettle();

    expect(find.text('إعدادات'), findsOneWidget);
    await revealText(tester, 'عام');
    expect(listed('عام'), findsOneWidget);
    expect(find.text('Edadat'), findsNothing);

    await tester.enterText(searchField, 'theme');
    await tester.pumpAndSettle();
    expect(find.text('عام ‹ السمة'), findsOneWidget);
  });

  testWidgets('theme toggle switches light to dark', (tester) async {
    await pumpExampleApp(tester);

    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('theme_toggle')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
  });

  testWidgets('desktop search result opens the section in the detail pane', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    await tester.tap(find.byKey(const ValueKey('layout_toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Select a setting to view details'), findsOneWidget);

    await tester.enterText(searchField, 'theme');
    await tester.pumpAndSettle();
    expect(find.text('General › Theme'), findsOneWidget);

    await tester.tap(find.text('General › Theme'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(tester.widget<TextField>(searchField).controller?.text, isEmpty);
    expect(find.text('Select a setting to view details'), findsNothing);
    expect(find.byKey(const ValueKey('detail_general')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('detail_general')),
        matching: find.text('Theme'),
      ),
      findsWidgets,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('detail_general')),
        matching: find.text('Light'),
      ),
      findsOneWidget,
    );
  });
}
