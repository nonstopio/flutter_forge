import 'package:flutter/services.dart';

abstract final class DeviceService {
  static Future<void> setOrientationToPortrait() async {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
