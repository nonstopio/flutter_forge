import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_tap/morse_tap.dart';

// GestureDetector with both onTap + onDoubleTap delays onTap until
// kDoubleTapTimeout elapses. Pump 400ms after a tap to let it resolve.
Future<void> _singleTap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _doubleTap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    HapticUtils.debugHapticSupportedOverride = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => null,
    );
  });

  tearDown(() {
    HapticUtils.debugHapticSupportedOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Widget buildDetector({
    required String expected,
    required VoidCallback onCorrect,
    VoidCallback? onIncorrect,
    VoidCallback? onTimeout,
    ValueChanged<String>? onChange,
    VoidCallback? onDot,
    VoidCallback? onDash,
    VoidCallback? onSpace,
    HapticConfig? hapticConfig,
    Duration timeout = const Duration(seconds: 10),
  }) {
    return MaterialApp(
      home: Scaffold(
        body: MorseTapDetector(
          expectedMorseCode: expected,
          onCorrectSequence: onCorrect,
          onIncorrectSequence: onIncorrect,
          onInputTimeout: onTimeout,
          onSequenceChange: onChange,
          onDotAdded: onDot,
          onDashAdded: onDash,
          onSpaceAdded: onSpace,
          hapticConfig: hapticConfig,
          inputTimeout: timeout,
          child: const SizedBox(
            width: 200,
            height: 200,
            child: Text('tap area'),
          ),
        ),
      ),
    );
  }

  testWidgets('triggers onCorrectSequence when tapped correctly',
      (tester) async {
    var correct = 0;
    final changes = <String>[];
    await tester.pumpWidget(
      buildDetector(
        expected: '.',
        onCorrect: () => correct++,
        onChange: changes.add,
        hapticConfig: HapticConfig.defaultConfig,
        onDot: () {},
      ),
    );
    await _singleTap(tester, find.byType(GestureDetector));
    expect(correct, 1);
    expect(changes.last, '');
  });

  testWidgets('triggers onIncorrectSequence when sequence diverges',
      (tester) async {
    var incorrect = 0;
    await tester.pumpWidget(
      buildDetector(
        expected: '.-',
        onCorrect: () {},
        onIncorrect: () => incorrect++,
        hapticConfig: HapticConfig.defaultConfig,
      ),
    );
    await tester.longPress(find.byType(GestureDetector));
    await tester.pump(const Duration(milliseconds: 50));
    expect(incorrect, greaterThan(0));
  });

  testWidgets('triggers incorrect when sequence exceeds expected',
      (tester) async {
    var incorrect = 0;
    await tester.pumpWidget(
      buildDetector(
        expected: '.',
        onCorrect: () {},
        onIncorrect: () => incorrect++,
        hapticConfig: HapticConfig.defaultConfig,
      ),
    );
    await _doubleTap(tester, find.byType(GestureDetector));
    expect(incorrect, greaterThan(0));
  });

  testWidgets('onDotAdded/onDashAdded/onSpaceAdded fire', (tester) async {
    var dots = 0, dashes = 0, spaces = 0;
    await tester.pumpWidget(
      buildDetector(
        expected: '.- /space',
        onCorrect: () {},
        onDot: () => dots++,
        onDash: () => dashes++,
        onSpace: () => spaces++,
      ),
    );
    await _singleTap(tester, find.byType(GestureDetector));
    await _doubleTap(tester, find.byType(GestureDetector));
    await tester.longPress(find.byType(GestureDetector));
    await tester.pump(const Duration(milliseconds: 50));
    expect(dots, greaterThan(0));
    expect(dashes, greaterThan(0));
    expect(spaces, greaterThan(0));
  });

  testWidgets('resets sequence after input timeout', (tester) async {
    var timeouts = 0;
    await tester.pumpWidget(
      buildDetector(
        expected: '....',
        onCorrect: () {},
        onTimeout: () => timeouts++,
        hapticConfig: HapticConfig.defaultConfig,
        timeout: const Duration(milliseconds: 100),
      ),
    );
    await _singleTap(tester, find.byType(GestureDetector));
    await tester.pump(const Duration(milliseconds: 200));
    expect(timeouts, greaterThan(0));
  });

  testWidgets('cancels timer when widget is disposed', (tester) async {
    await tester.pumpWidget(
      buildDetector(
        expected: '....',
        onCorrect: () {},
        timeout: const Duration(milliseconds: 500),
      ),
    );
    await _singleTap(tester, find.byType(GestureDetector));
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    expect(tester.takeException(), isNull);
  });

  testWidgets('works without haptic config', (tester) async {
    var correct = 0;
    await tester.pumpWidget(
      buildDetector(
        expected: '.',
        onCorrect: () => correct++,
      ),
    );
    await _singleTap(tester, find.byType(GestureDetector));
    expect(correct, 1);
  });
}
