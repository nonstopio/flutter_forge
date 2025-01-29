import 'address_check_options.dart';

/// [AddressCheckResult] is used to store the result of the address check.
/// It contains the options used for the address check and a boolean indicating
/// whether the address check was successful.
///
class AddressCheckResult {
  /// [AddressCheckResult] Constructor
  ///
  /// [options] is the options used for the address check.
  /// [isSuccess] is a boolean indicating whether the address check was successful.
  AddressCheckResult(
    this.options, {
    required this.isSuccess,
  });

  /// Options used for the address check.
  final AddressCheckOptions options;

  /// Boolean indicating whether the address check was successful.
  final bool isSuccess;

  @override
  String toString() => 'AddressCheckResult($options, $isSuccess)';
}
