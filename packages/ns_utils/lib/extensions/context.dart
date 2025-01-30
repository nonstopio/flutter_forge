import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../page_route/tansparent_route.dart';
import '../src.dart';

extension ContextExtensions on BuildContext {
  // Returns the MediaQuery
  MediaQueryData get mq => MediaQuery.of(this);

  /// Returns if Orientation is landscape
  bool get isLandscape => mq.orientation == Orientation.landscape;

  /// Returns same as MediaQuery.of(context).size
  ///
  Size get sizeX => mq.size;

  /// Returns same as MediaQuery.of(context).size.width
  ///
  double get width => sizeX.width;

  /// Returns same as MediaQuery.of(context).height
  ///
  double get height => sizeX.height;

  /// Requests the primary focus for this node, or for a supplied [node], which
  /// will also give focus to its [ancestors].
  ///
  void setFocus({FocusNode? focusNode}) {
    FocusScope.of(this).requestFocus(focusNode ?? FocusNode());
  }

  /// Push the given route onto the navigator.
  ///
  Future<T?> push<T>(
    Widget screen, {
    bool transparent = false,
    bool isCupertino = false,
  }) {
    final RouteSettings settings = RouteSettings(
      name: screen.toString(),
    );
    if (transparent) {
      return Navigator.of(this).push<T>(
        TransparentRoute<T>(
          builder: (_) => screen,
          settings: settings,
        ),
      );
    } else {
      if (isCupertino) {
        return Navigator.of(this).push<T>(
          CupertinoPageRoute<T>(
            builder: (_) => screen,
            settings: settings,
          ),
        );
      }
      return Navigator.of(this).push<T>(
        MaterialPageRoute<T>(
          builder: (_) => screen,
          settings: settings,
        ),
      );
    }
  }

  /// Replace the current route of the navigator by pushing the given route and
  /// then disposing the previous route.
  ///
  Future<void> replace(
    Widget screen, {
    bool transparent = false,
    bool isCupertino = false,
  }) {
    RouteSettings settings = RouteSettings(
      name: screen.toString(),
    );
    if (transparent) {
      return Navigator.of(this).pushReplacement(
        TransparentRoute(
          builder: (_) => screen,
          settings: settings,
        ),
      );
    } else {
      if (isCupertino) {
        return Navigator.of(this).pushReplacement(
          CupertinoPageRoute(
            builder: (_) => screen,
            settings: settings,
          ),
        );
      }
      return Navigator.of(this).pushReplacement(
        MaterialPageRoute(
          builder: (_) => screen,
          settings: settings,
        ),
      );
    }
  }

  /// Replace the all route of the navigator by pushing the given route and
  /// then disposing all the previous route.
  ///
  void makeFirst(
    Widget screen, {
    bool transparent = false,
    bool isCupertino = false,
  }) {
    popToFirst();
    replace(
      screen,
      transparent: transparent,
      isCupertino: isCupertino,
    );
  }

  /// Replace the all route of the navigator by pushing the given route and
  /// then disposing all the previous route.
  ///
  void pushAfterFirst(
    Widget screen, {
    bool transparent = false,
    bool isCupertino = false,
  }) {
    popToFirst();
    push(
      screen,
      transparent: transparent,
      isCupertino: isCupertino,
    );
  }

  /// Pop the top-most route off the navigator.
  ///
  void pop<T>({T? data}) {
    try {
      Navigator.of(this).pop(data);
    } on Exception catch (e, s) {
      errorLogsNS('pop failed', e, s);
    }
  }

  /// Pops the top-most route off the navigator till the first route.
  ///
  void popToFirst() {
    Navigator.of(this).popUntil((predicate) {
      return predicate.isFirst;
    });
  }

  /// Consults the current route's [Route.willPop] method, and acts accordingly,
  /// potentially popping the route as a result; returns whether the pop request
  /// should be considered handled.
  ///
  void maybePop() {
    Navigator.of(this).maybePop();
  }
}
