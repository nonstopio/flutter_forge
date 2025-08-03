import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';

import '../../widgets/result_display.dart';
import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class ErrorCodeSystemExample extends StatefulWidget {
  const ErrorCodeSystemExample({super.key});

  @override
  State<ErrorCodeSystemExample> createState() => _ErrorCodeSystemExampleState();
}

class _ErrorCodeSystemExampleState extends State<ErrorCodeSystemExample> {
  final _formKey = GlobalKey<FormState>();
  final _dataController = TextEditingController();

  ValidationResult<Map<String, dynamic>>? _result;
  String _selectedExample = 'invalid_email';

  // Example 20: Error Code System
  final schema = z.object({
    'email': z.string().email(),
    'age': z.number().min(18).max(120),
    'username': z.string().min(3).max(20),
    'password': z.string().min(8).regex(
          RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)'),
        ),
  });

  final Map<String, Map<String, dynamic>> _examples = {
    'invalid_email': {
      'email': 'invalid-email',
      'age': 25,
      'username': 'johndoe',
      'password': 'SecurePass123',
    },
    'invalid_type': {
      'email': 'user@example.com',
      'age': 'twenty-five', // Wrong type
      'username': 'johndoe',
      'password': 'SecurePass123',
    },
    'out_of_range': {
      'email': 'user@example.com',
      'age': 150, // Too old
      'username': 'jo', // Too short
      'password': 'short', // Too short
    },
    'multiple_errors': {
      'email': 'invalid',
      'age': -5,
      'username': 'a',
      'password': 'weak',
    },
  };

  void _validate() {
    final data = _examples[_selectedExample]!;
    setState(() {
      _result = schema.validate(data);
      _dataController.text = _formatData(data);
    });
  }

  String _formatData(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }

  Widget _buildErrorDetails() {
    if (_result == null || _result!.isSuccess) {
      return const SizedBox.shrink();
    }

    final errors = _result!.errors!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Error Details (${errors.errors.length} errors)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...errors.errors.map((error) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Field: ${error.fullPath}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildErrorProperty('Code', error.code.toString()),
                    _buildErrorProperty('Message', error.message),
                    _buildErrorProperty('Expected', error.expected.toString()),
                    if (error.received != null)
                      _buildErrorProperty(
                          'Received', error.received.toString()),
                    if (error.context?.isNotEmpty ?? false)
                      _buildErrorProperty('Context', error.context.toString()),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 16),

        // Error filtering examples
        Text(
          'Error Analysis',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total errors: ${errors.errors.length}'),
                Text('Has errors: ${errors.errors.isNotEmpty}'),
                Text('First error: ${errors.errors.first.message}'),
                const SizedBox(height: 8),
                Text(
                    'Unique error codes: ${errors.errors.map((e) => e.code.toString()).toSet().join(', ')}'),
                const SizedBox(height: 8),
                // Email errors count
                Text(
                    'Email field errors: ${errors.errors.where((e) => e.fullPath.contains('email')).length}'),
                // Type errors count
                Text('Total validation errors: ${errors.errors.length}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorProperty(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValidationCard(
      title: 'Example 20: Error Code System',
      description:
          'Comprehensive error handling with 100+ standardized error codes.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example selector
            DropdownButtonFormField<String>(
              value: _selectedExample,
              onChanged: (value) {
                setState(() {
                  _selectedExample = value!;
                  _result = null;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Error Example',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.bug_report),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'invalid_email',
                  child: Text('Invalid Email'),
                ),
                DropdownMenuItem(
                  value: 'invalid_type',
                  child: Text('Type Errors'),
                ),
                DropdownMenuItem(
                  value: 'out_of_range',
                  child: Text('Out of Range'),
                ),
                DropdownMenuItem(
                  value: 'multiple_errors',
                  child: Text('Multiple Errors'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Data display
            TextFormField(
              controller: _dataController,
              readOnly: true,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Test Data',
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),

            // Error details
            _buildErrorDetails(),
          ],
        ),
      ),
      result: _result != null
          ? ResultDisplay(
              schema: schema,
              title: 'Validation Result',
              value: _examples[_selectedExample]!,
              preValidatedResult: _result,
            )
          : const SizedBox.shrink(),
      schemaDisplay: const SchemaDisplay(
        title: 'Error Code System',
        code: '''// Access error details
if (result.isFailure) {
  final errors = result.errors!;
  
  for (final error in errors.errors) {
    print('Code: \${error.code}');
    print('Message: \${error.message}');
    print('Path: \${error.fullPath}');
    print('Expected: \${error.expected}');
    print('Received: \${error.received}');
    print('Context: \${error.context}');
  }
  
  // Error filtering
  final emailErrors = errors.filterByPath(['email']);
  final typeErrors = errors.filterByCode(ValidationErrorCode.invalidEmail);
}''',
        description:
            'Dzod provides comprehensive error information with standardized codes.',
      ),
      onValidate: _validate,
      onClear: () {
        setState(() {
          _result = null;
          _dataController.clear();
        });
      },
    );
  }

  @override
  void dispose() {
    _dataController.dispose();
    super.dispose();
  }
}
