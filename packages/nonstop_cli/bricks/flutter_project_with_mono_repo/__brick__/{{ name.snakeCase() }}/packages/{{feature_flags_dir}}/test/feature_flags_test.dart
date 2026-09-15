import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:feature_flags/feature_flags.dart';
import 'package:feature_flags/feature_flags.dart' as flags;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Logger extends Mock implements Logger {}

class _Provider extends Mock implements FeatureFlagProvider {}

class _RemoteConfig extends Mock implements FirebaseRemoteConfig {}

void main() {
  late _Logger logger;
  late _Provider provider;
  late FeatureFlag service;
  setUp(() {
    logger = _Logger();
    provider = _Provider();
    when(provider.init).thenAnswer((_) async {});
    service = FeatureFlag(provider: provider, logger: logger);
  });
  tearDown(di.reset);

  test('reads require initialization; lifecycle is idempotent', () async {
    expect(service.isInitialized, isFalse);
    await expectLater(service.isEnabled('flag'), throwsStateError);
    await service.init();
    await service.init();
    verify(provider.init).called(1);
    expect(service.isInitialized, isTrue);
    service.dispose();
    verify(provider.dispose).called(1);
    expect(service.isInitialized, isFalse);
  });

  test('failed initialization propagates and can be retried', () async {
    when(provider.init).thenThrow(StateError('offline'));
    await expectLater(service.init(), throwsStateError);
    expect(service.isInitialized, isFalse);
    when(provider.init).thenAnswer((_) async {});
    await service.init();
    expect(service.isInitialized, isTrue);
  });

  test('typed reads preserve caller defaults', () async {
    await service.init();
    when(
      () => provider.getBool('b', defaultValue: true),
    ).thenAnswer((_) async => true);
    when(
      () => provider.getString('s', defaultValue: 'fallback'),
    ).thenAnswer((_) async => 'value');
    when(
      () => provider.getInt('i', defaultValue: 3),
    ).thenAnswer((_) async => 5);
    when(
      () => provider.getDouble('d', defaultValue: 1.5),
    ).thenAnswer((_) async => 2.5);
    expect(await service.isEnabled('b', defaultValue: true), isTrue);
    expect(await service.getConfig('s', defaultValue: 'fallback'), 'value');
    expect(await service.getIntConfig('i', defaultValue: 3), 5);
    expect(await service.getDoubleConfig('d', defaultValue: 1.5), 2.5);
  });

  test(
    'module injection initializes and disposes the provider exactly once',
    () async {
      di.register<Logger>(logger);
      await flags.init(provider: provider);
      expect(di.get<FeatureFlag>().isInitialized, isTrue);
      await di.reset();
      verify(provider.dispose).called(1);
    },
  );

  test('module initialization failures propagate', () async {
    di.register<Logger>(logger);
    when(provider.init).thenThrow(StateError('offline'));
    await expectLater(flags.init(provider: provider), throwsStateError);
  });

  testWidgets('wrapper caches reads until its inputs change', (tester) async {
    await service.init();
    when(
      () => provider.getBool('flag', defaultValue: false),
    ).thenAnswer((_) async => true);
    when(
      () => provider.getBool('other', defaultValue: false),
    ).thenAnswer((_) async => false);
    Widget view(String key) => MaterialApp(
      home: FeatureFlagWrapper(
        service: service,
        flagKey: key,
        loading: const Text('Loading'),
        builder: (_, value) => Text('Enabled: $value'),
      ),
    );
    await tester.pumpWidget(view('flag'));
    expect(find.text('Loading'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Enabled: true'), findsOneWidget);
    await tester.pumpWidget(view('flag'));
    await tester.pumpAndSettle();
    verify(() => provider.getBool('flag', defaultValue: false)).called(1);
    await tester.pumpWidget(view('other'));
    await tester.pumpAndSettle();
    expect(find.text('Enabled: false'), findsOneWidget);
  });

  testWidgets('wrapper uses fallback when the service is unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FeatureFlagWrapper(
          flagKey: 'flag',
          defaultValue: true,
          builder: (_, value) => Text('Enabled: $value'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Enabled: true'), findsOneWidget);
  });

  group('Firebase adapter', () {
    late _RemoteConfig remote;
    late FirebaseRemoteConfigProvider adapter;
    setUp(() {
      remote = _RemoteConfig();
      adapter = FirebaseRemoteConfigProvider(
        remoteConfig: remote,
        logger: logger,
      );
      registerFallbackValue(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      when(() => remote.setConfigSettings(any())).thenAnswer((_) async {});
      when(() => remote.setDefaults(any())).thenAnswer((_) async {});
      when(remote.fetchAndActivate).thenAnswer((_) async => true);
      when(
        () => remote.lastFetchStatus,
      ).thenReturn(RemoteConfigFetchStatus.success);
      when(() => remote.lastFetchTime).thenReturn(DateTime(2026));
      when(
        () => remote.onConfigUpdated,
      ).thenAnswer((_) => const Stream.empty());
    });

    test('configures Firebase and exposes update metadata', () async {
      await adapter.init();
      verify(() => remote.setDefaults({})).called(1);
      expect(adapter.config.defaultParameters, isEmpty);
      expect(adapter.lastFetchTime, DateTime(2026));
      expect(adapter.lastFetchStatus, RemoteConfigFetchStatus.success);
      expect(await adapter.onConfigUpdated.toList(), isEmpty);
      adapter.dispose();
    });

    test('initialization failure propagates', () async {
      when(remote.fetchAndActivate).thenThrow(StateError('offline'));
      await expectLater(adapter.init(), throwsStateError);
    });

    test('missing keys respect nonzero and true defaults', () async {
      when(
        () => remote.getValue(any()),
      ).thenReturn(RemoteConfigValue([], ValueSource.valueStatic));
      expect(await adapter.getBool('missing', defaultValue: true), isTrue);
      expect(
        await adapter.getString('missing', defaultValue: 'fallback'),
        'fallback',
      );
      expect(await adapter.getInt('missing', defaultValue: 9), 9);
      expect(await adapter.getDouble('missing', defaultValue: 1.5), 1.5);
      expect(await adapter.hasFlag('missing'), isFalse);
    });

    test(
      'configured false, zero and empty values remain valid values',
      () async {
        when(
          () => remote.getValue(any()),
        ).thenReturn(RemoteConfigValue([], ValueSource.valueRemote));
        when(() => remote.getBool(any())).thenReturn(false);
        when(() => remote.getString(any())).thenReturn('');
        when(() => remote.getInt(any())).thenReturn(0);
        when(() => remote.getDouble(any())).thenReturn(0);
        expect(await adapter.getBool('key', defaultValue: true), isFalse);
        expect(await adapter.getString('key', defaultValue: 'fallback'), '');
        expect(await adapter.getInt('key', defaultValue: 9), 0);
        expect(await adapter.getDouble('key', defaultValue: 1.5), 0);
        expect(await adapter.hasFlag('key'), isTrue);
      },
    );

    test('SDK read failures return defaults', () async {
      when(() => remote.getValue(any())).thenThrow(StateError('unavailable'));
      expect(await adapter.getBool('key', defaultValue: true), isTrue);
      expect(
        await adapter.getString('key', defaultValue: 'fallback'),
        'fallback',
      );
      expect(await adapter.getInt('key', defaultValue: 9), 9);
      expect(await adapter.getDouble('key', defaultValue: 1.5), 1.5);
      expect(await adapter.hasFlag('key'), isFalse);
    });
  });
}
