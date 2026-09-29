{{#analytics}}import 'package:analytics/analytics.dart';
{{/analytics}}{{#auth}}import 'package:auth/auth.dart' as auth;
{{/auth}}import 'package:core/core.dart' as core;
{{#dashboard}}import 'package:dashboard/dashboard.dart';
{{/dashboard}}import 'package:design_system/design_system.dart';
{{#developer}}import 'package:developer/developer.dart' as developer;
{{/developer}}{{#analytics}}import 'package:di/di.dart';
{{/analytics}}{{^analytics}}{{#auth}}{{#dashboard}}{{#notifications}}import 'package:di/di.dart';
{{/notifications}}{{/dashboard}}{{/auth}}{{/analytics}}
import 'package:flutter/foundation.dart';
{{#auth}}import 'package:flutter/material.dart';
{{/auth}}{{^auth}}{{^dashboard}}import 'package:flutter/material.dart';
{{/dashboard}}{{/auth}}import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
{{#auth}}{{#dashboard}}{{#notifications}}import 'package:notifications/notifications.dart';
{{/notifications}}{{/dashboard}}{{/auth}}import 'package:{{name.snakeCase()}}/ui/splash_screen.dart';

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
{{#analytics}}        if (di.has<AnalyticsClient>())
          AnalyticsRouteObserver(client: di.get<AnalyticsClient>(), logger: di.get<core.Logger>()),
{{/analytics}}      ],
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
{{#dashboard}}        GoRoute(
          path: core.CoreRoutes.home,
          redirect: (context, state) => DashboardRouter.home,
        ),
        DashboardRouter.createShellRoute({{#auth}}
          // Demo tabs open before Firebase is configured; configured apps
          // require sign-in. Never allow unconfigured access to real data.
          redirect: auth.authRedirect(allowUnconfigured: true),
          onSignOut: {{#notifications}}signOut{{/notifications}}{{^notifications}}auth.signOut{{/notifications}},
        {{/auth}}),
{{/dashboard}}{{^dashboard}}        GoRoute(
          path: core.CoreRoutes.home,
          builder: (context, state) => const _HomeScreen(),
        ),
{{/dashboard}}{{#auth}}        ...auth.AuthRouter(
          onSignedIn: _onAuthenticated,
          onSignedUp: _onAuthenticated,
        ).routes,
{{/auth}}{{#developer}}        ...developer.DeveloperRouter().routes,
{{/developer}}        GoRoute(
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
{{#auth}}{{#dashboard}}{{#notifications}}
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
{{/notifications}}{{/dashboard}}{{/auth}}{{#auth}}
  /// Where a user lands once sign-in or sign-up succeeds.
  ///
  /// Load the profile / entitlements you need here before routing on.
  static Future<void> _onAuthenticated(BuildContext context) async {
{{#analytics}}    await AnalyticsHelper.logEvent(AnalyticsEvents.user.authenticatedRedirect);
{{/analytics}}    if (context.mounted) {
      context.go({{#dashboard}}DashboardRouter.home{{/dashboard}}{{^dashboard}}core.CoreRoutes.home{{/dashboard}});
    }
  }
{{/auth}}}
{{^dashboard}}
/// Placeholder landing screen - replace it with your first feature.
class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(strings.app.name)),
      body: Center(
        child: {{#developer}}developer.OpenDevToolsWrapper(
          // Tap 5x to reach the developer tools.
          child: Text(strings.app.welcome_to_app),
        ){{/developer}}{{^developer}}Text(strings.app.welcome_to_app){{/developer}},
      ),
    );
  }
}
{{/dashboard}}
