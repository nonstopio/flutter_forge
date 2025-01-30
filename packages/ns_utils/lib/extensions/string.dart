import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants.dart';
import '../src.dart';

extension StringExtensions on String {
  ///JSON String to Map using[json.decode]
  ///
  Map toMap() {
    try {
      if (isEmpty) return defaultMap;
      return json.decode(this);
    } on Exception catch (e, s) {
      errorLogsNS("Error in toMap\n\n *$this* ", e, s);
    }
    return defaultMap;
  }

  ///JSON String to List using[json.decode]
  ///
  List toList() {
    try {
      return json.decode(this);
    } on Exception catch (e, s) {
      errorLogsNS("Error in toList\n\n *$this* ", e, s);
    }
    return defaultList;
  }

  /// Returns true if s is neither null,
  /// empty nor is solely made of whitespace characters.
  ///
  bool get isNotBlank => trim().isNotEmpty;

  /// Parses the string as an int or 0 [defaultInt].
  ///
  int get toINT => toInt(this);

  /// Parses the string as an int or 0 [defaultDouble].
  ///
  double get toDOUBLE => toDouble(this);

  /// If string is not blank[isNotBlank] append the string with a ', '
  ///
  String get addSpaceAndCommaIfNotEmpty => isNotBlank ? '$this, ' : '';

  /// Convert this string into boolean.
  ///
  /// Returns `true` if this string is any of these
  /// values: `"true"`, `"yes"`, `"1"`,
  /// or if the string is a number and greater than 0, `false`
  /// if less than 1. This is also case insensitive.
  ///
  bool get asBool {
    String s = trim().toLowerCase();
    num n;
    try {
      n = num.parse(s);
    } on Exception catch (e, s) {
      n = -1;
      errorLogsNS("Error in toList\n\n *$this* ", e, s);
    }
    return s == 'true' || s == 'yes' || n > 0;
  }

  /// Parse string to [DateTime] or [Null]
  ///
  DateTime? toDateTime({dynamic context}) {
    String value = this;
    DateTime? tempDateTime;
    if (value.isEmpty) {
      errorLogsNS('toDateTime invalid $value context:$context');
      return tempDateTime;
    }
    if (value.startsWith('-00')) {
      errorLogsNS('toDateTime invalid $value context:$context');
      value = value.replaceFirst('-00', '');
    }
    try {
      tempDateTime = DateTime.parse(value);
    } on Exception catch (e, s) {
      errorLogsNS("toDateTime $context  $value ", e, s);
    }
    return tempDateTime;
  }

  /// Parse string to [Color]
  ///
  Color toColor() {
    Color color =
        Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    try {
      String hexColor = replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "0xFF$hexColor";
      }
      if (hexColor.length == 10) {
        color = Color(int.parse(hexColor));
      }
    } on Exception catch (e, s) {
      errorLogsNS("toColor", e, s);
    }
    return color;
  }

  ///Add prefix if not empty else return empty string
  ///
  String addPrefixIfNotEmpty(String prefix) {
    if (isEmpty) {
      return '';
    }
    return '$prefix$this';
  }

  ///Add prefix if not empty else return empty string
  ///
  String get showDashIfEmpty => isEmpty ? '-' : this;

  /// this will give last n characters of string
  String lastNChars({int n = 1}) {
    if (n > length || n < 1) return this;

    return substring(length - n);
  }

  ///this will give first n characters of string
  String firstNChars({int n = 1}) {
    if (n > length || n < 1) return this;
    return substring(0, n);
  }

  /// Truncates a long `String` in the middle while retaining the beginning and the end.
  ///
  /// Example :
  ///   'Hello World'.truncateMiddle(3) // 'Hel...rld'
  ///
  String truncateMiddle({int maxChars = 3, String truncateKey = '...'}) {
    if (isEmptyOrNull || maxChars < 1) {
      return this;
    }

    if ((maxChars * 2) >= length) {
      return this;
    }

    return '${firstNChars(n: maxChars)}$truncateKey${lastNChars(n: maxChars)}';
  }
}

extension StringNullExtensions on String? {
  /// Return a bool if the string is null or empty
  ///
  bool get isEmptyOrNull {
    if (this == null || this == '') {
      return true;
    }
    return false;
  }

  /// Returns true if s is neither null,
  /// empty nor is solely made of whitespace characters.
  ///
  bool get isNotBlank {
    if (isEmptyOrNull) return false;
    return !this!.trim().isEmptyOrNull;
  }
}
