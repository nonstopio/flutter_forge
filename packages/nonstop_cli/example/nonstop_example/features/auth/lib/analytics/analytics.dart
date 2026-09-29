import 'package:analytics/analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Every auth-related analytics event in one place.
///
/// Screens call these instead of `AnalyticsHelper` directly so the event names
/// and parameter shapes stay consistent across sign-in, sign-up and recovery.
abstract final class AuthAnalytics {
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
    await AnalyticsHelper.logSignIn(
      method: method,
      parameters: _successParams(),
    );
  }

  static Future<void> logSignUpSuccess({required String method}) async {
    await AnalyticsHelper.logSignUp(
      method: method,
      parameters: _successParams(),
    );
  }

  static Future<void> logSignOutSuccess() async {
    await AnalyticsHelper.logEvent(
      AnalyticsEvents.auth.signOut,
      parameters: _successParams(),
    );
  }

  /// [flowType] is one of 'sign_in', 'sign_up', 'forgot_password'.
  static Future<void> logAuthError({
    required String errorType,
    required String flowType,
    String? errorMessage,
    String? method,
  }) async {
    await AnalyticsHelper.logEvent(
      AnalyticsEvents.auth.failed,
      parameters: {
        'error_type': errorType,
        'flow_type': flowType,
        'auth_method': method,
        'error_message': errorMessage,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logSignOutError({required String errorMessage}) async {
    await AnalyticsHelper.logEvent(
      AnalyticsEvents.error.appError,
      parameters: {
        'error_type': 'sign_out_failed',
        'error_message': errorMessage,
        'feature': 'auth',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Map<String, Object?> _successParams() => {
    'success': 'true',
    'timestamp': DateTime.now().toIso8601String(),
  };
}
