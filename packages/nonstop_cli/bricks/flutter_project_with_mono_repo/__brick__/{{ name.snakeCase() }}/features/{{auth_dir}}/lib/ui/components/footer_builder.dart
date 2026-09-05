import 'package:auth/constants/index.dart';
import 'package:core/logger/logger.dart';
import 'package:di/di.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

enum FooterType { signIn, register }

Widget footerBuilder(BuildContext context, AuthAction action, FooterType type) {
  final logger = di.get<Logger>();
  switch (type) {
    case FooterType.signIn:
      return _AuthFooter(
        title: strings.auth.dont_have_account,
        linkText: strings.auth.register,
        onTap: () {
          logger.d('Navigating to register screen');

          context.go(AuthRoutes.signUp);
        },
      );
    case FooterType.register:
      return _AuthFooter(
        title: strings.auth.already_have_account,
        linkText: strings.auth.sign_in,
        onTap: () {
          logger.d('Navigating to sign in screen');

          context.go(AuthRoutes.signIn);
        },
      );
  }
}

class _AuthFooter extends StatelessWidget {
  final String title;
  final String linkText;
  final VoidCallback onTap;

  const _AuthFooter({
    required this.title,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          GestureDetector(
            onTap: onTap,
            child: Text(
              linkText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
