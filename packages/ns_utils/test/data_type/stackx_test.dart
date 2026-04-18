import 'package:flutter_test/flutter_test.dart';
import 'package:ns_utils/data_type/stackx.dart';

void main() {
  test('StackX push/top/pop/contains/addAll', () {
    final stack = StackX<int>();
    expect(stack.isEmpty, isTrue);
    expect(stack.isNotEmpty, isFalse);
    stack.push(1);
    stack.push(2);
    expect(stack.isEmpty, isFalse);
    expect(stack.isNotEmpty, isTrue);
    expect(stack.top(), 2);
    expect(stack.contains(1), isTrue);
    expect(stack.contains(3), isFalse);
    expect(stack.pop(), 2);
    expect(stack.top(), 1);
    final all = stack.addAll([3, 4, 5]);
    expect(all, [1, 3, 4, 5]);
  });
}
