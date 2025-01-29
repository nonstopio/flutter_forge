import '../utils/constants.dart';

/// [InternetAddressOption] is used to configure the address check options.
///
class InternetAddressOption {
  /// [InternetAddressOption] Constructor
  InternetAddressOption({
    required this.address,
    this.port = DEFAULT_PORT,
    this.timeout = DEFAULT_TIMEOUT,
    this.type = AddressCheckOptionsType.ANY,
  });

  /// Address to check
  final String address;

  /// Port to check
  final int port;

  /// Timeout Duration
  final Duration timeout;

  /// Type of address ["ANY", "IPv4", "IPv6", "Unix"]
  final AddressCheckOptionsType type;

  @override
  String toString() => 'AddressCheckOptions($address, $port, $timeout)';
}

enum AddressCheckOptionsType {
  ANY,
  IPv4,
  IPv6,
  Unix,
}
