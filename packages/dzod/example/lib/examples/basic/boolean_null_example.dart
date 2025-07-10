import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';

import '../../widgets/result_display.dart';
import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class BooleanNullExample extends StatefulWidget {
  const BooleanNullExample({super.key});

  @override
  State<BooleanNullExample> createState() => _BooleanNullExampleState();
}

class _BooleanNullExampleState extends State<BooleanNullExample> {
  final _booleanFormKey = GlobalKey<FormState>();

  String _selectedValidator = 'boolean';
  bool? _booleanValue = true;
  bool _allowNull = false;

  // Boolean and null validation schemas from README Example 4
  final Map<String, Schema> _validators = {
    'boolean': Z.boolean(),
    'null': Z.null_(),
  };

  final Map<String, String> _descriptions = {
    'boolean': 'Validates boolean values (true/false)',
    'null': 'Validates null values only',
  };

  void _validate() {
    _booleanFormKey.currentState?.validate();
  }

  void _clearInput() {
    _booleanFormKey.currentState?.reset();
    setState(() {
      _booleanValue = null;
      _allowNull = false;
    });
  }

  dynamic _getCurrentValue() {
    if (_selectedValidator == 'null') {
      return null;
    } else {
      return _allowNull ? null : _booleanValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSchema = _validators[_selectedValidator]!;

    return ValidationCard(
      title: 'Example 4: Boolean and Null Types',
      description: _descriptions[_selectedValidator] ?? '',
      form: Form(
        key: _booleanFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Validator selection
            DropdownButtonFormField<String>(
              value: _selectedValidator,
              onChanged: (value) {
                setState(() {
                  _selectedValidator = value!;
                  _booleanValue = null;
                  _allowNull = false;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Validator Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _validators.keys.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toUpperCase()),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            if (_selectedValidator == 'boolean') ...[
              // Boolean validation controls
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Boolean Value Selection',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),

                      // Allow null checkbox
                      CheckboxListTile(
                        title: const Text('Allow null value'),
                        subtitle: const Text('Test null handling'),
                        value: _allowNull,
                        onChanged: (value) {
                          setState(() {
                            _allowNull = value ?? false;
                            if (_allowNull) {
                              _booleanValue = null;
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                      if (!_allowNull) ...[
                        const Divider(),
                        const SizedBox(height: 8),

                        // Boolean value selection
                        Text(
                          'Select Boolean Value:',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text('true'),
                                value: true,
                                groupValue: _booleanValue,
                                onChanged: (value) {
                                  setState(() {
                                    _booleanValue = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text('false'),
                                value: false,
                                groupValue: _booleanValue,
                                onChanged: (value) {
                                  setState(() {
                                    _booleanValue = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Null validation display
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.block,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Null Validation',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This validator only accepts null values. Any other value will fail validation.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Current value display
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
                    'Current Value:',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getCurrentValue()?.toString() ?? 'null',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontFamily: 'monospace',
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Type: ${_getCurrentValue().runtimeType}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
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
        title: '${_selectedValidator.toUpperCase()} Validation Result',
        value: _getCurrentValue(),
      ),
      schemaDisplay: SchemaDisplay(
        title: 'Current Schema',
        code: _getSchemaCode(_selectedValidator),
        description: 'Validation schema for $_selectedValidator type.',
      ),
      onValidate: _validate,
      onClear: _clearInput,
    );
  }

  String _getSchemaCode(String validator) {
    switch (validator) {
      case 'boolean':
        return 'final boolSchema = Z.boolean();';
      case 'null':
        return 'final nullSchema = Z.null_();';
      default:
        return 'final schema = Z.any();';
    }
  }
}
