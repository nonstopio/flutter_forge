import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ns_intl_phone_input/ns_intl_phone_input.dart';

void main() {
  testWidgets('CountryDropdownWidget country not selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FontTextWidget(
          text: '🇮🇳',
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(Text), findsOneWidget);
  });
}
