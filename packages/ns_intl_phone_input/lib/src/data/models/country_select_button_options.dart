import 'package:flutter/material.dart';

class CountrySelectOption {
  final bool showCode;
  final TextStyle countryIsoCodeTextStyle;
  final TextStyle countryDialCodeTextStyle;
  final TextStyle defaultTextStyle;
  final String defaultText;

  const CountrySelectOption({
    this.showCode = false,
    this.countryIsoCodeTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    this.countryDialCodeTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    this.defaultTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    this.defaultText = '🏳️',
  });
}
