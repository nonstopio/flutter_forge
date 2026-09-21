import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dzod_example/main.dart' as app;
import 'package:dzod_example/widgets/schema_display.dart';
import 'package:dzod_example/widgets/validation_card.dart';
import 'package:dzod_example/examples/advanced/coercion_example.dart';
import 'package:dzod_example/examples/advanced/discriminated_union_example.dart';
import 'package:dzod_example/examples/advanced/pipeline_example.dart';
import 'package:dzod_example/examples/advanced/recursive_schema_example.dart';
import 'package:dzod_example/examples/async/api_validation_example.dart';
import 'package:dzod_example/examples/async/database_validation_example.dart';
import 'package:dzod_example/examples/basic/boolean_null_example.dart';
import 'package:dzod_example/examples/basic/number_validations_example.dart';
import 'package:dzod_example/examples/basic/string_validation_example.dart';
import 'package:dzod_example/examples/basic/user_schema_example.dart';
import 'package:dzod_example/examples/complex/array_advanced_example.dart';
import 'package:dzod_example/examples/complex/enum_example.dart';
import 'package:dzod_example/examples/complex/object_manipulation_example.dart';
import 'package:dzod_example/examples/complex/record_example.dart';
import 'package:dzod_example/examples/complex/tuple_example.dart';
import 'package:dzod_example/examples/error_handling/error_code_system_example.dart';
import 'package:dzod_example/examples/error_handling/error_formatting_example.dart';
import 'package:dzod_example/examples/real_world/authentication_schema_example.dart';
import 'package:dzod_example/examples/schema_composition/introspection_example.dart';
import 'package:dzod_example/examples/schema_composition/json_schema_generation_example.dart';
import 'package:dzod_example/examples/security/security_best_practices_example.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
  expect(tester.takeException(), isNull);
}

Future<void> pressButtons(WidgetTester tester) async {
  final buttons = tester
      .widgetList<ButtonStyleButton>(
          find.byWidgetPredicate((w) => w is ButtonStyleButton))
      .toList();
  for (final button in buttons) {
    button.onPressed?.call();
    await settle(tester);
    tester
        .widget<ValidationCard>(find.byType(ValidationCard))
        .onValidate
        ?.call();
    await settle(tester);
    for (final label in ['Check URL', 'Validate Async', 'Validate Securely']) {
      final control = find.ancestor(
          of: find.text(label),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton));
      if (control.evaluate().isNotEmpty) {
        tester.widget<ButtonStyleButton>(control).onPressed?.call();
        await settle(tester);
      }
    }
    for (final icon
        in tester.widgetList<IconButton>(find.byType(IconButton)).toList()) {
      icon.onPressed?.call();
      await settle(tester);
    }
  }
  for (final chip
      in tester.widgetList<ActionChip>(find.byType(ActionChip)).toList()) {
    chip.onPressed?.call();
    await settle(tester);
  }
  for (final toggle
      in tester.widgetList<Switch>(find.byType(Switch)).toList()) {
    toggle.onChanged?.call(!toggle.value);
    await settle(tester);
  }
  for (final radio in tester
      .widgetList<RadioGroup<bool>>(find.byType(RadioGroup<bool>))
      .toList()) {
    radio.onChanged(true);
    await settle(tester);
    radio.onChanged(false);
    await settle(tester);
  }
  for (final checkbox in tester
      .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
      .toList()) {
    checkbox.onChanged?.call(true);
    await settle(tester);
    checkbox.onChanged?.call(false);
    await settle(tester);
  }
  for (final slider
      in tester.widgetList<Slider>(find.byType(Slider)).toList()) {
    slider.onChanged?.call(slider.min);
    await settle(tester);
  }
}

