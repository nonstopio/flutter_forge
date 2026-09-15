import 'package:core/core.dart' as core;
import 'package:developer/src/screens/index.dart';
import 'package:di/di.dart';
import 'package:feature_flags/feature_flags.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeveloperRoutes {
  static const String developer = '/developer';
}

class DeveloperRouter extends core.CoreRouter {
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
                'developer_screen_enabled',
              )
              ? null
              : core.CoreRoutes.root;
        } catch (_) {
          return core.CoreRoutes.root;
        }
      },
      builder: (BuildContext context, GoRouterState state) {
        return const DeveloperScreen();
      },
    ),
  ];
}
