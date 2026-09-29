import 'package:core/logger/logger.dart';
import 'package:feature_flags/src/client/feature_flag.dart';
import 'package:feature_flags/src/providers/feature_flag_provider.dart';

/// [FeatureFlag] backed by a [FeatureFlagProvider].
class FeatureFlagService implements FeatureFlag {
  FeatureFlagService({
    required FeatureFlagProvider provider,
    required Logger logger,
  }) : _provider = provider,
       _logger = logger;

  final FeatureFlagProvider _provider;
  final Logger _logger;
  bool _initialized = false;

  @override
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

  @override
  bool get isInitialized => _initialized;

  @override
  Future<bool> isEnabled(String key, {bool defaultValue = false}) {
    _ensureInitialized();
    return _provider.getBool(key, defaultValue: defaultValue);
  }

  @override
  Future<bool> hasFlag(String key) {
    _ensureInitialized();
    return _provider.hasFlag(key);
  }

  @override
  Future<String> getConfig(String key, {String defaultValue = ''}) {
    _ensureInitialized();
    return _provider.getString(key, defaultValue: defaultValue);
  }

  @override
  Future<int> getIntConfig(String key, {int defaultValue = 0}) {
    _ensureInitialized();
    return _provider.getInt(key, defaultValue: defaultValue);
  }

  @override
  Future<double> getDoubleConfig(String key, {double defaultValue = 0.0}) {
    _ensureInitialized();
    return _provider.getDouble(key, defaultValue: defaultValue);
  }

  @override
  void dispose() {
    _provider.dispose();
    _initialized = false;
    _logger.i('FeatureFlag disposed');
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('FeatureFlag not initialized. Call init() first.');
    }
  }
}
