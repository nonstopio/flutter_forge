class CrashlyticsConfig {
  const CrashlyticsConfig({
    this.enableInDebugMode = false,
    this.installGlobalErrorHandlers = true,
    this.enableCustomLogs = true,
    this.logBufferSize = 100,
    this.enableUserMetadata = true,
    this.customKeys = const {},
  });

  /// Enable crashlytics in debug mode (typically disabled for development)
  final bool enableInDebugMode;

  /// Install `FlutterError.onError` and `PlatformDispatcher.onError` handlers
  /// that report uncaught errors as fatal (previous handlers still run).
  final bool installGlobalErrorHandlers;

  /// Enable custom logging
  final bool enableCustomLogs;

  /// Maximum number of log messages to buffer
  final int logBufferSize;

  /// Enable user metadata collection
  final bool enableUserMetadata;

  /// Default custom keys to set on initialization
  final Map<String, dynamic> customKeys;

  CrashlyticsConfig copyWith({
    bool? enableInDebugMode,
    bool? installGlobalErrorHandlers,
    bool? enableCustomLogs,
    int? logBufferSize,
    bool? enableUserMetadata,
    Map<String, dynamic>? customKeys,
  }) {
    return CrashlyticsConfig(
      enableInDebugMode: enableInDebugMode ?? this.enableInDebugMode,
      installGlobalErrorHandlers:
          installGlobalErrorHandlers ?? this.installGlobalErrorHandlers,
      enableCustomLogs: enableCustomLogs ?? this.enableCustomLogs,
      logBufferSize: logBufferSize ?? this.logBufferSize,
      enableUserMetadata: enableUserMetadata ?? this.enableUserMetadata,
      customKeys: customKeys ?? this.customKeys,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enableInDebugMode': enableInDebugMode,
      'installGlobalErrorHandlers': installGlobalErrorHandlers,
      'enableCustomLogs': enableCustomLogs,
      'logBufferSize': logBufferSize,
      'enableUserMetadata': enableUserMetadata,
      'customKeys': customKeys,
    };
  }

  @override
  String toString() {
    return 'CrashlyticsConfig{enableInDebugMode: $enableInDebugMode, installGlobalErrorHandlers: $installGlobalErrorHandlers, enableCustomLogs: $enableCustomLogs, logBufferSize: $logBufferSize, enableUserMetadata: $enableUserMetadata, customKeys: $customKeys}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrashlyticsConfig &&
          runtimeType == other.runtimeType &&
          enableInDebugMode == other.enableInDebugMode &&
          installGlobalErrorHandlers == other.installGlobalErrorHandlers &&
          enableCustomLogs == other.enableCustomLogs &&
          logBufferSize == other.logBufferSize &&
          enableUserMetadata == other.enableUserMetadata &&
          _mapEquals(customKeys, other.customKeys);

  @override
  int get hashCode =>
      enableInDebugMode.hashCode ^
      installGlobalErrorHandlers.hashCode ^
      enableCustomLogs.hashCode ^
      logBufferSize.hashCode ^
      enableUserMetadata.hashCode ^
      Object.hashAllUnordered(
        customKeys.entries.map((entry) => Object.hash(entry.key, entry.value)),
      );

  bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

class DefaultCrashlyticsConfig extends CrashlyticsConfig {
  const DefaultCrashlyticsConfig({
    super.enableInDebugMode = false,
    super.installGlobalErrorHandlers = true,
    super.enableCustomLogs = true,
    super.logBufferSize = 100,
    super.enableUserMetadata = true,
    super.customKeys = const {},
  });
}
