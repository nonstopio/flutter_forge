import 'package:crashlytics/crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'user metadata value equality is order-independent and agrees with hashing',
    () {
      final user = UserMetadata(
        userId: 'user',
        email: 'example@test',
        name: 'Tester',
        customAttributes: {'a': 1, 'b': 2},
      );
      final equal = user.copyWith(customAttributes: {'b': 2, 'a': 1});
      expect(user, user);
      expect(user, equal);
      expect(user.hashCode, equal.hashCode);
      expect(user.copyWith(), user);
      expect(user.toMap()['userId'], 'user');
      expect(user.toString(), contains('Tester'));
      expect(user, isNot(user.copyWith(customAttributes: {})));
      expect(user, isNot(user.copyWith(customAttributes: {'a': 1, 'b': 3})));
      expect(user, isNot(user.copyWith(userId: 'another')));
    },
  );

  test(
    'crash reports preserve fields, serialize and hash equivalent errors',
    () {
      final report = CrashReport(
        exception: StateError('failure'),
        stackTrace: StackTrace.fromString('trace'),
        fatal: true,
        timestamp: DateTime(2026),
        customKeys: {'build': 'test'},
        logs: ['first'],
        userMetadata: {'userId': 'user'},
      );
      final equal = report.copyWith(
        exception: StateError('failure'),
        stackTrace: StackTrace.fromString('trace'),
      );
      expect(report, report);
      expect(report, equal);
      expect(report.hashCode, equal.hashCode);
      expect(report.copyWith(), report);
      expect(report, isNot(report.copyWith(fatal: false)));
      expect(report.toMap()['logs'], ['first']);
      expect(report.toMap()['timestamp'], DateTime(2026).toIso8601String());
      expect(report.toString(), contains('failure'));
      expect(
        report
            .copyWith(customKeys: {'new': true}, logs: [], userMetadata: {})
            .customKeys,
        {'new': true},
      );
    },
  );

  test('crash configuration copying retains and overrides each option', () {
    const config = CrashlyticsConfig();
    final changed = config.copyWith(
      enableInDebugMode: true,
      enableAutomaticDataCollection: false,
      enableCustomLogs: false,
      enableUserMetadata: false,
      logBufferSize: 10,
      customKeys: {'build': 'test'},
    );
    expect(changed.copyWith(), changed);
    expect(changed.hashCode, changed.copyWith().hashCode);
    expect(changed.toString(), contains('10'));
    expect(changed.enableCustomLogs, isFalse);
    expect(changed.enableInDebugMode, isTrue);
    expect(changed.toMap()['logBufferSize'], 10);
    expect(changed, isNot(config));
  });
}
