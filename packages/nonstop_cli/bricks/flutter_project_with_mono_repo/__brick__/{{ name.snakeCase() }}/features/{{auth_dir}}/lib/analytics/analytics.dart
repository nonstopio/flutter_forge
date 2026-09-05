{{#analytics}}import 'package:analytics/analytics.dart';
{{/analytics}}import 'package:firebase_auth/firebase_auth.dart';

/// Every auth-related analytics event in one place.
///
/// Screens call these instead of `AnalyticsHelper` directly so the event names
/// and parameter shapes stay consistent across sign-in, sign-up and recovery.
{{^analytics}}///
/// Analytics is not enabled in this project, so the log methods are no-ops.
/// Wire them up by adding the `analytics` package back to `pubspec.yaml`.
{{/analytics}}class AuthAnalytics {
  const AuthAnalytics._();

  /// 'google', 'apple' or 'email', derived from the signed-in provider.
  static String getAuthMethod(List<UserInfo>? providerData) {
    if (providerData?.isNotEmpty ?? false) {
      final providerId = providerData!.first.providerId;
      if (providerId.contains('google')) return 'google';
      if (providerId.contains('apple')) return 'apple';
    }
    return 'email';
  }

  static Future<void> logSignInSuccess({
    required String method,
    String? userEmail,
  }) async {
{{#analytics}}    await AnalyticsHelper.logSignIn(
      method: method,
      parameters: _successParams(userEmail),
    );
{{/analytics}}  }

  static Future<void> logSignUpSuccess({
    required String method,
    String? userEmail,
  }) async {
{{#analytics}}    await AnalyticsHelper.logSignUp(
      method: method,
      parameters: _successParams(userEmail),
    );
{{/analytics}}  }

  static Future<void> logUserCreationSuccess({
    required String method,
    String? userEmail,
  }) async {
{{#analytics}}    await AnalyticsHelper.logEvent(
      AnalyticsEvents.user.authenticatedRedirect,
      parameters: {
        'auth_method': method,
        'flow_type': 'registration',
        ..._successParams(userEmail),
      },
    );
{{/analytics}}  }

  static Future<void> logSignOutSuccess() async {
{{#analytics}}    await AnalyticsHelper.logEvent(
      AnalyticsEvents.auth.signOut,
      parameters: _successParams(null),
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
  static Map<String, Object?> _successParams(String? userEmail) => {
    'success': 'true',
    'user_email_domain': userEmail?.split('@').last,
    'timestamp': DateTime.now().toIso8601String(),
  };
{{/analytics}}}
