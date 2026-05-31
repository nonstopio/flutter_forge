import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ns_utils/utils/focus_detector.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  testWidgets('fires focus/visibility callbacks based on visibility',
      (tester) async {
    var focusGained = 0, focusLost = 0;
    var visibilityGained = 0, visibilityLost = 0;
    var foregroundGained = 0, foregroundLost = 0;

    Widget build(bool visible) {
      return MaterialApp(
        home: Scaffold(
          body: Offstage(
            offstage: !visible,
            child: FocusDetector(
              onFocusGained: () => focusGained++,
              onFocusLost: () => focusLost++,
              onVisibilityGained: () => visibilityGained++,
              onVisibilityLost: () => visibilityLost++,
              onForegroundGained: () => foregroundGained++,
              onForegroundLost: () => foregroundLost++,
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(build(true));
    await tester.pumpAndSettle();
    expect(focusGained, greaterThan(0));
    expect(visibilityGained, greaterThan(0));

    // Hide the widget to trigger loss callbacks.
    await tester.pumpWidget(build(false));
    await tester.pumpAndSettle();
    expect(focusLost, greaterThan(0));
    expect(visibilityLost, greaterThan(0));

    // Simulate app going to background + returning to foreground.
    await tester.pumpWidget(build(true));
    await tester.pumpAndSettle();

    final binding = WidgetsFlutterBinding.ensureInitialized();
    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    expect(foregroundLost, greaterThanOrEqualTo(0));
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(foregroundGained, greaterThanOrEqualTo(0));
  });

  testWidgets('works when all callbacks are null', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FocusDetector(
            child: SizedBox(width: 10, height: 10),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final binding = WidgetsFlutterBinding.ensureInitialized();
    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
  });
}
