import 'package:auth/analytics/analytics.dart';
import 'package:auth/constants/index.dart';
import 'package:auth/ui/components/footer_builder.dart';
import 'package:auth/ui/components/header_builder.dart';
import 'package:core/core.dart' as core;
import 'package:core/logger/logger.dart';
import 'package:design_system/toast/toasts.dart';
import 'package:di/di.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui_auth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key, required this.onSignedIn});

  final Function(BuildContext context) onSignedIn;

  @override
  Widget build(BuildContext context) {
    final logger = di.get<Logger>();

    return ui_auth.SignInScreen(
      showAuthActionSwitch: false,
      oauthButtonVariant: ui_auth.OAuthButtonVariant.icon_and_text,
      actions: [
        ui_auth.ForgotPasswordAction((context, email) {
          logger.d('Navigating to forgot password screen for email: $email');

          final uri = Uri(
            path: AuthRoutes.forgotPassword,
            queryParameters: {core.Keys.email: email},
          );
          context.push(uri.toString());
        }),
        ui_auth.AuthStateChangeAction<ui_auth.SignedIn>((context, state) async {
          logger.d('User signed in successfully: ${state.user?.email}');

          final method = AuthAnalytics.getAuthMethod(state.user?.providerData);

          // Log successful sign in
          AuthAnalytics.logSignInSuccess(
            method: method,
            userEmail: state.user?.email,
          );

          onSignedIn(context);
        }),
        ui_auth.AuthStateChangeAction<ui_auth.UserCreated>((
          context,
          state,
        ) async {
          logger.d(
            'User signed in successfully: ${state.credential.user?.email}',
          );

          final method = AuthAnalytics.getAuthMethod(
            state.credential.user?.providerData,
          );

          // Log successful user creation (from sign in screen)
          AuthAnalytics.logUserCreationSuccess(
            method: method,
            userEmail: state.credential.user?.email,
          );

          onSignedIn(context);
        }),
        ui_auth.AuthStateChangeAction<ui_auth.AuthFailed>((
          context,
          state,
        ) async {
          logger.e('Sign-in failed: ${state.exception}');

          // Log auth error
          AuthAnalytics.logAuthError(
            errorType: state.exception.runtimeType.toString(),
            flowType: 'sign_in',
            errorMessage: state.exception.toString(),
          );

          Toast.error(context, message: strings.errors.default_error_message);
        }),
        //TODO: Handle other AuthState
      ],
      footerBuilder: (context, action) {
        return footerBuilder(context, action, FooterType.signIn);
      },
      headerBuilder: (context, constraints, shrinkOffset) {
        return headerBuilder(context);
      },
    );
  }
}
