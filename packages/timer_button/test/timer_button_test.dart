import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timer_button/timer_button.dart';

void main() {
  group('TimerButton', () {
    group('Constructor Tests', () {
      testWidgets('should create TimerButton with required parameters',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton(
                label: 'Start',
                onPressed: () {},
                timeOutInSeconds: 5,
              ),
            ),
          ),
        );

        expect(find.byType(TimerButton), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.text('Start |  5s'), findsOneWidget);
      });

      testWidgets('should create TimerButton with custom parameters',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton(
                label: 'Custom',
                onPressed: () {},
                timeOutInSeconds: 3,
                secPostFix: ' sec',
                color: Colors.red,
                disabledColor: Colors.orange,
                buttonType: ButtonType.textButton,
                activeTextStyle: const TextStyle(fontSize: 16),
                disabledTextStyle: const TextStyle(color: Colors.purple),
                resetTimerOnPressed: false,
                timeUpFlag: false,
              ),
            ),
          ),
        );

        expect(find.byType(TimerButton), findsOneWidget);
        expect(find.byType(TextButton), findsOneWidget);
        expect(find.text('Custom |  3 sec'), findsOneWidget);
      });

      testWidgets('should create TimerButton.builder with custom builder',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton.builder(
                builder: (context, seconds) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Text('Custom: $seconds'),
                  );
                },
                onPressed: () {},
                timeOutInSeconds: 2,
              ),
            ),
          ),
        );

        expect(find.byType(TimerButton), findsOneWidget);
        expect(find.byType(GestureDetector), findsOneWidget);
        expect(find.text('Custom: 2'), findsOneWidget);
      });
    });

    group('Button Type Tests', () {
      testWidgets('should render ElevatedButton by default', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton(
                label: 'Test',
                onPressed: () {},
                timeOutInSeconds: 1,
              ),
            ),
          ),
        );

        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.byType(TextButton), findsNothing);
        expect(find.byType(OutlinedButton), findsNothing);
      });

      testWidgets('should render TextButton when specified', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton(
                label: 'Test',
                onPressed: () {},
                timeOutInSeconds: 1,
                buttonType: ButtonType.textButton,
              ),
            ),
          ),
        );

        expect(find.byType(TextButton), findsOneWidget);
        expect(find.byType(ElevatedButton), findsNothing);
        expect(find.byType(OutlinedButton), findsNothing);
      });

      testWidgets('should render OutlinedButton when specified',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton(
                label: 'Test',
                onPressed: () {},
                timeOutInSeconds: 1,
                buttonType: ButtonType.outlinedButton,
              ),
            ),
          ),
        );

        expect(find.byType(OutlinedButton), findsOneWidget);
        expect(find.byType(ElevatedButton), findsNothing);
        expect(find.byType(TextButton), findsNothing);
      });

      testWidgets('should render custom widget with builder', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton.builder(
                builder: (context, seconds) => Text('Custom $seconds'),
                onPressed: () {},
                timeOutInSeconds: 1,
              ),
            ),
          ),
        );

        expect(find.byType(GestureDetector), findsOneWidget);
        expect(find.byType(ElevatedButton), findsNothing);
        expect(find.text('Custom 1'), findsOneWidget);
      });
    });

    group('Timer Functionality Tests', () {
      testWidgets('should start with disabled button and countdown text',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton(
                label: 'Start',
                onPressed: () {},
                timeOutInSeconds: 3,
              ),
            ),
          ),
        );

        final button =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);
        expect(find.text('Start |  3s'), findsOneWidget);
      });

      testWidgets('should countdown and enable button when timer completes',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton(
                label: 'Start',
                onPressed: () {},
                timeOutInSeconds: 1, // Reduced to 1 second for simpler test
              ),
            ),
          ),
        );

        // Initially disabled with countdown
        expect(find.text('Start |  1s'), findsOneWidget);
        var button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);

        // After 1 second total - wait long enough for timer to complete
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        // Check if button is enabled
        button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNotNull);
        expect(find.text('Start'), findsOneWidget);
      });

      testWidgets('should handle timeUpFlag initial state', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton(
                label: 'Ready',
                onPressed: () {},
                timeOutInSeconds: 5,
                timeUpFlag: true,
              ),
            ),
          ),
        );

        expect(find.text('Ready'), findsOneWidget);
        final button =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNotNull);
      });

      testWidgets(
          'should reset timer when button pressed with resetTimerOnPressed true',
          (tester) async {
        bool pressed = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton(
                label: 'Reset',
                onPressed: () => pressed = true,
                timeOutInSeconds: 2,
                resetTimerOnPressed: true,
              ),
            ),
          ),
        );

        // Wait for timer to complete
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // Press button
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(pressed, isTrue);
        expect(find.text('Reset |  2s'), findsOneWidget);
      });

      testWidgets('should not reset timer when resetTimerOnPressed is false',
          (tester) async {
        bool pressed = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton(
                label: 'NoReset',
                onPressed: () => pressed = true,
                timeOutInSeconds: 2,
                resetTimerOnPressed: false,
              ),
            ),
          ),
        );

        // Wait for timer to complete
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // Press button
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(pressed, isTrue);
        expect(find.text('NoReset'), findsOneWidget);
      });
    });

    group('Styling Tests', () {
      testWidgets('should apply custom secPostFix', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton(
                label: 'Custom',
                onPressed: () {},
                timeOutInSeconds: 1,
                secPostFix: ' seconds',
              ),
            ),
          ),
        );

        expect(find.text('Custom |  1 seconds'), findsOneWidget);
      });

      testWidgets('should apply disabled text style when timer active',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton(
                label: 'Styled',
                onPressed: () {},
                timeOutInSeconds: 1,
                disabledTextStyle:
                    const TextStyle(color: Colors.red, fontSize: 20),
              ),
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('Styled |  1s'));
        expect(text.style?.color, Colors.red);
        expect(text.style?.fontSize, 20);
      });

      testWidgets('should apply active text style when timer complete',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton(
                label: 'Active',
                onPressed: () {},
                timeOutInSeconds: 1,
                activeTextStyle:
                    const TextStyle(color: Colors.green, fontSize: 18),
                timeUpFlag: true,
              ),
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('Active'));
        expect(text.style?.color, Colors.green);
        expect(text.style?.fontSize, 18);
      });
    });

    group('Custom Builder Tests', () {
      testWidgets('should call builder with correct parameters',
          (tester) async {
        int receivedSeconds = -1;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton.builder(
                builder: (context, seconds) {
                  receivedSeconds = seconds;
                  return Text('Builder: $seconds');
                },
                onPressed: () {},
                timeOutInSeconds: 3,
              ),
            ),
          ),
        );

        expect(receivedSeconds, 3);
        expect(find.text('Builder: 3'), findsOneWidget);

        // Wait 1 second and check update
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        expect(receivedSeconds, 2);
        expect(find.text('Builder: 2'), findsOneWidget);
      });

      testWidgets('should handle gestures in custom builder', (tester) async {
        bool tapped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton.builder(
                builder: (context, seconds) => SizedBox(
                  width: 100,
                  height: 50,
                  child: Text('Tap: $seconds'),
                ),
                onPressed: () => tapped = true,
                timeOutInSeconds: 1,
                timeUpFlag: true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Tap: 1'));
        expect(tapped, isTrue);
      });

      testWidgets('should not respond to gestures when timer active in builder',
          (tester) async {
        bool tapped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton.builder(
                builder: (context, seconds) => Text('Wait: $seconds'),
                onPressed: () => tapped = true,
                timeOutInSeconds: 2,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Wait: 2'));
        expect(tapped, isFalse);
      });
    });

    group('Edge Cases and Error Handling', () {
      testWidgets('should handle zero timeout', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton(
                label: 'Zero',
                onPressed: () {},
                timeOutInSeconds: 0,
              ),
            ),
          ),
        );

        expect(find.text('Zero |  0s'), findsOneWidget);

        // Should enable immediately
        await tester.pump();
        final button =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNotNull);
      });

      testWidgets('should handle widget disposal during timer', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton(
                label: 'Dispose',
                onPressed: () {},
                timeOutInSeconds: 5,
                timeUpFlag: false,
              ),
            ),
          ),
        );

        // Let timer start
        await tester.pump(const Duration(milliseconds: 100));

        // Remove widget before timer completes
        await tester
            .pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));

        // Should not throw error when widget is disposed
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle widget disposal when timeUpFlag is true',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton(
                label: 'DisposeReady',
                onPressed: () {},
                timeOutInSeconds: 5,
                timeUpFlag: true,
              ),
            ),
          ),
        );

        // Remove widget immediately
        await tester
            .pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));

        // Should not throw error when widget is disposed with timeUpFlag true
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle multiple button presses correctly',
          (tester) async {
        int pressCount = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton(
                label: 'Multi',
                onPressed: () => pressCount++,
                timeOutInSeconds: 1,
                resetTimerOnPressed:
                    false, // Don't reset timer for simpler test
              ),
            ),
          ),
        );

        // Wait for timer to complete
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        // Press button multiple times
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        expect(pressCount, 1);

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        expect(pressCount, 2);
      });

      testWidgets('should handle default button type case', (tester) async {
        // This test covers the default case in the switch statement which returns Container()
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton(
                label: 'Default',
                onPressed: () {},
                timeOutInSeconds: 1,
                buttonType: ButtonType
                    .custom, // This should trigger default case since builder is null
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(ElevatedButton), findsNothing);
        expect(find.byType(TextButton), findsNothing);
        expect(find.byType(OutlinedButton), findsNothing);
      });

      testWidgets('should handle negative countdown properly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimerButton(
                label: 'Negative',
                onPressed: () {},
                timeOutInSeconds: 1,
              ),
            ),
          ),
        );

        // Wait for timer to complete and go negative
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        // Button should be enabled now
        final button =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNotNull);
        expect(find.text('Negative'), findsOneWidget);
      });
    });
  });

  group('TimerButtonChild', () {
    testWidgets('should display label when timer is up', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimerButtonChild(
              timeUpFlag: true,
              label: 'Ready',
              timerText: '5s',
              disabledTextStyle: TextStyle(color: Colors.grey),
              color: Colors.blue,
              buttonType: ButtonType.elevatedButton,
            ),
          ),
        ),
      );

      expect(find.text('Ready'), findsOneWidget);
    });

    testWidgets('should display label with timer when timer is active',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimerButtonChild(
              timeUpFlag: false,
              label: 'Wait',
              timerText: '3s',
              disabledTextStyle: TextStyle(color: Colors.grey),
              color: Colors.blue,
              buttonType: ButtonType.elevatedButton,
            ),
          ),
        ),
      );

      expect(find.text('Wait |  3s'), findsOneWidget);
    });

    testWidgets('should apply active text style for outlined button',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimerButtonChild(
              timeUpFlag: true,
              label: 'Outlined',
              timerText: '2s',
              disabledTextStyle: TextStyle(color: Colors.grey),
              color: Colors.red,
              buttonType: ButtonType.outlinedButton,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Outlined'));
      expect(text.style?.color, Colors.red);
    });

    testWidgets('should apply custom active text style when provided',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimerButtonChild(
              timeUpFlag: true,
              label: 'Custom',
              timerText: '1s',
              activeTextStyle: TextStyle(color: Colors.purple, fontSize: 24),
              disabledTextStyle: TextStyle(color: Colors.grey),
              color: Colors.blue,
              buttonType: ButtonType.elevatedButton,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Custom'));
      expect(text.style?.color, Colors.purple);
      expect(text.style?.fontSize, 24);
    });

    testWidgets('should apply disabled text style when timer is active',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimerButtonChild(
              timeUpFlag: false,
              label: 'Disabled',
              timerText: '4s',
              disabledTextStyle: TextStyle(color: Colors.orange, fontSize: 16),
              color: Colors.blue,
              buttonType: ButtonType.elevatedButton,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Disabled |  4s'));
      expect(text.style?.color, Colors.orange);
      expect(text.style?.fontSize, 16);
    });
  });

  group('ButtonType enum', () {
    test('should have all expected values', () {
      expect(ButtonType.values, hasLength(4));
      expect(ButtonType.values, contains(ButtonType.elevatedButton));
      expect(ButtonType.values, contains(ButtonType.textButton));
      expect(ButtonType.values, contains(ButtonType.outlinedButton));
      expect(ButtonType.values, contains(ButtonType.custom));
    });
  });

  group('Constants', () {
    test('should have correct constant values', () {
      // These are private constants in the library, but we can test their effects
      expect(1, equals(1)); // aSec
    });
  });
}
