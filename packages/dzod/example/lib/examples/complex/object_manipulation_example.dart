import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';

import '../../widgets/result_display.dart';
import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class ObjectManipulationExample extends StatefulWidget {
  const ObjectManipulationExample({super.key});

  @override
  State<ObjectManipulationExample> createState() =>
      _ObjectManipulationExampleState();
}

class _ObjectManipulationExampleState extends State<ObjectManipulationExample> {
  final _objectFormKey = GlobalKey<FormState>();

  // Controllers for base user fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController(); // For extended schema

  String _selectedManipulation = 'base';

  // Base user schema from README Example 5
  final _baseUserSchema = z.object({
    'name': z.string(),
    'email': z.string().email(),
    'age': z.number().min(18),
    'address': z.object({
      'street': z.string(),
      'city': z.string(),
      'country': z.string(),
    }),
  });

  final Map<String, String> _descriptions = {
    'base': 'Base user schema with all fields',
    'picked': 'Picked schema (name, email only)',
    'omitted': 'Omitted schema (without age)',
    'extended': 'Extended schema (with phone field)',
    'partial': 'Partial schema (all fields optional)',
    'deepPartial': 'Deep partial schema (nested objects optional)',
    'required': 'Required schema (name, email must be provided)',
    'strict': 'Strict schema (no unknown properties)',
    'passthrough': 'Passthrough schema (allows unknown properties)',
    'strip': 'Strip schema (removes unknown properties)',
    'catchall': 'Catchall schema (validates unknown properties as strings)',
  };

  void _validate() {
    _objectFormKey.currentState?.validate();
  }

  void _clearInput() {
    _objectFormKey.currentState?.reset();
    _nameController.clear();
    _emailController.clear();
    _ageController.clear();
    _streetController.clear();
    _cityController.clear();
    _countryController.clear();
    _phoneController.clear();
    setState(() {});
  }

  void _fillSampleData() {
    _nameController.text = 'John Doe';
    _emailController.text = 'john@example.com';
    _ageController.text = '25';
    _streetController.text = '123 Main St';
    _cityController.text = 'New York';
    _countryController.text = 'USA';
    _phoneController.text = '+1-555-0123';
    setState(() {});
  }

  Schema _getCurrentSchema() {
    switch (_selectedManipulation) {
      case 'base':
        return _baseUserSchema;
      case 'picked':
        return _baseUserSchema.pick(['name', 'email']);
      case 'omitted':
        return _baseUserSchema.omit(['age']);
      case 'extended':
        return _baseUserSchema.extend({'phone': z.string()});
      case 'partial':
        return _baseUserSchema.partial();
      case 'deepPartial':
        return _baseUserSchema.deepPartial();
      case 'required':
        return _baseUserSchema.partial().required(['name', 'email']);
      case 'strict':
        return _baseUserSchema.strict();
      case 'passthrough':
        return _baseUserSchema.passthrough();
      case 'strip':
        return _baseUserSchema.strip();
      case 'catchall':
        return _baseUserSchema.catchall(z.string());
      default:
        return _baseUserSchema;
    }
  }

  Map<String, dynamic> _getCurrentFormData() {
    final baseData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'address': {
        'street': _streetController.text,
        'city': _cityController.text,
        'country': _countryController.text,
      },
    };

    // Add age only if it's not empty and not omitted
    if (_ageController.text.isNotEmpty && _selectedManipulation != 'omitted') {
      final age = int.tryParse(_ageController.text);
      if (age != null) {
        baseData['age'] = age;
      }
    }

    // Add phone for extended schema
    if (_selectedManipulation == 'extended' &&
        _phoneController.text.isNotEmpty) {
      baseData['phone'] = _phoneController.text;
    }

    // Add extra properties for testing passthrough/strip/catchall
    if (['passthrough', 'strip', 'catchall'].contains(_selectedManipulation)) {
      baseData['unknownProperty'] = 'test value';
      baseData['extraField'] = 42;
    }

