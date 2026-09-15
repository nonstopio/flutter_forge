{{#auth}}import 'package:auth/auth.dart' as auth;
{{/auth}}import 'package:dashboard/ui/screens/index.dart';
import 'package:go_router/go_router.dart';

{{#auth}}/// Demo content is available before Firebase configuration; configured apps
/// require a signed-in identity. Do not enable this bypass for protected data.
typedef _ShellRoute = auth.GoAuthRoute;{{/auth}}{{^auth}}typedef _ShellRoute = GoRoute;{{/auth}}

/// Bottom-navigation shell for the signed-in part of the app.
///
/// Add a tab by adding a [StatefulShellBranch] here and a destination in
/// [DashboardShellScreen].
abstract final class DashboardRouter {

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
{{#auth}}              allowUnconfigured: true,
{{/auth}}              path: home,
              builder: (context, state) => const HomeTabScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            _ShellRoute(
{{#auth}}              allowUnconfigured: true,
{{/auth}}              path: explore,
              builder: (context, state) => const ExploreTabScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            _ShellRoute(
{{#auth}}              allowUnconfigured: true,
{{/auth}}              path: profile,
              builder: (context, state) => const ProfileTabScreen(),
            ),
          ],
        ),
      ],
    );
  }
}
