import 'package:analytics/analytics.dart';
import 'package:analytics/analytics.dart' as analytics;
import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Sdk extends Mock implements FirebaseAnalytics {}

class _Logger extends Mock implements Logger {}

void main() {
  late _Sdk sdk;
  late _Logger logger;
  late FirebaseAnalyticsClient client;
  setUp(() {
    sdk = _Sdk();
    logger = _Logger();
    when(
      () => sdk.setAnalyticsCollectionEnabled(any()),
    ).thenAnswer((_) async {});
    when(() => sdk.setUserId(id: any(named: 'id'))).thenAnswer((_) async {});
    when(
      () => sdk.setUserProperty(
        name: any(named: 'name'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => sdk.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});
    when(sdk.resetAnalyticsData).thenAnswer((_) async {});
    client = FirebaseAnalyticsClient(
      const DefaultAnalyticsConfig(
        enableDebugLogging: true,
        userId: 'user',
        defaultUserProperties: {'role': 'tester'},
      ),
      analytics: sdk,
      logger: logger,
    );
  });
  tearDown(di.reset);

  test('semantic events forward additional parameters', () async {
    await client.logScreenView(
      screenName: 'home',
      parameters: {'source': 'link'},
    );
    await client.logLogin(parameters: {'source': 'link'});
    await client.logSignUp(parameters: {'source': 'link'});
    await client.logPurchase(
      currency: 'USD',
      value: 2,
      parameters: {'source': 'link'},
    );
    verify(
      () => sdk.logEvent(name: 'login', parameters: {'source': 'link'}),
    ).called(1);
    verify(
      () => sdk.logEvent(name: 'sign_up', parameters: {'source': 'link'}),
    ).called(1);
  });

  test(
    'initialization awaits SDK setup and propagates startup failures',
    () async {
      await client.initialize();
      verify(() => sdk.setUserId(id: 'user')).called(1);
      verify(
        () => sdk.setUserProperty(name: 'role', value: 'tester'),
      ).called(1);
      when(
        () => sdk.setAnalyticsCollectionEnabled(any()),
      ).thenThrow(StateError('setup'));
      await expectLater(client.initialize(), throwsStateError);
    },
  );

  test('null event parameters are removed before SDK submission', () async {
    await client.logEvent(
      name: 'event',
      parameters: {'valid': 1, 'optional': null},
    );
    verify(
      () => sdk.logEvent(name: 'event', parameters: {'valid': 1}),
    ).called(1);
  });

  test('collection changes affect future logging', () async {
    await client.setAnalyticsCollectionEnabled(false);
    await client.logEvent(name: 'disabled');
    verifyNever(() => sdk.logEvent(name: 'disabled'));
    await client.setAnalyticsCollectionEnabled(true);
    await client.logEvent(name: 'enabled');
    verify(() => sdk.logEvent(name: 'enabled')).called(1);
  });

  test(
    'semantic events preserve their expected names and parameters',
    () async {
      await client.logCustomEvent(const AnalyticsEvent(name: 'custom'));
      await client.logAppOpen();
      await client.logScreenView(screenName: 'home', screenClass: 'Home');
      await client.logLogin(loginMethod: 'email');
      await client.logSignUp(signUpMethod: 'google');
      await client.logPurchase(currency: 'USD', value: 3.5);
      verify(
        () => sdk.logEvent(name: 'login', parameters: {'method': 'email'}),
      ).called(1);
      verify(
        () => sdk.logEvent(
          name: 'purchase',
          parameters: {'currency': 'USD', 'value': 3.5},
        ),
      ).called(1);
      await client.setUserId(null);
      await client.setUserProperty(name: 'role', value: null);
      await client.resetAnalyticsData();
      client.dispose();
    },
  );

  test('SDK event and property failures are contained', () async {
    when(
      () => sdk.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      ),
    ).thenThrow(StateError('event'));
    when(
      () => sdk.setUserId(id: any(named: 'id')),
    ).thenThrow(StateError('user'));
    when(
      () => sdk.setUserProperty(
        name: any(named: 'name'),
        value: any(named: 'value'),
      ),
    ).thenThrow(StateError('property'));
    when(sdk.resetAnalyticsData).thenThrow(StateError('reset'));
    when(
      () => sdk.setAnalyticsCollectionEnabled(any()),
    ).thenThrow(StateError('collection'));
    await client.logEvent(name: 'event');
    await client.setUserId('user');
    await client.setUserProperty(name: 'role', value: 'value');
    await client.resetAnalyticsData();
    await client.setAnalyticsCollectionEnabled(false);
    verify(() => logger.e(any(), any(), any())).called(5);
  });

  test(
    'module startup is injectable and helpers resolve fresh clients after reset',
    () async {
      di.register<Logger>(logger);
      await analytics.init(analytics: sdk);
      await AnalyticsHelper.logEvent('before');
      await di.reset();
      di.register<Logger>(logger);
      await analytics.init(
        analytics: sdk,
        config: const DefaultAnalyticsConfig(enableAnalytics: false),
      );
      await AnalyticsHelper.logEvent('after');
      verify(() => sdk.logEvent(name: 'before')).called(1);
      verifyNever(() => sdk.logEvent(name: 'after'));
    },
  );
}
