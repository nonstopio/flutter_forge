import 'package:core/core.dart' as core;
import 'package:di/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:{{name.snakeCase()}}/app.dart';
import 'package:{{name.snakeCase()}}/router/router.dart';

void main() {
  setUp(core.init);
  tearDown(di.reset);

  testWidgets('renders an injected router without platform initialization', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('Test destination')),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(App(router: router));
    await tester.pumpAndSettle();
    expect(find.text('Test destination'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('real routes boot without configured Firebase and switch tabs', (
    tester,
  ) async {
    final router = AppRouter.createRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(App(router: router));
    await tester.pumpAndSettle();
{{#dashboard}}    expect(find.text('Explore'), findsWidgets);
    await tester.tap(find.text('Explore').first);
    await tester.pumpAndSettle();
{{/dashboard}}    router.go('/error');
    await tester.pumpAndSettle();
    expect(find.text(strings.generic.error), findsWidgets);
    expect(find.text(strings.errors.unexpected_error), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
