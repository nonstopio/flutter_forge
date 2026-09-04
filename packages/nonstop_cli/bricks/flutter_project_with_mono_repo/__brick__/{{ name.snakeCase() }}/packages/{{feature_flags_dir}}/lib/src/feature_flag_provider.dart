/// Abstract interface for feature flag providers
abstract class FeatureFlagProvider {
  /// Initialize the feature flag provider
  Future<void> init();

  /// Get a boolean feature flag value
  Future<bool> getBool(String key, {bool defaultValue = false});

  /// Get a string feature flag value
  Future<String> getString(String key, {String defaultValue = ''});

  /// Get an integer feature flag value
  Future<int> getInt(String key, {int defaultValue = 0});

  /// Get a double feature flag value
  Future<double> getDouble(String key, {double defaultValue = 0.0});

  /// Check if a feature flag exists
  Future<bool> hasFlag(String key);

  /// Dispose resources
  void dispose();
}
