import '../constants.dart';

extension IntExtensions on int {
  /// If value is NULL or not in [covered cases]
  /// return default value [defaultString]
  /// Else returns the mapped value
  ///
  String get dayPrefix {
    String prefix = defaultString;
    switch (this) {
      case -1:
        prefix = 'Yesterday';
        break;
      case 0:
        prefix = 'Today';
        break;
      case 1:
        prefix = 'Tomorrow';
        break;
    }
    return prefix;
  }

  /// Convert this integer into boolean.
  ///
  /// Returns `true` if this integer is greater than *0*.
  bool get asBool => this > 0;

  /// returns null if 0
  ///
  int? get asNullIfZero => this == 0 ? null : this;

  /// Returns true if this is null or 0
  ///
  bool get isNullOrZero => asNullIfZero == null;

  /// Returns tenth of the number
  ///
  double get tenth => this / 10;

  /// Returns fourth of the number
  ///
  double get fourth => this / 4;

  /// Returns third of the number
  ///
  double get third => this / 3;

  /// Returns half of the number
  ///
  double get half => this / 2;

  /// Return this number time two
  ///
  int get doubled => this * 2;

  /// Return this number time three
  ///
  int get tripled => this * 3;
}
