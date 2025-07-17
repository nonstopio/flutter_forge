import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/result_display.dart';
import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class NumberValidationsExample extends StatefulWidget {
  const NumberValidationsExample({super.key});

  @override
  State<NumberValidationsExample> createState() =>
      _NumberValidationsExampleState();
}

class _NumberValidationsExampleState extends State<NumberValidationsExample> {
  final _numberFormKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  String _selectedValidator = 'basicNumber';

  // All number validation schemas from README Example 3
  Map<String, Schema> get _validators => {
        'basicNumber': Z.number().min(0).max(100),
        'step': Z.number().step(0.1),
        'precision': Z.number().precision(2),
        'safeInt': Z.number().safeInt(),
        'percentage': Z.number().percentage(),
        'probability': Z.number().probability(),
        'latitude': Z.number().latitude(),
        'longitude': Z.number().longitude(),
        'powerOfTwo': Z.number().powerOfTwo(),
        'prime': Z.number().prime(),
        'perfectSquare': Z.number().perfectSquare(),
      };

  final Map<String, String> _examples = {
    'basicNumber': '42',
    'step': '5.5',
    'precision': '123.45',
    'safeInt': '9007199254740991',
    'percentage': '85.5',
    'probability': '0.75',
    'latitude': '40.7128',
    'longitude': '-74.0060',
    'powerOfTwo': '64',
    'prime': '17',
    'perfectSquare': '25',
  };

  final Map<String, String> _descriptions = {
    'basicNumber': 'Number between 0-100',
    'step': 'Number with step validation (0.1 increments)',
    'precision': 'Number with maximum 2 decimal places',
    'safeInt': 'Safe integer within JavaScript safe range',
    'percentage': 'Percentage value (0-100)',
    'probability': 'Probability value (0-1)',
    'latitude': 'Valid latitude coordinate (-90 to 90)',
    'longitude': 'Valid longitude coordinate (-180 to 180)',
    'powerOfTwo': 'Number that is a power of 2',
    'prime': 'Prime number validation',
    'perfectSquare': 'Perfect square number validation',
  };

  void _validate() {
    _numberFormKey.currentState?.validate();
  }

  void _clearInput() {
    _numberFormKey.currentState?.reset();
    _textController.clear();
    setState(() {});
  }

