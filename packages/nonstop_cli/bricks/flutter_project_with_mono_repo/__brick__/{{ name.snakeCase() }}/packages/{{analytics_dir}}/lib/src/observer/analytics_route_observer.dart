import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

/// Analytics route observer that uses Firebase Analytics Observer internally
/// while providing additional logging and error handling capabilities
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver()
    : _logger = di.get<Logger>(),
      _firebaseObserver = FirebaseAnalyticsObserver(
        analytics: FirebaseAnalytics.instance,
      );

  final Logger _logger;
  final FirebaseAnalyticsObserver _firebaseObserver;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);

    try {
      // Delegate to Firebase Analytics Observer for native screen tracking
      _firebaseObserver.didPush(route, previousRoute);
    } catch (e, s) {
      _logger.e('Failed to track screen push event', e, s);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);

    try {
      // Delegate to Firebase Analytics Observer
      _firebaseObserver.didPop(route, previousRoute);
    } catch (e, s) {
      _logger.e('Failed to track screen pop event', e, s);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    try {
      // Delegate to Firebase Analytics Observer
      _firebaseObserver.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    } catch (e, s) {
      _logger.e('Failed to track screen replace event', e, s);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);

    try {
      // Delegate to Firebase Analytics Observer
      _firebaseObserver.didRemove(route, previousRoute);
    } catch (e, s) {
      _logger.e('Failed to track screen remove event', e, s);
    }
  }
}
