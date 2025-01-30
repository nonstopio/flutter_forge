class CustomException implements Exception {
  CustomException({
    required this.code,
    this.message,
    this.details,
  });

  /// An error code.
  final String code;

  /// A human-readable error message, possibly null.
  final String? message;

  /// Error details, possibly null.
  final dynamic details;

  @override
  String toString() => 'NSFException($code, $message, $details)';
}
