import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ns_intl_phone_input/ns_intl_phone_input.dart';

void main() {
  testWidgets('countrySelect Screen test', (WidgetTester tester) async {
    CountryModel? country;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return CountrySelectScreen(
              onCountrySelected: (countryModel) {
                country = countryModel;
              },
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle(Durations.long1);

    expect(find.byType(CountrySelectionWidget), findsOneWidget);

    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'india');

    await tester.pumpAndSettle();

    expect(find.text('India'), findsOneWidget);

    await tester.tap(find.byType(ListTile).first);

    await tester.pumpAndSettle();

    expect(country, isNotNull);
  });
}
