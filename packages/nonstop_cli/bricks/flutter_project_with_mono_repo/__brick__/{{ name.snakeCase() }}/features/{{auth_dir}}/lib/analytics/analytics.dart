{{#analytics}}import 'package:analytics/analytics.dart';
{{/analytics}}import 'package:firebase_auth/firebase_auth.dart';

/// Every auth-related analytics event in one place.
///
/// Screens call these instead of `AnalyticsHelper` directly so the event names
/// and parameter shapes stay consistent across sign-in, sign-up and recovery.
{{^analytics}}///
/// Analytics is not enabled in this project, so the log methods are no-ops.
/// Wire them up by adding the `analytics` package back to `pubspec.yaml`.
{{/analytics}}abstract final class AuthAnalytics {

  /// 'google', 'apple' or 'email', derived from the signed-in provider.
  static String getAuthMethod(List<UserInfo>? providerData) {
    if (providerData?.isNotEmpty ?? false) {
      final providerId = providerData!.first.providerId;
      if (providerId.contains('google')) return 'google';
      if (providerId.contains('apple')) return 'apple';
    }
    return 'email';
  }

  static Future<void> logSignInSuccess({required String method}) async {
{{#analytics}}    await AnalyticsHelper.logSignIn(
      method: method,
      parameters: _successParams(),
    );
{{/analytics}}  }

  static Future<void> logSignUpSuccess({required String method}) async {
{{#analytics}}    await AnalyticsHelper.logSignUp(
      method: method,
      parameters: _successParams(),
    );
{{/analytics}}  }

  static Future<void> logSignOutSuccess() async {
{{#analytics}}    await AnalyticsHelper.logEvent(
      AnalyticsEvents.auth.signOut,
      parameters: _successParams(),
    );
{{/analytics}}  }

  /// [flowType] is one of 'sign_in', 'sign_up', 'forgot_password'.
  static Future<void> logAuthError({
    required String errorType,
    required String flowType,
    String? errorMessage,
    String? method,
  }) async {
{{#analytics}}    await AnalyticsHelper.logEvent(
      AnalyticsEvents.auth.failed,
      parameters: {
        'error_type': errorType,
        'flow_type': flowType,
        'auth_method': method,
        'error_message': errorMessage,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
{{/analytics}}  }

  static Future<void> logSignOutError({required String errorMessage}) async {
{{#analytics}}    await AnalyticsHelper.logEvent(
      AnalyticsEvents.error.appError,
      parameters: {
        'error_type': 'sign_out_failed',
        'error_message': errorMessage,
        'feature': 'auth',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
{{/analytics}}  }
{{#analytics}}
  static Map<String, Object?> _successParams() => {
    'success': 'true',
    'timestamp': DateTime.now().toIso8601String(),
  };
{{/analytics}}}
