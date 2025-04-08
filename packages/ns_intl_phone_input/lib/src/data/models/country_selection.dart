import 'country.dart';

class CountrySelection {
  final CountryModel selectedCountry;

  final String formattedPhoneNumber;

  final String unformattedPhoneNumber;

  String get completeFormattedPhoneNumber =>
      '${selectedCountry.intlDialCode} $formattedPhoneNumber';

  String get completePhoneNumber =>
      '${selectedCountry.intlDialCode} $unformattedPhoneNumber';

  bool isValid() {
    return selectedCountry.iso2Code.isNotEmpty &&
        formattedPhoneNumber.isNotEmpty &&
        unformattedPhoneNumber.isNotEmpty &&
        formattedPhoneNumber.length == selectedCountry.format?.length;
  }

  bool isEqual(CountrySelection? countrySelection) {
    if (countrySelection == null) return false;
    return countrySelection.selectedCountry.iso2Code ==
            selectedCountry.iso2Code &&
        countrySelection.formattedPhoneNumber == formattedPhoneNumber &&
        countrySelection.unformattedPhoneNumber == unformattedPhoneNumber;
  }

  CountrySelection({
    required this.selectedCountry,
    required this.formattedPhoneNumber,
    required this.unformattedPhoneNumber,
  });

  @override
  String toString() {
    return '''CountrySelection(
      selectedCountry: $selectedCountry, 
      formattedPhoneNumber: $formattedPhoneNumber, 
      unformattedPhoneNumber: $unformattedPhoneNumber
      )''';
  }
}
