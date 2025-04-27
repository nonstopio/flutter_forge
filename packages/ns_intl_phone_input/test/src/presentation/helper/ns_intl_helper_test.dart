import 'package:flutter_test/flutter_test.dart';
import 'package:ns_intl_phone_input/ns_intl_phone_input.dart';

void main() {
  group(
    'NsIntlPhoneHelper',
    () {
      group('getMaskedPhoneNumber', () {
        test(
          'getMaskedPhoneNumber valid with countryCode and phoneNumber',
          () {
            final result = NSIntlPhoneHelper.getMaskedPhoneNumber(
              countryCode: '91',
              phoneNumber: '9876543210',
            );
            expect(result, '98765-43210');
          },
        );

        test(
          'getMaskedPhoneNumber invalid with countryCode and phoneNumber',
          () {
            final result = NSIntlPhoneHelper.getMaskedPhoneNumber(
              countryCode: '1021',
              phoneNumber: '9876543210',
            );
            expect(result, '9876543210');
          },
        );
      });

      group('getUnMaskedPhoneNumber getUnMaskedPhoneNumber', () {
        test(
          'getUnMaskedPhoneNumber getUnMaskedPhoneNumber',
          () {
            final result = NSIntlPhoneHelper.getUnMaskedPhoneNumber(
              phoneNumber: '+(98) 765-43210',
            );
            expect(result, '9876543210');
          },
        );
      });

      group('selectedCountryCode', () {
        test(
          'selectedCountryCode returns null when no country is selected',
          () {
            final result = NSIntlPhoneHelper.selectedCountryCode(
              countryCode: '9101',
            );
            expect(result, isNull);
          },
        );
        test(
          'selectedCountryCode returns with country selected',
          () {
            final result = NSIntlPhoneHelper.selectedCountryCode(
              countryCode: '91',
              phoneNumber: '9876543210',
            );
            expect(result!.countryName, 'India');
          },
        );
        test(
          'selectedCountryCode returns with country region code',
          () {
            final result = NSIntlPhoneHelper.selectedCountryCode(
              countryCode: '1',
              phoneNumber: '2041233123',
            );
            expect(result!.countryName, 'Canada');
          },
        );
      });

      group('getAllCountriesMap', () {
        test('getAllCountriesMap length test', () {
          final allCountry = NSIntlPhoneHelper.getAllCountriesMap();
          expect(allCountry.length, 544);
        });
      });

      group('countrySelectionFromPhoneNumber', () {
        test('countrySelectionFromPhoneNumber No country found', () {
          final country = NSIntlPhoneHelper.countrySelectionFromPhoneNumber(
            phoneNumber: '1293123123',
            countryCode: '2012',
          );

          expect(country, isNull);
        });

        test('countrySelectionFromPhoneNumber country found', () {
          final country = NSIntlPhoneHelper.countrySelectionFromPhoneNumber(
            phoneNumber: '9876543210',
            countryCode: '91',
          );

          expect(country!.selectedCountry.countryName, 'India');
        });
      });
    },
  );
}
