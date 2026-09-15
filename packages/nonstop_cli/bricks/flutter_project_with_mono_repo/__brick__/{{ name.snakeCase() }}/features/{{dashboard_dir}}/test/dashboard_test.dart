{{#auth}}import 'package:auth/auth.dart' as auth;
{{/auth}}
import 'package:core/core.dart' as core;
import 'package:dashboard/dashboard.dart';
import 'package:di/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

{{#auth}}class _Auth implements auth.AuthService {
  int signOuts = 0;
  @override
  String get uid => 'test';
  @override
  bool get isSignedIn => true;
  @override
  Future<void> signOut() async {
    signOuts++;
  }
}

{{/auth}}void main() {
  setUp(core.init);
  tearDown(di.reset);

  testWidgets('tabs navigate and profile sign-out requires confirmation', (
    tester,
  ) async {
{{#auth}}    final service = _Auth();
    di.register<auth.AuthService>(service);
{{/auth}}    final router = GoRouter(
      initialLocation: DashboardRouter.home,
      routes: [
        DashboardRouter.createShellRoute(),
{{#auth}}        GoRoute(
          path: auth.AuthRoutes.signIn,
          builder: (_, _) => const Text('Signed out'),
        ),
{{/auth}}      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.path,
      DashboardRouter.home,
    );
    await tester.tap(find.text('Explore').last);
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.path,
      DashboardRouter.explore,
    );
    await tester.tap(find.text(strings.nav.profile).last);
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.path,
      DashboardRouter.profile,
    );
    await tester.tap(find.text(strings.profile.settings));
{{#auth}}    await tester.tap(find.text(strings.auth.sign_out));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.generic.cancel));
    await tester.pumpAndSettle();
    expect(service.signOuts, 0);
    await tester.tap(find.text(strings.auth.sign_out));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, strings.auth.sign_out));
    await tester.pumpAndSettle();
    expect(service.signOuts, 1);
    expect(find.text('Signed out'), findsOneWidget);
{{/auth}}  });

  testWidgets('placeholder supports an action', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlaceholderTab(
            icon: Icons.add,
            title: 'Title',
            subtitle: 'Subtitle',
            action: TextButton(
              onPressed: () {
                calls++;
              },
              child: const Text('Start'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Start'));
    expect(calls, 1);
  });
}
