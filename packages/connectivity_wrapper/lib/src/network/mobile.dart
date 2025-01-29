import 'dart:io';

import '../models/models.dart';

class Network {
  static List<InternetAddressOption> get defaultPingTargets =>
      List<InternetAddressOption>.unmodifiable(
        <InternetAddressOption>[
          InternetAddressOption(
            address: '1.1.1.1',
            type: AddressCheckOptionsType.IPv4,
          ),
          InternetAddressOption(
            address: '2606:4700:4700::1111',
            type: AddressCheckOptionsType.IPv6,
          ),
          InternetAddressOption(
            address: '8.8.4.4',
            type: AddressCheckOptionsType.IPv4,
          ),
          InternetAddressOption(
            address: '2001:4860:4860::8888',
            type: AddressCheckOptionsType.IPv6,
          ),
          InternetAddressOption(
            address: '208.67.222.222',
            type: AddressCheckOptionsType.IPv4,
          ),
          InternetAddressOption(
            address: '2620:0:ccc::2',
            type: AddressCheckOptionsType.IPv6,
          ),
        ],
      );

  static Future<InternetAddressOptionResult> checkHostReachability(
    InternetAddressOption options,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final internetAddress = InternetAddress(
        options.address,
        type: options.type == AddressCheckOptionsType.IPv4
            ? InternetAddressType.IPv4
            : options.type == AddressCheckOptionsType.IPv6
                ? InternetAddressType.IPv6
                : InternetAddressType.any,
      );
      final socket = await Socket.connect(
        internetAddress,
        options.port,
        timeout: options.timeout,
      );
      socket.destroy();
      stopwatch.stop();
      return InternetAddressOptionResult(
        options,
        isSuccess: true,
        duration: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      stopwatch.stop();
      return InternetAddressOptionResult(
        options,
        isSuccess: false,
        duration: stopwatch.elapsedMilliseconds,
      );
    }
  }
}