    return baseData;
  }

  @override
  Widget build(BuildContext context) {
    final currentSchema = _getCurrentSchema();

    return ValidationCard(
      title: 'Example 5: Advanced Object Manipulation',
      description: _descriptions[_selectedManipulation] ?? '',
      form: Form(
        key: _objectFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Manipulation type selection
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedManipulation,
                    onChanged: (value) {
                      setState(() {
                        _selectedManipulation = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Object Manipulation Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.transform),
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
                  onPressed: _fillSampleData,
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Fill Sample'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // User fields
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Name field (always shown)
                    TextFormField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                        enabled: !['picked', 'omitted']
                                .contains(_selectedManipulation) ||
                            ['picked'].contains(_selectedManipulation),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Email field (always shown)
                    TextFormField(
                      controller: _emailController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.email),
                        enabled: !['picked', 'omitted']
                                .contains(_selectedManipulation) ||
                            ['picked'].contains(_selectedManipulation),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),

                    // Age field (hidden for omitted and picked)
                    if (!['omitted', 'picked'].contains(_selectedManipulation))
                      Column(
                        children: [
                          TextFormField(
                            controller: _ageController,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.cake),
                              helperText: 'Must be 18 or older',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),

                    // Phone field (only for extended)
                    if (_selectedManipulation == 'extended')
                      Column(
                        children: [
                          TextFormField(
                            controller: _phoneController,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Phone (Extended Field)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.phone),
                              helperText: 'Added by extend() operation',
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Address fields (hidden for picked)
            if (_selectedManipulation != 'picked')
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Address Information',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _streetController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Street',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.home),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cityController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'City',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_city),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _countryController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Country',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.flag),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Information about current manipulation
            const SizedBox(height: 16),
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
                        'Schema Manipulation:',
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
                    _getManipulationExplanation(_selectedManipulation),
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
        title: '${_getDisplayName(_selectedManipulation)} Validation Result',
        value: _getCurrentFormData(),
      ),
      schemaDisplay: SchemaDisplay(
        title: 'Current Schema Operation',
        code: _getSchemaCode(_selectedManipulation),
        description: 'Object manipulation operation: $_selectedManipulation',
      ),
      onValidate: _validate,
      onClear: _clearInput,
    );
  }

  String _getDisplayName(String manipulation) {
    switch (manipulation) {
      case 'base':
        return 'Base Schema';
      case 'picked':
        return 'Pick Fields';
      case 'omitted':
        return 'Omit Fields';
      case 'extended':
        return 'Extend Schema';
      case 'partial':
        return 'Partial Schema';
      case 'deepPartial':
        return 'Deep Partial';
      case 'required':
        return 'Required Fields';
      case 'strict':
        return 'Strict Mode';
      case 'passthrough':
        return 'Passthrough Mode';
      case 'strip':
        return 'Strip Unknown';
      case 'catchall':
        return 'Catchall Validation';
      default:
        return manipulation;
    }
  }

  String _getManipulationExplanation(String manipulation) {
    switch (manipulation) {
      case 'base':
        return 'Original schema with all fields required';
      case 'picked':
        return 'Only selected fields (name, email) are included in validation';
      case 'omitted':
        return 'Specified fields (age) are excluded from validation';
      case 'extended':
        return 'New fields (phone) are added to the schema';
      case 'partial':
        return 'All fields become optional';
      case 'deepPartial':
        return 'All fields including nested objects become optional';
      case 'required':
        return 'Specific fields (name, email) must be provided even in partial schema';
      case 'strict':
        return 'Unknown properties will cause validation to fail';
      case 'passthrough':
        return 'Unknown properties are allowed and passed through';
      case 'strip':
        return 'Unknown properties are removed during validation';
      case 'catchall':
        return 'Unknown properties must validate as strings';
      default:
        return 'Object manipulation operation';
    }
  }

  String _getSchemaCode(String manipulation) {
    const baseSchema = '''final baseUserSchema = z.object({
  'name': z.string(),
  'email': z.string().email(),
  'age': z.number().min(18),
  'address': z.object({
    'street': z.string(),
    'city': z.string(),
    'country': z.string(),
  }),
});''';

    switch (manipulation) {
      case 'base':
        return baseSchema;
      case 'picked':
        return '''$baseSchema

final pickedSchema = baseUserSchema.pick(['name', 'email']);''';
      case 'omitted':
        return '''$baseSchema

final omittedSchema = baseUserSchema.omit(['age']);''';
      case 'extended':
        return '''$baseSchema

final extendedSchema = baseUserSchema.extend({'phone': z.string()});''';
      case 'partial':
        return '''$baseSchema

final partialSchema = baseUserSchema.partial();''';
      case 'deepPartial':
        return '''$baseSchema

final deepPartialSchema = baseUserSchema.deepPartial();''';
      case 'required':
        return '''$baseSchema

final requiredSchema = baseUserSchema.partial().required(['name', 'email']);''';
      case 'strict':
        return '''$baseSchema

final strictSchema = baseUserSchema.strict();''';
      case 'passthrough':
        return '''$baseSchema

final passthroughSchema = baseUserSchema.passthrough();''';
      case 'strip':
        return '''$baseSchema

final stripSchema = baseUserSchema.strip();''';
      case 'catchall':
        return '''$baseSchema

final catchallSchema = baseUserSchema.catchall(z.string());''';
      default:
        return baseSchema;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
