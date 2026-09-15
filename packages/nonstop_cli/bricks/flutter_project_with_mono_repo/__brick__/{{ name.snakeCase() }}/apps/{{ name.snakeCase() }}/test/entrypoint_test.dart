import 'package:di/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
{{#network}}import 'package:network/network.dart';
{{/network}}
import 'package:{{name.snakeCase()}}/main.dart' as entrypoint;

void main() {
  tearDown(di.reset);
  testWidgets('real entrypoint starts offline without Firebase credentials', (
    tester,
  ) async {
    await entrypoint.main();
    await tester.pump();
    await tester.pumpAndSettle();
{{#network}}    expect(di.has<NetworkClient>(), isTrue);
{{/network}}
    expect(di.has<GoRouter>(), isTrue);
{{#dashboard}}    expect(find.text('Explore'), findsWidgets);
{{/dashboard}}
    final router = di.get<GoRouter>();
    router.go('/unknown');
    await tester.pumpAndSettle();
    expect(find.byType(OutlinedButton), findsOneWidget);
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();
    router.go('/error?title=Test&message=Try%20later&error=Details');
    await tester.pumpAndSettle();
    expect(find.text('Try later'), findsOneWidget);
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
