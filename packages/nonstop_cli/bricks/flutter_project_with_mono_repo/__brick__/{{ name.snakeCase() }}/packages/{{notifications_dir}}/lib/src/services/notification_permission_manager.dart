import 'package:core/logger/logger.dart';
import 'package:di/di.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:network/network.dart';
import 'package:notifications/src/exceptions/notification_exceptions.dart';

abstract class NotificationPermissionManager {
  Future<bool> requestPermissions();
}

class FirebasePermissionManager implements NotificationPermissionManager {
  static const String _tag = 'FirebasePermissionManager';

  final Logger _logger;
  final FirebaseMessaging _firebaseMessaging;

  FirebasePermissionManager({
    Logger? logger,
    FirebaseMessaging? firebaseMessaging,
  }) : _logger = logger ?? di.get<Logger>(),
       _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance;

  @override
  Future<bool> requestPermissions() async {
    try {
      _logger.i('$_tag: Requesting notification permissions');
      final authSettings = await _firebaseMessaging.requestPermission();

      final isGranted =
          authSettings.authorizationStatus == AuthorizationStatus.authorized ||
          authSettings.authorizationStatus == AuthorizationStatus.provisional;

      _logger.i(
        '$_tag: Notification permissions requested '
        'with status: ${authSettings.authorizationStatus}, '
        'granted: $isGranted',
      );

      return isGranted;
    } catch (e, s) {
      _logger.e('$_tag: Error requesting permissions', e, s);
      throw NotificationException(message: e.message());
    }
  }
}
