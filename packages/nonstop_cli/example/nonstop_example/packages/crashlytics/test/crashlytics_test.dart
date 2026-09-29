import 'package:crashlytics/crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Crashlytics', () {
    group('CrashlyticsConfig', () {
      test('creates default config correctly', () {
        const config = DefaultCrashlyticsConfig();

        expect(config.enableInDebugMode, false);
        expect(config.installGlobalErrorHandlers, true);
        expect(config.enableCustomLogs, true);
        expect(config.logBufferSize, 100);
        expect(config.enableUserMetadata, true);
        expect(config.customKeys, isEmpty);
      });

      test('creates custom config correctly', () {
        const config = CrashlyticsConfig(
          enableInDebugMode: true,
          installGlobalErrorHandlers: false,
          logBufferSize: 50,
          customKeys: {'test': 'value'},
        );

        expect(config.enableInDebugMode, true);
        expect(config.installGlobalErrorHandlers, false);
        expect(config.logBufferSize, 50);
        expect(config.customKeys, {'test': 'value'});
      });

      test('copyWith works correctly', () {
        const config = CrashlyticsConfig();
        final updated = config.copyWith(enableInDebugMode: true);

        expect(updated.enableInDebugMode, true);
        expect(
          updated.installGlobalErrorHandlers,
          config.installGlobalErrorHandlers,
        );
      });
    });

    group('UserMetadata', () {
      test('creates user metadata correctly', () {
        const metadata = UserMetadata(
          userId: 'user123',
          customAttributes: {'role': 'admin'},
        );

        expect(metadata.userId, 'user123');
        expect(metadata.customAttributes, {'role': 'admin'});
      });

      test('toMap works correctly', () {
        const metadata = UserMetadata(userId: 'user123');

        final map = metadata.toMap();
        expect(map, {'userId': 'user123', 'customAttributes': isEmpty});
      });

      test('copyWith works correctly', () {
        const metadata = UserMetadata(userId: 'user123');
        final updated = metadata.copyWith(customAttributes: {'plan': 'pro'});

        expect(updated.userId, 'user123');
        expect(updated.customAttributes, {'plan': 'pro'});
      });

      test('equality works correctly', () {
        const metadata1 = UserMetadata(userId: 'user123');
        const metadata2 = UserMetadata(userId: 'user123');
        const metadata3 = UserMetadata(userId: 'user456');

        expect(metadata1, equals(metadata2));
        expect(metadata1, isNot(equals(metadata3)));
      });
    });
  });
}
