import 'package:flutter/material.dart';

class ValidationCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget form;
  final Widget? result;
  final Widget? schemaDisplay;
  final VoidCallback? onValidate;
  final VoidCallback? onClear;

  const ValidationCard({
    super.key,
    required this.title,
    required this.description,
    required this.form,
    this.result,
    this.schemaDisplay,
    this.onValidate,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.verified_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form section
            form,
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onValidate,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Validate'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),
                ),
              ],
            ),

            // Result section
            if (result != null) ...[
              const SizedBox(height: 24),
              result!,
            ],

            // Schema display section
            if (schemaDisplay != null) ...[
              const SizedBox(height: 24),
              schemaDisplay!,
            ],
          ],
        ),
      ),
    );
  }
}
