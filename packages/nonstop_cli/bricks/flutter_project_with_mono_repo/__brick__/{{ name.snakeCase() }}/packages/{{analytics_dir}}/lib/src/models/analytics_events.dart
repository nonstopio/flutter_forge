/// Structured analytics event names organized by category.
///
/// Usage: `AnalyticsEvents.user.authenticatedRedirect`. Naming events here
/// instead of inline keeps them discoverable and typo-free, and gives you one
/// place to add the groups your own product needs.
class AnalyticsEvents {
  AnalyticsEvents._();

  /// User-related events
  static const user = _UserEvents();

  /// Authentication-related events
  static const auth = _AuthEvents();

  /// Navigation-related events
  static const navigation = _NavigationEvents();

  /// Feature usage events
  static const feature = _FeatureEvents();

  /// Error and debugging events
  static const error = _ErrorEvents();

  /// App lifecycle events
  static const app = _AppEvents();

  /// Profile-related events
  static const profile = _ProfileEvents();
}

class _UserEvents {
  const _UserEvents();

  /// User successfully authenticated and redirected
  String get authenticatedRedirect => 'user_authenticated_redirect';

  /// User profile updated
  String get profileUpdated => 'user_profile_updated';

  /// User preferences changed
  String get preferencesChanged => 'user_preferences_changed';

  /// User completed onboarding
  String get onboardingCompleted => 'user_onboarding_completed';

  /// User account deleted
  String get accountDeleted => 'user_account_deleted';
}

class _AuthEvents {
  const _AuthEvents();

  /// User signed in
  String get signIn => 'auth_sign_in';

  /// User signed up
  String get signUp => 'auth_sign_up';

  /// User signed out
  String get signOut => 'auth_sign_out';

  /// Password reset requested
  String get passwordReset => 'auth_password_reset';

  /// Authentication failed
  String get failed => 'auth_failed';

  /// Social authentication (Google, Apple, etc.)
  String get socialLogin => 'auth_social_login';
}

class _NavigationEvents {
  const _NavigationEvents();

  /// Screen viewed (automatically tracked)
  String get screenView => 'screen_view';

  /// Tab switched in bottom navigation
  String get tabSwitched => 'navigation_tab_switched';

  /// Back button pressed
  String get backPressed => 'navigation_back_pressed';

  /// Deep link opened
  String get deepLinkOpened => 'navigation_deep_link_opened';
}

class _FeatureEvents {
  const _FeatureEvents();

  /// Feature was used/accessed
  String get used => 'feature_used';

  /// Feature tutorial started
  String get tutorialStarted => 'feature_tutorial_started';

  /// Feature tutorial completed
  String get tutorialCompleted => 'feature_tutorial_completed';

  /// Feature feedback given
  String get feedbackGiven => 'feature_feedback_given';

  /// Button pressed
  String get buttonPressed => 'button_pressed';
}

class _ErrorEvents {
  const _ErrorEvents();

  /// General app error occurred
  String get appError => 'app_error';

  /// Network error occurred
  String get networkError => 'network_error';

  /// Crash occurred
  String get crash => 'app_crash';

  /// API error occurred
  String get apiError => 'api_error';

  /// Validation error
  String get validationError => 'validation_error';
}

class _AppEvents {
  const _AppEvents();

  /// App opened/launched
  String get open => 'app_open';

  /// App went to background
  String get background => 'app_background';

  /// App came to foreground
  String get foreground => 'app_foreground';

  /// App updated to new version
  String get updated => 'app_updated';

  /// App installed for first time
  String get installed => 'app_installed';

  /// App uninstalled
  String get uninstalled => 'app_uninstalled';
}



class _ProfileEvents {
  const _ProfileEvents();

  /// Profile viewed
  String get viewed => 'profile_viewed';

  /// Profile edited
  String get edited => 'profile_edited';

  /// Profile photo updated
  String get photoUpdated => 'profile_photo_updated';

  /// Profile settings changed
  String get settingsChanged => 'profile_settings_changed';

  /// Profile privacy settings updated
  String get privacyUpdated => 'profile_privacy_updated';
}
