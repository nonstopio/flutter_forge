import 'package:contact_permission/contact_permission_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final platform = MethodChannelContactPermission();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];
  tearDown(() {
    messenger.setMockMethodCallHandler(platform.methodChannel, null);
    calls.clear();
  });

  for (final response in [true, false, null]) {
    test('permission methods handle native response $response', () async {
      messenger.setMockMethodCallHandler(platform.methodChannel, (call) async {
        calls.add(call);
        return response;
      });
      expect(await platform.isPermissionGranted(), response ?? false);
      expect(await platform.requestPermission(), response ?? false);
      expect(calls.map((call) => call.method), [
        'isPermissionGranted',
        'requestPermission',
      ]);
      expect(calls.every((call) => call.arguments == null), isTrue);
    });
  }

  test('propagates native platform errors', () async {
    messenger.setMockMethodCallHandler(platform.methodChannel, (_) async {
      throw PlatformException(code: 'unavailable');
    });
    await expectLater(
      platform.isPermissionGranted(),
      throwsA(isA<PlatformException>()),
    );
    await expectLater(
      platform.requestPermission(),
      throwsA(isA<PlatformException>()),
    );
  });
}
