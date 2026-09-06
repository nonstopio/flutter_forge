{{#auth}}import 'package:auth/auth.dart' as auth;
{{/auth}}{{^dashboard}}import 'package:core/core.dart' as core;
{{/dashboard}}{{#dashboard}}import 'package:dashboard/dashboard.dart';
{{/dashboard}}import 'package:design_system/design_system.dart';
{{#auth}}import 'package:di/di.dart';
{{/auth}}import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

/// First frame the user sees.
///
/// It exists to give async startup work (session restore, profile fetch) a
/// place to happen before the app commits to a destination.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  Future<void> _redirect() async {
    if (!mounted) return;
{{#auth}}
    if (di.has<auth.AuthService>() &&
        !di.get<auth.AuthService>().isSignedIn) {
      context.go(auth.AuthRoutes.signIn);
      return;
    }
{{/auth}}
    // TODO: load whatever the first screen needs before navigating.
    context.go({{#dashboard}}DashboardRouter.home{{/dashboard}}{{^dashboard}}core.CoreRoutes.home{{/dashboard}});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              strings.app.name,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const DefaultLoader(),
          ],
        ),
      ),
    );
  }
}
