import 'dart:convert';

import '../constants.dart';
import '../src.dart';

/// extension methods for List
///
extension ListExtensions on List {
  ///List to JSON using[json.encode]
  ///
  String toJson() {
    String data = defaultString;
    try {
      data = json.encode(this);
    } catch (e, s) {
      errorLogsNS("ERROR in getJson", e, s);
    }
    return data;
  }

  ///List to coma separated Value
  ///
  String toComaSeparatedValues() {
    try {
      return join(', ');
    } catch (e, s) {
      errorLogsNS("ERROR in toComaSeparatedValues", e, s);
      return defaultString;
    }
  }
}

extension ListStringExtension on List<String> {
  /// check if list contains value without considering case
  bool containWithoutCase(String value) {
    return any((element) => element.toLowerCase() == value.toLowerCase());
  }
}
