import 'package:flutter_test/flutter_test.dart';
import 'package:morse_tap/src/utils/platform_utils_web.dart' as web;

void main() {
  test('web implementation consistently disables haptics', () {
    expect(web.PlatformUtils.isHapticSupported, isFalse);
  });
}
