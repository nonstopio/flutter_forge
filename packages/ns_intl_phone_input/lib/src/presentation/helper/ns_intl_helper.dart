// get masked phone number

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../ns_intl_phone_input.dart';

class NSIntlPhoneHelper {
  /// Returns the masked phone number for the given country code and phone
  ///  number
  ///
  /// Example:
  ///  countryCode = '+91'
  ///  phoneNumber = '9876543210'
  ///
  /// Returns: '98765-43210' because (for India) masked format is '.....-.....'
  static String getMaskedPhoneNumber({
    required String countryCode,
    required String phoneNumber,
  }) {
    final selectedCountry = selectedCountryCode(
      countryCode: countryCode,
      phoneNumber: phoneNumber,
    );

    if (selectedCountry == null) {
      return phoneNumber;
    }

    var maskFormatter = MaskTextInputFormatter(
      mask: selectedCountry.format,
      filter: {'.': RegExp(r'[0-9]')},
    );
    final text = maskFormatter.maskText(phoneNumber);
    return text;
  }

  static String getUnMaskedPhoneNumber({
    required String phoneNumber,
  }) {
    return phoneNumber
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(' ', '')
        .replaceAll('+', '');
  }

  /// Returns the country model for the given country code and phone number
  /// If the phone number is empty, the country model for the given country
  /// code is returned
  ///
  ///
  static CountryModel? selectedCountryCode({
    required String countryCode,
    String phoneNumber = '',
  }) {
    try {
      CountryModel? selectedCountry;

      List<CountryModel> selectedCountries = rawCountries
          .where(
            (country) => country.intlDialCode == countryCode,
          )
          .toList();
      if (phoneNumber.isEmpty || selectedCountries.length == 1) {
        selectedCountry = selectedCountries.first;
      }

      for (final country in selectedCountries) {
        if (country.areaCodes == null || country.areaCodes!.isEmpty) {
          continue;
        } else {
          for (final region in country.areaCodes!) {
            if (phoneNumber.startsWith(region)) {
              selectedCountry = country;
            }
          }
        }
      }

      return selectedCountry;
    } catch (e) {
      return null;
    }
  }

  /// Returns a map of all countries with their international dial code and
  /// area codes (if any) as the key
  ///
  /// Example:
  ///   {
  ///     '+91': CountryModel(...),
  ///     '+91 (11)': CountryModel(...),
  ///     '+91 (22)': CountryModel(...),
  ///     '+91 (33)': CountryModel(...),
  /// }
  ///
  static Map<String, CountryModel> getAllCountriesMap() {
    final Map<String, CountryModel> countriesMap = {};

    for (final country in rawCountries) {
      final intlDialCode = country.intlDialCode;
      final areaCodes = country.areaCodes;

      if (areaCodes == null || areaCodes.isEmpty) {
        countriesMap[intlDialCode] = country;
      } else {
        for (final region in areaCodes) {
          countriesMap['$intlDialCode ($region)'] = country.copyWith(
            currentAreaCode: region,
          );
        }
      }
    }

    return countriesMap;
  }

  /// Returns CountrySelection object for the given country code and phone
  /// number
  ///
  /// Example:
  ///  countryCode = '+91'
  /// phoneNumber = '9876543210'
  ///
  /// Returns: CountrySelection(
  ///  selectedCountry: CountryModel(...),
  /// formattedPhoneNumber: '98765-43210',
  /// unformattedPhoneNumber: '9876543210',
  /// )
  static CountrySelection? countrySelectionFromPhoneNumber({
    required String phoneNumber,
    required String countryCode,
  }) {
    final selectedCountry = selectedCountryCode(
      countryCode: countryCode,
      phoneNumber: phoneNumber,
    );

    if (selectedCountry == null) {
      return null;
    }

    var maskFormatter = MaskTextInputFormatter(
      mask: selectedCountry.format,
      filter: {'.': RegExp(r'[0-9]')},
    );
    final text = maskFormatter.maskText(phoneNumber);

    return CountrySelection(
      selectedCountry: selectedCountry,
      formattedPhoneNumber: text,
      unformattedPhoneNumber: phoneNumber,
    );
  }
}
