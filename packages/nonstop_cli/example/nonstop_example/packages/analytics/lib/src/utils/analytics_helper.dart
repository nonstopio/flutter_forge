import 'package:analytics/src/client/analytics_client.dart';
import 'package:analytics/src/models/analytics_event.dart';
import 'package:analytics/src/models/analytics_events.dart';
import 'package:core/core.dart';
import 'package:di/di.dart';

/// Fire-and-forget analytics facade for UI code.
///
/// This is the one allowed service-locator facade in the app: widgets and
/// feature helpers call these statics instead of threading an
/// [AnalyticsClient] through every constructor. Each call resolves the
/// registered client at call time and is a silent no-op when analytics is not
/// configured; client failures are logged, never thrown. Code that needs a
/// result or testable wiring should inject [AnalyticsClient] instead.
abstract final class AnalyticsHelper {
  static AnalyticsClient? get _analyticsClient =>
      di.has<AnalyticsClient>() ? di.get<AnalyticsClient>() : null;

  static Logger? get _log => di.has<Logger>() ? di.get<Logger>() : null;

  /// Log a custom event with optional parameters
  static Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    final client = _analyticsClient;
    if (client == null) return;

    try {
      await client.logEvent(name: name, parameters: parameters);
    } catch (e, s) {
      _log?.e('Failed to log analytics event: $name', e, s);
    }
  }

  /// Log user sign in
  static Future<void> logSignIn({
    String? method,
    Map<String, dynamic>? parameters,
  }) async {
    final client = _analyticsClient;
    if (client == null) return;

    try {
      await client.logLogin(loginMethod: method, parameters: parameters);
    } catch (e, s) {
      _log?.e('Failed to log sign in event', e, s);
    }
  }

  /// Log user sign up
  static Future<void> logSignUp({
    String? method,
    Map<String, dynamic>? parameters,
  }) async {
    final client = _analyticsClient;
    if (client == null) return;

    try {
      await client.logSignUp(signUpMethod: method, parameters: parameters);
    } catch (e, s) {
      _log?.e('Failed to log sign up event', e, s);
    }
  }

  /// Set user ID for analytics
  static Future<void> setUserId(String? userId) async {
    final client = _analyticsClient;
    if (client == null) return;

    try {
      await client.setUserId(userId);
    } catch (e, s) {
      _log?.e('Failed to set analytics user ID', e, s);
    }
  }

  /// Set user property
  static Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    final client = _analyticsClient;
    if (client == null) return;

    try {
      await client.setUserProperty(name: name, value: value);
    } catch (e, s) {
      _log?.e('Failed to set analytics user property: $name', e, s);
    }
  }

  /// Log app open event
  static Future<void> logAppOpen({Map<String, dynamic>? parameters}) async {
    final client = _analyticsClient;
    if (client == null) return;

    try {
      await client.logAppOpen(parameters: parameters);
    } catch (e, s) {
      _log?.e('Failed to log app open event', e, s);
    }
  }

  /// Log custom analytics event
  static Future<void> logCustomEvent(AnalyticsEvent event) async {
    final client = _analyticsClient;
    if (client == null) return;

    try {
      await client.logCustomEvent(event);
    } catch (e, s) {
      _log?.e('Failed to log custom analytics event: ${event.name}', e, s);
    }
  }

  /// Common business events
  static Future<void> logFeatureUsed(
    String featureName, {
    Map<String, dynamic>? parameters,
  }) async {
    await logEvent(
      AnalyticsEvents.feature.used,
      parameters: {
        'feature_name': featureName,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      },
    );
  }

  static Future<void> logButtonPressed(
    String buttonName, {
    String? screenName,
    Map<String, dynamic>? parameters,
  }) async {
    await logEvent(
      AnalyticsEvents.feature.buttonPressed,
      parameters: {
        'button_name': buttonName,
        'screen_name': ?screenName,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      },
    );
  }

  static Future<void> logAppError(
    String errorType, {
    String? errorMessage,
    Map<String, dynamic>? parameters,
  }) async {
    await logEvent(
      AnalyticsEvents.error.appError,
      parameters: {
        'error_type': errorType,
        'error_message': ?errorMessage,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      },
    );
  }
}
