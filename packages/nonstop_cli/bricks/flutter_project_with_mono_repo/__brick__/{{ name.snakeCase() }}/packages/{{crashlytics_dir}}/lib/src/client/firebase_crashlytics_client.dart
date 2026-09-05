import 'dart:async';
import 'dart:collection';

import 'package:core/core.dart';
import 'package:crashlytics/src/client/crashlytics_client.dart';
import 'package:crashlytics/src/config/crashlytics_config.dart';
import 'package:crashlytics/src/models/user_metadata.dart';
import 'package:di/di.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseCrashlyticsClient implements CrashlyticsClient {
  FirebaseCrashlyticsClient({required this.config, Logger? logger})
    : _logger = logger ?? di.get<Logger>();

  final CrashlyticsConfig config;
  final Logger _logger;
  late final FirebaseCrashlytics _crashlytics;
  final Queue<String> _logBuffer = Queue<String>();
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    try {
      _crashlytics = FirebaseCrashlytics.instance;

      // Set crashlytics collection enabled based on config
      await _crashlytics.setCrashlyticsCollectionEnabled(
        config.enableInDebugMode || kReleaseMode,
      );

      // Set up automatic Flutter error handling
      if (config.enableAutomaticDataCollection) {
        FlutterError.onError = (errorDetails) {
          _crashlytics.recordFlutterFatalError(errorDetails);
        };

        // Catch errors from the Flutter framework that are not handled by FlutterError
        PlatformDispatcher.instance.onError = (error, stack) {
          _crashlytics.recordError(error, stack, fatal: true);
          return true;
        };
      }

      // Set default custom keys
      if (config.customKeys.isNotEmpty) {
        await setCustomKeys(config.customKeys);
      }

      _isInitialized = true;
      _logger.i('🔥 Firebase Crashlytics initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to initialize Firebase Crashlytics: $e', stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    bool fatal = false,
    Iterable<Object> information = const [],
  }) async {
    if (!_isInitialized) {
      _logger.w('⚠️ Crashlytics not initialized, skipping error recording');
      return;
    }

    try {
      await _crashlytics.recordError(
        exception,
        stackTrace,
        fatal: fatal,
        information: information,
      );

      _logger.d(
        '📝 Recorded ${fatal ? 'fatal' : 'non-fatal'} error: $exception',
      );
    } catch (e) {
      _logger.e('❌ Failed to record error: $e');
    }
  }

  @override
  Future<void> recordFlutterFatalError(
    dynamic exception,
    StackTrace stackTrace, {
    Map<String, dynamic>? context,
  }) async {
    if (!_isInitialized) {
      _logger.w(
        '⚠️ Crashlytics not initialized, skipping Flutter fatal error recording',
      );
      return;
    }

    try {
      // Set context as custom keys if provided
      if (context != null && context.isNotEmpty) {
        await setCustomKeys(context);
      }

      await _crashlytics.recordError(exception, stackTrace, fatal: true);

      _logger.d('📝 Recorded Flutter fatal error: $exception');
    } catch (e) {
      _logger.e('❌ Failed to record Flutter fatal error: $e');
    }
  }

  @override
  Future<void> log(String message) async {
    if (!_isInitialized || !config.enableCustomLogs) {
      return;
    }

    try {
      await _crashlytics.log(message);

      // Add to local buffer for debugging
      _logBuffer.add('[${DateTime.now().toIso8601String()}] $message');

      // Maintain buffer size
      while (_logBuffer.length > config.logBufferSize) {
        _logBuffer.removeFirst();
      }

      _logger.d('📊 Logged message: $message');
    } catch (e) {
      _logger.e('❌ Failed to log message: $e');
    }
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    if (!_isInitialized || !config.enableUserMetadata) {
      return;
    }

    try {
      await _crashlytics.setUserIdentifier(identifier);
      _logger.d('👤 Set user identifier: $identifier');
    } catch (e) {
      _logger.e('❌ Failed to set user identifier: $e');
    }
  }

  @override
  Future<void> setUserMetadata(UserMetadata metadata) async {
    if (!_isInitialized || !config.enableUserMetadata) {
      return;
    }

    try {
      if (metadata.userId != null) {
        await setUserIdentifier(metadata.userId!);
      }

      // Set custom attributes
      final allAttributes = <String, dynamic>{
        if (metadata.email != null) 'email': metadata.email!,
        if (metadata.name != null) 'name': metadata.name!,
        ...metadata.customAttributes,
      };

      await setCustomKeys(allAttributes);
      _logger.d('👤 Set user metadata: $metadata');
    } catch (e) {
      _logger.e('❌ Failed to set user metadata: $e');
    }
  }

  @override
  Future<void> setCustomKey(String key, dynamic value) async {
    if (!_isInitialized) {
      return;
    }

    try {
      await _crashlytics.setCustomKey(key, value);
      _logger.d('🔑 Set custom key: $key = $value');
    } catch (e) {
      _logger.e('❌ Failed to set custom key: $e');
    }
  }

  @override
  Future<void> setCustomKeys(Map<String, dynamic> keys) async {
    if (!_isInitialized || keys.isEmpty) {
      return;
    }

    try {
      for (final entry in keys.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value);
      }
      _logger.d('🔑 Set ${keys.length} custom keys');
    } catch (e) {
      _logger.e('❌ Failed to set custom keys: $e');
    }
  }

  @override
  bool get isCrashlyticsCollectionEnabled {
    if (!_isInitialized) return false;
    return _crashlytics.isCrashlyticsCollectionEnabled;
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    if (!_isInitialized) {
      return;
    }

    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
      _logger.d(
        '⚙️ Crashlytics collection ${enabled ? 'enabled' : 'disabled'}',
      );
    } catch (e) {
      _logger.e('❌ Failed to set crashlytics collection enabled: $e');
    }
  }

  @override
  Future<void> sendUnsentReports() async {
    if (!_isInitialized) {
      return;
    }

    try {
      await _crashlytics.sendUnsentReports();
      _logger.d('📤 Sent unsent crash reports');
    } catch (e) {
      _logger.e('❌ Failed to send unsent reports: $e');
    }
  }

  @override
  Future<void> deleteUnsentReports() async {
    if (!_isInitialized) {
      return;
    }

    try {
      await _crashlytics.deleteUnsentReports();
      _logger.d('🗑️ Deleted unsent crash reports');
    } catch (e) {
      _logger.e('❌ Failed to delete unsent reports: $e');
    }
  }

  @override
  Future<bool> checkForUnsentReports() async {
    if (!_isInitialized) {
      return false;
    }

    try {
      final hasUnsent = await _crashlytics.checkForUnsentReports();
      _logger.d('📋 Has unsent reports: $hasUnsent');
      return hasUnsent;
    } catch (e) {
      _logger.e('❌ Failed to check for unsent reports: $e');
      return false;
    }
  }

  /// Get buffered log messages for debugging
  List<String> get bufferedLogs => _logBuffer.toList();

  /// Clear the log buffer
  void clearLogBuffer() {
    _logBuffer.clear();
    _logger.d('🧹 Cleared log buffer');
  }

  @override
  void dispose() {
    _logBuffer.clear();
    _isInitialized = false;
    _logger.d('🧹 Firebase Crashlytics client disposed');
  }
}
