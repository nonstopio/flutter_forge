import 'package:auth/auth.dart' as auth;
import 'package:core/core.dart' as core;
import 'package:di/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:notifications/notifications.dart';
import 'package:nonstop_example/app.dart';
import 'package:nonstop_example/router/router.dart';

class _Notifications implements NotificationClient {
  _Notifications({required this.fails});
  final bool fails;
  int unregistered = 0;

  @override
  Future<void> unregisterDevice() async {
    unregistered++;
    if (fails) throw Exception('backend down');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Auth implements auth.AuthService {
  int signOuts = 0;

  @override
  Future<void> signOut() async => signOuts++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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
    expect(find.text(strings.nav.explore), findsWidgets);
    await tester.tap(find.text(strings.nav.explore).first);
    await tester.pumpAndSettle();
    router.go('/error');
    await tester.pumpAndSettle();
    expect(find.text(strings.generic.error), findsWidgets);
    expect(find.text(strings.errors.unexpected_error), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  for (final fails in [false, true]) {
    testWidgets('sign-out unregisters the device first (failure: $fails)', (
      tester,
    ) async {
      final notifications = _Notifications(fails: fails);
      final service = _Auth();
      di.register<NotificationClient>(notifications);
      di.register<auth.AuthService>(service);
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, _) => TextButton(
              onPressed: () => AppRouter.signOut(context),
              child: const Text('out'),
            ),
          ),
          GoRoute(
            path: auth.AuthRoutes.signIn,
            builder: (_, _) => const Text('login'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.tap(find.text('out'));
      await tester.pumpAndSettle();
      expect(notifications.unregistered, 1);
      expect(service.signOuts, 1);
      expect(find.text('login'), findsOneWidget);
    });
  }
}
