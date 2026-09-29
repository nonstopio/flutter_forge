import 'package:design_system/design_system.dart';
import 'package:developer/developer.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

/// Account tab: identity, settings entry points, sign out.
///
/// This is deliberately thin - hang your real profile feature off it.
class ProfileTabScreen extends StatelessWidget {
  const ProfileTabScreen({super.key, this.onOpenSettings, this.onSignOut});

  /// Shows the settings entry when set; runs when it is tapped.
  final void Function(BuildContext context)? onOpenSettings;

  /// Shows the sign-out action when set; runs after the user confirms.
  final Future<void> Function(BuildContext context)? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(strings.profile.profile)),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 16),
            // Tap the avatar 5x to open developer tools.
            OpenDevToolsWrapper(child: const _ProfileAvatar()),
            const SizedBox(height: 24),
            if (onOpenSettings case final onOpenSettings?)
              ListTile(
                leading: const Icon(NavigationIcons.settings),
                title: Text(strings.profile.settings),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onOpenSettings(context),
              ),
            if (onSignOut case final onSignOut?)
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(strings.auth.sign_out),
                onTap: () => _confirmSignOut(context, onSignOut),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(
    BuildContext context,
    Future<void> Function(BuildContext context) onSignOut,
  ) async {
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

    if (confirmed == true && context.mounted) await onSignOut(context);
  }
}

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
