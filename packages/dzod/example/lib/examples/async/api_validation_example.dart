import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';

import '../../widgets/result_display.dart';
import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class ApiValidationExample extends StatefulWidget {
  const ApiValidationExample({super.key});

  @override
  State<ApiValidationExample> createState() => _ApiValidationExampleState();
}

class _ApiValidationExampleState extends State<ApiValidationExample> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  
  bool _isValidating = false;
  ValidationResult<String?>? _result;

  // Example 15: API Validation with External Service
  // Simulated HTTP response check
  Future<int> simulateHttpGet(String url) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Simulate different responses based on URL
    if (url.contains('example.com')) {
      return 200; // OK
    } else if (url.contains('notfound.com')) {
      return 404; // Not Found
    } else if (url.contains('error.com')) {
      return 500; // Server Error
    }
    return 200; // Default to OK
  }

  late final apiSchema = z.string().url()
      .transformAsync((url) async {
        final statusCode = await simulateHttpGet(url);
        return statusCode == 200 ? url : null;
      })
      .refineAsync(
        (result) async => result != null,
        message: 'URL is not accessible',
      );

  Future<void> _validateUrl() async {
    setState(() {
      _isValidating = true;
      _result = null;
    });

    try {
      final result = await apiSchema.validateAsync(_urlController.text);
      setState(() {
        _result = result;
        _isValidating = false;
      });
    } catch (e) {
      setState(() {
        _isValidating = false;
      });
    }
  }

  void _fillValidExample() {
    setState(() {
      _urlController.text = 'https://example.com/api/users';
    });
  }

  void _fillNotFoundExample() {
    setState(() {
      _urlController.text = 'https://notfound.com/missing';
    });
  }

  void _fillErrorExample() {
    setState(() {
      _urlController.text = 'https://error.com/server-error';
    });
  }

  void _clearInput() {
    setState(() {
      _urlController.clear();
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValidationCard(
      title: 'Example 15: API Validation',
      description: 'Validate URLs by checking their accessibility with simulated HTTP requests.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Simulated responses:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• URLs with "example.com" → 200 OK ✓',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '• URLs with "notfound.com" → 404 Not Found ✗',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '• URLs with "error.com" → 500 Server Error ✗',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // URL input
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'API URL',
                hintText: 'Enter URL to validate',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            
            // Action buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _isValidating ? null : _validateUrl,
                  icon: _isValidating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_done),
                  label: Text(_isValidating ? 'Checking...' : 'Check URL'),
                ),
                OutlinedButton.icon(
                  onPressed: _fillValidExample,
                  icon: const Icon(Icons.check, color: Colors.green),
                  label: const Text('Valid URL'),
                ),
                OutlinedButton.icon(
                  onPressed: _fillNotFoundExample,
                  icon: const Icon(Icons.warning, color: Colors.orange),
                  label: const Text('404 URL'),
                ),
                OutlinedButton.icon(
                  onPressed: _fillErrorExample,
                  icon: const Icon(Icons.error, color: Colors.red),
                  label: const Text('500 URL'),
                ),
              ],
            ),
            
            // Display result if available
            if (_result != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              ResultDisplay(
                schema: apiSchema,
                title: 'API Validation Result',
                value: _urlController.text,
                preValidatedResult: _result,
              ),
            ],
          ],
        ),
      ),
      result: const SizedBox.shrink(), // Result is shown inline
      schemaDisplay: const SchemaDisplay(
        title: 'API Validation Schema',
        code: '''final apiSchema = z.string().url()
    .transformAsync((url) async {
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200 ? url : null;
    })
    .refineAsync(
      (result) async => result != null,
      message: 'URL is not accessible',
    );

// Usage
final result = await apiSchema.validateAsync(url);''',
        description: 'Transform and validate data asynchronously by making API calls.',
      ),
      onValidate: () {}, // Validation is handled by the async button
      onClear: _clearInput,
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}