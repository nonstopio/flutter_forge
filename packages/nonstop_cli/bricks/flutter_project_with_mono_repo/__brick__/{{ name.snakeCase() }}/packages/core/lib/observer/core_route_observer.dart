import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:flutter/material.dart';

class CoreRouteObserver extends NavigatorObserver {
  CoreRouteObserver({Logger? logger}) : _logger = logger ?? di.get<Logger>();

  final Logger _logger;

  void _log(String action, Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null) return;
    _logger.d('$action route named $name');
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _log('push', route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _log('pop', route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _log('remove', route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _log('replace', newRoute);
  }
}
