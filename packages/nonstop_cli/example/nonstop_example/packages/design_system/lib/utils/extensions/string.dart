/// String extensions for common utility operations
extension StringExtensions on String? {
  /// Returns true if the string is not null and not empty
  ///
  /// Example:
  /// ```dart
  /// String? text = "Hello";
  /// print(text.isNotNullAndNotEmpty); // true
  ///
  /// String? emptyText = "";
  /// print(emptyText.isNotNullAndNotEmpty); // false
  ///
  /// String? nullText = null;
  /// print(nullText.isNotNullAndNotEmpty); // false
  /// ```
  bool get isNotNullAndNotEmpty {
    return this != null && this!.isNotEmpty;
  }

  /// Returns an empty string if the string is null, otherwise returns the string itself
  ///
  /// Example:
  /// ```dart
  /// String? text = "Hello";
  /// print(text.asEmptyIfNull); // "Hello"
  ///
  /// String? nullText = null;
  /// print(nullText.asEmptyIfNull); // ""
  /// ```
  String get asEmptyIfNull {
    return this ?? '';
  }
}
