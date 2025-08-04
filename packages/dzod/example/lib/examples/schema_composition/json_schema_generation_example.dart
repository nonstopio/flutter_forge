import 'dart:convert';

import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class JsonSchemaGenerationExample extends StatefulWidget {
  const JsonSchemaGenerationExample({super.key});

  @override
  State<JsonSchemaGenerationExample> createState() =>
      _JsonSchemaGenerationExampleState();
}

class _JsonSchemaGenerationExampleState
    extends State<JsonSchemaGenerationExample> {
  final _formKey = GlobalKey<FormState>();
  String _selectedExample = 'user';

  // Example 25: JSON Schema Generation
  final userSchema = z.object({
    'id': z.string().cuid2().describe('Unique user identifier'),
    'name': z.string().min(2).max(50).describe('User full name'),
    'email': z.string().email().describe('User email address'),
    'age': z.number().min(18).optional().describe('User age in years'),
    'roles': z
        .array(z.enum_(['admin', 'user', 'guest']))
        .describe('User roles and permissions'),
    'preferences': z.object({
      'theme': z.enum_(['light', 'dark']).defaultTo('light'),
      'notifications': z.boolean().defaultTo(true),
      'language': z.string().defaultTo('en'),
    }).describe('User preferences'),
    'metadata': z.object({
      'createdAt': z.string().datetime(),
      'updatedAt': z.string().datetime().optional(),
      'tags': z.array(z.string()).optional(),
    }).describe('System metadata'),
  }).describe('User account information');

  final productSchema = z.object({
    'id': z.string().uuid().describe('Product unique identifier'),
    'name': z.string().min(1).max(200).describe('Product name'),
    'description':
        z.string().max(1000).optional().describe('Product description'),
    'price': z.number().min(0).describe('Product price in USD'),
    'stock': z.number().integer().min(0).describe('Available stock quantity'),
    'categories': z.array(z.string()).min(1).describe('Product categories'),
    'specifications':
        z.record(z.string()).optional().describe('Technical specifications'),
    'images': z
        .array(z.object({
          'url': z.string().url(),
          'alt': z.string().optional(),
          'primary': z.boolean().defaultTo(false),
        }))
        .optional()
        .describe('Product images'),
  }).describe('Product catalog information');

  late final apiResponseSchema = z.object({
    'success': z.boolean().describe('Operation success status'),
    'data': z.string().describe('Response data payload'), // Simplified for demo
    'error': z
        .object({
          'code': z.string(),
          'message': z.string(),
          'details': z.record(z.string()).optional(),
        })
        .optional()
        .describe('Error information if operation failed'),
    'meta': z.object({
      'timestamp': z.string().datetime(),
      'requestId': z.string().uuid(),
      'version': z.string(),
    }).describe('Response metadata'),
  }).describe('Standard API response format');

  Schema get _currentSchema {
    switch (_selectedExample) {
      case 'product':
        return productSchema;
      case 'api':
        return apiResponseSchema;
      default:
        return userSchema;
    }
  }

  String get _jsonSchema {
    try {
      final schema = _currentSchema.toJsonSchema();
      return const JsonEncoder.withIndent('  ').convert(schema);
    } catch (e) {
      return 'Error generating JSON Schema: $e';
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _jsonSchema));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('JSON Schema copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSchemaPreview() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Generated JSON Schema:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    Text(
                      'OpenAPI 3.0 Compatible',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy to clipboard',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                _jsonSchema,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUseCases() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Use Cases',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildUseCase(
              'API Documentation',
              'Generate OpenAPI/Swagger schemas for your REST APIs',
              Icons.api,
            ),
            _buildUseCase(
              'Form Generation',
              'Automatically generate forms from schema definitions',
              Icons.dynamic_form,
            ),
            _buildUseCase(
              'Data Validation',
              'Share validation rules between frontend and backend',
              Icons.verified,
            ),
            _buildUseCase(
              'Code Generation',
              'Generate TypeScript interfaces or other language types',
              Icons.code,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUseCase(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValidationCard(
      title: 'Example 25: JSON Schema Generation',
      description:
          'Generate JSON Schema for OpenAPI documentation and tooling.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Schema selector
            DropdownButtonFormField<String>(
              value: _selectedExample,
              onChanged: (value) {
                setState(() {
                  _selectedExample = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Schema',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.schema),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'user',
                  child: Text('User Schema'),
                ),
                DropdownMenuItem(
                  value: 'product',
                  child: Text('Product Schema'),
                ),
                DropdownMenuItem(
                  value: 'api',
                  child: Text('API Response Schema'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Use cases
            _buildUseCases(),
            const SizedBox(height: 16),

            // Generated JSON Schema
            _buildSchemaPreview(),
          ],
        ),
      ),
      result: const SizedBox.shrink(), // No validation result needed
      schemaDisplay: const SchemaDisplay(
        title: 'JSON Schema Generation API',
        code: '''// Define schema with descriptions
final userSchema = z.object({
  'id': z.string().cuid2().describe('Unique identifier'),
  'name': z.string().min(2).max(50).describe('User name'),
  'email': z.string().email().describe('Email address'),
  'age': z.number().min(18).optional(),
  'roles': z.array(z.enum_(['admin', 'user', 'guest'])),
}).describe('User account information');

// Generate JSON Schema
final jsonSchema = userSchema.toJsonSchema();

// Output format:
// {
//   "type": "object",
//   "description": "User account information",
//   "properties": {
//     "id": {"type": "string", "pattern": "[a-z0-9]{25}"},
//     "name": {"type": "string", "minLength": 2, "maxLength": 50},
//     "email": {"type": "string", "format": "email"},
//     "age": {"type": "number", "minimum": 18},
//     "roles": {"type": "array", "items": {"enum": ["admin", "user", "guest"]}}
//   },
//   "required": ["id", "name", "email", "roles"]
// }''',
        description:
            'Generate standard JSON Schema from Dzod schemas for documentation and tooling.',
      ),
      onValidate: () {},
      onClear: () {},
    );
  }
}
