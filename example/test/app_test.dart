import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'screenshot_harness.dart';

Finder get searchField => find.byKey(const ValueKey('settings_search_field'));

void main() {
  testWidgets('example settings page renders tiles and bilingual search', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    expect(find.text('Edadat'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Accent color'), findsOneWidget);

    await tester.enterText(searchField, 'داكن');
    await tester.pumpAndSettle();
    expect(find.text('Theme'), findsWidgets);
  });

  testWidgets('search bar filters, shows empty state, and clears', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    await tester.enterText(searchField, 'zzzznotfound');
    await tester.pumpAndSettle();
    expect(find.textContaining('No settings found'), findsOneWidget);
    expect(find.text('General'), findsNothing);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    expect(searchField, findsOneWidget);
    expect(tester.widget<TextField>(searchField).controller?.text, isEmpty);
    expect(find.text('General'), findsOneWidget);
    expect(find.textContaining('No settings found'), findsNothing);
  });

  testWidgets('selecting a search result jumps back to the tile', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    await tester.enterText(searchField, 'theme');
    await tester.pumpAndSettle();
    expect(find.text('General › Theme'), findsOneWidget);

    await tester.tap(find.text('General › Theme'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 1600));

    expect(tester.widget<TextField>(searchField).controller?.text, isEmpty);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Theme'), findsWidgets);
    expect(find.text('Light'), findsOneWidget);
  });

  testWidgets('layout toggle switches mobile catalog to desktop split', (
    tester,
  ) async {
    await pumpExampleApp(tester);
    expect(find.text('Accent color'), findsOneWidget);
    expect(find.text('Select a setting to view details'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('layout_toggle')));
    await tester.pumpAndSettle();

    expect(find.text('Select a setting to view details'), findsOneWidget);
    expect(find.text('Accent color'), findsNothing);

    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();
    expect(find.text('Accent color'), findsOneWidget);
  });
}
