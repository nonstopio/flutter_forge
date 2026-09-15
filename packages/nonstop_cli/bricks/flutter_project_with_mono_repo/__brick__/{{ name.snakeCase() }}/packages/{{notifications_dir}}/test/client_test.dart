import 'dart:async';

import 'package:core/core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notifications/notifications.dart';

class _Logger extends Mock implements Logger {}

class _Messaging extends Mock implements FirebaseMessaging {}

class _Tokens extends Mock implements NotificationTokenManager {}

class _Permission extends Mock implements NotificationPermissionManager {}

void main() {
  late _Logger logger;
  late _Messaging messaging;
  late _Tokens tokens;
  late _Permission permission;
  late StreamController<RemoteMessage> foreground;
  late StreamController<RemoteMessage> opened;
  late StreamController<String> refreshed;
  late FirebaseNotificationClient client;
  late List<String> routes;
  late List<String> notifications;
  late List<int> badges;
  late bool supported;
  late bool callbackError;
  late Future<void> Function(RemoteMessage) background;

  setUp(() {
    logger = _Logger();
    messaging = _Messaging();
    tokens = _Tokens();
    permission = _Permission();
    foreground = StreamController.broadcast();
    opened = StreamController.broadcast();
    refreshed = StreamController.broadcast();
    routes = [];
    notifications = [];
    badges = [];
    supported = true;
    callbackError = false;
    when(
      () =>
          permission.requestPermissions(provisional: any(named: 'provisional')),
    ).thenAnswer((_) async => true);
    when(() => messaging.onTokenRefresh).thenAnswer((_) => refreshed.stream);
    when(messaging.getInitialMessage).thenAnswer((_) async => null);
    when(tokens.getFCMToken).thenAnswer((_) async => 'token');
    when(() => tokens.registerToken(any())).thenAnswer((_) async => 'device');
    when(() => tokens.handleTokenRefresh(any())).thenAnswer((_) async {});
    client = FirebaseNotificationClient(
      config: NotificationConfig(
        onForeground: (title, body) {
          if (callbackError) throw StateError('presentation');
          notifications.add('$title: $body');
        },
        onOpenRoute: (route) {
          if (callbackError) throw StateError('navigation');
          routes.add(route);
        },
      ),
      logger: logger,
      tokenManager: tokens,
      permissionManager: permission,
      messaging: messaging,
      foregroundMessages: foreground.stream,
      openedMessages: opened.stream,
      supportsBadge: () async => supported,
      updateBadge: (value) async {
        if (callbackError) throw StateError('badge');
        badges.add(value);
      },
      registerBackground: (handler) {
        background = handler;
      },
    );
  });
  tearDown(() async {
    await client.dispose();
    await foreground.close();
    await opened.close();
    await refreshed.close();
  });

  test(
    'concurrent initialization creates one subscription and registers a token',
    () async {
      await Future.wait([client.init(), client.init()]);
      await client.init();
      verify(() => permission.requestPermissions(provisional: false)).called(1);
      expect(client.fcmToken, 'token');
      expect(client.deviceId, 'device');
      expect(badges, [0]);
      await background(const RemoteMessage(messageId: 'background'));
      await client.requestPermissions(provisional: true);
      verify(() => permission.requestPermissions(provisional: true)).called(1);
    },
  );

  test(
    'permission denial can be retried and unsupported badges are skipped',
    () async {
      when(
        () => permission.requestPermissions(provisional: false),
      ).thenAnswer((_) async => false);
      await client.init();
      await client.clearBadge();
      expect(foreground.hasListener, isFalse);
      expect(badges, isEmpty);
      when(
        () => permission.requestPermissions(provisional: false),
      ).thenAnswer((_) async => true);
      supported = false;
      await client.init();
      expect(foreground.hasListener, isTrue);
      expect(badges, isEmpty);
    },
  );

  test(
    'foreground, opened, initial and token-refresh events reach their owners',
    () async {
      when(messaging.getInitialMessage).thenAnswer(
        (_) async => const RemoteMessage(data: {'route': '/initial'}),
      );
      await client.init();
      foreground.add(
        const RemoteMessage(
          notification: RemoteNotification(title: 'Title', body: 'Body'),
        ),
      );
      opened.add(const RemoteMessage(data: {'route': '/opened'}));
      refreshed.add('new-token');
      await pumpEventQueue();
      expect(routes, ['/initial', '/opened']);
      expect(notifications, ['Title: Body']);
      expect(client.fcmToken, 'new-token');
      verify(() => tokens.handleTokenRefresh('new-token')).called(1);
      for (final data in [
        <String, dynamic>{},
        {'route': ''},
        {'route': 1},
        {'route': 'https://outside.test'},
        {'route': '//outside.test'},
      ]) {
        await client.handleNotificationOpened(RemoteMessage(data: data));
      }
      await client.handleForegroundNotification(const RemoteMessage());
      expect(routes, hasLength(2));
      expect(notifications, hasLength(1));
    },
  );

  test(
    'stream, presentation, navigation and badge failures are contained',
    () async {
      await client.init();
      callbackError = true;
      when(
        () => tokens.handleTokenRefresh(any()),
      ).thenThrow(StateError('refresh'));
      foreground.addError(StateError('foreground'));
      opened.addError(StateError('opened'));
      refreshed.addError(StateError('tokens'));
      refreshed.add('new-token');
      await client.handleForegroundNotification(
        const RemoteMessage(
          notification: RemoteNotification(title: 'T', body: 'B'),
        ),
      );
      await client.handleNotificationOpened(
        const RemoteMessage(data: {'route': '/home'}),
      );
      await client.clearBadge();
      await pumpEventQueue();
      expect(client.fcmToken, 'token');
      expect(routes, isEmpty);
      expect(notifications, isEmpty);
    },
  );

  test(
    'registration failures clear cached state and a null token does not register',
    () async {
      when(tokens.getFCMToken).thenAnswer((_) async => null);
      expect(await client.getFCMToken(), isNull);
      verifyNever(() => tokens.registerToken(any()));
      when(tokens.getFCMToken).thenAnswer((_) async => 'token');
      when(() => tokens.registerToken(any())).thenThrow(StateError('backend'));
      expect(await client.getFCMToken(), isNull);
      expect(client.fcmToken, isNull);
      expect(client.deviceId, isNull);
    },
  );

  test('failed startup cancels subscriptions and can be retried', () async {
    when(messaging.getInitialMessage).thenThrow(StateError('startup'));
    await expectLater(client.init(), throwsStateError);
    expect(foreground.hasListener, isFalse);
    // Retry before subscribing again is supported by real broadcast FCM streams;
    // a denied permission also demonstrates that the failed future was cleared.
    when(
      () => permission.requestPermissions(provisional: false),
    ).thenAnswer((_) async => false);
    await client.init();
  });

  test('dispose closes listeners and prevents late startup work', () async {
    final initial = Completer<RemoteMessage?>();
    when(messaging.getInitialMessage).thenAnswer((_) => initial.future);
    final startup = client.init();
    await pumpEventQueue();
    await client.dispose();
    initial.complete(const RemoteMessage(data: {'route': '/late'}));
    await startup;
    expect(foreground.hasListener, isFalse);
    expect(await client.getFCMToken(), isNull);
    await client.handleForegroundNotification(const RemoteMessage());
    await client.handleNotificationOpened(
      const RemoteMessage(data: {'route': '/late'}),
    );
    await client.clearBadge();
    expect(routes, isEmpty);
    await expectLater(client.init(), throwsStateError);
  });
}
