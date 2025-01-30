import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:ns_firebase_utils/utils/const_keys.dart';
import 'package:ns_firebase_utils/utils/custom_exception.dart';

import '../src.dart';

/// A wrapper class for Firebase Analytics that provides enhanced logging and user tracking
class AppAnalytics implements FirebaseAnalytics {
  /// The underlying Firebase Analytics instance
  final FirebaseAnalytics _firebaseAnalytics;

  /// Stores current user information
  final Map<String, dynamic> _userInfo = {};

  /// Constructor initializes the Firebase Analytics instance
  AppAnalytics() : _firebaseAnalytics = FirebaseAnalytics.instance;

  /// Sets user information for analytics tracking
  Future<void> setUser({
    required String id,
    required String email,
  }) {
    appLogsNS("setUser:$id");

    return Future.wait([
      setUserId(id: id),
      setUserProperty(name: 'email', value: email),
    ]).then((_) {
      _userInfo.addAll({
        ConstKeys.id: id,
        ConstKeys.email: email,
      });
    });
  }

  /// Logs an event with optional category and parameters
  Future<void> log({
    required String eventName,
    String? category,
    Map<String, dynamic>? parameters,
  }) {
    parameters ??= <String, dynamic>{};
    category ??= '';

    return logEvent(
        name: eventName, category: category, parameters: parameters);
  }

  @override
  Future<void> logAppOpen({
    AnalyticsCallOptions? callOptions,
    Map<String, Object>? parameters,
  }) {
    if (!NSFirebase.instance.isInitialized) {
      throw CustomException(
        code: 'not_initialized',
        message: 'Please Initialize NSFirebase',
      );
    }
    return _firebaseAnalytics.logAppOpen(
      callOptions: callOptions,
      parameters: parameters,
    );
  }

  @override
  Future<void> logEvent({
    String? name,
    String? category,
    Map<String, dynamic>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    // Sanitize event name and category by replacing spaces with underscores
    name = name?.replaceAll(RegExp(r' '), '_');
    category = category?.replaceAll(RegExp(r' '), '_');

    // Combine name and category for full event name
    final eventName =
        category == null || category.isEmpty ? name! : "${name}_$category";

    // Initialize parameters if null
    parameters ??= <String, dynamic>{};

    // Add version and build information
    final buildStr = NSFirebase.instance.buildNumber;
    final versionStr = NSFirebase.instance.version;
    parameters.putIfAbsent(
        ConstKeys.version, () => '$versionStr${ConstKeys.dash}$buildStr');

    // Add user information if available
    if (_userInfo.isNotEmpty) {
      parameters.putIfAbsent(ConstKeys.id, () => _userInfo[ConstKeys.id]);
      parameters.putIfAbsent(ConstKeys.email, () => _userInfo[ConstKeys.email]);
    }

    // Create a new map to filter out null values
    final newParameters = <String, Object>{};
    parameters.forEach((key, dynamic value) {
      if (value != null) {
        newParameters[key] = value;
      }
    });

    // Log event name for debugging
    appLogsNS("eventName:$eventName");

    // Add timestamp to parameters
    newParameters['date_time'] = DateTime.now().toIso8601String();

    // Log the event to Firebase Analytics
    return _firebaseAnalytics.logEvent(
      name: eventName,
      parameters: newParameters,
      callOptions: callOptions,
    );
  }

  @override
  Future<void> logJoinGroup({
    required String groupId,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    return _firebaseAnalytics.logJoinGroup(
      groupId: groupId,
      parameters: parameters,
      callOptions: callOptions,
    );
  }

  @override
  Future<void> logLogin({
    String? loginMethod,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    return _firebaseAnalytics.logLogin(
      loginMethod: loginMethod,
      parameters: parameters,
      callOptions: callOptions,
    );
  }

  @override
  Future<void> logSignUp({
    required String signUpMethod,
    Map<String, Object>? parameters,
  }) {
    return _firebaseAnalytics.logSignUp(
      signUpMethod: signUpMethod,
      parameters: parameters,
    );
  }

  @override
  Future<void> logTutorialBegin({
    Map<String, Object>? parameters,
  }) {
    return _firebaseAnalytics.logTutorialBegin(
      parameters: parameters,
    );
  }

  @override
  Future<void> logTutorialComplete({
    Map<String, Object>? parameters,
  }) {
    return _firebaseAnalytics.logTutorialComplete(
      parameters: parameters,
    );
  }

  @override
  Future<void> logScreenView({
    String? screenClass,
    String? screenName,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    return _firebaseAnalytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
      parameters: parameters,
      callOptions: callOptions,
    );
  }

  @override
  Future<void> setUserId({
    String? id,
    AnalyticsCallOptions? callOptions,
  }) {
    return _firebaseAnalytics.setUserId(
      id: id,
      callOptions: callOptions,
    );
  }

  @override
  Future<void> setUserProperty({
    required String name,
    String? value,
    AnalyticsCallOptions? callOptions,
  }) {
    return _firebaseAnalytics.setUserProperty(
      name: name,
      value: value,
      callOptions: callOptions,
    );
  }

  // Implement noSuchMethod to handle any undefined method calls
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
