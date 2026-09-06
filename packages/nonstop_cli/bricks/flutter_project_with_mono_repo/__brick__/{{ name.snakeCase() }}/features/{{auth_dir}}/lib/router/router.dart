import 'package:auth/constants/index.dart';
import 'package:auth/data/services/auth_service.dart';
import 'package:auth/ui/screens/index.dart';
import 'package:core/core.dart' as core;
import 'package:di/di.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthRouter extends core.CoreRouter {
  final Function(BuildContext context) onSignedIn;
  final Function(BuildContext context) onSignedUp;

  AuthRouter({required this.onSignedIn, required this.onSignedUp});

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: AuthRoutes.signIn,
      builder: (context, state) => SignInScreen(onSignedIn: onSignedIn),
    ),
    GoRoute(
      path: AuthRoutes.signUp,
      builder: (context, state) => RegisterScreen(onSignedUp: onSignedUp),
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

final class GoAuthRoute extends GoRoute {
  /// Create a secure route that requires authentication
  GoAuthRoute({
    required super.path,
    required super.builder,
    List<GoRoute> super.routes = const [],
    super.pageBuilder,
  }) : super(
         redirect: (context, state) async {
           if (!di.has<AuthService>()) return null;

           final authService = di.get<AuthService>();

           if (!authService.isSignedIn) {
             return AuthRoutes.signIn;
           }

           return null;
         },
       );
}
