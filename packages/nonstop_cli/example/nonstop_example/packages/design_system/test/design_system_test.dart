import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DesignSystemWrapper hands the builder a themed context', (
    tester,
  ) async {
    late ThemeData built;

    await tester.pumpWidget(
      MaterialApp(
        home: DesignSystemWrapper(
          builder: (context, theme) {
            built = theme;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(built.useMaterial3, isTrue);
    expect(built.colorScheme.primary, isNot(Colors.transparent));
  });
}
