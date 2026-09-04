import 'package:core/logger/logger.dart';
import 'package:feature_flags/src/feature_flag_provider.dart';

/// Configuration class for feature flags initialization
class FeatureFlagsConfig {
  const FeatureFlagsConfig({
    this.fetchTimeout,
    this.minimumFetchInterval,
    required this.defaultParameters,
  });

  final Duration? fetchTimeout;
  final Duration? minimumFetchInterval;
  final Map<String, dynamic> defaultParameters;
}

/// Service for managing feature flags across the application
class FeatureFlag {
  final FeatureFlagProvider _provider;
  final Logger _logger;
  bool _initialized = false;

  FeatureFlag({required FeatureFlagProvider provider, required Logger logger})
    : _provider = provider,
      _logger = logger;

  /// Initialize the feature flag service
  Future<void> init() async {
    if (_initialized) {
      _logger.w('FeatureFlag already initialized');
      return;
    }

    try {
      await _provider.init();
      _initialized = true;
      _logger.i('FeatureFlag initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize FeatureFlag', e, stackTrace);
      rethrow;
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _initialized;

  /// Get a boolean feature flag
  Future<bool> isEnabled(String key, {bool defaultValue = false}) async {
    _ensureInitialized();
    final value = await _provider.getBool(key, defaultValue: defaultValue);
    _logger.i('isEnabled($key): Provider returned = $value');
    return value;
  }

  /// Get a string configuration value
  Future<String> getConfig(String key, {String defaultValue = ''}) async {
    _ensureInitialized();

    final value = await _provider.getString(key, defaultValue: defaultValue);
    return value;
  }

  /// Get an integer configuration value
  Future<int> getIntConfig(String key, {int defaultValue = 0}) async {
    _ensureInitialized();

    final value = await _provider.getInt(key, defaultValue: defaultValue);
    return value;
  }

  /// Get a double configuration value
  Future<double> getDoubleConfig(
    String key, {
    double defaultValue = 0.0,
  }) async {
    _ensureInitialized();

    final value = await _provider.getDouble(key, defaultValue: defaultValue);
    return value;
  }

  /// Dispose the service
  void dispose() {
    _provider.dispose();
    _initialized = false;
    _logger.i('FeatureFlag disposed');
  }

  /// Ensure the service is initialized
  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('FeatureFlag not initialized. Call initialize() first.');
    }
  }
}
