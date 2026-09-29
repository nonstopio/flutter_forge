import 'package:analytics/analytics.dart';
import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Client extends Mock implements AnalyticsClient {}

class _Logger extends Mock implements Logger {}

void main() {
  tearDown(di.reset);
  setUpAll(() => registerFallbackValue(const AnalyticsEvent(name: 'fallback')));
  test(
    'all helpers tolerate absent services, forward calls and contain asynchronous failures',
    () async {
      final logger = _Logger();
      final client = _Client();
      final operations = <Future<void> Function()>[
        () => AnalyticsHelper.logEvent('custom', parameters: {'key': 1}),
        () => AnalyticsHelper.logSignIn(method: 'email'),
        () => AnalyticsHelper.logSignUp(method: 'email'),
        () => AnalyticsHelper.setUserId('user'),
        () => AnalyticsHelper.setUserProperty(name: 'role', value: 'tester'),
        () => AnalyticsHelper.logAppOpen(),
        () => AnalyticsHelper.logCustomEvent(
          const AnalyticsEvent(name: 'custom'),
        ),
        () => AnalyticsHelper.logFeatureUsed(
          'search',
          parameters: {'source': 'home'},
        ),
        () => AnalyticsHelper.logButtonPressed(
          'submit',
          screenName: 'home',
          parameters: {'source': 'link'},
        ),
        () => AnalyticsHelper.logAppError(
          'validation',
          errorMessage: 'invalid',
          parameters: {'source': 'link'},
        ),
      ];
      for (final operation in operations) {
        await operation();
      }
      di.register<Logger>(logger);
      di.register<AnalyticsClient>(client);
      final stubs = [
        () => client.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
        () => client.logLogin(
          loginMethod: any(named: 'loginMethod'),
          parameters: any(named: 'parameters'),
        ),
        () => client.logSignUp(
          signUpMethod: any(named: 'signUpMethod'),
          parameters: any(named: 'parameters'),
        ),
        () => client.setUserId(any()),
        () => client.setUserProperty(
          name: any(named: 'name'),
          value: any(named: 'value'),
        ),
        () => client.logAppOpen(parameters: any(named: 'parameters')),
        () => client.logCustomEvent(any()),
      ];
      for (final stub in stubs) {
        when(stub).thenAnswer((_) async {});
      }
      for (final operation in operations) {
        await operation();
      }
      verify(() => client.logLogin(loginMethod: 'email')).called(1);
      verify(() => client.setUserId('user')).called(1);
      for (final stub in stubs) {
        when(stub).thenAnswer((_) async => throw StateError('offline'));
      }
      for (final operation in operations) {
        await operation();
      }
      verify(() => logger.e(any(), any(), any())).called(operations.length);
    },
  );

  test(
    'route observer tracks named pages and catches asynchronous failures',
    () async {
      final client = _Client();
      final logger = _Logger();
      when(
        () => client.logScreenView(screenName: any(named: 'screenName')),
      ).thenAnswer((_) async {});
      final observer = AnalyticsRouteObserver(client: client, logger: logger);
      final page = MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/home'),
        builder: (_) => const SizedBox(),
      );
      final unnamed = MaterialPageRoute<void>(builder: (_) => const SizedBox());
      observer.didPush(page, null);
      observer.didPop(unnamed, page);
      observer.didReplace(newRoute: page);
      observer.didPush(unnamed, page);
      observer.didPop(page, null);
      await pumpEventQueue();
      verify(() => client.logScreenView(screenName: '/home')).called(3);
      when(
        () => client.logScreenView(screenName: any(named: 'screenName')),
      ).thenAnswer((_) async => throw StateError('offline'));
      observer.didPush(page, null);
      await pumpEventQueue();
      verify(() => logger.e(any(), any(), any())).called(1);
      page.dispose();
      unnamed.dispose();
    },
  );

  test('event value equality agrees with hash codes and map serialization', () {
    final a = AnalyticsEvent(name: 'event', parameters: {'one': 1, 'two': 2});
    final b = AnalyticsEvent(name: 'event', parameters: {'two': 2, 'one': 1});
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, a);
    expect(a.toMap()['name'], 'event');
    expect(a.toString(), contains('event'));
    expect(a, isNot(const AnalyticsEvent(name: 'event')));
    expect(const AnalyticsEvent(name: 'event'), isNot(a));
    expect(
      a,
      isNot(const AnalyticsEvent(name: 'event', parameters: {'one': 1})),
    );
    expect(
      a,
      isNot(
        const AnalyticsEvent(name: 'event', parameters: {'one': 1, 'two': 3}),
      ),
    );
    expect(
      const AnalyticsEvent(name: 'empty'),
      const AnalyticsEvent(name: 'empty'),
    );
    final config = const DefaultAnalyticsConfig(userId: 'user')
        .copyWith(
          enableAnalytics: false,
          enableDebugLogging: true,
          defaultUserProperties: {'role': 'test'},
        )
        .copyWith();
    expect(config.enableAnalytics, isFalse);
    expect(config.enableDebugLogging, isTrue);
    expect(config.userId, 'user');
    expect(config.defaultUserProperties, {'role': 'test'});
  });
}
