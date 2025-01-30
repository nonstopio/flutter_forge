// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Duration _delayDuration = Duration(milliseconds: 500);

class StatusBarService {
  static Future<void> hideStatusBar() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: <SystemUiOverlay>[SystemUiOverlay.bottom],
    );
  }

  Future<void> showStatusBar() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  static Future<void> changeStatusColor(
    Color color, {
    bool whiteForeground = true,
  }) async {
    try {
      await Future<void>.delayed(_delayDuration);
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: color,
        ),
      );
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
        ),
      );
      await Future<void>.delayed(_delayDuration);
    } on PlatformException catch (e) {
      debugPrint('$e');
    }
  }

  static void resetStatusBarColor() {
    SystemChrome.restoreSystemUIOverlays();
  }
}
