import 'dart:convert';

import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class ErrorFormattingExample extends StatefulWidget {
  const ErrorFormattingExample({super.key});

  @override
  State<ErrorFormattingExample> createState() => _ErrorFormattingExampleState();
}

class _ErrorFormattingExampleState extends State<ErrorFormattingExample> {
  final _formKey = GlobalKey<FormState>();

  // Example 21: Multiple Error Output Formats
  final userSchema = z.object({
    'name': z.string().min(2).max(50),
    'email': z.string().email(),
    'age': z.number().min(18).max(120),
    'address': z.object({
      'street': z.string().min(5),
      'city': z.string().min(2),
      'zipCode': z.string().regex(RegExp(r'^\d{5}$')),
    }),
  });

  // Test data with multiple errors
  final Map<String, dynamic> invalidData = {
    'name': 'J', // Too short
    'email': 'invalid-email', // Invalid format
    'age': 15, // Too young
    'address': {
      'street': 'St', // Too short
      'city': 'X', // Too short
      'zipCode': '123', // Wrong format
    },
  };

  ValidationResult<Map<String, dynamic>>? _result;
  String _selectedFormat = 'formatted';

  @override
  void initState() {
    super.initState();
    _validate();
  }

  void _validate() {
    setState(() {
      _result = userSchema.validate(invalidData);
    });
  }

  String _getFormattedOutput() {
    if (_result == null || _result!.isSuccess) {
      return 'No errors to display';
    }

    final errors = _result!.errors!;

    switch (_selectedFormat) {
      case 'json':
        // JSON format for APIs
        return const JsonEncoder.withIndent('  ').convert(errors.toJson());

      case 'formatted':
        // Human-readable format
        return errors.formattedErrors;

      case 'individual':
        // Individual error formatting
        return errors.errors
            .map((error) => '${error.fullPath}: ${error.message}')
            .join('\n');

      case 'by_path':
        // Errors grouped by path
        final errorsByPath = <String, List<ValidationError>>{};
        for (final error in errors.errors) {
          final path = error.fullPath;
          errorsByPath.putIfAbsent(path, () => []).add(error);
        }

        final buffer = StringBuffer();
        errorsByPath.forEach((path, pathErrors) {
          buffer.writeln('$path:');
          for (final error in pathErrors) {
            buffer.writeln('  - ${error.message}');
          }
        });
        return buffer.toString();

      case 'custom':
        // Custom format with emojis
        final buffer = StringBuffer();
        buffer.writeln(
            '❌ Validation failed with ${errors.errors.length} errors:\n');

        for (final error in errors.errors) {
          final icon = _getErrorIcon(error.code);
          buffer.writeln('$icon ${error.fullPath}');
          buffer.writeln('   └─ ${error.message}');
          buffer.writeln('      Expected: ${error.expected}');
          if (error.received != null) {
            buffer.writeln('      Received: ${error.received}');
          }
          buffer.writeln();
        }
        return buffer.toString();

      default:
        return 'Unknown format';
    }
  }

  String _getErrorIcon(dynamic code) {
    switch (code.toString()) {
      case 'invalidEmail':
        return '📧';
      case 'minLength':
      case 'maxLength':
        return '📏';
      case 'min':
      case 'max':
        return '🔢';
      case 'invalidType':
        return '❓';
      case 'regex':
        return '🔤';
      default:
        return '⚠️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValidationCard(
      title: 'Example 21: Error Formatting',
      description:
          'Multiple ways to format validation errors for different use cases.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test data display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Data (with errors):',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      const JsonEncoder.withIndent('  ').convert(invalidData),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Format selector
            DropdownButtonFormField<String>(
              value: _selectedFormat,
              onChanged: (value) {
                setState(() {
                  _selectedFormat = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Error Format',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.format_list_bulleted),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'formatted',
                  child: Text('Human-readable'),
                ),
                DropdownMenuItem(
                  value: 'json',
                  child: Text('JSON (for APIs)'),
                ),
                DropdownMenuItem(
                  value: 'individual',
                  child: Text('Individual Errors'),
                ),
                DropdownMenuItem(
                  value: 'by_path',
                  child: Text('Grouped by Path'),
                ),
                DropdownMenuItem(
                  value: 'custom',
                  child: Text('Custom with Emojis'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Formatted output
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Output:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: _getFormattedOutput()),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 20),
                        tooltip: 'Copy to clipboard',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getFormattedOutput(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      result: const SizedBox.shrink(), // Result shown in formatted output
      schemaDisplay: const SchemaDisplay(
        title: 'Error Formatting Methods',
        code: '''// JSON format for APIs
final jsonErrors = errors.toJson();

// Human-readable format
final readable = errors.formattedErrors;

// Individual error formatting
for (final error in errors.errors) {
  print('\${error.fullPath}: \${error.message}');
}

// Custom error collection analysis
final errorsByPath = <String, List<ValidationError>>{};
for (final error in errors.errors) {
  errorsByPath.putIfAbsent(error.fullPath, () => []).add(error);
}''',
        description:
            'Format errors for different contexts: APIs, user interfaces, or logging.',
      ),
      onValidate: _validate,
      onClear: () {},
    );
  }
}
