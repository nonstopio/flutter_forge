import 'package:flutter/cupertino.dart';

/// A Custom PageRoute with transition from bottom to top
/// where it can be transparent [opaque]=false depending upon the
/// background color of child widget.
///

const int _transitionDuration = 700;

class TransparentRoute<T> extends PageRoute<T> {
  TransparentRoute({
    required this.builder,
    RouteSettings? settings,
  }) : super(settings: settings, fullscreenDialog: true);

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration =>
      const Duration(milliseconds: _transitionDuration);

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget result = builder(context);
    return CupertinoFullscreenDialogTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: true,
      child: result,
    );
  }
}
