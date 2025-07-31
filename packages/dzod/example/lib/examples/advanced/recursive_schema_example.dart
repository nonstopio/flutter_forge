import 'dart:convert';

import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';

import '../../widgets/result_display.dart';
import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class RecursiveSchemaExample extends StatefulWidget {
  const RecursiveSchemaExample({super.key});

  @override
  State<RecursiveSchemaExample> createState() => _RecursiveSchemaExampleState();
}

class _RecursiveSchemaExampleState extends State<RecursiveSchemaExample> {
  final _formKey = GlobalKey<FormState>();
  final _jsonController = TextEditingController();
  
  int _maxDepth = 10;
  bool _enableCircularDetection = true;
  bool _enableMemoization = true;

  // Example 12: Enhanced Recursive Schemas
  Schema<Map<String, dynamic>> get categorySchema => z.recursive<Map<String, dynamic>>(
    () => z.object({
      'name': z.string().min(1).max(50),
      'children': z.array(z.recursive<Map<String, dynamic>>(
        () => z.object({
          'name': z.string().min(1).max(50),
          'children': z.array(z.recursive<Map<String, dynamic>>(
            () => z.object({
              'name': z.string().min(1).max(50),
            })
          )).optional(),
        })
      )).optional(),
    }),
    maxDepth: _maxDepth,
    enableCircularDetection: _enableCircularDetection,
    enableMemoization: _enableMemoization,
  );

  // Modify settings with fluent API (Note: these methods may not be available in current API)
  // Schema<Map<String, dynamic>> get modifiedSchema => categorySchema
  //     .withMaxDepth(5)
  //     .withCircularDetection(false)
  //     .withMemoization(false);

  final Map<String, dynamic> validCategoryTree = {
    'name': 'Root Category',
    'children': [
      {
        'name': 'Electronics',
        'children': [
          {'name': 'Computers'},
          {'name': 'Phones'},
          {
            'name': 'Accessories',
            'children': [
              {'name': 'Cables'},
              {'name': 'Cases'},
            ],
          },
        ],
      },
      {
        'name': 'Clothing',
        'children': [
          {'name': 'Mens'},
          {'name': 'Womens'},
          {'name': 'Kids'},
        ],
      },
    ],
  };

  final Map<String, dynamic> deepTree = {
    'name': 'Level 1',
    'children': [
      {
        'name': 'Level 2',
        'children': [
          {
            'name': 'Level 3',
            'children': [
              {
                'name': 'Level 4',
                'children': [
                  {
                    'name': 'Level 5',
                    'children': [
                      {'name': 'Level 6'},
                    ],
                  },
                ],
              },
            ],
          },
        ],
      },
    ],
  };

  void _fillValidExample() {
    setState(() {
      _jsonController.text = const JsonEncoder.withIndent('  ').convert(validCategoryTree);
    });
  }

  void _fillDeepExample() {
    setState(() {
      _jsonController.text = const JsonEncoder.withIndent('  ').convert(deepTree);
    });
  }

  void _fillInvalidExample() {
    setState(() {
      _jsonController.text = const JsonEncoder.withIndent('  ').convert({
        'name': '', // Empty name
        'children': [
          {
            'name': 'Valid Child',
            'children': 'invalid', // Should be array
          },
        ],
      });
    });
  }

  void _clearInput() {
    setState(() {
      _jsonController.clear();
    });
  }

  Map<String, dynamic>? _parseJson() {
    try {
      return jsonDecode(_jsonController.text) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Widget _buildSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recursion Settings:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            
            // Max depth slider
            Row(
              children: [
                const Icon(Icons.layers, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Max Depth: $_maxDepth'),
                      Slider(
                        value: _maxDepth.toDouble(),
                        min: 1,
                        max: 100,
                        divisions: 99,
                        label: _maxDepth.toString(),
                        onChanged: (value) {
                          setState(() {
                            _maxDepth = value.toInt();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Circular detection switch
            SwitchListTile(
              title: const Text('Circular Detection'),
              subtitle: const Text('Detect circular references'),
              value: _enableCircularDetection,
              onChanged: (value) {
                setState(() {
                  _enableCircularDetection = value;
                });
              },
              secondary: const Icon(Icons.refresh),
            ),
            
            // Memoization switch
            SwitchListTile(
              title: const Text('Memoization'),
              subtitle: const Text('Cache validation results'),
              value: _enableMemoization,
              onChanged: (value) {
                setState(() {
                  _enableMemoization = value;
                });
              },
              secondary: const Icon(Icons.memory),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateDepth(Map<String, dynamic> node, [int currentDepth = 1]) {
    if (!node.containsKey('children') || node['children'] == null) {
      return currentDepth;
    }
    
    final children = node['children'] as List<dynamic>?;
    if (children == null || children.isEmpty) {
      return currentDepth;
    }
    
    int maxChildDepth = currentDepth;
    for (final child in children) {
      if (child is Map<String, dynamic>) {
        final childDepth = _calculateDepth(child, currentDepth + 1);
        maxChildDepth = childDepth > maxChildDepth ? childDepth : maxChildDepth;
      }
    }
    
    return maxChildDepth;
  }

  @override
  Widget build(BuildContext context) {
    return ValidationCard(
      title: 'Example 12: Recursive Schemas',
      description: 'Validate hierarchical data structures with circular detection and depth limits.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Settings card
            _buildSettingsCard(),
            const SizedBox(height: 16),
            
            // JSON input
            TextFormField(
              controller: _jsonController,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Category Tree (JSON)',
                hintText: 'Enter hierarchical category data',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            const SizedBox(height: 8),
            
            // Tree depth indicator
            if (_jsonController.text.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      const Icon(Icons.analytics, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Tree Depth: ${_parseJson() != null ? _calculateDepth(_parseJson()!) : 0}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Action buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _fillValidExample,
                  icon: const Icon(Icons.check),
                  label: const Text('Valid Tree'),
                ),
                OutlinedButton.icon(
                  onPressed: _fillDeepExample,
                  icon: const Icon(Icons.layers),
                  label: const Text('Deep Tree'),
                ),
                OutlinedButton.icon(
                  onPressed: _fillInvalidExample,
                  icon: const Icon(Icons.close),
                  label: const Text('Invalid Tree'),
                ),
                OutlinedButton.icon(
                  onPressed: _clearInput,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
      result: ResultDisplay(
        schema: categorySchema,
        title: 'Recursive Validation Result',
        value: _parseJson() ?? {},
      ),
      schemaDisplay: SchemaDisplay(
        title: 'Recursive Schema Configuration',
        code: '''final categorySchema = z.recursive<Map<String, dynamic>>(
  () => z.object({
    'name': z.string(),
    'children': z.array(z.recursive<Map<String, dynamic>>(
      () => z.object({
        'name': z.string(),
        'children': z.array(...).optional(),
      })
    )).optional(),
  }),
  maxDepth: $_maxDepth,
  enableCircularDetection: $_enableCircularDetection,
  enableMemoization: $_enableMemoization,
);

// Modify settings with fluent API
final modified = categorySchema
    .withMaxDepth(50)
    .withCircularDetection(false)
    .withMemoization(false);''',
        description: 'Recursive schemas handle self-referential structures with performance optimizations.',
      ),
      onValidate: () {
        _formKey.currentState?.validate();
      },
      onClear: _clearInput,
    );
  }

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }
}