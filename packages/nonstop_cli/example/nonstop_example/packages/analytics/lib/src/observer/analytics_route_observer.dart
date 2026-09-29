import 'dart:async';
import 'package:analytics/src/client/analytics_client.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Tracks named pages through the analytics abstraction, including async errors.
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver({
    required AnalyticsClient client,
    required Logger logger,
  }) : _client = client,
       _logger = logger;

  final AnalyticsClient _client;
  final Logger _logger;

  Future<void> _track(Route<dynamic>? route) async {
    if (route is! PageRoute || route.settings.name == null) return;
    try {
      await _client.logScreenView(screenName: route.settings.name!);
    } catch (error, stack) {
      _logger.e('Failed to track screen navigation', error, stack);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    unawaited(_track(route));
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    unawaited(_track(previousRoute));
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    unawaited(_track(newRoute));
  }
}
