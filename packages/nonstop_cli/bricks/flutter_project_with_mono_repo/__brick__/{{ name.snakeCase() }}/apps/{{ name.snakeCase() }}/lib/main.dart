import 'package:flutter/material.dart';
{{#notifications}}import 'package:core/core.dart';
{{/notifications}}
import 'package:di/di.dart';
import 'package:go_router/go_router.dart';
{{#notifications}}import 'package:notifications/notifications.dart';
{{/notifications}}
import 'package:{{name.snakeCase()}}/app.dart';
import 'package:{{name.snakeCase()}}/bootstrap.dart' as bootstrap;
{{#notifications}}import 'package:{{name.snakeCase()}}/notification_lifecycle.dart';
{{/notifications}}
import 'package:{{name.snakeCase()}}/router/router.dart';

Future<void> main() => startApp();

/// Composition root. Queue cold-start notification routes until routing exists.
Future<void> startApp({
  Future<void> Function(void Function(String) onOpenRoute)? initialize,
  void Function(Widget) mount = runApp,
}) async {
  GoRouter? activeRouter;
  String? pendingRoute;
  void onOpenRoute(String route) {
    if (activeRouter == null) {
      pendingRoute = route;
    } else {
      activeRouter.go(route);
    }
  }

  if (initialize == null) {
    await bootstrap.init(onOpenRoute: onOpenRoute);
  } else {
    await initialize(onOpenRoute);
  }
  final router = AppRouter.createRouter(initialLocation: pendingRoute);
  activeRouter = router;
  di.register<GoRouter>(router, dispose: (router) => router.dispose());
  mount(
{{#notifications}}    NotificationLifecycle(
      logger: di.get<Logger>(),
      client: di.has<NotificationClient>()
          ? di.get<NotificationClient>()
          : null,
      child: App(router: router),
    ),{{/notifications}}{{^notifications}}    App(router: router),{{/notifications}}
  );
}
