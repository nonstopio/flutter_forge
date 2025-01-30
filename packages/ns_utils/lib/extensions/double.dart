extension DoubleExtensions on double {
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
  double get doubled => this * 2;

  /// Return this number time three
  ///
  double get tripled => this * 3;

  /// Convert this integer into boolean.
  ///
  /// Returns `true` if this integer is greater than *0*.
  bool get asBool => this > 0;

  /// returns null if 0
  ///
  double? get asNullIfZero => this == 0 ? null : this;

  /// Returns true if this is null or 0
  ///
  bool get isNullOrZero => asNullIfZero == null;
}
