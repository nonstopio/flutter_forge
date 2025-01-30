import 'package:flutter_test/flutter_test.dart';
import 'package:ns_utils/src.dart';

void main() {
  group('StringExtensions', () {
    test('toMap', () {
      expect(''.toMap(), {});

      expect('{"id":1}'.toMap(), {"id": 1});

      expect('{"id":"123"}'.toMap(), {"id": "123"});
    });
    test('toList', () {
      expect(''.toList(), []);

      expect('[1,2,3]'.toList(), [1, 2, 3]);

      expect('["1","2"]'.toList(), ["1", "2"]);
    });
    test('isNotBlank', () {
      String? data;
      expect(data.isNotBlank, false);
      expect(''.isNotBlank, false);
      expect('   '.isNotBlank, false);
      expect('Ajay'.isNotBlank, true);
    });
    test('isEmptyOrNull', () {
      String? data;
      expect(data.isEmptyOrNull, true);
      expect(''.isEmptyOrNull, true);
    });
    test('toINT', () {
      expect('12121'.toINT, 12121);
      expect('12.121'.toINT, 12);
      expect('12.1.21'.toINT, 0);
    });
    test('toDOUBLE', () {
      expect('12121'.toDOUBLE, 12121);
      expect('12.121'.toDOUBLE, 12.121);
      expect('12.1.21'.toDOUBLE, 0);
    });
    test('asBool', () {
      expect('true'.asBool, true);
      expect('True'.asBool, true);
      expect('false'.asBool, false);
      expect('False'.asBool, false);
      expect('yes'.asBool, true);
      expect('YES'.asBool, true);
      expect('no'.asBool, false);
      expect('NO'.asBool, false);
      // string numbers
      expect('232'.asBool, true);
      expect('1'.asBool, true);
      expect('0'.asBool, false);
      expect('-1'.asBool, false);
    });
    test('toDateTime', () {
      expect('2020-08-01'.toDateTime(), DateTime(2020, 08, 01));
      String value = DateTime(2020, 08, 01).toIso8601String();
      expect(value.toDateTime(), DateTime(2020, 08, 01));
    });

    test('truncate Middle', () {
      expect(''.truncateMiddle(), '');
      expect('12'.truncateMiddle(), '12');
      expect('123456'.truncateMiddle(), '123456');
      expect('1234567'.truncateMiddle(), '123...567');
      expect('1234567890'.truncateMiddle(maxChars: 2), '12...90');
      expect(
        '1234567890'.truncateMiddle(maxChars: 2, truncateKey: "-"),
        '12-90',
      );
    });

    test('first N char', () {
      expect(''.firstNChars(), '');
      expect('12'.firstNChars(n: 5), '12');
      expect('123456'.firstNChars(n: 2), '12');
      expect('1234567'.firstNChars(n: 20), '1234567');
      expect('1234567'.firstNChars(n: -20), '1234567');
    });

    test('last N char', () {
      expect(''.lastNChars(), '');
      expect('12'.lastNChars(n: 5), '12');
      expect('123456'.lastNChars(n: 2), '56');
      expect('1234567'.lastNChars(n: 20), '1234567');
      expect('1234567'.lastNChars(n: -20), '1234567');
    });
  });
}
