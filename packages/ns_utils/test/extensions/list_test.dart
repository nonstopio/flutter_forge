import 'package:flutter_test/flutter_test.dart';
import 'package:ns_utils/src.dart';

void main() {
  group('ListExtensions', () {
    test('toJson', () {
      expect([12, 12].toJson(), '[12,12]');
      expect([].toJson(), '[]');
      expect(['123', '1234'].toJson(), '["123","1234"]');
    });

    test('containWithoutCase', () {
      List<String> list = ['Test', 'User'];
      expect(list.containWithoutCase('test'), true);
      expect(list.containWithoutCase('User1'), false);
    });
  });
}
