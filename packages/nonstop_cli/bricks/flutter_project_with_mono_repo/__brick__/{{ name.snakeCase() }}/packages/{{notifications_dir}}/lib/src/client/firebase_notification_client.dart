import 'dart:async';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:core/logger/logger.dart';
import 'package:design_system/toast/toasts.dart';
import 'package:di/di.dart';
import 'package:firebase_messaging/firebase_messaging.dart'
    hide NotificationSettings;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:network/network.dart';
import 'package:notifications/notifications.dart';

const String _tag = 'FirebaseNotificationClient';

/// Firebase implementation of the notification client
class FirebaseNotificationClient implements NotificationClient {
  FirebaseNotificationClient({
    required this.config,
    Logger? logger,
    NotificationTokenManager? tokenManager,
    NotificationPermissionManager? permissionManager,
  }) : _logger = logger ?? di.get<Logger>(),
       _tokenManager = tokenManager ?? di.get<NotificationTokenManager>(),
       _permissionManager =
           permissionManager ?? di.get<NotificationPermissionManager>();

  final NotificationConfig config;
  final Logger _logger;
  final NotificationTokenManager _tokenManager;
  final NotificationPermissionManager _permissionManager;
  bool _isGranted = false;

  FirebaseMessaging? _firebaseMessaging;

  String? _fcmToken;
  String? _deviceId;

  // Store subscriptions for cleanup
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedAppSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  @override
  Future<void> init() async {
    try {
      _logger.i('$_tag: Initializing Firebase notification client');

      // Initialize Firebase Messaging
      _firebaseMessaging = FirebaseMessaging.instance;

      final isGranted = await requestPermissions();
      if (!isGranted) {
        _logger.w('$_tag: Notification permissions not granted');
        return;
      }
      _isGranted = isGranted;

      // Setup FCM handlers if background notifications are enabled
      await _setupFCMHandlers();

      // Get FCM token and register if backend registration is enabled
      await getFCMToken();

      // Clear badge count as the last step of initialization
      await clearBadge();

      _logger.i('$_tag: Firebase notification client initialized successfully');
    } catch (e, s) {
      _logger.e('$_tag: Error initializing Firebase notification client', e, s);
      throw NotificationException(message: e.message());
    }
  }

  @override
  Future<bool> requestPermissions({bool provisional = false}) async {
    return await _permissionManager.requestPermissions();
  }

  @override
  Future<void> clearBadge() async {
    try {
      _logger.i('🔔 Clearing badge count');
      if (!_isGranted) {
        _logger.w(
          '🔔 Notification permissions '
          'not granted, cannot clear badge',
        );
        return;
      }
      if (!await AppBadgePlus.isSupported()) {
        _logger.w('🔔 AppBadgePlus is not supported on this platform');
        return;
      }
      await AppBadgePlus.updateBadge(0);
      _logger.i('🔔 Badge count cleared');
    } catch (e) {
      _logger.w('🔔 Failed to clear badge count: $e');
    }
  }

  Future<void> _setupFCMHandlers() async {
    // Handle background messages (when app is terminated)
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundNotification);

    // Handle foreground messages
    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        _logger.i('$_tag: Received foreground message: ${message.messageId}');
        handleForegroundNotification(message);
      },
      onError: (error) {
        _logger.e('$_tag: Error in foreground message handler', error);
      },
    );

    // Handle notification opened (from background/terminated)
    _messageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        _logger.i('$_tag: Notification opened app: ${message.messageId}');
        handleNotificationOpened(message, source: 'background');
      },
      onError: (error) {
        _logger.e('$_tag: Error in notification opened handler', error);
      },
    );

    // Handle initial message (if app was opened from terminated state)
    if (_firebaseMessaging != null) {
      final initialMessage = await _firebaseMessaging!.getInitialMessage();
      if (initialMessage != null) {
        _logger.i(
          '$_tag: App opened from terminated state: ${initialMessage.messageId}',
        );
        handleNotificationOpened(initialMessage, source: 'terminated');
      }

      // Handle token refresh
      _tokenRefreshSubscription = _firebaseMessaging!.onTokenRefresh.listen(
        (String newToken) {
          _fcmToken = newToken;
          _tokenManager.handleTokenRefresh(newToken);
        },
        onError: (error) {
          _logger.e('$_tag: Error in token refresh handler', error);
        },
      );
    }

    _logger.i('$_tag: FCM handlers setup complete');
  }

  @override
  Future<String?> getFCMToken() async {
    try {
      _fcmToken = await _tokenManager.getFCMToken();

      if (_fcmToken != null) {
        _deviceId = await _tokenManager.registerToken(_fcmToken!);
        _logger.i('$_tag: Token registered with device ID: $_deviceId');
      }

      return _fcmToken;
    } catch (e, s) {
      _logger.e('$_tag: Error getting FCM token', e, s);
      return null;
    }
  }

  /// Handle background notification (when app is not running)
  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundNotification(
    RemoteMessage message,
  ) async {
    try {
      debugPrint(
        '$_tag: Handling background notification: ${message.messageId}',
      );
    } catch (e, s) {
      debugPrint(
        '$_tag: Error handling background notification:'
        ' ${message.messageId} - $e $s',
      );
    }
  }

  @override
  Future<void> handleForegroundNotification(RemoteMessage message) async {
    try {
      _logger.i(
        '$_tag: Handling foreground notification: ${message.messageId}',
      );

      final notification = message.notification;
      if (notification != null &&
          notification.title != null &&
          notification.body != null) {
        Toast.notification(
          title: notification.title!,
          body: notification.body!,
        );
      }
    } catch (e, s) {
      _logger.e('$_tag: Error handling foreground notification', e, s);
    }
  }

  @override
  Future<void> handleNotificationOpened(
    RemoteMessage message, {
    String? source,
  }) async {
    try {
      _logger.i('$_tag: Handling notification opened: ${message.messageId}');

      final notification = message.notification;

      _logger.i(
        '$_tag: Notification opened from $source: ${notification?.title} - ${notification?.body}',
      );

      // Deep link contract: send a `route` in the message data and the app
      // navigates there, e.g. {"route": "/home/orders/42"}. Branch on your own
      // payload fields here if you need something richer than a path.
      final route = message.data['route'];
      if (route is! String || route.isEmpty) return;

      di.get<GoRouter>().push(route);
    } catch (e, s) {
      _logger.e('$_tag: Error handling notification opened', e, s);
    }
  }

  @override
  String? get fcmToken => _fcmToken;

  @override
  String? get deviceId => _deviceId;

  @override
  Future<void> dispose() async {
    _logger.i('$_tag: Disposing Firebase notification client');

    // Cancel all subscriptions to prevent memory leaks
    _foregroundMessageSubscription?.cancel();
    _messageOpenedAppSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();

    _foregroundMessageSubscription = null;
    _messageOpenedAppSubscription = null;
    _tokenRefreshSubscription = null;

    _firebaseMessaging = null;
  }
}
