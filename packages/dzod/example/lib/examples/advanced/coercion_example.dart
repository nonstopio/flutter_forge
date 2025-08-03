import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';

import '../../widgets/result_display.dart';
import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class CoercionExample extends StatefulWidget {
  const CoercionExample({super.key});

  @override
  State<CoercionExample> createState() => _CoercionExampleState();
}

class _CoercionExampleState extends State<CoercionExample> {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();

  String _selectedType = 'number';
  bool _strictMode = false;

  // Example 13: Automatic Type Coercion
  Schema get _currentSchema {
    switch (_selectedType) {
      case 'number':
        return _strictMode ? z.coerce.number(strict: true) : z.coerce.number();
      case 'boolean':
        return _strictMode
            ? z.coerce.boolean(strict: true)
            : z.coerce.boolean();
      case 'date':
        return _strictMode ? z.coerce.date(strict: true) : z.coerce.date();
      case 'list':
        return _strictMode ? z.coerce.list(strict: true) : z.coerce.list();
      case 'advanced':
        // Advanced number coercion with additional validation
        return z.coerce
            .number(strict: false)
            .transform((value) => double.parse(value.toStringAsFixed(2)))
            .refine((value) => value >= 0 && value <= 100,
                message: 'Must be between 0 and 100');
      default:
        return z.string();
    }
  }

  final Map<String, List<String>> _examples = {
    'number': ['123', '45.67', 'true', 'false', 'invalid'],
    'boolean': ['true', 'false', '1', '0', 'yes', 'no', 'on', 'off', ''],
    'date': [
      '2024-01-01',
      '2024-01-01T12:00:00Z',
      'January 1, 2024',
      'invalid'
    ],
    'list': ['item1,item2,item3', '["a","b","c"]', 'single', ''],
    'advanced': ['25.5555', '150', '-10', '50', 'invalid'],
  };

  final Map<String, String> _descriptions = {
    'number':
        'Coerces strings to numbers. In non-strict mode: "123" → 123, "45.67" → 45.67',
    'boolean':
        'Coerces various inputs to boolean. "true", "1", "yes", "on" → true; "false", "0", "no", "off", "" → false',
    'date':
        'Coerces date strings to DateTime objects. Supports ISO 8601 and common formats',
    'list': 'Coerces comma-separated strings or JSON arrays to lists',
    'advanced':
        'Advanced coercion with transformation and validation (0-100 range, 2 decimal places)',
  };

  void _fillExample(String example) {
    setState(() {
      _inputController.text = example;
    });
  }

  Widget _buildExampleButtons() {
    final examples = _examples[_selectedType] ?? [];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: examples.map((example) {
        return ActionChip(
          label: Text(example.isEmpty ? '(empty)' : example),
          onPressed: () => _fillExample(example),
          avatar: Icon(
            _getExampleIcon(example),
            size: 16,
          ),
        );
      }).toList(),
    );
  }

  IconData _getExampleIcon(String example) {
    if (_selectedType == 'number') {
      if (RegExp(r'^\d+\.?\d*$').hasMatch(example)) {
        return Icons.check_circle;
      }
    } else if (_selectedType == 'boolean') {
      if (['true', '1', 'yes', 'on'].contains(example.toLowerCase())) {
        return Icons.toggle_on;
      } else if (['false', '0', 'no', 'off', '']
          .contains(example.toLowerCase())) {
        return Icons.toggle_off;
      }
    }
    return Icons.help_outline;
  }

  dynamic _getInputValue() {
    final text = _inputController.text;

    // For demonstration, we'll parse the input based on type
    switch (_selectedType) {
      case 'number':
        // Try to parse as number
        final num = double.tryParse(text);
        return num ?? text;
      case 'boolean':
        // Various boolean representations
        if (text.toLowerCase() == 'true' ||
            text == '1' ||
            text.toLowerCase() == 'yes' ||
            text.toLowerCase() == 'on') {
          return true;
        } else if (text.toLowerCase() == 'false' ||
            text == '0' ||
            text.toLowerCase() == 'no' ||
            text.toLowerCase() == 'off' ||
            text.isEmpty) {
          return false;
        }
        return text;
      case 'date':
        // Try to parse as date
        try {
          return DateTime.parse(text);
        } catch (_) {
          return text;
        }
      case 'list':
        // Try JSON parse first
        try {
          final parsed = text.contains('[') ? text : '[$text]';
          return parsed;
        } catch (_) {
          // Fall back to comma-separated
          return text.split(',').map((e) => e.trim()).toList();
        }
      default:
        return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValidationCard(
      title: 'Example 13: Type Coercion',
      description: 'Automatic type conversion with optional strict mode.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type selector
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                        _inputController.clear();
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Coercion Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.transform),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'number',
                        child: Text('Number Coercion'),
                      ),
                      DropdownMenuItem(
                        value: 'boolean',
                        child: Text('Boolean Coercion'),
                      ),
                      DropdownMenuItem(
                        value: 'date',
                        child: Text('Date Coercion'),
                      ),
                      DropdownMenuItem(
                        value: 'list',
                        child: Text('List Coercion'),
                      ),
                      DropdownMenuItem(
                        value: 'advanced',
                        child: Text('Advanced Number'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Strict mode toggle
                Column(
                  children: [
                    const Text('Strict Mode'),
                    Switch(
                      value: _strictMode,
                      onChanged: _selectedType != 'advanced'
                          ? (value) {
                              setState(() {
                                _strictMode = value;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'How it works:',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _descriptions[_selectedType] ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (_strictMode) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Strict mode: Only exact type matches are coerced',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Input field
            TextFormField(
              controller: _inputController,
              decoration: InputDecoration(
                labelText: 'Input Value',
                hintText: 'Enter value to coerce to $_selectedType',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.input),
              ),
            ),
            const SizedBox(height: 16),

            // Example buttons
            Text(
              'Try these examples:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _buildExampleButtons(),
          ],
        ),
      ),
      result: ResultDisplay(
        schema: _currentSchema,
        title: 'Coercion Result',
        value: _getInputValue(),
      ),
      schemaDisplay: const SchemaDisplay(
        title: 'Coercion Schema',
        code: '''// Automatic type coercion
final numberCoercion = z.coerce.number(); // String -> Number
final booleanCoercion = z.coerce.boolean(); // String -> Boolean
final dateCoercion = z.coerce.date(); // String -> DateTime
final listCoercion = z.coerce.list(); // String -> List

// Strict coercion mode
final strictNumber = z.coerce.number(strict: true);

// Advanced with validation
final advancedNumber = z.coerce.number(strict: false)
    .transform((num) => double.parse(num.toStringAsFixed(2)))
    .refine((num) => num >= 0 && num <= 100, 
        message: 'Must be between 0 and 100');''',
        description: 'Coercion schemas automatically convert compatible types.',
      ),
      onValidate: () {
        _formKey.currentState?.validate();
      },
      onClear: () {
        setState(() {
          _inputController.clear();
        });
      },
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}
