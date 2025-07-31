import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';

import '../../widgets/result_display.dart';
import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class AuthenticationSchemaExample extends StatefulWidget {
  const AuthenticationSchemaExample({super.key});

  @override
  State<AuthenticationSchemaExample> createState() =>
      _AuthenticationSchemaExampleState();
}

class _AuthenticationSchemaExampleState
    extends State<AuthenticationSchemaExample> {
  final _formKey = GlobalKey<FormState>();
  String _selectedMethod = 'email';
  
  // Controllers for different auth methods
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _providerController = TextEditingController(text: 'google');
  final _tokenController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _apiSecretController = TextEditingController();

  // Example 32: Advanced Authentication Schema
  final authSchema = z.discriminatedUnion('method', [
    // Email/password authentication
    z.object({
      'method': z.literal('email'),
      'email': z.string().email(),
      'password': z.string().min(8).max(128)
          .refine(
            (password) => RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@\$!%*?&])[A-Za-z\d@\$!%*?&]').hasMatch(password),
          ),
    }),

    // OAuth authentication
    z.object({
      'method': z.literal('oauth'),
      'provider': z.enum_(['google', 'github', 'facebook']),
      'token': z.string().jwt(),
    }),

    // API key authentication
    z.object({
      'method': z.literal('apikey'),
      'key': z.string().length(32).hex(),
      'secret': z.string().length(64).hex(),
    }),
  ]);

  Map<String, dynamic> _buildAuthData() {
    switch (_selectedMethod) {
      case 'email':
        return {
          'method': 'email',
          'email': _emailController.text,
          'password': _passwordController.text,
        };
      case 'oauth':
        return {
          'method': 'oauth',
          'provider': _providerController.text,
          'token': _tokenController.text,
        };
      case 'apikey':
        return {
          'method': 'apikey',
          'key': _apiKeyController.text,
          'secret': _apiSecretController.text,
        };
      default:
        return {};
    }
  }

  void _fillValidExample() {
    setState(() {
      switch (_selectedMethod) {
        case 'email':
          _emailController.text = 'user@example.com';
          _passwordController.text = 'SecurePass123!';
          break;
        case 'oauth':
          _providerController.text = 'google';
          _tokenController.text = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
          break;
        case 'apikey':
          _apiKeyController.text = '12345678901234567890123456789012';
          _apiSecretController.text = '1234567890123456789012345678901234567890123456789012345678901234';
          break;
      }
    });
  }

  void _fillInvalidExample() {
    setState(() {
      switch (_selectedMethod) {
        case 'email':
          _emailController.text = 'invalid-email';
          _passwordController.text = 'weak';
          break;
        case 'oauth':
          _providerController.text = 'google';
          _tokenController.text = 'invalid-jwt-token';
          break;
        case 'apikey':
          _apiKeyController.text = 'too-short';
          _apiSecretController.text = 'not-hex';
          break;
      }
    });
  }

  void _clearInputs() {
    setState(() {
      _emailController.clear();
      _passwordController.clear();
      _tokenController.clear();
      _apiKeyController.clear();
      _apiSecretController.clear();
    });
  }

  Widget _buildAuthMethodForm() {
    switch (_selectedMethod) {
      case 'email':
        return Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'user@example.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Min 8 chars, uppercase, lowercase, number, special',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password Requirements:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    const Text('• At least 8 characters', style: TextStyle(fontSize: 12)),
                    const Text('• One uppercase letter', style: TextStyle(fontSize: 12)),
                    const Text('• One lowercase letter', style: TextStyle(fontSize: 12)),
                    const Text('• One number', style: TextStyle(fontSize: 12)),
                    const Text('• One special character (@\$!%*?&)', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        );
      
      case 'oauth':
        return Column(
          children: [
            DropdownButtonFormField<String>(
              value: _providerController.text,
              onChanged: (value) {
                setState(() {
                  _providerController.text = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'OAuth Provider',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_box),
              ),
              items: const [
                DropdownMenuItem(value: 'google', child: Text('Google')),
                DropdownMenuItem(value: 'github', child: Text('GitHub')),
                DropdownMenuItem(value: 'facebook', child: Text('Facebook')),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tokenController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'JWT Token',
                hintText: 'Paste your JWT token here',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key),
                alignLabelWithHint: true,
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        );
      
      case 'apikey':
        return Column(
          children: [
            TextFormField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: '32 character hex string',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
              ),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _apiSecretController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'API Secret',
                hintText: '64 character hex string',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'API credentials must be hexadecimal strings of exact length',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMethodIcon(String method) {
    IconData icon;
    Color? color;
    
    switch (method) {
      case 'email':
        icon = Icons.email;
        color = Colors.blue;
        break;
      case 'oauth':
        icon = Icons.account_circle;
        color = Colors.orange;
        break;
      case 'apikey':
        icon = Icons.vpn_key;
        color = Colors.green;
        break;
      default:
        icon = Icons.lock;
        color = null;
    }
    
    return Icon(icon, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return ValidationCard(
      title: 'Example 32: Authentication Schema',
      description: 'Advanced authentication patterns for different auth methods.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auth method selector
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                  _clearInputs();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Authentication Method',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.security),
              ),
              items: ['email', 'oauth', 'apikey'].map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Row(
                    children: [
                      _buildMethodIcon(method),
                      const SizedBox(width: 8),
                      Text(method == 'email' 
                          ? 'Email/Password' 
                          : method == 'oauth' 
                          ? 'OAuth Provider'
                          : 'API Key'),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            // Dynamic form based on auth method
            _buildAuthMethodForm(),
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _fillValidExample,
                  icon: const Icon(Icons.check),
                  label: const Text('Valid Example'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _fillInvalidExample,
                  icon: const Icon(Icons.close),
                  label: const Text('Invalid Example'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _clearInputs,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
      result: ResultDisplay(
        schema: authSchema,
        title: 'Authentication Validation Result',
        value: _buildAuthData(),
      ),
      schemaDisplay: const SchemaDisplay(
        title: 'Authentication Schema',
        code: '''final authSchema = z.discriminatedUnion('method', [
  // Email/password
  z.object({
    'method': z.literal('email'),
    'email': z.string().email(),
    'password': z.string().min(8).max(128),
  }),

  // OAuth
  z.object({
    'method': z.literal('oauth'),
    'provider': z.enum_(['google', 'github', 'facebook']),
    'token': z.string().jwt(),
  }),

  // API key
  z.object({
    'method': z.literal('apikey'),
    'key': z.string().length(32).hex(),
    'secret': z.string().length(64).hex(),
  }),
]);

// Validate different auth methods
final emailAuth = authSchema.parse({
  'method': 'email',
  'email': 'user@example.com',
  'password': 'securepassword123',
});''',
        description: 'Discriminated unions enable type-safe authentication with multiple methods.',
      ),
      onValidate: () {
        _formKey.currentState?.validate();
      },
      onClear: _clearInputs,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _providerController.dispose();
    _tokenController.dispose();
    _apiKeyController.dispose();
    _apiSecretController.dispose();
    super.dispose();
  }
}