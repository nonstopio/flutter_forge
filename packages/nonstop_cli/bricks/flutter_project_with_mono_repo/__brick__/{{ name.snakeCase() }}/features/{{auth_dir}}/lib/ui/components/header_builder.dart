import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

/// Banner shown above the sign-in and register forms.
///
/// Deliberately drawn from the theme rather than an image, so a fresh project
/// has no asset to ship and nothing to fetch. Swap it for your own artwork:
/// add the file under the app's `assets:` and use `design_system`'s `Header`
/// with `HeaderType.asset`.
Widget headerBuilder(BuildContext context) {
  final theme = Theme.of(context);

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Column(
      children: [
        Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.bolt_outlined,
            size: 40,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          strings.app.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
