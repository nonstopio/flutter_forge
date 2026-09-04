import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:flutter/material.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';
import 'package:talker_flutter/talker_flutter.dart';

class CoreRouteObserver extends NavigatorObserver {
  CoreRouteObserver() : _observer = di.get<Logger>().logger as Talker;

  final Talker _observer;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == null) {
      return;
    }
    _observer.logCustom(TalkerRouteLog(route: route, type: RouteLogType.push));
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (route.settings.name == null) {
      return;
    }
    _observer.logCustom(TalkerRouteLog(route: route, type: RouteLogType.pop));
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (route.settings.name == null) {
      return;
    }
    _observer.logCustom(
      TalkerRouteLog(route: route, type: RouteLogType.remove),
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute?.settings.name == null) {
      return;
    }
    _observer.logCustom(
      TalkerRouteLog(route: newRoute!, type: RouteLogType.replace),
    );
  }
}

enum RouteLogType { push, pop, remove, replace }

class TalkerRouteLog extends TalkerLog {
  TalkerRouteLog({required Route route, required RouteLogType type})
    : super(_createMessage(route, type));

  @override
  AnsiPen get pen => AnsiPen()..xterm(135);

  @override
  String get key => TalkerLogType.route.key;

  static String _createMessage(Route<dynamic> route, RouteLogType type) {
    final buffer = StringBuffer();
    buffer.write(type.name);
    buffer.write(' route named ');
    buffer.write(route.settings.name ?? 'null');

    final args = route.settings.arguments;
    if (args != null) {
      buffer.write('\nArguments: $args');
    }

    final historyObserver = NavigationHistoryObserver();
    final history = historyObserver.history;
    if (history.isEmpty) {
      buffer.write('\nHistory: na');
    } else {
      final historyAsString = historyObserver.history
          .map((r) => r.settings.name)
          .join(' -> ');
      buffer.write('\nHistory: $historyAsString');
    }

    return buffer.toString();
  }
}
