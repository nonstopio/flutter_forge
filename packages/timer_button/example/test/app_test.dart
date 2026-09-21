import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timer_button/timer_button.dart';
import 'package:timer_button_example/main.dart' as app;

void main() {
  testWidgets('all demo buttons count down and restart after activation',
      (tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.byType(TimerButton), findsNWidgets(4));
    for (var seconds = 0; seconds < 5; seconds++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text('Custom: 0'), findsOneWidget);
    for (final label in [
      'Try Again',
      'Outlined: Try Again',
      'Text: Try Again',
      'Custom: 0'
    ]) {
      await tester.tap(find.text(label));
      await tester.pump();
    }
    expect(find.text('Custom: 5'), findsOneWidget);
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
