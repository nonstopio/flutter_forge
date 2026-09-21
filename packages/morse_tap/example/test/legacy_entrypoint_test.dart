import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_tap_example/main.dart' as maintained;

import '../main.dart' as legacy;

void main() {
  testWidgets('legacy entrypoint launches the maintained example', (
    tester,
  ) async {
    legacy.main();
    await tester.pumpAndSettle();
    expect(find.byType(legacy.MorseTapExampleApp), findsOneWidget);
    expect(find.byType(maintained.MorseTapExampleApp), findsOneWidget);
    expect(find.text('Morse Tap Detector'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
