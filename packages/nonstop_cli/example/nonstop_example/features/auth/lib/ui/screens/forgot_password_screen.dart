import 'package:auth/ui/components/header_builder.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui_auth;
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final String? email;

  const ForgotPasswordScreen({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    return ui_auth.ForgotPasswordScreen(
      email: email,
      headerBuilder: (context, constraints, shrinkOffset) {
        return headerBuilder(context);
      },
    );
  }
}
