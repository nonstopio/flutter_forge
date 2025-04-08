import 'package:flutter_test/flutter_test.dart';
import 'package:ns_intl_phone_input/ns_intl_phone_input.dart';

void main() {
  const country1 = CountryModel(
    countryName: 'India',
    regions: {'Asia'},
    iso2Code: 'in',
    intlDialCode: '91',
    format: '.....-.....',
  );
  group(
    'IntlTextController',
    () {
      test(
        'should set the initial value correctly',
        () {
          final controller = IntlTextEditingController(text: '9876543210');
          expect(controller.text, '9876543210');
        },
      );

      test(
        'should update the value correctly',
        () {
          final controller = IntlTextEditingController(text: '9876543210');
          controller.initialPhone(
            intlDialCode: '91',
            phoneNumber: '9876543210',
          );
          expect(controller.text, '98765-43210');
        },
      );

      test('intl setCountry', () {
        final controller = IntlTextEditingController(text: '9876543210');
        controller.initialPhone(
          intlDialCode: '91123',
          phoneNumber: '9876543210',
        );

        controller.setCountry(country1);
        expect(controller.text, '');
      });

      test(
        'should clear the value correctly',
        () {
          final controller = IntlTextEditingController(text: '9876543210');
          controller.clear();
          expect(controller.text, '');
        },
      );
    },
  );
}
