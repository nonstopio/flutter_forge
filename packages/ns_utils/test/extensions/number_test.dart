import 'package:flutter_test/flutter_test.dart';
import 'package:ns_utils/src.dart';

void main() {
  group('Numbers', () {
    test('asBool', () {
      expect(1.asBool, true);
      expect(0.asBool, false);
      expect(9382.asBool, true);
      expect((-2272).asBool, false);
    });
    test('tenth', () {
      expect(100.tenth, 10);
    });

    test('fourth', () {
      expect(16.fourth, 4);
    });

    test('third', () {
      expect(9.third, 3);
    });

    test('half', () {
      expect(100.half, 50);
    });

    test('doubled', () {
      expect(100.doubled, 200);
    });

    test('tripled', () {
      expect(100.tripled, 300);
    });
  });
}
