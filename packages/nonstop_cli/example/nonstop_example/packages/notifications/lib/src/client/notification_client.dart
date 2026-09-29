import 'package:firebase_messaging/firebase_messaging.dart'
    hide NotificationSettings;

/// Messaging, permission and device-registration contract used by the app.
abstract interface class NotificationClient {
  Future<void> init();

  Future<bool> requestPermissions({bool provisional = false});

  Future<String?> getFCMToken();

  Future<void> handleForegroundNotification(RemoteMessage message);

  Future<void> handleNotificationOpened(RemoteMessage message);

  Future<void> clearBadge();

  /// Removes this device's token registration from the backend, for example
  /// on sign-out. Does nothing when the device was never registered. Backend
  /// failures propagate so the caller decides whether sign-out continues.
  Future<void> unregisterDevice();

  String? get fcmToken;

  String? get deviceId;

  Future<void> dispose();
}
