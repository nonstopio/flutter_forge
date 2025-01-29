import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// [PositionOnScreen] is an enum that represents the position of the offline
/// widget.
///
enum PositionOnScreen {
  TOP,
  BOTTOM,
}

/// [ConnectivityScreenWrapper] is a StatelessWidget that wraps a widget and
/// displays an offline widget if the connectivity status is not CONNECTED.
///
class ConnectivityScreenWrapper extends StatelessWidget {
  /// The [child] contained by the ConnectivityScreenWrapper.
  final Widget? child;

  /// The decoration to paint behind the [child].
  final Decoration? decoration;

  /// The color to paint behind the [child].
  final Color? color;

  /// Disconnected message.
  final String? message;

  /// If non-null, the style to use for this text.
  final TextStyle? messageStyle;

  /// widget height.
  final double? height;

  /// How to align the offline widget.
  final PositionOnScreen positionOnScreen;

  /// How to align the offline widget.
  final Duration? duration;

  /// Disable the user interaction with child widget
  final bool disableInteraction;

  /// Disable the user interaction with child widget
  final Widget? disableWidget;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  const ConnectivityScreenWrapper({
    super.key,
    this.child,
    this.color,
    this.decoration,
    this.message,
    this.messageStyle,
    this.height,
    this.textAlign,
    this.duration,
    this.positionOnScreen = PositionOnScreen.BOTTOM,
    this.disableInteraction = false,
    this.disableWidget,
  }) : assert(
            color == null || decoration == null,
            'Cannot provide both a color and a decoration\n'
            'The color argument is just a shorthand for "decoration: new BoxDecoration(color: color)".');

  @override
  Widget build(BuildContext context) {
    final bool isOffline =
        Provider.of<ConnectivityStatus>(context).isDisconnected;

    double height = this.height ?? defaultHeight;

    final Widget offlineWidget = AnimatedPositioned(
      top: positionOnScreen.top(height, isOffline),
      bottom: positionOnScreen.bottom(height, isOffline),
      duration: duration ?? const Duration(milliseconds: 300),
      child: AnimatedContainer(
        height: height,
        width: MediaQuery.of(context).size.width,
        decoration:
            decoration ?? BoxDecoration(color: color ?? Colors.red.shade500),
        duration: duration ?? const Duration(milliseconds: 300),
        child: Center(
          child: Text(
            message ?? disconnectedMessage,
            style: messageStyle ?? defaultMessageStyle,
            textAlign: textAlign,
          ),
        ),
      ),
    );

    return AbsorbPointer(
      absorbing: (disableInteraction && isOffline),
      child: Stack(
        children: [
          if (child != null) child!,
          if (disableInteraction && isOffline)
            if (disableWidget != null) disableWidget!,
          offlineWidget,
        ],
      ),
    );
  }
}
