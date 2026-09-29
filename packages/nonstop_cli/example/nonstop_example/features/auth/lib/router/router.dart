import 'dart:async';

import 'package:auth/constants/index.dart';
import 'package:auth/data/services/auth_service.dart';
import 'package:auth/ui/screens/index.dart';
import 'package:core/core.dart' as core;
import 'package:di/di.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthRouter implements core.CoreRouter {
  final FutureOr<void> Function(BuildContext context) onSignedIn;
  final FutureOr<void> Function(BuildContext context) onSignedUp;

  AuthRouter({required this.onSignedIn, required this.onSignedUp});

  final core.Logger _logger = di.get<core.Logger>();

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: AuthRoutes.signIn,
      builder: (context, state) =>
          SignInScreen(onSignedIn: onSignedIn, logger: _logger),
    ),
    GoRoute(
      path: AuthRoutes.signUp,
      builder: (context, state) =>
          RegisterScreen(onSignedUp: onSignedUp, logger: _logger),
    ),
    GoRoute(
      path: AuthRoutes.forgotPassword,
      builder: (context, state) {
        final email = state.uri.queryParameters[core.Keys.email];
        return ForgotPasswordScreen(email: email);
      },
    ),
  ];
}

/// Where a user must go before continuing: sign-in, or null when signed in.
///
/// [allowUnconfigured] lets the user through while auth is not set up yet (the
/// demo before `flutterfire configure`). Never use it for protected data.
String? authRedirectLocation({bool allowUnconfigured = false}) {
  if (!di.has<AuthService>()) {
    return allowUnconfigured ? null : AuthRoutes.signIn;
  }
  return di.get<AuthService>().isSignedIn ? null : AuthRoutes.signIn;
}

/// Route guard form of [authRedirectLocation].
GoRouterRedirect authRedirect({bool allowUnconfigured = false}) =>
    (context, state) =>
        authRedirectLocation(allowUnconfigured: allowUnconfigured);

/// Signs the user out and returns to sign-in. Hand this to features that
/// offer sign-out so they never depend on this package.
Future<void> signOut(BuildContext context) async {
  if (!di.has<AuthService>()) return;
  await di.get<AuthService>().signOut();
  if (context.mounted) context.go(AuthRoutes.signIn);
}

final class GoAuthRoute extends GoRoute {
  /// Create a secure route that requires authentication
  GoAuthRoute({
    required super.path,
    required super.builder,
    List<GoRoute> super.routes = const [],
    super.pageBuilder,
    bool allowUnconfigured = false,
  }) : super(redirect: authRedirect(allowUnconfigured: allowUnconfigured));
}
