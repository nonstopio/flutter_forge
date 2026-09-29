import 'package:flutter/material.dart';
import 'package:core/core.dart';

import 'package:di/di.dart';
import 'package:go_router/go_router.dart';
import 'package:notifications/notifications.dart';

import 'package:nonstop_example/app.dart';
import 'package:nonstop_example/bootstrap.dart' as bootstrap;
import 'package:nonstop_example/notification_lifecycle.dart';

import 'package:nonstop_example/router/router.dart';

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
    NotificationLifecycle(
      logger: di.get<Logger>(),
      client: di.has<NotificationClient>()
          ? di.get<NotificationClient>()
          : null,
      child: App(router: router),
    ),
  );
}
