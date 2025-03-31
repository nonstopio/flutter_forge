import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ns_intl_phone_input/ns_intl_phone_input.dart';

void main() {
  testWidgets('CountryDropdownWidget', (WidgetTester tester) async {
    CountryModel? country;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CountrySelectionWidget(
            onCountrySelected: ((p0) {
              country = p0;
            }),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'india');

    await tester.pumpAndSettle();

    expect(find.text('India'), findsOneWidget);

    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    expect(country, isNotNull);
  });
}
