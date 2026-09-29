import 'package:intl/intl.dart';

String _minutesAgo(int minutes) => '${minutes}m ago';
String _hoursAgo(int hours) => '${hours}h ago';
String _daysAgo(int days) => '${days}d ago';

extension DateTimeFormatting on DateTime {
  /// Formats this time relative to [now]: `Just now`, `5m ago`, `3h ago`,
  /// `Yesterday`, `2d ago`, then a short date in the default intl locale.
  ///
  /// Labels default to English; pass localized ones (utils stays free of the
  /// localization package).
  String formatRelative({
    DateTime? now,
    String justNow = 'Just now',
    String yesterday = 'Yesterday',
    String Function(int minutes) minutesAgo = _minutesAgo,
    String Function(int hours) hoursAgo = _hoursAgo,
    String Function(int days) daysAgo = _daysAgo,
  }) {
    final difference = (now ?? DateTime.now()).difference(this);

    if (difference.inMinutes < 1) {
      return justNow;
    } else if (difference.inMinutes < 60) {
      return minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return hoursAgo(difference.inHours);
    } else if (difference.inDays == 1) {
      return yesterday;
    } else if (difference.inDays < 7) {
      return daysAgo(difference.inDays);
    } else {
      return DateFormat.yMd().format(this);
    }
  }
}
