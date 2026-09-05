import 'package:analytics/src/client/analytics_client.dart';
import 'package:analytics/src/config/analytics_config.dart';
import 'package:analytics/src/models/analytics_event.dart';
import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsClient implements AnalyticsClient {
  FirebaseAnalyticsClient(this._config)
    : _analytics = FirebaseAnalytics.instance {
    _setupAnalytics();
  }

  final AnalyticsConfig _config;
  final FirebaseAnalytics _analytics;
  final Logger _logger = di.get<Logger>();

  void _setupAnalytics() {
    _analytics.setAnalyticsCollectionEnabled(_config.enableAnalytics);

    if (_config.userId != null) {
      _analytics.setUserId(id: _config.userId);
      _logger.d('🔍 Analytics user ID set: ${_config.userId}');
    }

    if (_config.defaultUserProperties != null) {
      for (final entry in _config.defaultUserProperties!.entries) {
        _analytics.setUserProperty(name: entry.key, value: entry.value);
      }
      _logger.d('🔍 Analytics default user properties set');
    }

    if (_config.enableDebugLogging) {
      _logger.d('🔍 Firebase Analytics initialized with debug logging enabled');
    } else {
      _logger.i('🔍 Firebase Analytics initialized');
    }
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      if (!_config.enableAnalytics) {
        if (_config.enableDebugLogging) {
          _logger.d('🔍 Analytics disabled, skipping event: $name');
        }
        return;
      }

      await _analytics.logEvent(
        name: name,
        parameters: parameters?.cast<String, Object>(),
      );

      if (_config.enableDebugLogging) {
        _logger.d(
          '🔍 Analytics event logged: $name with parameters: $parameters',
        );
      }
    } catch (e, s) {
      _logger.e('Failed to log analytics event: $name', e, s);
    }
  }

  @override
  Future<void> logCustomEvent(AnalyticsEvent event) async {
    await logEvent(name: event.name, parameters: event.parameters);
  }

  @override
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);

      if (_config.enableDebugLogging) {
        _logger.d('🔍 Analytics user ID set: $userId');
      }
    } catch (e, s) {
      _logger.e('Failed to set analytics user ID: $userId', e, s);
    }
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);

      if (_config.enableDebugLogging) {
        _logger.d('🔍 Analytics user property set: $name = $value');
      }
    } catch (e, s) {
      _logger.e('Failed to set analytics user property: $name', e, s);
    }
  }

  @override
  Future<void> resetAnalyticsData() async {
    try {
      await _analytics.resetAnalyticsData();

      if (_config.enableDebugLogging) {
        _logger.d('🔍 Analytics data reset');
      }
    } catch (e, s) {
      _logger.e('Failed to reset analytics data', e, s);
    }
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);

      if (_config.enableDebugLogging) {
        _logger.d(
          '🔍 Analytics collection ${enabled ? 'enabled' : 'disabled'}',
        );
      }
    } catch (e, s) {
      _logger.e('Failed to set analytics collection enabled: $enabled', e, s);
    }
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? parameters,
  }) async {
    final eventParameters = <String, dynamic>{
      PredefinedParameters.screenName: screenName,
      if (screenClass != null) PredefinedParameters.screenClass: screenClass,
      ...?parameters,
    };

    await logEvent(
      name: PredefinedEvents.screenView,
      parameters: eventParameters,
    );
  }

  @override
  Future<void> logAppOpen({Map<String, dynamic>? parameters}) async {
    await logEvent(name: PredefinedEvents.appOpen, parameters: parameters);
  }

  @override
  Future<void> logLogin({
    String? loginMethod,
    Map<String, dynamic>? parameters,
  }) async {
    final eventParameters = <String, dynamic>{
      if (loginMethod != null) PredefinedParameters.method: loginMethod,
      ...?parameters,
    };

    await logEvent(name: PredefinedEvents.login, parameters: eventParameters);
  }

  @override
  Future<void> logSignUp({
    String? signUpMethod,
    Map<String, dynamic>? parameters,
  }) async {
    final eventParameters = <String, dynamic>{
      if (signUpMethod != null) PredefinedParameters.method: signUpMethod,
      ...?parameters,
    };

    await logEvent(name: PredefinedEvents.signUp, parameters: eventParameters);
  }

  @override
  Future<void> logPurchase({
    required String currency,
    required double value,
    Map<String, dynamic>? parameters,
  }) async {
    final eventParameters = <String, dynamic>{
      PredefinedParameters.currency: currency,
      PredefinedParameters.value: value,
      ...?parameters,
    };

    await logEvent(
      name: PredefinedEvents.purchase,
      parameters: eventParameters,
    );
  }

  @override
  void dispose() {
    // Firebase Analytics doesn't need explicit disposal
    if (_config.enableDebugLogging) {
      _logger.d('🔍 Firebase Analytics client disposed');
    }
  }
}
