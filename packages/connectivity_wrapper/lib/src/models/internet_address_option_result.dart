import 'internet_address_option.dart';

/// [InternetAddressOptionResult] is used to store the result of the address check.
/// It contains the options used for the address check and a boolean indicating
/// whether the address check was successful.
///
class InternetAddressOptionResult {
  /// [InternetAddressOptionResult] Constructor
  ///
  /// [options] is the options used for the address check.
  /// [isSuccess] is a boolean indicating whether the address check was successful.
  InternetAddressOptionResult(
    this.options, {
    required this.isSuccess,
    required this.duration,
  });

  /// Options used for the address check.
  final InternetAddressOption options;

  /// Boolean indicating whether the address check was successful.
  final bool isSuccess;

  final int duration;

  @override
  String toString() => 'AddressCheckResult($options, $isSuccess)';
}
