import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/result_display.dart';
import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class TupleExample extends StatefulWidget {
  const TupleExample({super.key});

  @override
  State<TupleExample> createState() => _TupleExampleState();
}

class _TupleExampleState extends State<TupleExample> {
  final _tupleFormKey = GlobalKey<FormState>();

  // Controllers for tuple elements
  final _element1Controller = TextEditingController();
  final _element2Controller = TextEditingController();
  final _element3Controller = TextEditingController();
  final _restElementsController = TextEditingController();

  String _selectedTupleType = 'basic';

  // Basic tuple schema from README Example 7
  final _basicTupleSchema = Z.tuple([
    Z.string(),
    Z.number(),
    Z.boolean(),
  ]);

  final Map<String, String> _descriptions = {
    'basic': 'Basic tuple: [string, number, boolean]',
    'withRest': 'Tuple with rest elements (additional strings)',
    'exactLength': 'Tuple with exact length constraint',
    'minLength': 'Tuple with minimum length constraint',
    'maxLength': 'Tuple with maximum length constraint',
  };

  final Map<String, List<String>> _examples = {
    'basic': ['Hello', '42', 'true'],
    'withRest': ['Hello', '42', 'true', 'extra1', 'extra2'],
    'exactLength': ['Hello', '42', 'true'],
    'minLength': ['Hello', '42', 'true', 'extra'],
    'maxLength': ['Hello', '42', 'true'],
  };

  void _validate() {
    _tupleFormKey.currentState?.validate();
  }

  void _clearInput() {
    _tupleFormKey.currentState?.reset();
    _element1Controller.clear();
    _element2Controller.clear();
    _element3Controller.clear();
    _restElementsController.clear();
    setState(() {});
  }

  void _fillExample() {
    final example = _examples[_selectedTupleType] ?? [];
    _element1Controller.text = example.isNotEmpty ? example[0] : '';
    _element2Controller.text = example.length > 1 ? example[1] : '';
    _element3Controller.text = example.length > 2 ? example[2] : '';

    if (example.length > 3) {
      _restElementsController.text = example.skip(3).join(', ');
    } else {
      _restElementsController.clear();
    }
    setState(() {});
  }

  Schema _getCurrentSchema() {
    switch (_selectedTupleType) {
      case 'basic':
        return _basicTupleSchema;
      case 'withRest':
        return _basicTupleSchema.rest(Z.string());
      case 'exactLength':
        return _basicTupleSchema.exactLength(3);
      case 'minLength':
        return _basicTupleSchema.minLength(2);
      case 'maxLength':
        return _basicTupleSchema.maxLength(5);
      default:
        return _basicTupleSchema;
    }
  }

  List<dynamic> _getCurrentTupleData() {
    final tuple = <dynamic>[];

    // First element (string)
    if (_element1Controller.text.isNotEmpty) {
      tuple.add(_element1Controller.text);
    }

    // Second element (number)
    if (_element2Controller.text.isNotEmpty) {
      final number = num.tryParse(_element2Controller.text);
      tuple.add(number ?? _element2Controller.text);
    }

    // Third element (boolean)
    if (_element3Controller.text.isNotEmpty) {
      final boolText = _element3Controller.text.toLowerCase();
      if (boolText == 'true' || boolText == 'false') {
        tuple.add(boolText == 'true');
      } else {
        tuple.add(_element3Controller.text);
      }
    }

    // Rest elements (strings, for withRest type)
    if (_selectedTupleType == 'withRest' &&
        _restElementsController.text.isNotEmpty) {
      final restElements = _restElementsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      tuple.addAll(restElements);
    }

    return tuple;
  }

