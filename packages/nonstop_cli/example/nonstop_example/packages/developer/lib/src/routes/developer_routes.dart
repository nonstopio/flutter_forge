import 'package:core/core.dart' as core;
import 'package:developer/src/screens/index.dart';
import 'package:di/di.dart';
import 'package:feature_flags/feature_flags.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeveloperRoutes {
  static const String developer = '/developer';
}

/// Feature flag keys owned by the developer tools.
abstract final class DeveloperFlags {
  /// Gates both the entry gesture and the route itself.
  static const String screenEnabled = 'developer_screen_enabled';
}

class DeveloperRouter implements core.CoreRouter {
  final core.Logger _logger = di.get<core.Logger>();

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: DeveloperRoutes.developer,
      name: 'developer-screen',
      redirect: (context, state) async {
        // Hiding the entry gesture does not protect a directly entered route.
        if (!di.has<FeatureFlag>()) return core.CoreRoutes.root;
        try {
          return await di.get<FeatureFlag>().isEnabled(
                DeveloperFlags.screenEnabled,
              )
              ? null
              : core.CoreRoutes.root;
        } catch (_) {
          return core.CoreRoutes.root;
        }
      },
      builder: (BuildContext context, GoRouterState state) {
        return DeveloperScreen(logger: _logger);
      },
    ),
  ];
}
