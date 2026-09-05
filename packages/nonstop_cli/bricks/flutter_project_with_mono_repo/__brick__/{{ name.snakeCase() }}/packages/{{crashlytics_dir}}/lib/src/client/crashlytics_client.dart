import 'package:crashlytics/src/models/user_metadata.dart';

abstract class CrashlyticsClient {
  /// Initialize the crashlytics client
  Future<void> initialize();

  /// Record a fatal error/exception
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    bool fatal = false,
    Iterable<Object> information = const [],
  });

  /// Record a non-fatal error with custom context
  Future<void> recordFlutterFatalError(
    dynamic exception,
    StackTrace stackTrace, {
    Map<String, dynamic>? context,
  });

  /// Log a custom message for debugging
  Future<void> log(String message);

  /// Set user identifier for crash reports
  Future<void> setUserIdentifier(String identifier);

  /// Set user metadata
  Future<void> setUserMetadata(UserMetadata metadata);

  /// Set custom key-value pairs for debugging
  Future<void> setCustomKey(String key, dynamic value);

  /// Set custom keys from a map
  Future<void> setCustomKeys(Map<String, dynamic> keys);

  /// Check if crashlytics collection is enabled
  bool get isCrashlyticsCollectionEnabled;

  /// Enable or disable crashlytics collection
  Future<void> setCrashlyticsCollectionEnabled(bool enabled);

  /// Send any unsent crash reports
  Future<void> sendUnsentReports();

  /// Delete any unsent crash reports
  Future<void> deleteUnsentReports();

  /// Check if there are any unsent crash reports
  Future<bool> checkForUnsentReports();

  /// Dispose of resources
  void dispose();
}
