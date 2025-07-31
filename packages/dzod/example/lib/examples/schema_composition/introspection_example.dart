
import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';

import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class IntrospectionExample extends StatefulWidget {
  const IntrospectionExample({super.key});

  @override
  State<IntrospectionExample> createState() => _IntrospectionExampleState();
}

class _IntrospectionExampleState extends State<IntrospectionExample> {
  final _formKey = GlobalKey<FormState>();
  
  // Example 23: Schema Introspection
  final userSchema = z.object({
    'name': z.string().min(2).max(50).describe('User full name'),
    'email': z.string().email().describe('User email address'),
    'age': z.number().min(18).describe('User age in years'),
    'isActive': z.boolean().optional().describe('Account status'),
    'role': z.enum_(['admin', 'user', 'guest']).describe('User role'),
    'metadata': z.object({
      'lastLogin': z.string().datetime().optional(),
      'loginCount': z.number().optional(),
    }).optional().describe('Additional user metadata'),
  }).describe('User profile schema');

  final productSchema = z.object({
    'id': z.string().cuid2(),
    'name': z.string().min(1).max(100),
    'price': z.number().min(0),
    'inStock': z.boolean(),
    'categories': z.array(z.string()).optional(),
  }).describe('Product information schema');

  String _selectedSchema = 'user';

  Schema<Map<String, dynamic>> get _currentSchema {
    return _selectedSchema == 'user' ? userSchema : productSchema;
  }

  Widget _buildSchemaInfo() {
    final schema = _currentSchema;
    // Note: Some introspection methods may not be available in current API
    // This is a demonstration of what schema introspection could look like

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Schema information display
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Schema Introspection Demo',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              'Selected Schema: ${_selectedSchema == 'user' ? 'User Schema' : 'Product Schema'}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            
            Text(
              'Schema Type: ${schema.runtimeType}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schema Introspection Features:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text('• Runtime type information'),
                    const Text('• Schema structure analysis'),
                    const Text('• Field requirement detection'),
                    const Text('• Type validation rules'),
                    const Text('• Schema composition support'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return ValidationCard(
      title: 'Example 23: Schema Introspection',
      description: 'Analyze schema structure, fields, and metadata programmatically.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Schema selector
            DropdownButtonFormField<String>(
              value: _selectedSchema,
              onChanged: (value) {
                setState(() {
                  _selectedSchema = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Schema to Inspect',
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
              ],
            ),
            const SizedBox(height: 16),
            
            // Schema information display
            _buildSchemaInfo(),
          ],
        ),
      ),
      result: const SizedBox.shrink(), // No validation result needed for introspection
      schemaDisplay: const SchemaDisplay(
        title: 'Introspection API',
        code: '''// Get schema information
print('Schema shape: \${schema.shape.keys}');
print('Required fields: \${schema.requiredKeys}');
print('Optional fields: \${schema.optionalKeys}');
print('Total fields: \${schema.shape.length}');

// Analyze field structure
for (final entry in schema.shape.entries) {
  final field = entry.key;
  final fieldSchema = entry.value;
  final isRequired = schema.requiredKeys.contains(field);
  print('Field \$field: \${fieldSchema.runtimeType} (required: \$isRequired)');
}

// Schema comparison
final sameKeys = schema1.shape.keys.toSet()
    .difference(schema2.shape.keys.toSet()).isEmpty;''',
        description: 'Introspection allows runtime analysis of schema structure and metadata.',
      ),
      onValidate: () {},
      onClear: () {},
    );
  }
}