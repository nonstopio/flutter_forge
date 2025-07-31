import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';

import '../../widgets/result_display.dart';
import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class SecurityBestPracticesExample extends StatefulWidget {
  const SecurityBestPracticesExample({super.key});

  @override
  State<SecurityBestPracticesExample> createState() =>
      _SecurityBestPracticesExampleState();
}

class _SecurityBestPracticesExampleState
    extends State<SecurityBestPracticesExample> {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _apiKeyController = TextEditingController();
  
  String _selectedExample = 'sanitization';
  bool _isValidating = false;
  ValidationResult? _result;

  // Example 30: Security Best Practices
  
  // Input sanitization
  final sanitizedSchema = z.string()
      .trim() // Remove whitespace
      .max(1000) // Prevent DoS
      .refine(
        (value) => !value.contains('<script>'),
        message: 'XSS attempt detected',
      );

  // Simulated rate limit tracking
  final Map<String, List<DateTime>> _rateLimitTracker = {};
  
  bool checkRateLimit(String email) {
    final now = DateTime.now();
    final attempts = _rateLimitTracker[email] ?? [];
    
    // Remove attempts older than 1 minute
    attempts.removeWhere((time) => now.difference(time).inMinutes > 1);
    
    // Check if rate limit exceeded (max 3 attempts per minute)
    if (attempts.length >= 3) {
      return false;
    }
    
    // Add current attempt
    attempts.add(now);
    _rateLimitTracker[email] = attempts;
    return true;
  }

  // Rate limiting validation
  late final rateLimitedSchema = z.object({
    'email': z.string().email(),
    'message': z.string().max(5000),
  }).refine(
    (data) => checkRateLimit(data['email'] as String),
    message: 'Rate limit exceeded. Please try again later.',
  );

  // Simulated API key validation
  Future<bool> validateApiKey(String key) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Simulate valid keys (in real app, check against secure storage)
    const validKeys = {
      'a1b2c3d4e5f6789012345678901234567890123456789012345678901234abcd',
      'test1234567890abcdef1234567890abcdef1234567890abcdef1234567890ab',
    };
    
    return validKeys.contains(key);
  }

  // API key validation
  late final apiKeySchema = z.string()
      .length(64) // Exact length
      .hex() // Hexadecimal format
      .refineAsync(
        (key) => validateApiKey(key),
        message: 'Invalid API key',
      );

  // SQL injection prevention
  final sqlSafeSchema = z.string()
      .max(255)
      .refine(
        (value) => !RegExp(r"(';|--;|\/\*|\*\/|xp_|sp_|UNION|SELECT|INSERT|UPDATE|DELETE|DROP)", caseSensitive: false).hasMatch(value),
        message: 'Potentially dangerous SQL pattern detected',
      );

  // Path traversal prevention
  final pathSafeSchema = z.string()
      .max(255)
      .refine(
        (value) => !value.contains('..') && !value.contains('~') && !RegExp(r'[<>:|?*]').hasMatch(value),
        message: 'Invalid path characters detected',
      );

  Future<void> _validateInput() async {
    setState(() {
      _isValidating = true;
      _result = null;
    });

    try {
      switch (_selectedExample) {
        case 'sanitization':
          _result = sanitizedSchema.validate(_inputController.text);
          break;
        case 'rateLimit':
          _result = rateLimitedSchema.validate({
            'email': _emailController.text,
            'message': _messageController.text,
          });
          break;
        case 'apiKey':
          _result = await apiKeySchema.validateAsync(_apiKeyController.text);
          break;
        case 'sqlInjection':
          _result = sqlSafeSchema.validate(_inputController.text);
          break;
        case 'pathTraversal':
          _result = pathSafeSchema.validate(_inputController.text);
          break;
      }
    } catch (e) {
      // Handle validation errors
    } finally {
      setState(() {
        _isValidating = false;
      });
    }
  }

  void _fillExample() {
    setState(() {
      switch (_selectedExample) {
        case 'sanitization':
          _inputController.text = '  <script>alert("XSS")</script>  ';
          break;
        case 'rateLimit':
          _emailController.text = 'test@example.com';
          _messageController.text = 'This is a test message';
          break;
        case 'apiKey':
          _apiKeyController.text = 'a1b2c3d4e5f6789012345678901234567890123456789012345678901234abcd';
          break;
        case 'sqlInjection':
          _inputController.text = "'; DROP TABLE users; --";
          break;
        case 'pathTraversal':
          _inputController.text = '../../../etc/passwd';
          break;
      }
    });
  }

  void _clearInputs() {
    setState(() {
      _inputController.clear();
      _emailController.clear();
      _messageController.clear();
      _apiKeyController.clear();
      _result = null;
    });
  }

  Widget _buildInputFields() {
    switch (_selectedExample) {
      case 'rateLimit':
        return Column(
          children: [
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
            TextFormField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Enter your message',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
              ),
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
                        'Rate limit: 3 attempts per minute per email',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      
      case 'apiKey':
        return Column(
          children: [
            TextFormField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'Enter 64-character hex API key',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key),
              ),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valid test keys:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'a1b2c3d4e5f6789012345678901234567890123456789012345678901234abcd',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      
      default:
        return TextFormField(
          controller: _inputController,
          maxLines: _selectedExample == 'sanitization' ? 3 : 1,
          decoration: InputDecoration(
            labelText: _getInputLabel(),
            hintText: _getInputHint(),
            border: const OutlineInputBorder(),
            prefixIcon: Icon(_getInputIcon()),
          ),
        );
    }
  }

  String _getInputLabel() {
    switch (_selectedExample) {
      case 'sanitization':
        return 'User Input';
      case 'sqlInjection':
        return 'Database Query Parameter';
      case 'pathTraversal':
        return 'File Path';
      default:
        return 'Input';
    }
  }

  String _getInputHint() {
    switch (_selectedExample) {
      case 'sanitization':
        return 'Enter text (XSS attempts will be blocked)';
      case 'sqlInjection':
        return 'Enter search term';
      case 'pathTraversal':
        return 'Enter file path';
      default:
        return 'Enter value';
    }
  }

  IconData _getInputIcon() {
    switch (_selectedExample) {
      case 'sanitization':
        return Icons.security;
      case 'sqlInjection':
        return Icons.storage;
      case 'pathTraversal':
        return Icons.folder;
      default:
        return Icons.input;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValidationCard(
      title: 'Example 30: Security Best Practices',
      description: 'Implement secure validation patterns to protect against common attacks.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security example selector
            DropdownButtonFormField<String>(
              value: _selectedExample,
              onChanged: (value) {
                setState(() {
                  _selectedExample = value!;
                  _clearInputs();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Security Pattern',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shield),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'sanitization',
                  child: Text('Input Sanitization (XSS Prevention)'),
                ),
                DropdownMenuItem(
                  value: 'rateLimit',
                  child: Text('Rate Limiting'),
                ),
                DropdownMenuItem(
                  value: 'apiKey',
                  child: Text('API Key Validation'),
                ),
                DropdownMenuItem(
                  value: 'sqlInjection',
                  child: Text('SQL Injection Prevention'),
                ),
                DropdownMenuItem(
                  value: 'pathTraversal',
                  child: Text('Path Traversal Prevention'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Dynamic input fields
            _buildInputFields(),
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _isValidating ? null : _validateInput,
                  icon: _isValidating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.security),
                  label: Text(_isValidating ? 'Validating...' : 'Validate Securely'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _fillExample,
                  icon: const Icon(Icons.warning),
                  label: const Text('Malicious Example'),
                ),
              ],
            ),
            
            // Display result if available
            if (_result != null) ...[
              const SizedBox(height: 24),
              ResultDisplay(
                schema: sanitizedSchema, // Default schema for display
                title: 'Security Validation Result',
                value: _selectedExample == 'rateLimit' 
                    ? {'email': _emailController.text, 'message': _messageController.text}
                    : _selectedExample == 'apiKey'
                    ? _apiKeyController.text
                    : _inputController.text,
                preValidatedResult: _result,
              ),
            ],
          ],
        ),
      ),
      result: const SizedBox.shrink(), // Result shown inline
      schemaDisplay: const SchemaDisplay(
        title: 'Security Validation Patterns',
        code: '''// Input sanitization
final sanitized = z.string()
    .trim()
    .max(1000)
    .refine(
      (value) => !value.contains('<script>'),
      message: 'XSS attempt detected',
    );

// Rate limiting
final rateLimited = z.object({
  'email': z.string().email(),
  'message': z.string().max(5000),
}).refine(
  (data) => checkRateLimit(data['email']),
  message: 'Rate limit exceeded',
);

// API key validation
final apiKey = z.string()
    .length(32)
    .hex()
    .refineAsync(
      (key) => validateApiKey(key),
      message: 'Invalid API key',
    );''',
        description: 'Implement security best practices to protect against common vulnerabilities.',
      ),
      onValidate: () {},
      onClear: _clearInputs,
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }
}