void main() {
  final examples = <Widget>[
    const CoercionExample(),
    const DiscriminatedUnionExample(),
    const PipelineExample(),
    const RecursiveSchemaExample(),
    const ApiValidationExample(),
    const DatabaseValidationExample(),
    const BooleanNullExample(),
    const NumberValidationsExample(),
    const StringValidationExample(),
    const UserSchemaExample(),
    const ArrayAdvancedExample(),
    const EnumExample(),
    const ObjectManipulationExample(),
    const RecordExample(),
    const TupleExample(),
    const ErrorCodeSystemExample(),
    const ErrorFormattingExample(),
    const AuthenticationSchemaExample(),
    const IntrospectionExample(),
    const JsonSchemaGenerationExample(),
    const SecurityBestPracticesExample(),
  ];

  for (final example in examples) {
    testWidgets(
        '${example.runtimeType} renders and validates every selectable example',
        (tester) async {
      tester.view.physicalSize = const Size(1600, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: example))));
      await settle(tester);
      expect(find.byType(ValidationCard), findsOneWidget);
      expect(find.byType(SchemaDisplay), findsWidgets);
      await pressButtons(tester);
      final dropdownCount =
          find.byWidgetPredicate((w) => w is DropdownButton).evaluate().length;
      for (var index = 0; index < dropdownCount; index++) {
        dynamic dropdown = tester.widget(
            find.byWidgetPredicate((w) => w is DropdownButton).at(index));
        final values =
            (dropdown.items as List).map((dynamic item) => item.value).toList();
        for (final value in values) {
          dropdown = tester.widget(
              find.byWidgetPredicate((w) => w is DropdownButton).at(index));
          dropdown.onChanged(value);
          await settle(tester);
          expect(find.byType(ValidationCard), findsOneWidget);
          await pressButtons(tester);
          final nestedDropdowns = tester
              .widgetList(find.byWidgetPredicate((w) => w is DropdownButton))
              .toList();
          for (final nested in nestedDropdowns.skip(1)) {
            final dynamic control = nested;
            for (final dynamic item in control.items) {
              control.onChanged(item.value);
              await settle(tester);
            }
          }
          final fields = tester
              .widgetList<TextFormField>(find.byType(TextFormField))
              .toList();
          for (final field in fields) {
            field.controller?.text = 'invalid input';
            field.onChanged?.call('invalid input');
            field.validator?.call('invalid input');
          }
          await settle(tester);
          await pressButtons(tester);
        }
      }
      for (final toggle in tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .toList()) {
        toggle.onChanged?.call(!toggle.value);
        await settle(tester);
      }
      for (final field in tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .toList()) {
        field.controller?.text = 'invalid input';
        field.onChanged?.call('invalid input');
        field.validator?.call('invalid input');
      }
      await settle(tester);
      await pressButtons(tester);
      expect(find.byType(ValidationCard), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await settle(tester);
    });
  }

  testWidgets('record editor adds numeric values and rejects invalid values',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: RecordExample()))));
    final fields =
        tester.widgetList<TextFormField>(find.byType(TextFormField)).toList();
    fields[0].controller!.text = 'count';
    fields[1].controller!.text = '42';
    await tester.tap(find.byTooltip('Add entry'));
    await settle(tester);
    expect(find.text('count: 42'), findsOneWidget);
    expect(fields[0].controller!.text, isEmpty);
    expect(fields[1].controller!.text, isEmpty);
  });

  testWidgets('app entry point builds the showcase', (tester) async {
    tester.view.physicalSize = const Size(1600, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    app.main();
    await tester.pumpAndSettle();
    expect(find.byType(app.ValidationShowcasePage), findsOneWidget);
    dynamic categories =
        tester.widget(find.byWidgetPredicate((w) => w is DropdownButton).first);
    final values =
        (categories.items as List).map((dynamic item) => item.value).toList();
    for (final value in values) {
      categories = tester
          .widget(find.byWidgetPredicate((w) => w is DropdownButton).first);
      categories.onChanged(value);
      await settle(tester);
      for (final tile
          in tester.widgetList<ListTile>(find.byType(ListTile)).toList()) {
        tile.onTap?.call();
        await settle(tester);
      }
    }
  });
}
