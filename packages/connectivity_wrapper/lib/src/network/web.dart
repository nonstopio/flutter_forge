import 'package:http/http.dart' as http;

import '../models/models.dart';

class Network {
  static List<InternetAddressOption> get defaultPingTargets =>
      List<InternetAddressOption>.unmodifiable(
        <InternetAddressOption>[
          InternetAddressOption(address: 'https://icanhazip.com'),
          InternetAddressOption(address: 'https://api.ipify.org'),
          InternetAddressOption(address: 'https://ipinfo.io/ip'),
          InternetAddressOption(address: 'https://checkip.amazonaws.com'),
          InternetAddressOption(address: 'https://ifconfig.me/ip'),
          InternetAddressOption(address: 'https://ipecho.net/plain'),
        ],
      );

  static Future<InternetAddressOptionResult> checkHostReachability(
    InternetAddressOption options,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final response =
          await http.get(Uri.parse(options.address)).timeout(options.timeout);

      final result = response.statusCode == 200 || response.statusCode == 204;

      stopwatch.stop();
      return InternetAddressOptionResult(
        options,
        isSuccess: result,
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
