import 'package:developer/developer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Developer Package', () {
    test('package exports are available', () {
      expect(DeveloperRoutes.developer, '/developer');
    });

    testWidgets('DebugGestureDetector exports are available', (tester) async {
      // Test that the widget can be instantiated
      const widget = OpenDevToolsWrapper(child: Text('Test'));

      expect(widget, isNotNull);
      expect(widget.tapCount, 5); // Default value
      expect(widget.tapWindow, const Duration(seconds: 2)); // Default value
      expect(widget.enableHaptics, true); // Default value
      expect(widget.enableVisualFeedback, false); // Default value
    });

    testWidgets('DebugGestureDetector custom values work', (tester) async {
      // Test custom configuration
      const widget = OpenDevToolsWrapper(
        tapCount: 7,
        tapWindow: Duration(seconds: 2),
        enableHaptics: false,
        enableVisualFeedback: true,
        child: Text('Test'),
      );

      expect(widget.tapCount, 7);
      expect(widget.tapWindow, const Duration(seconds: 2));
      expect(widget.enableHaptics, false);
      expect(widget.enableVisualFeedback, true);
    });
  });
}
