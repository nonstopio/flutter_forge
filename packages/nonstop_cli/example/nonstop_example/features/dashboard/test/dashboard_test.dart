import 'package:core/core.dart' as core;
import 'package:dashboard/dashboard.dart';
import 'package:di/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

void main() {
  setUp(core.init);
  tearDown(di.reset);

  testWidgets('tabs navigate and profile sign-out requires confirmation', (
    tester,
  ) async {
    var signOuts = 0;
    var settingsOpened = 0;
    final redirected = <String>[];
    final router = GoRouter(
      initialLocation: DashboardRouter.home,
      routes: [
        DashboardRouter.createShellRoute(
          redirect: (_, state) {
            redirected.add(state.uri.path);
            return null;
          },
          onOpenSettings: (_) => settingsOpened++,
          onSignOut: (context) async {
            signOuts++;
            context.go('/signed-out');
          },
        ),
        GoRoute(
          path: '/signed-out',
          builder: (_, _) => const Text('Signed out'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.path,
      DashboardRouter.home,
    );
    await tester.tap(find.text(strings.nav.explore).last);
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
    expect(
      redirected,
      containsAll(<String>[
        DashboardRouter.home,
        DashboardRouter.explore,
        DashboardRouter.profile,
      ]),
    );
    await tester.tap(find.text(strings.profile.settings));
    expect(settingsOpened, 1);
    await tester.tap(find.text(strings.auth.sign_out));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.generic.cancel));
    await tester.pumpAndSettle();
    expect(signOuts, 0);
    await tester.tap(find.text(strings.auth.sign_out));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, strings.auth.sign_out));
    await tester.pumpAndSettle();
    expect(signOuts, 1);
    expect(find.text('Signed out'), findsOneWidget);
  });

  testWidgets('profile hides settings and sign-out without handlers', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileTabScreen()));
    expect(find.text(strings.profile.settings), findsNothing);
    expect(find.text(strings.auth.sign_out), findsNothing);
  });

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
