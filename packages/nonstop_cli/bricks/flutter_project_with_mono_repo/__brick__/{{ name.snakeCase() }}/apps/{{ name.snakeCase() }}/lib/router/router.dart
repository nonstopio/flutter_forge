{{#analytics}}import 'package:analytics/analytics.dart';
{{/analytics}}{{#auth}}import 'package:auth/auth.dart' as auth;
{{/auth}}import 'package:core/core.dart' as core;
{{#dashboard}}import 'package:dashboard/dashboard.dart';
{{/dashboard}}import 'package:design_system/design_system.dart';
{{#developer}}import 'package:developer/developer.dart' as developer;
{{/developer}}import 'package:di/di.dart';
{{#analytics}}import 'package:firebase_core/firebase_core.dart';
{{/analytics}}import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';
import 'package:{{name.snakeCase()}}/ui/splash_screen.dart';

/// The app's single [GoRouter].
///
/// Feature packages expose their own `routes` list and are spliced in here, so
/// adding a feature is one import plus one spread - no route table to merge.
class AppRouter {
  const AppRouter._();

  static final GoRouter _router = createRouter();

  static RouterDelegate<Object> get routerDelegate => _router.routerDelegate;

  static RouteInformationParser<Object> get routeInformationParser =>
      _router.routeInformationParser;

  static RouteInformationProvider? get routeInformationProvider =>
      _router.routeInformationProvider;

  static GoRouter createRouter() {
    final router = GoRouter(
      debugLogDiagnostics: kDebugMode,
      initialLocation: core.CoreRoutes.root,
      observers: [
        NavigationHistoryObserver(),
        core.CoreRouteObserver(),
{{#analytics}}        if (Firebase.apps.isNotEmpty) AnalyticsRouteObserver(),
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
        DashboardRouter.createShellRoute(),
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

    di.register<GoRouter>(router);
    return router;
  }
{{#auth}}
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