import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';

import '../../widgets/result_display.dart';
import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class ArrayAdvancedExample extends StatefulWidget {
  const ArrayAdvancedExample({super.key});

  @override
  State<ArrayAdvancedExample> createState() => _ArrayAdvancedExampleState();
}

class _ArrayAdvancedExampleState extends State<ArrayAdvancedExample> {
  final _arrayFormKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  String _selectedArrayType = 'base';

  // Base array schema from README Example 6
  final _baseArraySchema = z.array(z.string());

  final Map<String, String> _descriptions = {
    'base': 'Basic string array validation',
    'range': 'Array with length constraints (1-10 items)',
    'exactLength': 'Array with exact length (5 items)',
    'nonempty': 'Array that cannot be empty',
    'unique': 'Array with unique elements only',
    'includes': 'Array that must include "required"',
    'excludes': 'Array that must not include "forbidden"',
    'someEmail': 'Array where some element contains "@"',
    'everyMinLength': 'Array where every element has min length 2',
    'mapped': 'Array with elements trimmed',
    'filtered': 'Array with empty strings removed',
    'sorted': 'Array sorted alphabetically',
  };

  final Map<String, String> _examples = {
    'base': 'apple, banana, cherry',
    'range': 'apple, banana, cherry',
    'exactLength': 'apple, banana, cherry, date, elderberry',
    'nonempty': 'apple, banana',
    'unique': 'apple, banana, cherry',
    'includes': 'apple, required, banana',
    'excludes': 'apple, banana, cherry',
    'someEmail': 'apple, user@example.com, banana',
    'everyMinLength': 'apple, banana, cherry',
    'mapped': '  apple  , banana , cherry  ',
    'filtered': 'apple, , banana, , cherry',
    'sorted': 'cherry, apple, banana',
  };

  void _validate() {
    _arrayFormKey.currentState?.validate();
  }

  void _clearInput() {
    _arrayFormKey.currentState?.reset();
    _textController.clear();
    setState(() {});
  }

  void _fillExample() {
    _textController.text = _examples[_selectedArrayType] ?? '';
    setState(() {});
  }

  Schema _getCurrentSchema() {
    switch (_selectedArrayType) {
      case 'base':
        return _baseArraySchema;
      case 'range':
        return _baseArraySchema.min(1).max(10);
      case 'exactLength':
        return _baseArraySchema.length(5);
      case 'nonempty':
        return _baseArraySchema.nonempty();
      case 'unique':
        return _baseArraySchema.unique();
      case 'includes':
        return _baseArraySchema.includes('required');
      case 'excludes':
        return _baseArraySchema.excludes('forbidden');
      case 'someEmail':
        return _baseArraySchema.some((element) => element.contains('@'));
      case 'everyMinLength':
        return _baseArraySchema.every((element) => element.length >= 2);
      case 'mapped':
        return _baseArraySchema.mapElements((s) => s.trim());
      case 'filtered':
        return _baseArraySchema.filter((s) => s.isNotEmpty);
      case 'sorted':
        return _baseArraySchema.sort((a, b) => a.compareTo(b));
      default:
        return _baseArraySchema;
    }
  }

