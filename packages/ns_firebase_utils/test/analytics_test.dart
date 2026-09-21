import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ns_firebase_utils/analytics/analytics_service.dart';
import 'package:ns_firebase_utils/api/firebase_api.dart';
import 'package:ns_firebase_utils/api/firebase_group_api.dart';
import 'package:ns_firebase_utils/src.dart';
import 'package:ns_firebase_utils/utils/custom_exception.dart';

class MockAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUp(() {
    NSFirebase.instance = NSFirebase();
  });

  test('initialization stores release information and configures log callbacks',
      () async {
    expect(NSFirebase.instance.isInitialized, isFalse);
    expect(NSFirebase.instance.buildNumber, isEmpty);
    expect(NSFirebase.instance.version, isEmpty);
    final logs = <Object>[];
    final errors = <Object>[];
    await NSFirebase.instance.init(
      printLogs: true,
      buildNumber: '42',
      version: '1.2',
      appLogsFunction: (message, [detail = '']) => logs.add(message),
      errorLogsFunction: (message, [error, trace = StackTrace.empty]) =>
          errors.add(message),
    );
    expect(NSFirebase.instance.isInitialized, isTrue);
    expect(NSFirebase.instance.buildNumber, '42');
    expect(NSFirebase.instance.version, '1.2');
    expect(logs.single.toString(), contains('Initialized default app'));
    errorLogsNS('failure');
    expect(errors, ['failure']);
    expect(analytics, isA<AppAnalytics>());
    expect(FirebaseApi('users').ref.path, 'users');
    expect(FirebaseGroupApi('items').query, isNotNull);
    await initializeDefault(
      name: 'secondary',
      options: const FirebaseOptions(
          apiKey: 'key',
          appId: 'app',
          messagingSenderId: 'sender',
          projectId: 'project'),
    );
    expect(Firebase.app('secondary').name, 'secondary');
    expect(logs.last.toString(), contains('secondary'));
  });

  test('events normalize names, enrich metadata, and omit null values',
      () async {
    await NSFirebase.instance
        .init(printLogs: false, buildNumber: '7', version: '2');
    final backend = MockAnalytics();
    when(() => backend.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
        callOptions: any(named: 'callOptions'))).thenAnswer((_) async {});
    when(() => backend.setUserId(
        id: any(named: 'id'),
        callOptions: any(named: 'callOptions'))).thenAnswer((_) async {});
    when(() => backend.setUserProperty(
        name: any(named: 'name'),
        value: any(named: 'value'),
        callOptions: any(named: 'callOptions'))).thenAnswer((_) async {});
    final service = AppAnalytics(firebaseAnalytics: backend);
    await service.logEvent(name: 'without_parameters');
    final noParameters = verify(() => backend.logEvent(
        name: 'without_parameters',
        parameters: captureAny(named: 'parameters'),
        callOptions: null)).captured.single as Map;
    expect(noParameters['version'], '2-7');
    await service.log(eventName: 'app started');
    final anonymous = verify(() => backend.logEvent(
        name: 'app_started',
        parameters: captureAny(named: 'parameters'),
        callOptions: null)).captured.single as Map;
    expect(anonymous['version'], '2-7');
    expect(anonymous.containsKey('id'), isFalse);
    expect(DateTime.tryParse(anonymous['date_time'] as String), isNotNull);
    await service.setUser(id: 'alice', email: 'a@example.com');
    verify(() => backend.setUserId(id: 'alice', callOptions: null)).called(1);
    verify(() => backend.setUserProperty(
        name: 'email', value: 'a@example.com', callOptions: null)).called(1);
    await service.logEvent(
        name: 'button clicked',
        category: 'main screen',
        parameters: {'missing': null, 'count': 3});
    final identified = verify(() => backend.logEvent(
        name: 'button_clicked_main_screen',
        parameters: captureAny(named: 'parameters'),
        callOptions: null)).captured.single as Map;
    expect(identified, containsPair('id', 'alice'));
    expect(identified, containsPair('email', 'a@example.com'));
    expect(identified, containsPair('count', 3));
    expect(identified.containsKey('missing'), isFalse);
    await service.logEvent(name: 'override', parameters: {
      'version': 'custom',
      'id': 'bob',
      'email': 'b@example.com'
    });
    final overridden = verify(() => backend.logEvent(
        name: 'override',
        parameters: captureAny(named: 'parameters'),
        callOptions: null)).captured.single as Map;
    expect(overridden['version'], 'custom');
    expect(overridden['id'], 'bob');
    expect(overridden['email'], 'b@example.com');
    final items = [AnalyticsEventItem(itemId: 'sku-1', itemName: 'Book')];
    final options = AnalyticsCallOptions(global: true);
    when(() => backend.logEvent(
          name: 'purchase',
          items: items,
          parameters: any(named: 'parameters'),
          callOptions: options,
        )).thenAnswer((_) async {});
    await service.logEvent(
        name: 'purchase', items: items, callOptions: options);
    verify(() => backend.logEvent(
          name: 'purchase',
          items: items,
          parameters: any(named: 'parameters'),
          callOptions: options,
        )).called(1);
  });

  test(
      'analytics methods forward arguments and require initialization for app open',
      () async {
    final backend = MockAnalytics();
    final service = AppAnalytics(firebaseAnalytics: backend);
    expect(
        () => service.logAppOpen(),
        throwsA(isA<CustomException>()
            .having((e) => e.code, 'code', 'not_initialized')));
    await NSFirebase.instance
        .init(printLogs: false, buildNumber: '1', version: '1');
    const parameters = <String, Object>{'source': 'test'};
    final options = AnalyticsCallOptions(global: true);
    when(() => backend.logAppOpen(callOptions: options, parameters: parameters))
        .thenAnswer((_) async {});
    when(() => backend.logJoinGroup(
        groupId: 'group',
        callOptions: options,
        parameters: parameters)).thenAnswer((_) async {});
    when(() => backend.logLogin(
        loginMethod: 'password',
        callOptions: options,
        parameters: parameters)).thenAnswer((_) async {});
    when(() => backend.logSignUp(signUpMethod: 'email', parameters: parameters))
        .thenAnswer((_) async {});
    when(() => backend.logTutorialBegin(parameters: parameters))
        .thenAnswer((_) async {});
    when(() => backend.logTutorialComplete(parameters: parameters))
        .thenAnswer((_) async {});
    when(() => backend.logScreenView(
        screenName: 'home',
        screenClass: 'Home',
        callOptions: options,
        parameters: parameters)).thenAnswer((_) async {});
    when(() => backend.setUserId(id: 'user', callOptions: options))
        .thenAnswer((_) async {});
    when(() => backend.setUserProperty(
        name: 'tier',
        value: 'free',
        callOptions: options)).thenAnswer((_) async {});
    await service.logAppOpen(callOptions: options, parameters: parameters);
    await service.logJoinGroup(
        groupId: 'group', callOptions: options, parameters: parameters);
    await service.logLogin(
        loginMethod: 'password', callOptions: options, parameters: parameters);
    await service.logSignUp(signUpMethod: 'email', parameters: parameters);
    await service.logTutorialBegin(parameters: parameters);
    await service.logTutorialComplete(parameters: parameters);
    await service.logScreenView(
        screenName: 'home',
        screenClass: 'Home',
        callOptions: options,
        parameters: parameters);
    await service.setUserId(id: 'user', callOptions: options);
    await service.setUserProperty(
        name: 'tier', value: 'free', callOptions: options);
    verifyInOrder([
      () => backend.logAppOpen(callOptions: options, parameters: parameters),
      () => backend.logJoinGroup(
          groupId: 'group', callOptions: options, parameters: parameters),
      () => backend.logLogin(
          loginMethod: 'password',
          callOptions: options,
          parameters: parameters),
      () => backend.logSignUp(signUpMethod: 'email', parameters: parameters),
      () => backend.logTutorialBegin(parameters: parameters),
      () => backend.logTutorialComplete(parameters: parameters),
      () => backend.logScreenView(
          screenName: 'home',
          screenClass: 'Home',
          callOptions: options,
          parameters: parameters),
      () => backend.setUserId(id: 'user', callOptions: options),
      () => backend.setUserProperty(
          name: 'tier', value: 'free', callOptions: options),
    ]);
    expect(() => service.resetAnalyticsData(), throwsNoSuchMethodError);
  });
}
