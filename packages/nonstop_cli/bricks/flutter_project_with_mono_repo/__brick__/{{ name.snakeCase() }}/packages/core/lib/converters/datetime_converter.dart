import 'package:intl/intl.dart';

final class DateTimeConverter {
  const DateTimeConverter();

  /// Converts a [DateTime] to a [String] in the format 'MMMM d, y'.
  /// If the [date] is null, it returns an empty string.
  ///
  /// Example:
  /// ```dart
  /// DateTime date = DateTime.now();
  /// String formattedDate = DateTimeConverter.toViewFormat(date);
  /// print(formattedDate); // Output: 'October 1, 2023'
  /// ```
  static String toViewFormat(DateTime? date) {
    if (date == null) return '';
    final dateFormate = DateFormat('MMMM d, y');

    return dateFormate.format(date.toLocal());
  }

  static String toViewFormatWithTime(DateTime? date) {
    if (date == null) return '';
    final dateFormate = DateFormat('MMMM d, y, h:mm a');

    return dateFormate.format(date);
  }

  static String toViewFormatTime(DateTime? date) {
    if (date == null) return '';
    final dateFormate = DateFormat('h:mm:ss a');

    return dateFormate.format(date);
  }
}
