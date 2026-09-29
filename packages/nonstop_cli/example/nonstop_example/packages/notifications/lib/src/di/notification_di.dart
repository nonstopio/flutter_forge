import 'package:di/di.dart';
import 'package:core/core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:network/network.dart';
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
  // Composition edge: resolve collaborators once, then inject them.
  final selectedMessaging = messaging ?? FirebaseMessaging.instance;
  final logger = di.get<Logger>();
  final networkClient = di.get<NetworkClient>();
  final deviceInfo = DeviceInfoImpl(logger: logger);
  final tokenManager = FirebaseTokenManager(
    logger: logger,
    networkClient: networkClient,
    deviceInfo: deviceInfo,
    firebaseMessaging: selectedMessaging,
  );
  final permissionManager = FirebasePermissionManager(
    logger: logger,
    firebaseMessaging: selectedMessaging,
  );

  di.register<NotificationConfig>(config);
  di.register<DeviceInfo>(deviceInfo);
  di.register<NotificationTokenManager>(tokenManager);
  di.register<NotificationPermissionManager>(permissionManager);
  di.register<NotificationClient>(
    FirebaseNotificationClient(
      config: config,
      logger: logger,
      messaging: selectedMessaging,
      tokenManager: tokenManager,
      permissionManager: permissionManager,
    ),
    dispose: (client) => client.dispose(),
  );
}
