class AuthRoutes {
  AuthRoutes._();

  static const String auth = '/auth';

  static const String signIn = '$auth/sign-in';
  static const String signUp = '$auth/sign-up';
  static const String forgotPassword = '$auth/forgot-password';
  static const String resetPassword = '$auth/reset-password';
}
