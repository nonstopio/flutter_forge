import 'package:flutter_test/flutter_test.dart';
import 'package:ns_utils/methods/helper.dart';

void main() {
  test('generateDbId returns a non-empty hex string', () {
    final id = generateDbId();
    expect(id, isNotEmpty);
    expect(id.length, 24);
  });

  test('uniqueId and uniqueObjectId produce 24-char hex strings', () {
    expect(uniqueId.length, 24);
    expect(uniqueObjectId.length, 24);
  });
}
