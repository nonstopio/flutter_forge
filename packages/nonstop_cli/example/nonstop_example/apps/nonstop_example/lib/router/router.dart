import 'package:analytics/analytics.dart';
import 'package:auth/auth.dart' as auth;
import 'package:core/core.dart' as core;
import 'package:dashboard/dashboard.dart';
import 'package:design_system/design_system.dart';
import 'package:developer/developer.dart' as developer;
import 'package:di/di.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:notifications/notifications.dart';
import 'package:nonstop_example/ui/splash_screen.dart';

/// The app's single [GoRouter].
///
/// Feature packages expose their own `routes` list and are spliced in here, so
/// adding a feature is one import plus one spread - no route table to merge.
abstract final class AppRouter {
  static GoRouter createRouter({String? initialLocation}) {
    final router = GoRouter(
      debugLogDiagnostics: kDebugMode,
      initialLocation: initialLocation ?? core.CoreRoutes.root,
      observers: [
        core.CoreRouteObserver(),
        if (di.has<AnalyticsClient>())
          AnalyticsRouteObserver(
            client: di.get<AnalyticsClient>(),
            logger: di.get<core.Logger>(),
          ),
      ],
      errorBuilder: (context, state) => ErrorScreen(
        title: strings.errors.page_not_found,
        message: strings.errors.page_not_found_description,
        onGoHome: () => context.go(core.CoreRoutes.root),
        error: state.uri.toString(),
      ),
      routes: [
        GoRoute(
          path: core.CoreRoutes.root,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: core.CoreRoutes.home,
          redirect: (context, state) => DashboardRouter.home,
        ),
        DashboardRouter.createShellRoute(
          // Demo tabs open before Firebase is configured; configured apps
          // require sign-in. Never allow unconfigured access to real data.
          redirect: auth.authRedirect(allowUnconfigured: true),
          onSignOut: signOut,
        ),
        ...auth.AuthRouter(
          onSignedIn: _onAuthenticated,
          onSignedUp: _onAuthenticated,
        ).routes,
        ...developer.DeveloperRouter().routes,
        GoRoute(
          path: core.CoreRoutes.error,
          builder: (context, state) => ErrorScreen(
            title:
                state.uri.queryParameters[core.Keys.title] ??
                strings.generic.error,
            message:
                state.uri.queryParameters[core.Keys.message] ??
                strings.errors.unexpected_error,
            error: state.uri.queryParameters[core.Keys.error],
            onGoHome: () => context.go(core.CoreRoutes.root),
          ),
        ),
      ],
    );

    return router;
  }

  /// Signs out after removing this device's push token, so a signed-out
  /// device stops receiving the previous user's notifications. A backend
  /// failure is logged and never blocks sign-out.
  @visibleForTesting
  static Future<void> signOut(BuildContext context) async {
    if (di.has<NotificationClient>()) {
      try {
        await di.get<NotificationClient>().unregisterDevice();
      } catch (error, stackTrace) {
        di.get<core.Logger>().e(
          'Could not unregister the device token',
          error,
          stackTrace,
        );
      }
    }
    if (context.mounted) await auth.signOut(context);
  }

  /// Where a user lands once sign-in or sign-up succeeds.
  ///
  /// Load the profile / entitlements you need here before routing on.
  static Future<void> _onAuthenticated(BuildContext context) async {
    await AnalyticsHelper.logEvent(AnalyticsEvents.user.authenticatedRedirect);
    if (context.mounted) {
      context.go(DashboardRouter.home);
    }
  }
}
