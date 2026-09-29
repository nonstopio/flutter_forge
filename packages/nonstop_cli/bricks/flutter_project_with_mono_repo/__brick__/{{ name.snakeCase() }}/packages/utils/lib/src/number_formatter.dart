import 'package:intl/intl.dart';

/// Extension for formatting decimal numbers with clean, professional display
extension DoubleFormatting on double {
  /// Formats decimal values, removing unnecessary .0 for whole numbers
  String format({int decimalPlaces = 1}) {
    final formatter = NumberFormat('#.${'#' * decimalPlaces}');
    return formatter.format(this);
  }

  /// Formats score values with clean decimal handling
  String asScore() => format(decimalPlaces: 1);
}

/// Extension for formatting any numeric value
extension NumFormatting on num {
  /// Formats large numbers with the default locale's compact suffixes.
  String compact() => NumberFormat.compact().format(this);
}

/// Extension for formatting time duration from seconds
extension IntTimeFormatting on int {
  /// Formats seconds as `1 sec`, `1 min 1 sec` or `1 hr 1 min`.
  ///
  /// Unit labels default to English abbreviations; pass localized ones.
  String asTime({String sec = 'sec', String min = 'min', String hr = 'hr'}) {
    if (this < 60) {
      return '$this $sec';
    } else if (this < 3600) {
      final minutes = this ~/ 60;
      final remainingSeconds = this % 60;
      if (remainingSeconds == 0) {
        return '$minutes $min';
      }
      return '$minutes $min $remainingSeconds $sec';
    } else {
      final hours = this ~/ 3600;
      final remainingMinutes = (this % 3600) ~/ 60;
      if (remainingMinutes == 0) {
        return '$hours $hr';
      }
      return '$hours $hr $remainingMinutes $min';
    }
  }
}
