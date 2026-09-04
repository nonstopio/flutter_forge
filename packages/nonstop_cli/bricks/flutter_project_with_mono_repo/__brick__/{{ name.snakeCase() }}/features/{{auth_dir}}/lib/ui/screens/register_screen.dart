import 'package:auth/analytics/analytics.dart';
import 'package:auth/ui/components/footer_builder.dart';
import 'package:auth/ui/components/header_builder.dart';
import 'package:core/logger/logger.dart';
import 'package:di/di.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui_auth;
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key, required this.onSignedUp});

  final void Function(BuildContext context) onSignedUp;

  @override
  Widget build(BuildContext context) {
    final logger = di.get<Logger>();

    return ui_auth.RegisterScreen(
      showAuthActionSwitch: false,
      actions: [
        ui_auth.AuthStateChangeAction<ui_auth.SignedIn>((context, state) async {
          logger.d('User registered successfully: ${state.user?.email}');

          final method = AuthAnalytics.getAuthMethod(state.user?.providerData);

          // Log successful sign in (when user already exists)
          AuthAnalytics.logSignInSuccess(
            method: method,
            userEmail: state.user?.email,
          );

          onSignedUp(context);
        }),
        ui_auth.AuthStateChangeAction<ui_auth.UserCreated>((
          context,
          state,
        ) async {
          logger.d(
            'User created successfully: ${state.credential.user?.email}',
          );

          final method = AuthAnalytics.getAuthMethod(
            state.credential.user?.providerData,
          );

          // Log successful sign up
          AuthAnalytics.logSignUpSuccess(
            method: method,
            userEmail: state.credential.user?.email,
          );

          // Log user creation success
          AuthAnalytics.logUserCreationSuccess(
            method: method,
            userEmail: state.credential.user?.email,
          );

          onSignedUp(context);
        }),
        ui_auth.AuthStateChangeAction<ui_auth.AuthFailed>((
          context,
          state,
        ) async {
          logger.e('Registration failed: ${state.exception}');

          // Log auth error
          AuthAnalytics.logAuthError(
            errorType: state.exception.runtimeType.toString(),
            flowType: 'sign_up',
            errorMessage: state.exception.toString(),
            method: 'email',
          );
        }),
      ],
      footerBuilder: (context, action) {
        return footerBuilder(context, action, FooterType.register);
      },
      headerBuilder: (context, constraints, shrinkOffset) {
        return headerBuilder(context);
      },
    );
  }
}
