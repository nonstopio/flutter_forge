library;

import 'dart:async';

import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:notifications/src/config/index.dart';
import 'package:notifications/src/di/index.dart';

export 'src/client/index.dart';
export 'src/config/index.dart';
export 'src/device_info/index.dart';
export 'src/exceptions/index.dart';
export 'src/models/index.dart';
export 'src/services/index.dart';

/// Initialize the notifications module with dependency injection
Future<void> init({
  NotificationConfig config = const DefaultNotificationConfig(),
}) async {
  final logger = di.get<Logger>();
  try {
    await registerNotificationWithDI(config);
    logger.i('🔔 Notifications module initialized');
  } catch (e, s) {
    logger.e('🔔 Failed to initialize notifications module', e, s);
  }
}
