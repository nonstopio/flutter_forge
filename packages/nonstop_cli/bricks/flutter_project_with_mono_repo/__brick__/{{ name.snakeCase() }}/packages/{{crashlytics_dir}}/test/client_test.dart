import 'package:core/core.dart';
import 'package:crashlytics/crashlytics.dart';
import 'package:crashlytics/crashlytics.dart' as crash;
import 'package:di/di.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Sdk extends Mock implements FirebaseCrashlytics {}

class _Logger extends Mock implements Logger {}

class _Metadata extends Mock implements UserMetadata {}

void main() {
  late _Sdk sdk;
  late _Logger logger;
  late FirebaseCrashlyticsClient client;
  setUp(() {
    sdk = _Sdk();
    logger = _Logger();
    when(
      () => sdk.setCrashlyticsCollectionEnabled(any()),
    ).thenAnswer((_) async {});
    when(() => sdk.setCustomKey(any(), any())).thenAnswer((_) async {});
    when(() => sdk.setUserIdentifier(any())).thenAnswer((_) async {});
    when(() => sdk.log(any())).thenAnswer((_) async {});
    when(
      () => sdk.recordError(
        any(),
        any(),
        fatal: any(named: 'fatal'),
        information: any(named: 'information'),
      ),
    ).thenAnswer((_) async {});
    when(() => sdk.isCrashlyticsCollectionEnabled).thenReturn(true);
    when(sdk.checkForUnsentReports).thenAnswer((_) async => false);
    when(sdk.sendUnsentReports).thenAnswer((_) async {});
    when(sdk.deleteUnsentReports).thenAnswer((_) async {});
    client = FirebaseCrashlyticsClient(
      config: const CrashlyticsConfig(
        enableAutomaticDataCollection: false,
        logBufferSize: 2,
        customKeys: {'build': 'test'},
      ),
      logger: logger,
      crashlytics: sdk,
    );
  });
  tearDown(() async {
    client.dispose();
    await di.reset();
  });

  Future<void> exerciseClient() async {
    await client.recordError('error', StackTrace.current);
    await client.recordFlutterFatalError(
      'fatal',
      StackTrace.current,
      context: {'screen': 'home'},
    );
    await client.log('log');
    await client.setUserIdentifier('user');
    await client.setUserMetadata(
      const UserMetadata(
        userId: 'user',
        email: 'test@example.test',
        name: 'Test',
        customAttributes: {'role': 'tester'},
      ),
    );
    await client.setCustomKey('key', 'value');
    await client.setCustomKeys({'key': 'value'});
    await client.setCrashlyticsCollectionEnabled(false);
    await client.sendUnsentReports();
    await client.deleteUnsentReports();
    await client.checkForUnsentReports();
  }

  test(
    'invalid metadata is contained and startup SDK errors propagate',
    () async {
      await client.initialize();
      final metadata = _Metadata();
      when(() => metadata.userId).thenThrow(StateError('invalid metadata'));
      await client.setUserMetadata(metadata);
      verify(() => logger.e(any())).called(1);
      di.register<Logger>(logger);
      when(
        () => sdk.setCrashlyticsCollectionEnabled(any()),
      ).thenThrow(StateError('startup'));
      await expectLater(crash.init(crashlytics: sdk), throwsStateError);
      expect(di.has<CrashlyticsClient>(), isFalse);
      expect(di.has<CrashlyticsConfig>(), isFalse);
      when(
        () => sdk.setCrashlyticsCollectionEnabled(any()),
      ).thenAnswer((_) async {});
      await crash.init(crashlytics: sdk);
      expect(di.has<CrashlyticsClient>(), isTrue);
    },
  );

  test('before initialization operations safely skip SDK calls', () async {
    await exerciseClient();
    expect(client.isCrashlyticsCollectionEnabled, isFalse);
    verifyNever(() => sdk.log(any()));
  });

  test('initialization applies custom keys and can be called twice', () async {
    await client.initialize();
    await client.initialize();
    verify(() => sdk.setCustomKey('build', 'test')).called(1);
    expect(client.isCrashlyticsCollectionEnabled, isTrue);
    await exerciseClient();
    await client.log('second');
    await client.log('third');
    expect(client.bufferedLogs, hasLength(2));
    expect(client.bufferedLogs.last, endsWith('third'));
    client.clearLogBuffer();
    expect(client.bufferedLogs, isEmpty);
  });

  test('SDK failures are contained after initialization', () async {
    await client.initialize();
    when(
      () => sdk.setCrashlyticsCollectionEnabled(any()),
    ).thenThrow(StateError('sdk'));
    when(() => sdk.setCustomKey(any(), any())).thenThrow(StateError('sdk'));
    when(() => sdk.setUserIdentifier(any())).thenThrow(StateError('sdk'));
    when(() => sdk.log(any())).thenThrow(StateError('sdk'));
    when(
      () => sdk.recordError(
        any(),
        any(),
        fatal: any(named: 'fatal'),
        information: any(named: 'information'),
      ),
    ).thenThrow(StateError('sdk'));
    when(sdk.checkForUnsentReports).thenThrow(StateError('sdk'));
    when(sdk.sendUnsentReports).thenThrow(StateError('sdk'));
    when(sdk.deleteUnsentReports).thenThrow(StateError('sdk'));
    await exerciseClient();
    expect(await client.checkForUnsentReports(), isFalse);
  });

  test('failed initialization remains retryable', () async {
    when(
      () => sdk.setCrashlyticsCollectionEnabled(any()),
    ).thenThrow(StateError('sdk'));
    await expectLater(client.initialize(), throwsStateError);
    expect(client.isCrashlyticsCollectionEnabled, isFalse);
    when(
      () => sdk.setCrashlyticsCollectionEnabled(any()),
    ).thenAnswer((_) async {});
    await client.initialize();
    expect(client.isCrashlyticsCollectionEnabled, isTrue);
  });

  test('global handlers are chained and restored when disposed', () async {
    final previousFlutter = FlutterError.onError;
    final previousPlatform = PlatformDispatcher.instance.onError;
    var flutterCalls = 0;
    var platformCalls = 0;
    void flutterHandler(FlutterErrorDetails details) {
      flutterCalls++;
    }

    bool platformHandler(Object error, StackTrace stack) {
      platformCalls++;
      return true;
    }

    FlutterError.onError = flutterHandler;
    PlatformDispatcher.instance.onError = platformHandler;
    try {
      client = FirebaseCrashlyticsClient(
        config: const CrashlyticsConfig(),
        logger: logger,
        crashlytics: sdk,
      );
      await client.initialize();
      FlutterError.onError!(FlutterErrorDetails(exception: StateError('test')));
      expect(
        PlatformDispatcher.instance.onError!(
          StateError('test'),
          StackTrace.current,
        ),
        isTrue,
      );
      await pumpEventQueue();
      expect(flutterCalls, 1);
      expect(platformCalls, 1);
      client.dispose();
      expect(FlutterError.onError, same(flutterHandler));
      expect(PlatformDispatcher.instance.onError, same(platformHandler));
    } finally {
      FlutterError.onError = previousFlutter;
      PlatformDispatcher.instance.onError = previousPlatform;
    }
  });

  for (final hasReports in [false, true]) {
    test('module initializes with pending reports=$hasReports', () async {
      di.register<Logger>(logger);
      when(sdk.checkForUnsentReports).thenAnswer((_) async => hasReports);
      await crash.init(
        config: const CrashlyticsConfig(enableAutomaticDataCollection: false),
        crashlytics: sdk,
      );
      expect(di.has<CrashlyticsClient>(), isTrue);
      if (hasReports) verify(sdk.sendUnsentReports).called(1);
    });
  }

  test('equal config values have equal hashes regardless of map order', () {
    const first = CrashlyticsConfig(customKeys: {'a': 1, 'b': 2});
    const second = CrashlyticsConfig(customKeys: {'b': 2, 'a': 1});
    expect(first, second);
    expect(first.hashCode, second.hashCode);
    expect({first, second}, hasLength(1));
  });
}
