import 'package:dzod/dzod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('verify that `package:dzod/dzod.dart` import is working', () {
    expect(z.string().max(4).validate('DzoD').isSuccess, isTrue);
    expect(dzod.string().max(4).validate('DzoD').isSuccess, isTrue);
  });
}
