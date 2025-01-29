import 'package:flutter/material.dart';

class SizeGap extends StatelessWidget {
  final double? size;

  const SizeGap({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(size ?? 5.0));
  }
}
