class CrashlyticsConfig {
  const CrashlyticsConfig({
    this.enableInDebugMode = false,
    this.enableAutomaticDataCollection = true,
    this.enableCustomLogs = true,
    this.logBufferSize = 100,
    this.enableUserMetadata = true,
    this.customKeys = const {},
  });

  /// Enable crashlytics in debug mode (typically disabled for development)
  final bool enableInDebugMode;

  /// Enable automatic data collection
  final bool enableAutomaticDataCollection;

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
    bool? enableAutomaticDataCollection,
    bool? enableCustomLogs,
    int? logBufferSize,
    bool? enableUserMetadata,
    Map<String, dynamic>? customKeys,
  }) {
    return CrashlyticsConfig(
      enableInDebugMode: enableInDebugMode ?? this.enableInDebugMode,
      enableAutomaticDataCollection:
          enableAutomaticDataCollection ?? this.enableAutomaticDataCollection,
      enableCustomLogs: enableCustomLogs ?? this.enableCustomLogs,
      logBufferSize: logBufferSize ?? this.logBufferSize,
      enableUserMetadata: enableUserMetadata ?? this.enableUserMetadata,
      customKeys: customKeys ?? this.customKeys,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enableInDebugMode': enableInDebugMode,
      'enableAutomaticDataCollection': enableAutomaticDataCollection,
      'enableCustomLogs': enableCustomLogs,
      'logBufferSize': logBufferSize,
      'enableUserMetadata': enableUserMetadata,
      'customKeys': customKeys,
    };
  }

  @override
  String toString() {
    return 'CrashlyticsConfig{enableInDebugMode: $enableInDebugMode, enableAutomaticDataCollection: $enableAutomaticDataCollection, enableCustomLogs: $enableCustomLogs, logBufferSize: $logBufferSize, enableUserMetadata: $enableUserMetadata, customKeys: $customKeys}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrashlyticsConfig &&
          runtimeType == other.runtimeType &&
          enableInDebugMode == other.enableInDebugMode &&
          enableAutomaticDataCollection ==
              other.enableAutomaticDataCollection &&
          enableCustomLogs == other.enableCustomLogs &&
          logBufferSize == other.logBufferSize &&
          enableUserMetadata == other.enableUserMetadata &&
          _mapEquals(customKeys, other.customKeys);

  @override
  int get hashCode =>
      enableInDebugMode.hashCode ^
      enableAutomaticDataCollection.hashCode ^
      enableCustomLogs.hashCode ^
      logBufferSize.hashCode ^
      enableUserMetadata.hashCode ^
      customKeys.hashCode;

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
    super.enableAutomaticDataCollection = true,
    super.enableCustomLogs = true,
    super.logBufferSize = 100,
    super.enableUserMetadata = true,
    super.customKeys = const {},
  });
}
