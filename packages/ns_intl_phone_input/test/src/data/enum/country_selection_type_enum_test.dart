import 'package:flutter_test/flutter_test.dart';
import 'package:ns_intl_phone_input/src/data/enum/country_selection_type_enum.dart';

void main() {
  group(
    'CountrySelectionType',
    () {
      test(
        'CountrySelectionTypeEnum contains : dialog, screen.',
        () {
          expect(
            CountrySelectionTypeEnum.values,
            [
              CountrySelectionTypeEnum.dialog,
              CountrySelectionTypeEnum.screen,
            ],
          );
        },
      );
    },
  );
}
