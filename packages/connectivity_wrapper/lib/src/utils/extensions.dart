import 'package:flutter/material.dart';

import '../models/models.dart';

extension AddressCheckOptionsListExtension
    on List<InternetAddressOptionResult> {
  InternetSpeed determineInternetSpeed() {
    final averageLatency =
        map((result) => result.duration).reduce((a, b) => a + b) / length;
    if (averageLatency < 500) {
      return InternetSpeed.GOOD;
    } else if (averageLatency < 1000) {
      return InternetSpeed.SLOW;
    } else {
      return InternetSpeed.BAD;
    }
  }
}

extension ConnectivityStatusExtension on InternetSpeed {
  Color get color {
    switch (this) {
      case InternetSpeed.GOOD:
        return Colors.green;
      case InternetSpeed.SLOW:
        return Colors.orange;
      case InternetSpeed.BAD:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case InternetSpeed.GOOD:
        return Icons.signal_wifi_4_bar;
      case InternetSpeed.SLOW:
        return Icons.signal_wifi_statusbar_connected_no_internet_4;
      case InternetSpeed.BAD:
        return Icons.signal_wifi_bad;
    }
  }

  String get value {
    switch (this) {
      case InternetSpeed.GOOD:
        return 'good';
      case InternetSpeed.SLOW:
        return 'slow';
      case InternetSpeed.BAD:
        return 'bad';
    }
  }
}
