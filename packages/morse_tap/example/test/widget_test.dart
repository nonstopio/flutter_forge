// Basic widget test for Morse Tap Example app.

import 'package:flutter_test/flutter_test.dart';

import 'package:morse_tap_example/main.dart';

void main() {
  testWidgets('Morse Tap Example app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MorseTapExampleApp());

    // Verify that the app loads with expected elements
    expect(find.text('Morse Tap Example'), findsOneWidget);
    expect(find.text('Tap Detector'), findsOneWidget);
  });
}
