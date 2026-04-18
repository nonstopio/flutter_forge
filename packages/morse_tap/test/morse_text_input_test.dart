import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_tap/morse_tap.dart';

Finder _tapArea() => find.byType(GestureDetector).last;

Future<void> _singleTap(WidgetTester tester) async {
  await tester.tap(_tapArea());
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _doubleTap(WidgetTester tester) async {
  await tester.tap(_tapArea());
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(_tapArea());
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('asserts without controller or onTextChanged', (tester) async {
    expect(
      () => MorseTextInput(),
      throwsA(isA<AssertionError>()),
    );
  });

  testWidgets('renders preview + text field + tap area', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MorseTextInput(onTextChanged: (_) {}),
        ),
      ),
    );
    expect(find.text('Tap for Morse Input'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('hides preview when showMorsePreview is false', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MorseTextInput(
            onTextChanged: (_) {},
            showMorsePreview: false,
          ),
        ),
      ),
    );
    expect(find.text('Morse Code:'), findsNothing);
  });

  testWidgets('dot tap converts to text via auto-convert', (tester) async {
    final changes = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MorseTextInput(
            onTextChanged: changes.add,
            letterGap: const Duration(milliseconds: 200),
            wordGap: const Duration(milliseconds: 300),
          ),
        ),
      ),
    );
    await _singleTap(tester);
    // After tap, wait for letter gap + word gap to complete + elapse.
    await tester.pump(const Duration(milliseconds: 300));
    expect(changes, contains('E'));
    // Let the word gap timer fire to exercise _completeWord from wordGap path.
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('dash taps emit Morse output when autoConvert is off',
      (tester) async {
    final changes = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MorseTextInput(
            onTextChanged: changes.add,
            autoConvertToText: false,
            letterGap: const Duration(milliseconds: 200),
            wordGap: const Duration(seconds: 5),
          ),
        ),
      ),
    );
    await _doubleTap(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(changes.any((c) => c.contains('-')), isTrue);
  });

  testWidgets('long press forces word completion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MorseTextInput(
            onTextChanged: (_) {},
            autoConvertToText: false,
            letterGap: const Duration(seconds: 5),
            wordGap: const Duration(seconds: 5),
          ),
        ),
      ),
    );
    await _singleTap(tester);
    await tester.longPress(_tapArea());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(MorseTextInput), findsOneWidget);
  });

  testWidgets('uses the provided TextEditingController', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MorseTextInput(
            controller: controller,
            letterGap: const Duration(milliseconds: 200),
          ),
        ),
      ),
    );
    await _singleTap(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(controller.text, 'E');
  });

  testWidgets('clear button resets state and fires onClear', (tester) async {
    var cleared = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MorseTextInput(
            onTextChanged: (_) {},
            onClear: () => cleared++,
            letterGap: const Duration(milliseconds: 200),
          ),
        ),
      ),
    );
    await _singleTap(tester);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();
    expect(cleared, 1);
  });

  testWidgets('accepts custom decoration', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MorseTextInput(
            onTextChanged: (_) {},
            decoration: const InputDecoration(labelText: 'Morse'),
          ),
        ),
      ),
    );
    expect(find.text('Morse'), findsOneWidget);
  });

  testWidgets('disposes internal controller when not provided',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MorseTextInput(onTextChanged: (_) {}),
        ),
      ),
    );
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    expect(tester.takeException(), isNull);
  });

  testWidgets('animations update feedback color and value (smoke)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MorseTextInput(
            onTextChanged: (_) {},
            feedbackColor: Colors.teal,
          ),
        ),
      ),
    );
    await _singleTap(tester);
    await _doubleTap(tester);
    await tester.longPress(_tapArea());
    await tester.pumpAndSettle();
    expect(find.byType(MorseTextInput), findsOneWidget);
  });
}
