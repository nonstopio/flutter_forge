import 'package:core/core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network/network.dart';
import 'package:notifications/notifications.dart';
import 'package:notifications/notifications.dart' as notifications;
import 'package:di/di.dart';

class _Logger extends Mock implements Logger {}

class _Messaging extends Mock implements FirebaseMessaging {}

class _Settings extends Mock implements NotificationSettings {}

class _Network extends Mock implements NetworkClient {}

class _Device extends Mock implements DeviceInfo {}

void main() {
  late _Logger logger;
  late _Messaging messaging;
  setUp(() {
    logger = _Logger();
    messaging = _Messaging();
  });
  tearDown(di.reset);

  test('module registration failures are surfaced to startup', () async {
    di.register<Logger>(logger);
    await expectLater(
      notifications.init(messaging: messaging),
      throwsA(anything),
    );
  });

  test(
    'module composition registers swappable contracts without device calls',
    () async {
      di.register<Logger>(logger);
      di.register<NetworkClient>(_Network());
      await notifications.init(messaging: messaging);
      expect(di.has<NotificationClient>(), isTrue);
      expect(di.has<NotificationTokenManager>(), isTrue);
      expect(di.has<NotificationPermissionManager>(), isTrue);
      expect(di.has<DeviceInfo>(), isTrue);
    },
  );

  for (final status in AuthorizationStatus.values) {
    test(
      'permission status $status is mapped correctly and provisional forwarded',
      () async {
        final settings = _Settings();
        when(() => settings.authorizationStatus).thenReturn(status);
        when(
          () => messaging.requestPermission(provisional: true),
        ).thenAnswer((_) async => settings);
        final manager = FirebasePermissionManager(
          logger: logger,
          firebaseMessaging: messaging,
        );
        expect(
          await manager.requestPermissions(provisional: true),
          status == AuthorizationStatus.authorized ||
              status == AuthorizationStatus.provisional,
        );
      },
    );
  }

  test(
    'permission errors are reported through the notification contract',
    () async {
      when(
        () => messaging.requestPermission(provisional: false),
      ).thenThrow(StateError('unavailable'));
      final manager = FirebasePermissionManager(
        logger: logger,
        firebaseMessaging: messaging,
      );
      await expectLater(
        manager.requestPermissions(),
        throwsA(isA<NotificationException>()),
      );
    },
  );

  group('token manager', () {
    late _Network network;
    late _Device device;
    late FirebaseTokenManager manager;
    const success = SuccessResponse<Map<String, dynamic>>(
      statusCode: 200,
      success: true,
      data: {},
      timestamp: '2026-01-01',
    );
    setUp(() {
      network = _Network();
      device = _Device();
      manager = FirebaseTokenManager(
        logger: logger,
        networkClient: network,
        deviceInfo: device,
        firebaseMessaging: messaging,
      );
      registerFallbackValue((Object? json) => json as Map<String, dynamic>);
      when(device.generateDeviceId).thenAnswer((_) async => 'install-1');
      when(device.getDeviceName).thenAnswer((_) async => 'Test device');
      when(
        () => network.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          fromJsonT: any(named: 'fromJsonT'),
        ),
      ).thenAnswer((call) async {
        final decode =
            call.namedArguments[#fromJsonT]
                as Map<String, dynamic> Function(Object?);
        expect(decode({'ok': true}), {'ok': true});
        return success;
      });
      when(
        () => network.delete<Map<String, dynamic>>(
          any(),
          fromJsonT: any(named: 'fromJsonT'),
        ),
      ).thenAnswer((call) async {
        final decode =
            call.namedArguments[#fromJsonT]
                as Map<String, dynamic> Function(Object?);
        expect(decode({'ok': true}), {'ok': true});
        return success;
      });
      when(
        () => network.handleSuccessResponse<Map<String, dynamic>>(success),
      ).thenReturn(success);
    });

    test('returns nullable FCM tokens and propagates SDK failures', () async {
      when(() => messaging.getToken()).thenAnswer((_) async => 'token');
      expect(await manager.getFCMToken(), 'token');
      when(() => messaging.getToken()).thenAnswer((_) async => null);
      expect(await manager.getFCMToken(), isNull);
      when(() => messaging.getToken()).thenThrow(StateError('offline'));
      await expectLater(manager.getFCMToken(), throwsStateError);
    });

    test('registers metadata, refreshes and unregisters', () async {
      expect(await manager.registerToken('token'), 'install-1');
      final data =
          verify(
                () => network.post<Map<String, dynamic>>(
                  '/device-tokens/me',
                  data: captureAny(named: 'data'),
                  fromJsonT: any(named: 'fromJsonT'),
                ),
              ).captured.single
              as Map;
      expect(data['fcmToken'], 'token');
      expect(data['deviceId'], 'install-1');
      expect(data['deviceName'], 'Test device');
      await manager.handleTokenRefresh('next-token');
      await manager.unRegisterToken('install-1');
      verify(
        () => network.handleSuccessResponse<Map<String, dynamic>>(success),
      ).called(3);
    });

    test(
      'application-level backend rejection cannot be reported as success',
      () async {
        when(
          () => network.handleSuccessResponse<Map<String, dynamic>>(success),
        ).thenThrow(UnauthorizedException());
        await expectLater(
          manager.registerToken('token'),
          throwsA(isA<UnauthorizedException>()),
        );
        await expectLater(
          manager.unRegisterToken('install-1'),
          throwsA(isA<UnauthorizedException>()),
        );
      },
    );
  });

  test('token request models round-trip JSON', () {
    const request = DeviceTokenRequest(
      fcmToken: 'token',
      deviceId: 'id',
      deviceName: 'phone',
      deviceType: 'ios',
    );
    expect(
      DeviceTokenRequest.fromJson(request.toJson()).toJson(),
      request.toJson(),
    );
    const update = DeviceTokenUpdateRequest(fcmToken: 'next');
    expect(DeviceTokenUpdateRequest.fromJson(update.toJson()).fcmToken, 'next');
    expect(const DefaultNotificationConfig(), isA<NotificationConfig>());
  });
}
