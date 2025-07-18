import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';

import '../../widgets/result_display.dart';
import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class EnumExample extends StatefulWidget {
  const EnumExample({super.key});

  @override
  State<EnumExample> createState() => _EnumExampleState();
}

class _EnumExampleState extends State<EnumExample> {
  final _enumFormKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  String _selectedEnumType = 'basic';

  // Basic enum schema from README Example 8
  final _basicRoleSchema = z.enum_(['admin', 'user', 'guest']);

  final Map<String, String> _descriptions = {
    'basic': 'Basic enum: admin, user, guest',
    'excluded': 'Enum with excluded values (no guest)',
    'extended': 'Enum with additional values (moderator, supervisor)',
    'caseInsensitive': 'Case-insensitive enum matching',
  };

  final Map<String, List<String>> _availableValues = {
    'basic': ['admin', 'user', 'guest'],
    'excluded': ['admin', 'user'],
    'extended': ['admin', 'user', 'guest', 'moderator', 'supervisor'],
    'caseInsensitive': ['admin', 'user', 'guest'],
  };

  final Map<String, String> _examples = {
    'basic': 'admin',
    'excluded': 'user',
    'extended': 'moderator',
    'caseInsensitive': 'ADMIN',
  };

  void _validate() {
    _enumFormKey.currentState?.validate();
  }

  void _clearInput() {
    _enumFormKey.currentState?.reset();
    _textController.clear();
    setState(() {});
  }

  void _fillExample() {
    _textController.text = _examples[_selectedEnumType] ?? '';
    setState(() {});
  }

  Schema _getCurrentSchema() {
    switch (_selectedEnumType) {
      case 'basic':
        return _basicRoleSchema;
      case 'excluded':
        return _basicRoleSchema.exclude(['guest']);
      case 'extended':
        return _basicRoleSchema.extend(['moderator', 'supervisor']);
      case 'caseInsensitive':
        return _basicRoleSchema.caseInsensitive();
      default:
        return _basicRoleSchema;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSchema = _getCurrentSchema();
    final availableValues = _availableValues[_selectedEnumType] ?? [];

    return ValidationCard(
      title: 'Example 8: Flexible Enums',
      description: _descriptions[_selectedEnumType] ?? '',
      form: Form(
        key: _enumFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enum type selection
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedEnumType,
                    onChanged: (value) {
                      setState(() {
                        _selectedEnumType = value!;
                        _textController.clear();
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Enum Validation Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.list_alt),
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

            // Text input for enum value
            TextFormField(
              controller: _textController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Enum Value',
                hintText: 'Enter an enum value',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.text_format),
                helperText: _descriptions[_selectedEnumType],
              ),
            ),
            const SizedBox(height: 16),

            // Available values display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Valid Values',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableValues.map((value) {
                        final isSelected = _textController.text == value ||
                            (_selectedEnumType == 'caseInsensitive' &&
                                _textController.text.toLowerCase() ==
                                    value.toLowerCase());

                        return ActionChip(
                          label: Text(value),
                          onPressed: () {
                            _textController.text = value;
                            setState(() {});
                          },
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Special notes for case insensitive
            if (_selectedEnumType == 'caseInsensitive')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.3),
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
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Case Insensitive Mode',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try typing: ADMIN, User, guest, AdMiN - all variations will be accepted!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
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
                        Icons.rule,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Enum Rules:',
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
                    _getEnumRules(_selectedEnumType),
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
        title: '${_getDisplayName(_selectedEnumType)} Validation Result',
        value: _textController.text,
      ),
      schemaDisplay: SchemaDisplay(
        title: 'Current Enum Schema',
        code: _getSchemaCode(_selectedEnumType),
        description: 'Enum validation schema for $_selectedEnumType type.',
      ),
      onValidate: _validate,
      onClear: _clearInput,
    );
  }

  String _getDisplayName(String enumType) {
    switch (enumType) {
      case 'basic':
        return 'Basic Enum';
      case 'excluded':
        return 'Exclude Values';
      case 'extended':
        return 'Extend Values';
      case 'caseInsensitive':
        return 'Case Insensitive';
      default:
        return enumType;
    }
  }

  String _getEnumRules(String enumType) {
    switch (enumType) {
      case 'basic':
        return '• Must be one of: admin, user, guest\n• Case sensitive matching\n• Exact string match required';
      case 'excluded':
        return '• Original enum minus excluded values\n• Cannot use: guest\n• Valid: admin, user';
      case 'extended':
        return '• Original enum plus new values\n• Added: moderator, supervisor\n• All original values still valid';
      case 'caseInsensitive':
        return '• Case insensitive matching\n• ADMIN = admin = AdMiN\n• Any case variation accepted';
      default:
        return 'Enum validation rules';
    }
  }

  String _getSchemaCode(String enumType) {
    const baseSchema =
        "final roleSchema = z.enum_(['admin', 'user', 'guest']);";

    switch (enumType) {
      case 'basic':
        return baseSchema;
      case 'excluded':
        return '''$baseSchema
final restrictedRoles = roleSchema.exclude(['guest']);''';
      case 'extended':
        return '''$baseSchema
final extendedRoles = roleSchema.extend(['moderator', 'supervisor']);''';
      case 'caseInsensitive':
        return '''$baseSchema
final caseInsensitiveRoles = roleSchema.caseInsensitive();''';
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
