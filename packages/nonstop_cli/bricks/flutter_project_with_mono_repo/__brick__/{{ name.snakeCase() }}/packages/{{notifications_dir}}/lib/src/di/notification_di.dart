import 'package:di/di.dart';
import 'package:core/core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notifications/src/client/index.dart';
import 'package:notifications/src/config/index.dart';
import 'package:notifications/src/device_info/index.dart';
import 'package:notifications/src/services/notification_permission_manager.dart';
import 'package:notifications/src/services/notification_token_manager.dart';

/// Register notification services with dependency injection
Future<void> registerNotificationWithDI(
  NotificationConfig config, {
  FirebaseMessaging? messaging,
}) async {
  final selectedMessaging = messaging ?? FirebaseMessaging.instance;
  // Register config
  di.register<NotificationConfig>(config);

  // Register device info service
  di.register<DeviceInfo>(DeviceInfoImpl(logger: di.get<Logger>()));

  // Register token manager
  di.register<NotificationTokenManager>(
    FirebaseTokenManager(firebaseMessaging: selectedMessaging),
  );

  // Register permission manager
  di.register<NotificationPermissionManager>(
    FirebasePermissionManager(firebaseMessaging: selectedMessaging),
  );

  // Register notification client with proper disposal
  di.register<NotificationClient>(
    FirebaseNotificationClient(
      config: config,
      logger: di.get<Logger>(),
      messaging: selectedMessaging,
      tokenManager: di.get<NotificationTokenManager>(),
      permissionManager: di.get<NotificationPermissionManager>(),
    ),
    dispose: (client) => client.dispose(),
  );
}
