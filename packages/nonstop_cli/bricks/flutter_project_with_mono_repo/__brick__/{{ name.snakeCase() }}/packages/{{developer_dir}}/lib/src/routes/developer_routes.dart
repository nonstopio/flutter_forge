import 'package:core/core.dart' as core;
import 'package:developer/src/screens/index.dart';
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
      builder: (BuildContext context, GoRouterState state) {
        return const DeveloperScreen();
      },
    ),
  ];
}
