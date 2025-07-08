import 'package:dzod/dzod.dart';
import 'package:dzod_example/utils/form_validation_extensions.dart';
import 'package:flutter/material.dart';

class ResultDisplay extends StatelessWidget {
  final Schema schema;
  final String title;
  final String value;

  const ResultDisplay({
    super.key,
    required this.schema,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final result = schema.validate(value);
    final isSuccess = result.isSuccess;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSuccess
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : colorScheme.errorContainer.withValues(alpha: 0.3),
        border: Border.all(
          color: isSuccess
              ? colorScheme.primary.withValues(alpha: 0.5)
              : colorScheme.error.withValues(alpha: 0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? colorScheme.primary : colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color:
                          isSuccess ? colorScheme.primary : colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSuccess ? colorScheme.surface : colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: SelectableText(
              result.toDisplayMessage(value),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    color:
                        isSuccess ? colorScheme.onSurface : colorScheme.error,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
