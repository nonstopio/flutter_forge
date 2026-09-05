{{#auth}}import 'package:auth/auth.dart' as auth;
{{/auth}}import 'package:design_system/design_system.dart';
{{#developer}}import 'package:developer/developer.dart';
{{/developer}}{{#auth}}import 'package:di/di.dart';
{{/auth}}import 'package:flutter/material.dart';
{{#auth}}import 'package:go_router/go_router.dart';
{{/auth}}import 'package:localization/localization.dart';

/// Account tab: identity, settings entry points, sign out.
///
/// This is deliberately thin - hang your real profile feature off it.
class ProfileTabScreen extends StatelessWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(strings.profile.profile)),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 16),
            {{#developer}}// Tap the avatar 5x to open developer tools.
            OpenDevToolsWrapper(child: const _ProfileAvatar()),{{/developer}}{{^developer}}const _ProfileAvatar(),{{/developer}}
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(NavigationIcons.settings),
              title: Text(strings.profile.settings),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            {{#auth}}ListTile(
              leading: const Icon(Icons.logout),
              title: Text(strings.auth.sign_out),
              onTap: () => _confirmSignOut(context),
            ),{{/auth}}
          ],
        ),
      ),
    );
  }
{{#auth}}
  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.auth.sign_out),
        content: Text(strings.auth.sign_out_confirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.generic.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.auth.sign_out),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await di.get<auth.AuthService>().signOut();
    if (context.mounted) context.go(auth.AuthRoutes.signIn);
  }
{{/auth}}}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: CircleAvatar(
        radius: 44,
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(
          NavigationIcons.profileSelected,
          size: 44,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
