import 'dart:async';

import 'package:auth/analytics/analytics.dart';
import 'package:auth/ui/components/footer_builder.dart';
import 'package:auth/ui/components/header_builder.dart';
import 'package:core/logger/logger.dart';
import 'package:design_system/toast/toasts.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui_auth;
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({
    super.key,
    required this.onSignedUp,
    required this.logger,
  });

  final FutureOr<void> Function(BuildContext context) onSignedUp;
  final Logger logger;

  @override
  Widget build(BuildContext context) {
    return ui_auth.RegisterScreen(
      showAuthActionSwitch: false,
      actions: [
        ui_auth.AuthStateChangeAction<ui_auth.SignedIn>((context, state) async {
          logger.d('User registered successfully');

          final method = AuthAnalytics.getAuthMethod(state.user?.providerData);
          unawaited(AuthAnalytics.logSignUpSuccess(method: method));

          await onSignedUp(context);
        }),
        ui_auth.AuthStateChangeAction<ui_auth.UserCreated>((
          context,
          state,
        ) async {
          logger.d('User created successfully');

          final method = AuthAnalytics.getAuthMethod(
            state.credential.user?.providerData,
          );
          unawaited(AuthAnalytics.logSignUpSuccess(method: method));

          await onSignedUp(context);
        }),
        ui_auth.AuthStateChangeAction<ui_auth.AuthFailed>((
          context,
          state,
        ) async {
          logger.e('Registration failed: ${state.exception}');

          unawaited(
            AuthAnalytics.logAuthError(
              errorType: state.exception.runtimeType.toString(),
              flowType: 'sign_up',
              errorMessage: state.exception.toString(),
              method: 'email',
            ),
          );

          Toast.error(context, message: strings.errors.default_error_message);
        }),
      ],
      footerBuilder: (context, action) {
        return footerBuilder(context, action, FooterType.register, logger);
      },
      headerBuilder: (context, constraints, shrinkOffset) {
        return headerBuilder(context);
      },
    );
  }
}
