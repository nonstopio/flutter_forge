/// Remote-config fetch settings and in-app defaults.
class FeatureFlagsConfig {
  const FeatureFlagsConfig({
    this.fetchTimeout = defaultFetchTimeout,
    this.minimumFetchInterval = defaultMinimumFetchInterval,
    this.defaultParameters = const {},
  });

  /// Used by both module startup and the provider when no config is given.
  static const defaultFetchTimeout = Duration(seconds: 10);
  static const defaultMinimumFetchInterval = Duration(minutes: 30);

  final Duration fetchTimeout;
  final Duration minimumFetchInterval;
  final Map<String, dynamic> defaultParameters;
}
