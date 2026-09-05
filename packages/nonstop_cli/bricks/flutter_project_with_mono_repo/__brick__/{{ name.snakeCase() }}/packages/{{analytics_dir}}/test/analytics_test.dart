import 'package:analytics/analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Analytics Package', () {
    test('should create AnalyticsEvent correctly', () {
      const event = AnalyticsEvent(
        name: 'test_event',
        parameters: {'key': 'value'},
      );

      expect(event.name, 'test_event');
      expect(event.parameters, {'key': 'value'});
    });

    test('should create DefaultAnalyticsConfig correctly', () {
      const config = DefaultAnalyticsConfig(
        enableAnalytics: true,
        enableDebugLogging: false,
      );

      expect(config.enableAnalytics, isTrue);
      expect(config.enableDebugLogging, isFalse);
    });
  });
}
