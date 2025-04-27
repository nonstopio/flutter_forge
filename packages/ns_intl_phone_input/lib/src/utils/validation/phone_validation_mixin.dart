import '../../../ns_intl_phone_input.dart';

mixin PhoneValidationMixin {
  String? validatePhone({
    required CountryModel? selectedCountry,
    required String? value,
    required String validationMessage,
  }) {
    if (selectedCountry == null) {
      return validationMessage;
    } else if (value == null || value.isEmpty) {
      return validationMessage;
    } else if (value.length < (selectedCountry.format?.length ?? 15)) {
      return validationMessage;
    }
    return null;
  }
}
