class CrashReport {
  const CrashReport({
    required this.exception,
    this.stackTrace,
    this.fatal = false,
    this.timestamp,
    this.customKeys = const {},
    this.logs = const [],
    this.userMetadata,
  });

  final dynamic exception;
  final StackTrace? stackTrace;
  final bool fatal;
  final DateTime? timestamp;
  final Map<String, dynamic> customKeys;
  final List<String> logs;
  final Map<String, dynamic>? userMetadata;

  CrashReport copyWith({
    dynamic exception,
    StackTrace? stackTrace,
    bool? fatal,
    DateTime? timestamp,
    Map<String, dynamic>? customKeys,
    List<String>? logs,
    Map<String, dynamic>? userMetadata,
  }) {
    return CrashReport(
      exception: exception ?? this.exception,
      stackTrace: stackTrace ?? this.stackTrace,
      fatal: fatal ?? this.fatal,
      timestamp: timestamp ?? this.timestamp,
      customKeys: customKeys ?? this.customKeys,
      logs: logs ?? this.logs,
      userMetadata: userMetadata ?? this.userMetadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exception': exception.toString(),
      'stackTrace': stackTrace?.toString(),
      'fatal': fatal,
      'timestamp': timestamp?.toIso8601String(),
      'customKeys': customKeys,
      'logs': logs,
      'userMetadata': userMetadata,
    };
  }

  @override
  String toString() {
    return 'CrashReport{exception: $exception, fatal: $fatal, timestamp: $timestamp}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrashReport &&
          runtimeType == other.runtimeType &&
          exception.toString() == other.exception.toString() &&
          stackTrace.toString() == other.stackTrace.toString() &&
          fatal == other.fatal &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      exception.hashCode ^
      stackTrace.hashCode ^
      fatal.hashCode ^
      timestamp.hashCode;
}
