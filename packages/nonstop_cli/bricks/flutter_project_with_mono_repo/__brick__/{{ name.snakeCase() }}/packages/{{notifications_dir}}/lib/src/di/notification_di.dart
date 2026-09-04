import 'package:di/di.dart';
import 'package:notifications/src/client/index.dart';
import 'package:notifications/src/config/index.dart';
import 'package:notifications/src/device_info/index.dart';
import 'package:notifications/src/services/notification_permission_manager.dart';
import 'package:notifications/src/services/notification_token_manager.dart';

/// Register notification services with dependency injection
Future<void> registerNotificationWithDI(NotificationConfig config) async {
  // Register config
  di.register<NotificationConfig>(config);

  // Register device info service
  di.register<DeviceInfo>(DeviceInfoImpl());

  // Register token manager
  di.register<NotificationTokenManager>(FirebaseTokenManager());

  // Register permission manager
  di.register<NotificationPermissionManager>(FirebasePermissionManager());

  // Register notification client with proper disposal
  di.register<NotificationClient>(
    FirebaseNotificationClient(config: config),
    dispose: (client) => client.dispose(),
  );
}
