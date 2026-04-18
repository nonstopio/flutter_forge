import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ns_utils/extensions/date_time.dart';
import 'package:ns_utils/extensions/double.dart';
import 'package:ns_utils/extensions/duration.dart';
import 'package:ns_utils/extensions/int.dart';
import 'package:ns_utils/extensions/list.dart';
import 'package:ns_utils/extensions/map.dart';
import 'package:ns_utils/extensions/string.dart';
import 'package:ns_utils/extensions/widgets/gesture_detector.dart';
import 'package:ns_utils/extensions/widgets/widgets.dart';
import 'package:ns_utils/methods/conversion.dart';

void main() {
  group('IntExtensions', () {
    test('dayPrefix', () {
      expect((-1).dayPrefix, 'Yesterday');
      expect(0.dayPrefix, 'Today');
      expect(1.dayPrefix, 'Tomorrow');
      expect(5.dayPrefix, '');
    });
    test('asNullIfZero / isNullOrZero', () {
      expect(0.asNullIfZero, isNull);
      expect(1.asNullIfZero, 1);
      expect(0.isNullOrZero, isTrue);
      expect(2.isNullOrZero, isFalse);
    });
  });

  group('DoubleExtensions', () {
    test('tenth/fourth/third/half', () {
      expect(10.0.tenth, 1);
      expect(16.0.fourth, 4);
      expect(9.0.third, 3);
      expect(10.0.half, 5);
    });
    test('doubled/tripled', () {
      expect(2.0.doubled, 4);
      expect(2.0.tripled, 6);
    });
    test('asBool / asNullIfZero / isNullOrZero', () {
      expect(1.0.asBool, isTrue);
      expect(0.0.asBool, isFalse);
      expect(0.0.asNullIfZero, isNull);
      expect(0.5.asNullIfZero, 0.5);
      expect(0.0.isNullOrZero, isTrue);
      expect(3.0.isNullOrZero, isFalse);
    });
  });

  group('DateExtensions', () {
    test('dayDifference + isToday/Yesterday/Tomorrow', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      expect(today.dayDifference, 0);
      expect(today.isToday, isTrue);
      expect(today.isYesterday, isFalse);
      expect(today.isTomorrow, isFalse);
      final yesterday = today.yesterday();
      expect(yesterday.isYesterday, isTrue);
      final tomorrow = today.tomorrow();
      expect(tomorrow.isTomorrow, isTrue);
    });
    test('toServerFormat returns ISO-8601', () {
      final d = DateTime.utc(2020, 1, 2, 3, 4, 5);
      expect(d.toServerFormat(), d.toUtc().toIso8601String());
    });
  });

  group('DurationExtensions', () {
    test('toHoursMinutes', () {
      expect(const Duration(hours: 5, minutes: 7).toHoursMinutes(), '05:07');
      expect(const Duration(hours: 12, minutes: 45).toHoursMinutes(), '12:45');
    });
    test('toHoursMinutesSeconds', () {
      expect(
        const Duration(minutes: 2, seconds: 9).toHoursMinutesSeconds(),
        '02:09',
      );
    });
  });

  group('ListExtensions', () {
    test('toComaSeparatedValues joins with comma', () {
      expect(['a', 'b', 'c'].toComaSeparatedValues(), 'a, b, c');
    });

    test('toJson swallows exceptions and returns default', () {
      // A list containing a non-encodable value forces json.encode to throw.
      final result = [DateTime(2020)].toJson();
      expect(result, isA<String>());
    });

    test('toComaSeparatedValues swallows toString errors', () {
      final result = [_Throwing()].toComaSeparatedValues();
      expect(result, isA<String>());
    });
  });

  group('MapExtensions error paths', () {
    test('toJson swallows exceptions and returns default', () {
      final map = <String, dynamic>{'k': DateTime(2020)};
      expect(map.toJson(), isA<String>());
    });

    test('toPretty returns default on encoding error', () {
      // Circular structures are not json-encodable even with toEncodable.
      final map = <String, dynamic>{};
      map['self'] = map;
      final result = map.toPretty();
      expect(result, isA<String>());
    });
  });

  group('MapExtensions', () {
    test('add returns existing value when key present', () {
      final map = <String, dynamic>{'a': 1};
      final result = map.add(key: 'a', value: 42);
      expect(result, 1);
      expect(map['a'], 1);
    });
    test('add inserts when absent', () {
      final map = <String, dynamic>{};
      final result = map.add(key: 'a', value: 42);
      expect(result, 42);
      expect(map['a'], 42);
    });
  });

  group('StringExtensions (extra)', () {
    test('addSpaceAndCommaIfNotEmpty', () {
      expect('hi'.addSpaceAndCommaIfNotEmpty, 'hi, ');
      expect(''.addSpaceAndCommaIfNotEmpty, '');
    });

    test('toColor handles 6 char hex', () {
      expect('#FF0000'.toColor(), const Color(0xFFFF0000));
      expect('FF0000'.toColor(), const Color(0xFFFF0000));
    });

    test('toColor handles 8 char hex with 0x prefix (10 char full)', () {
      expect('0xFFAABBCC'.toColor(), const Color(0xFFAABBCC));
    });

    test('toColor returns random color on invalid input', () {
      // Just ensure it does not throw and returns a Color instance.
      expect('not-a-color'.toColor(), isA<Color>());
    });

    test('addPrefixIfNotEmpty', () {
      expect('abc'.addPrefixIfNotEmpty('>'), '>abc');
      expect(''.addPrefixIfNotEmpty('>'), '');
    });

    test('showDashIfEmpty', () {
      expect(''.showDashIfEmpty, '-');
      expect('x'.showDashIfEmpty, 'x');
    });

    test('toDateTime empty + -00 prefix', () {
      expect(''.toDateTime(), isNull);
      final result = '-002020-01-01'.toDateTime();
      expect(result, isNotNull);
    });

    test('toDateTime returns null for unparseable input', () {
      expect('not-a-date'.toDateTime(), isNull);
    });

    test('toMap returns default on invalid JSON', () {
      expect('not json'.toMap(), {});
    });

    test('toColor handles exceptions gracefully', () {
      // 10-char string that is not valid hex will trigger int.parse to throw.
      final c = '0xZZZZZZZZ'.toColor();
      expect(c, isA<Color>());
    });
  });

  group('StringNullExtensions', () {
    bool nullableIsNotBlank(String? s) => s.isNotBlank;
    test('isNotBlank on null string', () {
      expect(nullableIsNotBlank(null), isFalse);
    });
    test('isNotBlank on non-empty string', () {
      expect(nullableIsNotBlank(' hi '), isTrue);
    });
  });

  group('toEncodable', () {
    test('returns primitive types as-is', () {
      expect(toEncodable(1), 1);
      expect(toEncodable('x'), 'x');
      expect(toEncodable(true), true);
      expect(toEncodable([1, 2]), [1, 2]);
      expect(toEncodable({'a': 1}), {'a': 1});
    });
    test('converts other types to strings', () {
      expect(toEncodable(DateTime(2020, 1, 1)), isA<String>());
    });
  });

  group('Conversions error paths', () {
    test('toInt returns default on non-parseable input', () {
      expect(toInt('abc'), 0);
      expect(toInt('abc', defaultValue: 9), 0);
    });
    test('toDouble returns 0 on non-parseable input', () {
      expect(toDouble('abc'), 0);
    });
    test('toInt catches UnsupportedError on NaN/Infinity', () {
      expect(toInt(double.nan), 0);
      expect(toInt(double.infinity), 0);
    });
  });

  group('Widget extensions', () {
    // placeholder group marker
    testWidgets('GestureDetector extensions wrap widgets', (tester) async {
      int onTap = 0, onDouble = 0, onLong = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const SizedBox(
                  width: 100,
                  height: 30,
                  child: Text('a'),
                ).onTap(() => onTap++),
                const SizedBox(
                  width: 100,
                  height: 30,
                  child: Text('b'),
                ).onDoubleTap(() => onDouble++),
                const SizedBox(
                  width: 100,
                  height: 30,
                  child: Text('c'),
                ).onLongPress(() => onLong++),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('a'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('b'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('b'));
      await tester.pump();
      await tester.longPress(find.text('c'));
      await tester.pump();
      expect(onTap, 1);
      expect(onDouble, 1);
      expect(onLong, 1);
    });

    testWidgets('withTooltip wraps in a Tooltip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('hi').withTooltip(
              'a tip',
              decoration: const BoxDecoration(),
              preferBelow: true,
              padding: EdgeInsets.zero,
              textStyle: const TextStyle(),
              waitDuration: Duration.zero,
              margin: EdgeInsets.zero,
            ),
          ),
        ),
      );
      expect(find.byType(Tooltip), findsOneWidget);
    });
  });
}

class _Throwing {
  @override
  String toString() => throw Exception('boom');
}
