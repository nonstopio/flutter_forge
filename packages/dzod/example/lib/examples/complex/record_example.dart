import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';

import '../../widgets/result_display.dart';
import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class RecordExample extends StatefulWidget {
  const RecordExample({super.key});

  @override
  State<RecordExample> createState() => _RecordExampleState();
}

class _RecordExampleState extends State<RecordExample> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();
  final Map<String, dynamic> _recordData = {};

  // Example 9: Key-value Records
  final recordSchema = z.record(z.number());
  
  // Size constrained record
  final sizedRecord = z.record(z.number()).min(1).max(10);
  
  // Key requirements
  final keyConstrainedRecord = z.record(z.number())
      .requiredKeys({'id'})
      .optionalKeys({'meta'});
  
  // Strict validation (no additional keys)
  final strictRecord = z.record(z.number()).strict();

  void _addEntry() {
    if (_keyController.text.isNotEmpty && _valueController.text.isNotEmpty) {
      setState(() {
        final value = num.tryParse(_valueController.text);
        if (value != null) {
          _recordData[_keyController.text] = value;
          _keyController.clear();
          _valueController.clear();
        }
      });
    }
  }

  void _removeEntry(String key) {
    setState(() {
      _recordData.remove(key);
    });
  }

  void _clearAll() {
    setState(() {
      _recordData.clear();
      _keyController.clear();
      _valueController.clear();
    });
  }

  void _fillExample() {
    setState(() {
      _recordData.clear();
      _recordData['id'] = 1;
      _recordData['score'] = 98.5;
      _recordData['count'] = 42;
      _recordData['meta'] = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValidationCard(
      title: 'Example 9: Key-value Records',
      description: 'Flexible record schemas with key-value pairs and constraints.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add new entry section
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _keyController,
                    decoration: const InputDecoration(
                      labelText: 'Key',
                      hintText: 'Enter key name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.key),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _valueController,
                    decoration: const InputDecoration(
                      labelText: 'Value',
                      hintText: 'Enter number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addEntry,
                  icon: const Icon(Icons.add),
                  tooltip: 'Add entry',
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Current record data
            if (_recordData.isNotEmpty) ...[
              const Text(
                'Current Record Data:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Column(
                  children: _recordData.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${entry.key}: ${entry.value}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeEntry(entry.key),
                            icon: const Icon(Icons.delete, size: 20),
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Action buttons
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _fillExample,
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Fill Example'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _clearAll,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear All'),
                ),
              ],
            ),
          ],
        ),
      ),
      result: ResultDisplay(
        schema: keyConstrainedRecord,
        title: 'Record Validation Result',
        value: _recordData,
      ),
      schemaDisplay: const SchemaDisplay(
        title: 'Record Schema Variations',
        code: '''// Basic record
final recordSchema = z.record(z.number());

// Size constraints
final sizedRecord = recordSchema.min(1).max(10);

// Key requirements
final keyConstrainedRecord = recordSchema
    .requiredKeys({'id'})
    .optionalKeys({'meta'});

// Strict validation (no additional keys)
final strictRecord = recordSchema.strict();''',
        description: 'Record schemas validate key-value pairs with flexible constraints.',
      ),
      onValidate: () {
        _formKey.currentState?.validate();
      },
      onClear: _clearAll,
    );
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }
}