  @override
  Widget build(BuildContext context) {
    final currentSchema = _getCurrentSchema();

    return ValidationCard(
      title: 'Example 7: Type-safe Tuples',
      description: _descriptions[_selectedTupleType] ?? '',
      form: Form(
        key: _tupleFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tuple type selection
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTupleType,
                    onChanged: (value) {
                      setState(() {
                        _selectedTupleType = value!;
                        _clearInput();
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Tuple Validation Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.view_list),
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
            const SizedBox(height: 20),

            // Tuple elements
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tuple Elements',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Element 1 (String)
                    TextFormField(
                      controller: _element1Controller,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Element 1 (String)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.text_fields),
                        helperText: 'First element must be a string',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Element 2 (Number)
                    TextFormField(
                      controller: _element2Controller,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Element 2 (Number)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                        helperText: 'Second element must be a number',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Element 3 (Boolean)
                    TextFormField(
                      controller: _element3Controller,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Element 3 (Boolean)',
                        hintText: 'true or false',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.toggle_on),
                        helperText: 'Third element must be true or false',
                      ),
                    ),

                    // Rest elements (only for withRest type)
                    if (_selectedTupleType == 'withRest') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _restElementsController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Additional Elements (Strings)',
                          hintText: 'extra1, extra2, extra3',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.add),
                          helperText:
                              'Additional string elements (comma-separated)',
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tuple preview
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
                    'Tuple Preview:',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getCurrentTupleData().toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Length: ${_getCurrentTupleData().length}',
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
                        'Tuple Rules:',
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
                    _getTupleRules(_selectedTupleType),
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
        title: '${_getDisplayName(_selectedTupleType)} Validation Result',
        value: _getCurrentTupleData(),
      ),
      schemaDisplay: SchemaDisplay(
        title: 'Current Tuple Schema',
        code: _getSchemaCode(_selectedTupleType),
        description: 'Tuple validation schema for $_selectedTupleType type.',
      ),
      onValidate: _validate,
      onClear: _clearInput,
    );
  }

  String _getDisplayName(String tupleType) {
    switch (tupleType) {
      case 'basic':
        return 'Basic Tuple';
      case 'withRest':
        return 'With Rest Elements';
      case 'exactLength':
        return 'Exact Length';
      case 'minLength':
        return 'Minimum Length';
      case 'maxLength':
        return 'Maximum Length';
      default:
        return tupleType;
    }
  }

  String _getTupleRules(String tupleType) {
    switch (tupleType) {
      case 'basic':
        return '• Exactly 3 elements: [string, number, boolean]\n• Each element must match its type\n• Order matters';
      case 'withRest':
        return '• First 3 elements: [string, number, boolean]\n• Additional elements must be strings\n• Can have any number of extra elements';
      case 'exactLength':
        return '• Must have exactly 3 elements\n• Types: [string, number, boolean]\n• No more, no less';
      case 'minLength':
        return '• Must have at least 2 elements\n• Types: [string, number, boolean, ...]\n• Can have more elements';
      case 'maxLength':
        return '• Must have at most 5 elements\n• Types: [string, number, boolean, ...]\n• Cannot exceed 5 elements';
      default:
        return 'Tuple validation rules';
    }
  }

  String _getSchemaCode(String tupleType) {
    const baseSchema = '''final tupleSchema = Z.tuple([
  Z.string(),
  Z.number(),
  Z.boolean(),
]);''';

    switch (tupleType) {
      case 'basic':
        return baseSchema;
      case 'withRest':
        return '''$baseSchema
final tupleWithRest = tupleSchema.rest(Z.string());''';
      case 'exactLength':
        return '''$baseSchema
final exactLengthTuple = tupleSchema.exactLength(3);''';
      case 'minLength':
        return '''$baseSchema
final minLengthTuple = tupleSchema.minLength(2);''';
      case 'maxLength':
        return '''$baseSchema
final maxLengthTuple = tupleSchema.maxLength(5);''';
      default:
        return baseSchema;
    }
  }

  @override
  void dispose() {
    _element1Controller.dispose();
    _element2Controller.dispose();
    _element3Controller.dispose();
    _restElementsController.dispose();
    super.dispose();
  }
}
