import 'package:core/logger/logger.dart';
import 'package:feature_flags/src/client/feature_flag_service.dart';
import 'package:feature_flags/src/providers/feature_flag_provider.dart';

/// Read access to feature flags and remote configuration values.
///
/// Reads throw [StateError] until [init] has completed.
abstract interface class FeatureFlag {
  /// Creates the default [FeatureFlagService] implementation.
  factory FeatureFlag({
    required FeatureFlagProvider provider,
    required Logger logger,
  }) = FeatureFlagService;

  /// Initializes the underlying provider; repeated calls are no-ops.
  Future<void> init();

  bool get isInitialized;

  /// Whether the boolean flag [key] is on, or [defaultValue] when unset.
  Future<bool> isEnabled(String key, {bool defaultValue = false});

  /// Whether [key] has a remote or in-app default value.
  Future<bool> hasFlag(String key);

  Future<String> getConfig(String key, {String defaultValue = ''});

  Future<int> getIntConfig(String key, {int defaultValue = 0});

  Future<double> getDoubleConfig(String key, {double defaultValue = 0.0});

  void dispose();
}
