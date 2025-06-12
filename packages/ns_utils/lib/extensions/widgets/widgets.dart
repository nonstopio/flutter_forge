import 'package:flutter/material.dart';

extension WidgetsExtension on Widget {
  Widget withTooltip(
    String message, {
    required Decoration decoration,
    required bool preferBelow,
    required EdgeInsetsGeometry padding,
    required TextStyle textStyle,
    required Duration waitDuration,
    required EdgeInsetsGeometry margin,
  }) =>
      Tooltip(
        message: message,
        decoration: decoration,
        padding: padding,
        preferBelow: preferBelow,
        textStyle: textStyle,
        waitDuration: waitDuration,
        margin: margin,
        child: this,
      );
}
