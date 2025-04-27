import 'package:flutter/material.dart';

import '../../../ns_intl_phone_input.dart';

class FontTextWidget extends StatelessWidget {
  const FontTextWidget({
    super.key,
    required this.text,
    this.fontSize = 20,
  });

  final String text;

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        fontFamily: NsConstants.appleColorEmoji,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: NsConstants.appleColorEmoji,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
