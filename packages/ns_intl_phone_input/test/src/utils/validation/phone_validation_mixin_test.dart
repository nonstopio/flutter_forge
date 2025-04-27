import 'package:flutter_test/flutter_test.dart';
import 'package:ns_intl_phone_input/ns_intl_phone_input.dart';
import 'package:ns_intl_phone_input/src/utils/validation/phone_validation_mixin.dart';

void main() {
  group(
    'PhoneValidationMixin',
    () {
      const country = CountryModel(
        countryName: 'India',
        regions: {'Asia'},
        iso2Code: 'in',
        intlDialCode: '91',
        format: '.....-.....',
        currentAreaCode: '91',
      );
      //  empty selectedCountry
      test(
        'PhoneValidationMixin Test',
        () async {
          final phoneValidationMixinTest = PhoneValidationMixinTest();
          expect(
            phoneValidationMixinTest.validate(
              selectedCountry: null,
              value: '1234567890',
              validationMessage: 'Validation Message',
            ),
            'Validation Message',
          );
        },
      );

      test(
        'PhoneValidationMixin Test',
        () async {
          final phoneValidationMixinTest = PhoneValidationMixinTest();
          expect(
            phoneValidationMixinTest.validate(
              selectedCountry: country,
              value: '1234567890',
              validationMessage: 'Validation Message',
            ),
            'Validation Message',
          );

          // empty value
          expect(
            phoneValidationMixinTest.validate(
              selectedCountry: country,
              value: '',
              validationMessage: 'Validation Message',
            ),
            'Validation Message',
          );

          // null value

          expect(
            phoneValidationMixinTest.validate(
              selectedCountry: country,
              value: null,
              validationMessage: 'Validation Message',
            ),
            'Validation Message',
          );

          // in valid value
          expect(
            phoneValidationMixinTest.validate(
              selectedCountry: country,
              value: '12345',
              validationMessage: 'Validation Message',
            ),
            'Validation Message',
          );
        },
      );

      // test valid value
      test('Valid value', () {
        final phoneValidationMixinTest = PhoneValidationMixinTest();
        expect(
          phoneValidationMixinTest.validate(
            selectedCountry: country,
            value: '12345-67890',
            validationMessage: 'Validation Message',
          ),
          null,
        );
      });
    },
  );
}

class PhoneValidationMixinTest with PhoneValidationMixin {
  String? validate({
    required CountryModel? selectedCountry,
    required String? value,
    required String validationMessage,
  }) {
    return validatePhone(
      selectedCountry: selectedCountry,
      value: value,
      validationMessage: 'Validation Message',
    );
  }
}