  void _fillExample() {
    _textController.text = _examples[_selectedValidator] ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentSchema = _validators[_selectedValidator]!;

    return ValidationCard(
      title: 'Example 3: Number Validations',
      description: _descriptions[_selectedValidator] ?? '',
      form: Form(
        key: _numberFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Validator selection
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedValidator,
                    onChanged: (value) {
                      setState(() {
                        _selectedValidator = value!;
                        _textController.clear();
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Number Validator Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag),
                    ),
                    items: _validators.keys.map((type) {
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

            // Input field
            TextFormField(
              controller: _textController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: '${_getDisplayName(_selectedValidator)} Input',
                hintText: 'Enter a $_selectedValidator value',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(_getIconForValidator(_selectedValidator)),
                helperText: _descriptions[_selectedValidator],
              ),
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: true),
              inputFormatters: [
                if (_selectedValidator == 'basicNumber' ||
                    _selectedValidator == 'safeInt' ||
                    _selectedValidator == 'powerOfTwo' ||
                    _selectedValidator == 'prime' ||
                    _selectedValidator == 'perfectSquare')
                  FilteringTextInputFormatter.digitsOnly
                else
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
              ],
            ),

            // Validation hints
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
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
                    _getValidationRules(_selectedValidator),
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
        title: '${_getDisplayName(_selectedValidator)} Validation Result',
        value: _parseInputValue(_textController.text),
      ),
      schemaDisplay: SchemaDisplay(
        title: 'Current Number Validator',
        code: _getSchemaCode(_selectedValidator),
        description: 'Number validation schema for $_selectedValidator type.',
      ),
      onValidate: _validate,
      onClear: _clearInput,
    );
  }

  String _getDisplayName(String validator) {
    switch (validator) {
      case 'basicNumber':
        return 'Basic Number';
      case 'step':
        return 'Step Validation';
      case 'precision':
        return 'Precision';
      case 'safeInt':
        return 'Safe Integer';
      case 'percentage':
        return 'Percentage';
      case 'probability':
        return 'Probability';
      case 'latitude':
        return 'Latitude';
      case 'longitude':
        return 'Longitude';
      case 'powerOfTwo':
        return 'Power of Two';
      case 'prime':
        return 'Prime Number';
      case 'perfectSquare':
        return 'Perfect Square';
      default:
        return validator;
    }
  }

  IconData _getIconForValidator(String validator) {
    switch (validator) {
      case 'basicNumber':
        return Icons.numbers;
      case 'step':
        return Icons.stairs;
      case 'precision':
        return Icons.precision_manufacturing;
      case 'safeInt':
        return Icons.security;
      case 'percentage':
        return Icons.percent;
      case 'probability':
        return Icons.casino;
      case 'latitude':
      case 'longitude':
        return Icons.location_on;
      case 'powerOfTwo':
        return Icons.functions;
      case 'prime':
        return Icons.star;
      case 'perfectSquare':
        return Icons.crop_square;
      default:
        return Icons.tag;
    }
  }

  String _getValidationRules(String validator) {
    switch (validator) {
      case 'basicNumber':
        return '• Must be between 0 and 100';
      case 'step':
        return '• Must be in increments of 0.1\n• Valid: 0.1, 0.2, 1.5, etc.';
      case 'precision':
        return '• Maximum 2 decimal places\n• Valid: 123.45, 1.1, 100';
      case 'safeInt':
        return '• Must be within JavaScript safe integer range\n• Between -9007199254740991 and 9007199254740991';
      case 'percentage':
        return '• Must be between 0 and 100\n• Can have decimal places';
      case 'probability':
        return '• Must be between 0 and 1\n• Represents probability values';
      case 'latitude':
        return '• Must be between -90 and 90\n• Represents latitude coordinates';
      case 'longitude':
        return '• Must be between -180 and 180\n• Represents longitude coordinates';
      case 'powerOfTwo':
        return '• Must be a power of 2\n• Valid: 1, 2, 4, 8, 16, 32, 64, etc.';
      case 'prime':
        return '• Must be a prime number\n• Valid: 2, 3, 5, 7, 11, 13, 17, etc.';
      case 'perfectSquare':
        return '• Must be a perfect square\n• Valid: 1, 4, 9, 16, 25, 36, etc.';
      default:
        return 'Number validation rules';
    }
  }

  dynamic _parseInputValue(String text) {
    if (text.isEmpty) return null;

    // Try to parse as number
    final number = num.tryParse(text);
    if (number == null) return text; // Return string if can't parse as number

    // Return as int if it's a whole number and the validator expects integers
    if (_selectedValidator == 'basicNumber' ||
        _selectedValidator == 'safeInt' ||
        _selectedValidator == 'powerOfTwo' ||
        _selectedValidator == 'prime' ||
        _selectedValidator == 'perfectSquare') {
      return number.toInt();
    }

    return number;
  }

  String _getSchemaCode(String validator) {
    switch (validator) {
      case 'basicNumber':
        return 'final basicNumberSchema = Z.number().min(0).max(100);';
      case 'step':
        return 'final stepSchema = Z.number().step(0.1);';
      case 'precision':
        return 'final precisionSchema = Z.number().precision(2);';
      case 'safeInt':
        return 'final safeIntSchema = Z.number().safeInt();';
      case 'percentage':
        return 'final percentageSchema = Z.number().percentage();';
      case 'probability':
        return 'final probabilitySchema = Z.number().probability();';
      case 'latitude':
        return 'final latitudeSchema = Z.number().latitude();';
      case 'longitude':
        return 'final longitudeSchema = Z.number().longitude();';
      case 'powerOfTwo':
        return 'final powerOfTwoSchema = Z.number().powerOfTwo();';
      case 'prime':
        return 'final primeSchema = Z.number().prime();';
      case 'perfectSquare':
        return 'final perfectSquareSchema = Z.number().perfectSquare();';
      default:
        return 'final numberSchema = Z.number();';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
