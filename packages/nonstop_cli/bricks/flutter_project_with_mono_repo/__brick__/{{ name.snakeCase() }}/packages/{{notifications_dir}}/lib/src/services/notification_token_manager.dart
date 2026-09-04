import 'dart:io';

import 'package:core/logger/logger.dart';
import 'package:di/di.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:network/network.dart';
import 'package:notifications/notifications.dart';

abstract class NotificationTokenManager {
  Future<String?> getFCMToken();

  Future<String> registerToken(String fcmToken);

  Future<void> unRegisterToken(String deviceId);

  Future<void> handleTokenRefresh(String newToken);
}

class FirebaseTokenManager implements NotificationTokenManager {
  static const String _tag = 'FirebaseTokenManager';

  final Logger _logger;
  final NetworkClient _networkClient;
  final DeviceInfo _deviceInfo;
  final FirebaseMessaging _firebaseMessaging;

  FirebaseTokenManager({
    Logger? logger,
    NetworkClient? networkClient,
    DeviceInfo? deviceInfo,
    FirebaseMessaging? firebaseMessaging,
  }) : _logger = logger ?? di.get<Logger>(),
       _networkClient = networkClient ?? di.get<NetworkClient>(),
       _deviceInfo = deviceInfo ?? di.get<DeviceInfo>(),
       _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance;

  @override
  Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        _logger.i('$_tag: FCM Token obtained successfully');
      } else {
        _logger.w('$_tag: Failed to obtain FCM token');
      }
      return token;
    } catch (e, s) {
      _logger.e('$_tag: Error getting FCM token', e, s);
      rethrow;
    }
  }

  @override
  Future<String> registerToken(String fcmToken) async {
    try {
      _logger.i('$_tag: Registering FCM token with backend');

      final deviceId = await _deviceInfo.generateDeviceId();
      final deviceName = await _deviceInfo.getDeviceName();
      final deviceType = Platform.isIOS ? 'ios' : 'android';

      final request = DeviceTokenRequest(
        fcmToken: fcmToken,
        deviceId: deviceId,
        deviceName: deviceName,
        deviceType: deviceType,
      );

      await _networkClient.post<Map<String, dynamic>>(
        '/device-tokens/me',
        data: request.toJson(),
        fromJsonT: (json) => json as Map<String, dynamic>,
      );
      _logger.i('$_tag: FCM token registered successfully');
      return deviceId;
    } catch (e, s) {
      _logger.e('$_tag: Error registering FCM token', e, s);
      rethrow;
    }
  }

  @override
  Future<void> unRegisterToken(String deviceId) async {
    try {
      _logger.i('$_tag: Removing FCM token from backend');

      await _networkClient.delete<Map<String, dynamic>>(
        '/device-tokens/me/$deviceId',
        fromJsonT: (json) => json as Map<String, dynamic>,
      );
      _logger.i('$_tag: FCM token removed successfully');
    } catch (e, s) {
      _logger.e('$_tag: Error removing FCM token', e, s);
      rethrow;
    }
  }

  @override
  Future<void> handleTokenRefresh(String newToken) async {
    _logger.i('$_tag: FCM token refreshed');
    await registerToken(newToken);
  }
}
