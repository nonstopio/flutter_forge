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

  /// Formats HRV values with smart decimal handling
  String asHrv() => format(decimalPlaces: 1);

  /// Formats sleep hours with smart decimal handling
  String asSleepHours() => format(decimalPlaces: 1);

  /// Formats respiratory rate with smart decimal handling
  String asRespiratoryRate() => format(decimalPlaces: 1);
}

/// Extension for formatting any numeric value
extension NumFormatting on num {
  /// Formats large numbers with K, M, B suffixes and smart decimal handling
  String compact() {
    final NumberFormat formatter = NumberFormat.compact(locale: 'en_US');
    return formatter.format(this);
  }

  /// Formats heart rate values (always whole numbers)
  String asHeartRate() => round().toString();
}

/// Extension for formatting time duration from seconds
extension IntTimeFormatting on int {
  /// Format time from seconds to 1 sec or 1min 1sec or 1hr 1min
  String asTime() {
    if (this < 60) {
      return '$this sec';
    } else if (this < 3600) {
      final minutes = this ~/ 60;
      final remainingSeconds = this % 60;
      if (remainingSeconds == 0) {
        return '$minutes min';
      }
      return '$minutes min $remainingSeconds sec';
    } else {
      final hours = this ~/ 3600;
      final remainingMinutes = (this % 3600) ~/ 60;
      if (remainingMinutes == 0) {
        return '$hours hr';
      }
      return '$hours hr $remainingMinutes min';
    }
  }
}

extension DateTimeFormatting on DateTime {
  String formatRelative() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '$day/$month/$year';
    }
  }
}
