abstract class AnalyticsConfig {
  bool get enableAnalytics;
  bool get enableDebugLogging;
  String? get userId;
  Map<String, String>? get defaultUserProperties;
}

class DefaultAnalyticsConfig implements AnalyticsConfig {
  const DefaultAnalyticsConfig({
    this.enableAnalytics = true,
    this.enableDebugLogging = false,
    this.userId,
    this.defaultUserProperties,
  });

  @override
  final bool enableAnalytics;

  @override
  final bool enableDebugLogging;

  @override
  final String? userId;

  @override
  final Map<String, String>? defaultUserProperties;

  DefaultAnalyticsConfig copyWith({
    bool? enableAnalytics,
    bool? enableDebugLogging,
    String? userId,
    Map<String, String>? defaultUserProperties,
  }) {
    return DefaultAnalyticsConfig(
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      enableDebugLogging: enableDebugLogging ?? this.enableDebugLogging,
      userId: userId ?? this.userId,
      defaultUserProperties:
          defaultUserProperties ?? this.defaultUserProperties,
    );
  }
}
