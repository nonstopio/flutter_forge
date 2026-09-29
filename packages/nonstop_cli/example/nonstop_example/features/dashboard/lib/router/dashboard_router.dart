import 'package:dashboard/ui/screens/index.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Bottom-navigation shell for the signed-in part of the app.
///
/// Add a tab by adding a [StatefulShellBranch] here and a destination in
/// [DashboardShellScreen].
abstract final class DashboardRouter {
  static const String home = '/home/dashboard';
  static const String explore = '/home/explore';
  static const String profile = '/home/profile';

  /// [redirect] guards every tab (the app passes its auth guard);
  /// [onOpenSettings] and [onSignOut] show the settings and sign-out actions
  /// on the profile tab when given. All are injected so the dashboard never depends on another feature.
  static StatefulShellRoute createShellRoute({
    GoRouterRedirect? redirect,
    void Function(BuildContext context)? onOpenSettings,
    Future<void> Function(BuildContext context)? onSignOut,
  }) {
    GoRoute tab(String path, Widget screen) =>
        GoRoute(path: path, redirect: redirect, builder: (_, _) => screen);
    return StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          DashboardShellScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [tab(home, const HomeTabScreen())]),
        StatefulShellBranch(routes: [tab(explore, const ExploreTabScreen())]),
        StatefulShellBranch(
          routes: [
            tab(
              profile,
              ProfileTabScreen(
                onOpenSettings: onOpenSettings,
                onSignOut: onSignOut,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
