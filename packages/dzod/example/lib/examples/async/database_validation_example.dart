import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';

import '../../widgets/result_display.dart';
import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class DatabaseValidationExample extends StatefulWidget {
  const DatabaseValidationExample({super.key});

  @override
  State<DatabaseValidationExample> createState() =>
      _DatabaseValidationExampleState();
}

class _DatabaseValidationExampleState extends State<DatabaseValidationExample> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _isValidating = false;
  ValidationResult<Map<String, dynamic>>? _result;

  // Example 14: Database Validation
  // Simulated database of existing emails and usernames
  static final Set<String> _existingEmails = {
    'john@example.com',
    'jane@example.com',
    'admin@example.com',
  };

  static final Set<String> _existingUsernames = {
    'johndoe',
    'janedoe',
    'admin',
  };

  // Simulated async database check functions
  Future<bool> checkEmailExists(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _existingEmails.contains(email.toLowerCase());
  }

  Future<bool> checkUsernameAvailable(String username) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return !_existingUsernames.contains(username.toLowerCase());
  }

  late final userSchema = z.object({
    'email': z.string().email().refineAsync(
      (email) async {
        final exists = await checkEmailExists(email);
        return !exists;
      },
      message: 'Email already exists',
    ),
    'username': z.string().min(3).refineAsync(
      (username) async {
        final available = await checkUsernameAvailable(username);
        return available;
      },
      message: 'Username not available',
    ),
  });

  Future<void> _validateAsync() async {
    setState(() {
      _isValidating = true;
      _result = null;
    });

    final data = {
      'email': _emailController.text,
      'username': _usernameController.text,
    };

    try {
      final result = await userSchema.validateAsync(data);
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

  void _fillAvailableExample() {
    setState(() {
      _emailController.text = 'newuser@example.com';
      _usernameController.text = 'newuser';
    });
  }

  void _fillTakenExample() {
    setState(() {
      _emailController.text = 'john@example.com';
      _usernameController.text = 'johndoe';
    });
  }

  void _clearInputs() {
    setState(() {
      _emailController.clear();
      _usernameController.clear();
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValidationCard(
      title: 'Example 14: Database Validation',
      description:
          'Async validation with simulated database checks for email and username availability.',
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
                      'Existing records (for demo):',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Emails: ${_existingEmails.join(', ')}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Usernames: ${_existingUsernames.join(', ')}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Email input
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter email address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Username input
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Enter username (min 3 chars)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Wrap(
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _isValidating ? null : _validateAsync,
                  icon: _isValidating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle),
                  label:
                      Text(_isValidating ? 'Validating...' : 'Validate Async'),
                ),
                OutlinedButton.icon(
                  onPressed: _fillAvailableExample,
                  icon: const Icon(Icons.check),
                  label: const Text('Available Example'),
                ),
                OutlinedButton.icon(
                  onPressed: _fillTakenExample,
                  icon: const Icon(Icons.close),
                  label: const Text('Taken Example'),
                ),
              ],
            ),

            // Display result if available
            if (_result != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              ResultDisplay(
                schema: userSchema,
                title: 'Async Validation Result',
                value: {
                  'email': _emailController.text,
                  'username': _usernameController.text,
                },
                preValidatedResult: _result,
              ),
            ],
          ],
        ),
      ),
      result: const SizedBox.shrink(), // Result is shown inline
      schemaDisplay: const SchemaDisplay(
        title: 'Database Validation Schema',
        code: '''final userSchema = z.object({
  'email': z.string().email().refineAsync(
    (email) async {
      final exists = await checkEmailExists(email);
      return !exists;
    },
    message: 'Email already exists',
  ),
  'username': z.string().min(3).refineAsync(
    (username) async {
      final available = await checkUsernameAvailable(username);
      return available;
    },
    message: 'Username not available',
  ),
});

// Usage
final result = await userSchema.validateAsync(data);''',
        description:
            'Async validation allows checking against external resources like databases or APIs.',
      ),
      onValidate: () {}, // Validation is handled by the async button
      onClear: _clearInputs,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