  List<String> _parseArrayInput(String input) {
    if (input.trim().isEmpty) return [];
    return input.split(',').map((s) => s.trim()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentSchema = _getCurrentSchema();

    return ValidationCard(
      title: 'Example 6: Advanced Arrays',
      description: _descriptions[_selectedArrayType] ?? '',
      form: Form(
        key: _arrayFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Array type selection
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedArrayType,
                    onChanged: (value) {
                      setState(() {
                        _selectedArrayType = value!;
                        _textController.clear();
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Array Validation Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.list),
                    ),
                    items: _descriptions.keys.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getDisplayName(type)),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _fillExample,
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Example'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Array input field
            TextFormField(
              controller: _textController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Array Items (comma-separated)',
                hintText: 'Enter items separated by commas',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.format_list_bulleted),
                helperText: _descriptions[_selectedArrayType],
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Array preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Array Preview:',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _parseArrayInput(_textController.text).toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Length: ${_parseArrayInput(_textController.text).length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Validation rules
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Validation Rules:',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getValidationRules(_selectedArrayType),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      result: ResultDisplay(
        schema: currentSchema,
        title: '${_getDisplayName(_selectedArrayType)} Validation Result',
        value: _parseArrayInput(_textController.text),
      ),
      schemaDisplay: SchemaDisplay(
        title: 'Current Array Schema',
        code: _getSchemaCode(_selectedArrayType),
        description: 'Array validation schema for $_selectedArrayType type.',
      ),
      onValidate: _validate,
      onClear: _clearInput,
    );
  }

  String _getDisplayName(String arrayType) {
    switch (arrayType) {
      case 'base':
        return 'Base Array';
      case 'range':
        return 'Length Range';
      case 'exactLength':
        return 'Exact Length';
      case 'nonempty':
        return 'Non-empty';
      case 'unique':
        return 'Unique Elements';
      case 'includes':
        return 'Must Include';
      case 'excludes':
        return 'Must Exclude';
      case 'someEmail':
        return 'Some Email';
      case 'everyMinLength':
        return 'Every Min Length';
      case 'mapped':
        return 'Mapped (Trim)';
      case 'filtered':
        return 'Filtered';
      case 'sorted':
        return 'Sorted';
      default:
        return arrayType;
    }
  }

  String _getValidationRules(String arrayType) {
    switch (arrayType) {
      case 'base':
        return '• Basic array of strings\n• Any length allowed';
      case 'range':
        return '• Must have 1-10 items\n• All items must be strings';
      case 'exactLength':
        return '• Must have exactly 5 items\n• All items must be strings';
      case 'nonempty':
        return '• Array cannot be empty\n• Must have at least 1 item';
      case 'unique':
        return '• All elements must be unique\n• No duplicate values allowed';
      case 'includes':
        return '• Must include the string "required"\n• Can have other elements';
      case 'excludes':
        return '• Must NOT include "forbidden"\n• All other strings allowed';
      case 'someEmail':
        return '• At least one element must contain "@"\n• Simulates email check';
      case 'everyMinLength':
        return '• Every element must be at least 2 characters\n• No short strings allowed';
      case 'mapped':
        return '• Elements are trimmed of whitespace\n• Shows transformation';
      case 'filtered':
        return '• Empty strings are removed\n• Only non-empty elements remain';
      case 'sorted':
        return '• Elements are sorted alphabetically\n• Shows ordering transformation';
      default:
        return 'Array validation rules';
    }
  }

  String _getSchemaCode(String arrayType) {
    const baseSchema = 'final baseArraySchema = z.array(z.string());';

    switch (arrayType) {
      case 'base':
        return baseSchema;
      case 'range':
        return '''$baseSchema
final rangeArraySchema = baseArraySchema.min(1).max(10);''';
      case 'exactLength':
        return '''$baseSchema
final exactLengthSchema = baseArraySchema.length(5);''';
      case 'nonempty':
        return '''$baseSchema
final nonemptySchema = baseArraySchema.nonempty();''';
      case 'unique':
        return '''$baseSchema
final uniqueSchema = baseArraySchema.unique();''';
      case 'includes':
        return '''$baseSchema
final includesSchema = baseArraySchema.includes('required');''';
      case 'excludes':
        return '''$baseSchema
final excludesSchema = baseArraySchema.excludes('forbidden');''';
      case 'someEmail':
        return '''$baseSchema
final someEmailSchema = baseArraySchema.some((element) => element.contains('@'));''';
      case 'everyMinLength':
        return '''$baseSchema
final everyMinLengthSchema = baseArraySchema.every((element) => element.length >= 2);''';
      case 'mapped':
        return '''$baseSchema
final mappedSchema = baseArraySchema.mapElements((s) => s.trim());''';
      case 'filtered':
        return '''$baseSchema
final filteredSchema = baseArraySchema.filter((s) => s.length > 0);''';
      case 'sorted':
        return '''$baseSchema
final sortedSchema = baseArraySchema.sort((a, b) => a.compareTo(b));''';
      default:
        return baseSchema;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
