import 'package:contact_permission/contact_permission.dart';
import 'package:contact_permission/contact_permission_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class TestPermissionPlatform extends ContactPermissionPlatform {
  bool granted = false;
  bool requested = false;
  bool fail = false;

  @override
  Future<bool> isPermissionGranted() {
    if (fail) throw StateError('platform unavailable');
    return Future.value(granted);
  }

  @override
  Future<bool> requestPermission() {
    requested = true;
    if (fail) throw StateError('platform unavailable');
    return Future.value(granted);
  }
}

void main() {
  late ContactPermissionPlatform original;
  late TestPermissionPlatform platform;
  setUp(() {
    original = ContactPermissionPlatform.instance;
    platform = TestPermissionPlatform();
    ContactPermissionPlatform.instance = platform;
  });
  tearDown(() => ContactPermissionPlatform.instance = original);

  test(
    'delegates permission checks and requests to the registered platform',
    () async {
      for (final granted in [false, true]) {
        platform.granted = granted;
        expect(await ContactPermission.isPermissionGranted(), granted);
        expect(await ContactPermission.requestPermission(), granted);
        expect(platform.requested, isTrue);
      }
    },
  );

  test('returns false when platform calls throw synchronously', () async {
    platform.fail = true;
    expect(await ContactPermission.isPermissionGranted(), isFalse);
    expect(await ContactPermission.requestPermission(), isFalse);
  });
}
