import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ns_utils/services/device_service/device_service.dart';
import 'package:ns_utils/services/statusbar_service/statusbar_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call);
      return null;
    });
  });
  tearDown(() => TestDefaultBinaryMessengerBinding
      .instance.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, null));
  test('portrait orientation enables both portrait rotations', () async {
    await DeviceService.setOrientationToPortrait();
    expect(calls.single.method, 'SystemChrome.setPreferredOrientations');
    expect(calls.single.arguments,
        ['DeviceOrientation.portraitUp', 'DeviceOrientation.portraitDown']);
  });
  test('status bar can be hidden, shown and restored', () async {
    await StatusBarService.hideStatusBar();
    await StatusBarService().showStatusBar();
    StatusBarService.resetStatusBarColor();
    await Future<void>.delayed(Duration.zero);
    expect(calls.map((call) => call.method), [
      'SystemChrome.setEnabledSystemUIOverlays',
      'SystemChrome.setEnabledSystemUIOverlays',
      'SystemChrome.restoreSystemUIOverlays'
    ]);
    expect(calls[0].arguments, ['SystemUiOverlay.bottom']);
    expect(
        calls[1].arguments, ['SystemUiOverlay.top', 'SystemUiOverlay.bottom']);
  });
  test('status color handles a platform exception during scheduling', () async {
    final messages = <String?>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => messages.add(message);
    addTearDown(() => debugPrint = originalDebugPrint);
    await runZoned(() => StatusBarService.changeStatusColor(Colors.blue),
        zoneSpecification: ZoneSpecification(
            createTimer: (self, parent, zone, duration, callback) {
      throw PlatformException(code: 'unavailable');
    }));
    expect(messages.single, contains('unavailable'));
  });
  testWidgets('status color change completes its delayed overlay update',
      (tester) async {
    final future = StatusBarService.changeStatusColor(Colors.red);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await future;
    final styles = calls
        .where((call) => call.method == 'SystemChrome.setSystemUIOverlayStyle')
        .toList();
    expect(styles, isNotEmpty);
    expect(styles.last.arguments['statusBarBrightness'], 'Brightness.light');
  });
}
