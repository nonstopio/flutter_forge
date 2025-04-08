import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ns_intl_phone_input/ns_intl_phone_input.dart';

void main() {
  const country = CountryModel(
    countryName: 'India',
    regions: {'Asia'},
    iso2Code: 'in',
    intlDialCode: '91',
    format: '.....-.....',
    currentAreaCode: '91',
  );
  testWidgets('CountryDropdownWidget', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CountryDropDownWidget(
          country: country,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('India'), findsOneWidget);
  });
}
