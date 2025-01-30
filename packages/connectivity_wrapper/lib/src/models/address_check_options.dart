import 'dart:io';

import '../utils/constants.dart';

/// [AddressCheckOptions] is used to configure the address check options.
///
class AddressCheckOptions {
  /// [AddressCheckOptions] Constructor
  AddressCheckOptions({
    this.address,
    this.hostname,
    this.port = DEFAULT_PORT,
    this.timeout = DEFAULT_TIMEOUT,
  }) : assert(
          (address != null || hostname != null) &&
              ((address != null) != (hostname != null)),
          'Either address or hostname must be provided, but not both.',
        );

  /// Address to check
  final InternetAddress? address;

  /// Hostname to check
  final String? hostname;

  /// Port to check
  final int port;

  /// Timeout Duration
  final Duration timeout;

  @override
  String toString() => 'AddressCheckOptions($address, $port, $timeout)';
}
