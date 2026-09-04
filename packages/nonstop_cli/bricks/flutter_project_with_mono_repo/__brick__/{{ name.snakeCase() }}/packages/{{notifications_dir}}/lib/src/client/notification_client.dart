import 'package:firebase_messaging/firebase_messaging.dart'
    hide NotificationSettings;

/// Abstract notification client interface
/// Simplified interface following network package patterns
abstract class NotificationClient {
  Future<void> init();

  Future<bool> requestPermissions({bool provisional = false});

  Future<String?> getFCMToken();

  Future<void> handleForegroundNotification(RemoteMessage message);

  Future<void> handleNotificationOpened(
    RemoteMessage message, {
    String? source,
  });

  Future<void> clearBadge();

  String? get fcmToken;

  String? get deviceId;

  Future<void> dispose();
}
