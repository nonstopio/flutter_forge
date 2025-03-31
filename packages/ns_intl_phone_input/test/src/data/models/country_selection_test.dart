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

  const country2 = CountryModel(
    countryName: 'USA',
    regions: {'North America'},
    iso2Code: 'us',
    intlDialCode: '1',
  );

  final selection1 = CountrySelection(
    selectedCountry: country1,
    formattedPhoneNumber: '12345-67890',
    unformattedPhoneNumber: '1234567890',
  );

  final selection2 = CountrySelection(
    selectedCountry: country2,
    formattedPhoneNumber: '9876543210',
    unformattedPhoneNumber: '9876543210',
  );
  group(CountrySelection, () {
    test('CountrySelection instances with different properties are not equal',
        () {
      expect(selection1, isNot(equals(selection2)));
      expect(selection1, equals(selection1));
    });

    test('CountrySelection phone number is valid or not', () {
      expect(selection1.isValid(), true);
      expect(selection2.isValid(), false);
    });

    // is equal
    test('CountrySelection phone number is equal or not', () {
      expect(selection1.isEqual(selection1), true);
    });

    test('Test the complete Formatted & UnFormatted Numbers', () {
      final selection = CountrySelection(
        selectedCountry: country1,
        formattedPhoneNumber: '12345-67890',
        unformattedPhoneNumber: '1234567890',
      );

      expect(selection.completePhoneNumber, '91 1234567890');
      expect(selection.completeFormattedPhoneNumber, '91 12345-67890');
    });

    // to String
    test('Test the toString method', () {
      final selection = CountrySelection(
        selectedCountry: country1,
        formattedPhoneNumber: '12345-67890',
        unformattedPhoneNumber: '1234567890',
      );

      expect(
        selection.toString(),
        contains('CountrySelection'),
      );
    });
  });
}
