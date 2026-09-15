import 'dart:async';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:core/logger/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart'
    hide NotificationSettings;
import 'package:flutter/foundation.dart';
import 'package:notifications/notifications.dart';

/// Owns messaging subscriptions; presentation is supplied by the app.
class FirebaseNotificationClient implements NotificationClient {
  FirebaseNotificationClient({
    required this.config,
    required Logger logger,
    required NotificationTokenManager tokenManager,
    required NotificationPermissionManager permissionManager,
    required FirebaseMessaging messaging,
    Stream<RemoteMessage>? foregroundMessages,
    Stream<RemoteMessage>? openedMessages,
    Future<bool> Function()? supportsBadge,
    Future<void> Function(int)? updateBadge,
    void Function(Future<void> Function(RemoteMessage))? registerBackground,
  }) : _logger = logger,
       _tokenManager = tokenManager,
       _permissionManager = permissionManager,
       _messaging = messaging,
       _foregroundMessages = foregroundMessages ?? FirebaseMessaging.onMessage,
       _openedMessages = openedMessages ?? FirebaseMessaging.onMessageOpenedApp,
       _supportsBadge = supportsBadge ?? AppBadgePlus.isSupported,
       _updateBadge = updateBadge ?? AppBadgePlus.updateBadge,
       _registerBackground =
           registerBackground ?? FirebaseMessaging.onBackgroundMessage;

  final NotificationConfig config;
  final Logger _logger;
  final NotificationTokenManager _tokenManager;
  final NotificationPermissionManager _permissionManager;
  final FirebaseMessaging _messaging;
  final Stream<RemoteMessage> _foregroundMessages;
  final Stream<RemoteMessage> _openedMessages;
  final Future<bool> Function() _supportsBadge;
  final Future<void> Function(int) _updateBadge;
  final void Function(Future<void> Function(RemoteMessage)) _registerBackground;
  bool _isGranted = false;
  bool _initialized = false;
  bool _disposed = false;
  Future<void>? _initializing;
  String? _fcmToken;
  String? _deviceId;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _tokenSubscription;

  @override
  Future<void> init() {
    if (_disposed) {
      return Future.error(StateError('Notification client is disposed'));
    }
    if (_initialized) return Future.value();
    return _initializing ??= _initialize().whenComplete(
      () => _initializing = null,
    );
  }

  Future<void> _initialize() async {
    try {
      _isGranted = await requestPermissions();
      if (_disposed || !_isGranted) return;
      _registerBackground(handleBackgroundNotification);
      _foregroundSubscription = _foregroundMessages.listen(
        (message) => unawaited(handleForegroundNotification(message)),
        onError: (Object error) =>
            _logger.e('Foreground notification stream failed', error),
      );
      _openedSubscription = _openedMessages.listen(
        (message) =>
            unawaited(handleNotificationOpened(message, source: 'background')),
        onError: (Object error) =>
            _logger.e('Opened notification stream failed', error),
      );
      _tokenSubscription = _messaging.onTokenRefresh.listen(
        (token) async {
          try {
            await _tokenManager.handleTokenRefresh(token);
            if (!_disposed) _fcmToken = token;
          } catch (error, stack) {
            _logger.e('Notification token refresh failed', error, stack);
          }
        },
        onError: (Object error) =>
            _logger.e('Notification token stream failed', error),
      );
      final initial = await _messaging.getInitialMessage();
      if (_disposed) return;
      if (initial != null) {
        await handleNotificationOpened(initial, source: 'terminated');
      }
      await getFCMToken();
      await clearBadge();
      if (!_disposed) _initialized = true;
    } catch (error, stack) {
      await _cancelSubscriptions();
      _logger.e('Notification initialization failed', error, stack);
      rethrow;
    }
  }

  @override
  Future<bool> requestPermissions({bool provisional = false}) =>
      _permissionManager.requestPermissions(provisional: provisional);

  @override
  Future<void> clearBadge() async {
    try {
      if (_disposed || !_isGranted || !await _supportsBadge()) return;
      if (!_disposed) await _updateBadge(0);
    } catch (error, stack) {
      _logger.e('Notification badge clearing failed', error, stack);
    }
  }

  @override
  Future<String?> getFCMToken() async {
    if (_disposed) return null;
    try {
      final token = await _tokenManager.getFCMToken();
      if (_disposed) return null;
      final device = token == null
          ? null
          : await _tokenManager.registerToken(token);
      if (_disposed) return null;
      _fcmToken = token;
      _deviceId = device;
      return token;
    } catch (error, stack) {
      _fcmToken = null;
      _deviceId = null;
      _logger.e('Notification token registration failed', error, stack);
      return null;
    }
  }

  @override
  Future<void> handleForegroundNotification(RemoteMessage message) async {
    if (_disposed) return;
    try {
      final notification = message.notification;
      final title = notification?.title;
      final body = notification?.body;
      if (title != null && body != null) {
        await config.onForeground?.call(title, body);
      }
    } catch (error, stack) {
      _logger.e('Foreground notification presentation failed', error, stack);
    }
  }

  @override
  Future<void> handleNotificationOpened(
    RemoteMessage message, {
    String? source,
  }) async {
    if (_disposed) return;
    try {
      final route = message.data['route'];
      // Notifications may navigate only to local app paths.
      if (route is! String ||
          !route.startsWith('/') ||
          route.startsWith('//')) {
        return;
      }
      await config.onOpenRoute?.call(route);
    } catch (error, stack) {
      _logger.e('Notification navigation failed', error, stack);
    }
  }

  @override
  String? get fcmToken => _fcmToken;
  @override
  String? get deviceId => _deviceId;

  Future<void> _cancelSubscriptions() async {
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _tokenSubscription?.cancel();
    _foregroundSubscription = null;
    _openedSubscription = null;
    _tokenSubscription = null;
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _initialized = false;
    _isGranted = false;
    _fcmToken = null;
    _deviceId = null;
    await _cancelSubscriptions();
  }
}

/// Background work runs in its own isolate, without app DI or navigation.
@pragma('vm:entry-point')
Future<void> handleBackgroundNotification(RemoteMessage message) async {
  debugPrint('Background notification received: ${message.messageId}');
}
