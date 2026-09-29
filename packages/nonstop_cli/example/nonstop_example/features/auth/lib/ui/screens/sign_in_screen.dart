import 'dart:async';

import 'package:auth/analytics/analytics.dart';
import 'package:auth/constants/index.dart';
import 'package:auth/ui/components/footer_builder.dart';
import 'package:auth/ui/components/header_builder.dart';
import 'package:core/core.dart' as core;
import 'package:core/logger/logger.dart';
import 'package:design_system/toast/toasts.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui_auth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({
    super.key,
    required this.onSignedIn,
    required this.logger,
  });

  final FutureOr<void> Function(BuildContext context) onSignedIn;
  final Logger logger;

  @override
  Widget build(BuildContext context) {
    return ui_auth.SignInScreen(
      showAuthActionSwitch: false,
      oauthButtonVariant: ui_auth.OAuthButtonVariant.icon_and_text,
      actions: [
        ui_auth.ForgotPasswordAction((context, email) {
          logger.d('Navigating to forgot password screen');

          final uri = Uri(
            path: AuthRoutes.forgotPassword,
            queryParameters: {core.Keys.email: email},
          );
          context.push(uri.toString());
        }),
        ui_auth.AuthStateChangeAction<ui_auth.SignedIn>((context, state) async {
          logger.d('User signed in successfully');

          final method = AuthAnalytics.getAuthMethod(state.user?.providerData);
          unawaited(AuthAnalytics.logSignInSuccess(method: method));

          await onSignedIn(context);
        }),
        ui_auth.AuthStateChangeAction<ui_auth.UserCreated>((
          context,
          state,
        ) async {
          logger.d('User created from the sign-in screen');

          final method = AuthAnalytics.getAuthMethod(
            state.credential.user?.providerData,
          );
          unawaited(AuthAnalytics.logSignUpSuccess(method: method));

          await onSignedIn(context);
        }),
        ui_auth.AuthStateChangeAction<ui_auth.AuthFailed>((
          context,
          state,
        ) async {
          logger.e('Sign-in failed: ${state.exception}');

          unawaited(
            AuthAnalytics.logAuthError(
              errorType: state.exception.runtimeType.toString(),
              flowType: 'sign_in',
              errorMessage: state.exception.toString(),
            ),
          );

          Toast.error(context, message: strings.errors.default_error_message);
        }),
        //TODO: Handle other AuthState
      ],
      footerBuilder: (context, action) {
        return footerBuilder(context, action, FooterType.signIn, logger);
      },
      headerBuilder: (context, constraints, shrinkOffset) {
        return headerBuilder(context);
      },
    );
  }
}
