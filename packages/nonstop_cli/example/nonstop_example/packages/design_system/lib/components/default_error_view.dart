import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class DefaultErrorView extends StatelessWidget {
  const DefaultErrorView({
    super.key,
    this.error,
    this.stackTrace,
    this.onRetry,
    this.descriptionBuilder,
    this.padding,
  });

  final Object? error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;
  final String? Function(Object?)? descriptionBuilder;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final title = strings.errors.default_error_message;
    final description = descriptionBuilder?.call(error);

    return SafeArea(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.error.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 20,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (error != null && kDebugMode) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: SelectableText(
                    'type:${error.runtimeType}:\n$error\n${stackTrace?.toString() ?? ''}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.left,
                    maxLines: 10,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (onRetry != null)
                    OutlinedButton(
                      onPressed: onRetry,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        minimumSize: const Size(88, 44),
                      ),
                      child: Text(strings.generic.try_again),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
