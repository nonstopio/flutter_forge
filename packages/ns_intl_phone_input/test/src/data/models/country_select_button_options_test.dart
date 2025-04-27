import 'package:flutter_test/flutter_test.dart';
import 'package:ns_intl_phone_input/ns_intl_phone_input.dart';

void main() {
  group(
    'CountrySelectOption',
    () {
      test(
        'CountrySelectOption Default Constructor',
        () async {
          const countrySelectOption = CountrySelectOption();

          expect(countrySelectOption.showCode, false);

          expect(
            countrySelectOption.defaultText,
            '🏳️',
          );
        },
      );
    },
  );
}
