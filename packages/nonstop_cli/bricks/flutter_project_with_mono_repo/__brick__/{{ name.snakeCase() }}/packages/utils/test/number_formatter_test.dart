import 'package:flutter_test/flutter_test.dart';
import 'package:utils/utils.dart';

void main() {
  test('formats decimals and domain conveniences consistently', () {
    expect(2.0.format(), '2');
    expect(2.125.format(decimalPlaces: 2), '2.13');
    expect(2.25.asScore(), '2.3');
    expect(2.25.asHrv(), '2.3');
    expect(2.25.asSleepHours(), '2.3');
    expect(2.25.asRespiratoryRate(), '2.3');
    expect(1250.compact(), '1.25K');
    expect(72.6.asHeartRate(), '73');
  });

  test('formats duration boundaries', () {
    for (final entry in {
      0: '0 sec',
      59: '59 sec',
      60: '1 min',
      61: '1 min 1 sec',
      3599: '59 min 59 sec',
      3600: '1 hr',
      3660: '1 hr 1 min',
    }.entries) {
      expect(entry.key.asTime(), entry.value);
    }
  });

  test('relative time has deterministic minute, hour and date boundaries', () {
    final now = DateTime(2026, 1, 15, 12);
    for (final entry in {
      Duration.zero: 'Just now',
      const Duration(minutes: 1): '1m ago',
      const Duration(hours: 1): '1h ago',
      const Duration(days: 1): 'Yesterday',
      const Duration(days: 3): '3d ago',
      const Duration(days: 7): '8/1/2026',
    }.entries) {
      expect(now.subtract(entry.key).formatRelative(now: now), entry.value);
    }
    expect(DateTime.now().formatRelative(), 'Just now');
  });
}
