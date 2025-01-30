import 'package:flutter/material.dart';

extension GestureDetectorExtensions on Widget {
  Widget onDoubleTap(GestureTapCallback function) => GestureDetector(
        onDoubleTap: function,
        child: this,
      );

  Widget onTap(GestureTapCallback function) => GestureDetector(
        onTap: function,
        child: this,
      );

  Widget onLongPress(GestureTapCallback function) => GestureDetector(
        onLongPress: function,
        child: this,
      );
}
