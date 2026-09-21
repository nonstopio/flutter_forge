import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ns_intl_phone_input/ns_intl_phone_input.dart';
import 'package:ns_intl_phone_input_example/home/home_screen.dart';
import 'package:ns_intl_phone_input_example/main.dart' as app;

void main() {
  testWidgets('form example sets a sample number, submits and clears',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set Sample Phone Number'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<TextField>(find.byType(TextField).last)
            .controller!
            .text
            .replaceAll(RegExp(r'\D'), ''),
        samplePhoneNumber);
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(find.text('Validated'), findsOneWidget);
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(
        tester.widget<TextField>(find.byType(TextField).last).controller!.text,
        isEmpty);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(find.text('Not Validated'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });
  testWidgets('phone example accepts phone input', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('NsIntlPhoneInput Example'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '987654321');
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<TextField>(find.byType(TextField).last)
            .controller!
            .text
            .replaceAll(RegExp(r'\D'), ''),
        '987654321');
    final phone =
        tester.widget<NsIntlPhoneInput>(find.byType(NsIntlPhoneInput));
    phone.textEditingController.initialPhone(
        phoneNumber: samplePhoneNumber, intlDialCode: sampleCountryCode);
    await tester.pumpAndSettle();
    final messages = <String?>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => messages.add(message);
    try {
      phone.onPhoneChange(CountrySelection(
          selectedCountry: phone.textEditingController.selectedCountry!,
          formattedPhoneNumber: samplePhoneNumber,
          unformattedPhoneNumber: samplePhoneNumber));
      expect(messages.single, contains(samplePhoneNumber));
    } finally {
      debugPrint = originalDebugPrint;
    }
  });
}
