{{#auth}}import 'package:auth/auth.dart' as auth;
{{/auth}}import 'package:dashboard/ui/screens/index.dart';
import 'package:go_router/go_router.dart';

{{#auth}}/// Every shell branch is guarded - unauthenticated users bounce to sign-in.
typedef _ShellRoute = auth.GoAuthRoute;{{/auth}}{{^auth}}typedef _ShellRoute = GoRoute;{{/auth}}

/// Bottom-navigation shell for the signed-in part of the app.
///
/// Add a tab by adding a [StatefulShellBranch] here and a destination in
/// [DashboardShellScreen].
class DashboardRouter {
  const DashboardRouter._();

  static const String home = '/home/dashboard';
  static const String explore = '/home/explore';
  static const String profile = '/home/profile';

  static StatefulShellRoute createShellRoute() {
    return StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          DashboardShellScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            _ShellRoute(
              path: home,
              builder: (context, state) => const HomeTabScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            _ShellRoute(
              path: explore,
              builder: (context, state) => const ExploreTabScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            _ShellRoute(
              path: profile,
              builder: (context, state) => const ProfileTabScreen(),
            ),
          ],
        ),
      ],
    );
  }
}
