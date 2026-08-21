import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'screenshot_harness.dart';

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

    await tester.enterText(find.byType(TextField), 'داكن');
    await tester.pumpAndSettle();
    expect(find.text('Theme'), findsWidgets);
  });
}