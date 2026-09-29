import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:utils/utils.dart';

void main() {
  test('formats decimals and compact numbers', () {
    expect(2.0.format(), '2');
    expect(2.125.format(decimalPlaces: 2), '2.13');
    expect(2.25.asScore(), '2.3');
    expect(1250.compact(), '1.25K');
    Intl.withLocale('de', () => expect(1250.compact(), '1250'));
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
    expect(3661.asTime(sec: 's', min: 'm', hr: 'h'), '1 h 1 m');
    expect(61.asTime(sec: 's', min: 'm', hr: 'h'), '1 m 1 s');
  });

  test('relative time has deterministic minute, hour and date boundaries', () {
    final now = DateTime(2026, 1, 15, 12);
    for (final entry in {
      Duration.zero: 'Just now',
      const Duration(minutes: 1): '1m ago',
      const Duration(hours: 1): '1h ago',
      const Duration(days: 1): 'Yesterday',
      const Duration(days: 3): '3d ago',
      const Duration(days: 7): '1/8/2026',
    }.entries) {
      expect(now.subtract(entry.key).formatRelative(now: now), entry.value);
    }
    expect(DateTime.now().formatRelative(), 'Just now');
    String label(int n) => 'vor $n';
    for (final entry in {
      Duration.zero: 'Gerade eben',
      const Duration(minutes: 2): 'vor 2',
      const Duration(hours: 2): 'vor 2',
      const Duration(days: 1): 'Gestern',
      const Duration(days: 2): 'vor 2',
    }.entries) {
      expect(
        now
            .subtract(entry.key)
            .formatRelative(
              now: now,
              justNow: 'Gerade eben',
              yesterday: 'Gestern',
              minutesAgo: label,
              hoursAgo: label,
              daysAgo: label,
            ),
        entry.value,
      );
    }
  });
}
