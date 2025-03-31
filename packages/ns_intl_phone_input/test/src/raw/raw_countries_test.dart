import 'package:flutter_test/flutter_test.dart';
import 'package:ns_intl_phone_input/ns_intl_phone_input.dart';

void main() {
  group(
    'CountryModel',
    () {
      test(
        'RawCountriesTest',
        () {
          expect(rawCountries.length, 212);
          expect(rawCountries, rawCountries);
        },
      );
    },
  );
}
