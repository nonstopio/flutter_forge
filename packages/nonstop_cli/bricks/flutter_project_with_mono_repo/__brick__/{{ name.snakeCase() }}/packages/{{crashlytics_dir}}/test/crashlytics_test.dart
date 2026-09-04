import 'package:crashlytics/crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Crashlytics', () {
    group('CrashlyticsConfig', () {
      test('creates default config correctly', () {
        const config = DefaultCrashlyticsConfig();

        expect(config.enableInDebugMode, false);
        expect(config.enableAutomaticDataCollection, true);
        expect(config.enableCustomLogs, true);
        expect(config.logBufferSize, 100);
        expect(config.enableUserMetadata, true);
        expect(config.customKeys, isEmpty);
      });

      test('creates custom config correctly', () {
        const config = CrashlyticsConfig(
          enableInDebugMode: true,
          enableAutomaticDataCollection: false,
          logBufferSize: 50,
          customKeys: {'test': 'value'},
        );

        expect(config.enableInDebugMode, true);
        expect(config.enableAutomaticDataCollection, false);
        expect(config.logBufferSize, 50);
        expect(config.customKeys, {'test': 'value'});
      });

      test('copyWith works correctly', () {
        const config = CrashlyticsConfig();
        final updated = config.copyWith(enableInDebugMode: true);

        expect(updated.enableInDebugMode, true);
        expect(
          updated.enableAutomaticDataCollection,
          config.enableAutomaticDataCollection,
        );
      });
    });

    group('UserMetadata', () {
      test('creates user metadata correctly', () {
        const metadata = UserMetadata(
          userId: 'user123',
          email: 'test@example.com',
          name: 'Test User',
          customAttributes: {'role': 'admin'},
        );

        expect(metadata.userId, 'user123');
        expect(metadata.email, 'test@example.com');
        expect(metadata.name, 'Test User');
        expect(metadata.customAttributes, {'role': 'admin'});
      });

      test('toMap works correctly', () {
        const metadata = UserMetadata(
          userId: 'user123',
          email: 'test@example.com',
        );

        final map = metadata.toMap();
        expect(map['userId'], 'user123');
        expect(map['email'], 'test@example.com');
        expect(map['name'], null);
        expect(map['customAttributes'], isEmpty);
      });

      test('copyWith works correctly', () {
        const metadata = UserMetadata(userId: 'user123');
        final updated = metadata.copyWith(email: 'new@example.com');

        expect(updated.userId, 'user123');
        expect(updated.email, 'new@example.com');
        expect(updated.name, null);
      });

      test('equality works correctly', () {
        const metadata1 = UserMetadata(userId: 'user123');
        const metadata2 = UserMetadata(userId: 'user123');
        const metadata3 = UserMetadata(userId: 'user456');

        expect(metadata1, equals(metadata2));
        expect(metadata1, isNot(equals(metadata3)));
      });
    });

    group('CrashReport', () {
      test('creates crash report correctly', () {
        final timestamp = DateTime.now();
        final report = CrashReport(
          exception: Exception('Test error'),
          stackTrace: StackTrace.current,
          fatal: true,
          timestamp: timestamp,
          customKeys: {'key': 'value'},
        );

        expect(report.exception.toString(), contains('Test error'));
        expect(report.fatal, true);
        expect(report.timestamp, timestamp);
        expect(report.customKeys, {'key': 'value'});
      });

      test('toMap works correctly', () {
        final report = CrashReport(
          exception: Exception('Test error'),
          fatal: false,
          customKeys: {'test': 'data'},
        );

        final map = report.toMap();
        expect(map['fatal'], false);
        expect(map['customKeys'], {'test': 'data'});
        expect(map['exception'], contains('Test error'));
      });

      test('copyWith works correctly', () {
        final report = CrashReport(
          exception: Exception('Test error'),
          fatal: false,
        );

        final updated = report.copyWith(fatal: true);
        expect(updated.fatal, true);
        expect(updated.exception.toString(), report.exception.toString());
      });
    });
  });
}
