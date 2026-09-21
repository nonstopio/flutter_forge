import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_tap/morse_tap.dart';
import 'package:morse_tap_example/haptic_config_modal.dart';
import 'package:morse_tap_example/main.dart' as app;

void main() {
  setUp(() {
    HapticUtils.debugHapticSupportedOverride = true;
  });
  tearDown(() {
    HapticUtils.debugHapticSupportedOverride = null;
  });

  testWidgets(
    'entry point navigates between all examples without layout errors',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      app.main();
      await tester.pumpAndSettle();
      expect(find.text('Morse Tap Detector'), findsOneWidget);
      await tester.tap(find.text('Text Input').last);
      await tester.pumpAndSettle();
      expect(find.text('Morse Text Input'), findsOneWidget);
      await tester.tap(find.text('Extensions'));
      await tester.pumpAndSettle();
      expect(find.text('String Extensions'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'detector presents gestures, sequence feedback, and timed resets',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: app.MorseTapDetectorExample())),
      );
      MorseTapDetector detector() =>
          tester.widget(find.byType(MorseTapDetector));
      detector().onDotAdded!();
      detector().onSequenceChange!('.');
      await tester.pumpAndSettle();
      expect(find.text('Added dot (•)'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('Current: .')).style?.color,
        Colors.green,
      );
      detector().onDashAdded!();
      detector().onSequenceChange!('-');
      await tester.pumpAndSettle();
      expect(find.text('Added dash (—)'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('Current: -')).style?.color,
        Colors.orange,
      );
      detector().onSpaceAdded!();
      await tester.pump();
      expect(find.text('Added space'), findsOneWidget);
      detector().onCorrectSequence();
      await tester.pump();
      expect(find.text('✅ Perfect! You tapped SOS correctly!'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(
        find.text('Use gestures to input SOS (... --- ...)'),
        findsOneWidget,
      );
      detector().onIncorrectSequence!();
      await tester.pump();
      expect(find.text('❌ Wrong sequence. Try again!'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.text('Use gestures to input SOS (... --- ...)'),
        findsOneWidget,
      );
      detector().onInputTimeout!();
      await tester.pump();
      expect(find.text('⏰ Sequence timed out. Try again!'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('HELLO'));
      await tester.pumpAndSettle();
      expect(detector().expectedMorseCode, '.... . .-.. .-.. ---');
      expect(find.text('Target: HELLO'), findsOneWidget);
      await tester.tap(find.text('HELLO'));
      await tester.pumpAndSettle();
      expect(find.text('Target: HELLO'), findsOneWidget);
      detector().onCorrectSequence();
      detector().onIncorrectSequence!();
      detector().onInputTimeout!();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'detector settings save a new configuration and cancel preserves it',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: app.MorseTapDetectorExample())),
      );
      await tester.tap(find.text('Haptic Settings (Enabled)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Haptic Settings (Disabled)'), findsOneWidget);
      expect(
        tester
            .widget<MorseTapDetector>(find.byType(MorseTapDetector))
            .hapticConfig
            ?.enabled,
        isFalse,
      );
      await tester.tap(find.text('Haptic Settings (Disabled)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Haptic Settings (Disabled)'), findsOneWidget);
    },
  );

  testWidgets('text input selects its controller and conversion mode', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: app.MorseTextInputExample())),
    );
    MorseTextInput input() => tester.widget(find.byType(MorseTextInput));
    expect(input().autoConvertToText, isTrue);
    final textController = input().controller;
    input().onTextChanged?.call('SOS');
    expect(find.text('Converted Text'), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(input().autoConvertToText, isFalse);
    expect(input().controller, isNot(same(textController)));
    expect(find.text('Morse Code'), findsOneWidget);
    tester.widget<Checkbox>(find.byType(Checkbox)).onChanged!(null);
    await tester.pumpAndSettle();
    expect(input().autoConvertToText, isTrue);
    expect(input().controller, same(textController));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'string example converts input and shows empty and invalid states',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: app.StringExtensionExample())),
      );
      expect(
        find.text('.... . .-.. .-.. --- / .-- --- .-. .-.. -..'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField), 'SOS');
      await tester.pumpAndSettle();
      expect(find.text('... --- ...'), findsOneWidget);
      expect(
        tester
            .widgetList<SelectableText>(find.byType(SelectableText))
            .last
            .data,
        'SOS',
      );
      await tester.enterText(find.byType(TextField), '🙂');
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.cancel), findsWidgets);
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      expect(find.text('Enter text above...'), findsOneWidget);
      expect(find.text('Converted text appears here...'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'haptic modal updates every intensity and returns the saved configuration',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          calls.add(call);
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      HapticConfig? saved;
      HapticConfig? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showDialog<HapticConfig>(
                    context: context,
                    builder: (_) => HapticConfigModal(
                      initialConfig: HapticConfig.defaultConfig,
                      onConfigChanged: (config) => saved = config,
                    ),
                  );
                },
                child: const Text('configure'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('configure'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Strong'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'Strong'))
            .selected,
        isTrue,
      );
      for (var i = 0; i < 6; i++) {
        final dropdown = tester
            .widget<DropdownButtonFormField<HapticFeedbackType>>(
              find.byType(DropdownButtonFormField<HapticFeedbackType>).at(i),
            );
        dropdown.onChanged!(HapticFeedbackType.vibrate);
        await tester.pump();
      }
      await tester.tap(find.byTooltip('Test haptic').first);
      await tester.pump(const Duration(milliseconds: 150));
      expect(
        calls.any(
          (call) =>
              call.method == 'HapticFeedback.vibrate' && call.arguments == null,
        ),
        isTrue,
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(saved, same(result));
      expect(
        saved,
        const HapticConfig(
          enabled: true,
          dotIntensity: HapticFeedbackType.vibrate,
          dashIntensity: HapticFeedbackType.vibrate,
          spaceIntensity: HapticFeedbackType.vibrate,
          correctSequenceIntensity: HapticFeedbackType.vibrate,
          incorrectSequenceIntensity: HapticFeedbackType.vibrate,
          timeoutIntensity: HapticFeedbackType.vibrate,
        ),
      );
    },
  );

  testWidgets(
    'haptic switch toggles settings and unsupported platforms disable it',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HapticConfigModal(initialConfig: HapticConfig.defaultConfig),
        ),
      );
      expect(
        find.text('Provide tactile feedback for gestures'),
        findsOneWidget,
      );
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(find.text('Quick Presets'), findsNothing);
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(find.text('Quick Presets'), findsOneWidget);
      HapticUtils.debugHapticSupportedOverride = false;
      await tester.pumpWidget(
        const MaterialApp(
          home: HapticConfigModal(
            key: ValueKey('unsupported'),
            initialConfig: HapticConfig.defaultConfig,
          ),
        ),
      );
      expect(find.text('Not supported on this platform'), findsOneWidget);
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).onChanged,
        isNull,
      );
      expect(
        tester
            .widget<IconButton>(
              find
                  .byWidgetPredicate(
                    (widget) =>
                        widget is IconButton && widget.tooltip == 'Test haptic',
                  )
                  .first,
            )
            .onPressed,
        isNull,
      );
    },
  );
}
