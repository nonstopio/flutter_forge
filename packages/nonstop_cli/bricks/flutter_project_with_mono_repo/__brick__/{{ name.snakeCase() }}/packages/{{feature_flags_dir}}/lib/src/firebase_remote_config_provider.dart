import 'package:core/logger/logger.dart';
import 'package:feature_flags/feature_flags.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Firebase Remote Config implementation of FeatureFlagProvider
class FirebaseRemoteConfigProvider implements FeatureFlagProvider {
  final FirebaseRemoteConfig _remoteConfig;
  final FeatureFlagsConfig _config;
  final Logger logger;

  FirebaseRemoteConfigProvider({
    required FirebaseRemoteConfig remoteConfig,
    required this.logger,
    FeatureFlagsConfig? config,
  }) : _remoteConfig = remoteConfig,
       _config =
           config ??
           const FeatureFlagsConfig(
             defaultParameters: {},
             fetchTimeout: Duration(seconds: 10),
             minimumFetchInterval: Duration(hours: 1),
           );

  @override
  Future<void> init() async {
    try {
      // Configure settings
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: _config.fetchTimeout ?? const Duration(seconds: 10),
          minimumFetchInterval:
              _config.minimumFetchInterval ?? const Duration(hours: 1),
        ),
      );

      // Set default values
      await _setDefaults();

      // Fetch and activate
      final activated = await _remoteConfig.fetchAndActivate();

      logger.i('Firebase Remote Config initialized successfully');
      logger.i('Remote Config activated: $activated');
      logger.i('Last fetch status: ${_remoteConfig.lastFetchStatus}');
      logger.i('Last fetch time: ${_remoteConfig.lastFetchTime}');
    } catch (e, stackTrace) {
      logger.e('Failed to initialize Firebase Remote Config', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _setDefaults() async {
    await _remoteConfig.setDefaults(_config.defaultParameters);
  }

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    try {
      final configValue = _remoteConfig.getValue(key);
      return configValue.source == ValueSource.valueStatic
          ? defaultValue
          : _remoteConfig.getBool(key);
    } catch (e) {
      logger.e(
        'Failed to get bool flag: $key, using default: $defaultValue',
        e,
      );
      return defaultValue;
    }
  }

  @override
  Future<String> getString(String key, {String defaultValue = ''}) async {
    try {
      return _remoteConfig.getValue(key).source == ValueSource.valueStatic
          ? defaultValue
          : _remoteConfig.getString(key);
    } catch (e) {
      logger.w('Failed to get string flag: $key, using default: $defaultValue');
      return defaultValue;
    }
  }

  @override
  Future<int> getInt(String key, {int defaultValue = 0}) async {
    try {
      return _remoteConfig.getValue(key).source == ValueSource.valueStatic
          ? defaultValue
          : _remoteConfig.getInt(key);
    } catch (e) {
      logger.w('Failed to get int flag: $key, using default: $defaultValue');
      return defaultValue;
    }
  }

  @override
  Future<double> getDouble(String key, {double defaultValue = 0.0}) async {
    try {
      return _remoteConfig.getValue(key).source == ValueSource.valueStatic
          ? defaultValue
          : _remoteConfig.getDouble(key);
    } catch (e) {
      logger.w('Failed to get double flag: $key, using default: $defaultValue');
      return defaultValue;
    }
  }

  @override
  Future<bool> hasFlag(String key) async {
    try {
      final value = _remoteConfig.getValue(key);
      return value.source != ValueSource.valueStatic;
    } catch (e) {
      logger.w('Failed to check if flag exists: $key');
      return false;
    }
  }

  @override
  void dispose() {
    // Firebase Remote Config doesn't require explicit disposal
    logger.i('Firebase Remote Config provider disposed');
  }

  /// Get the last fetch time
  DateTime get lastFetchTime => _remoteConfig.lastFetchTime;

  /// Get the last fetch status
  RemoteConfigFetchStatus get lastFetchStatus => _remoteConfig.lastFetchStatus;

  /// Add a listener for config updates
  Stream<RemoteConfigUpdate> get onConfigUpdated =>
      _remoteConfig.onConfigUpdated;

  /// Get the current configuration
  FeatureFlagsConfig get config => _config;
}
