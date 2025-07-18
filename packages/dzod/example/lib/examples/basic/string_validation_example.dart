import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';

import '../../widgets/result_display.dart';
import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class StringValidationExample extends StatefulWidget {
  const StringValidationExample({super.key});

  @override
  State<StringValidationExample> createState() =>
      _StringValidationExampleState();
}

class _StringValidationExampleState extends State<StringValidationExample> {
  final _stringFormKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  String _selectedValidator = 'email';

  // All string validation schemas from README Example 2
  Map<String, Schema> get _validators => {
        'email': z.string().email(),
        'url': z.string().url(),
        'uuid': z.string().uuid(),
        'cuid': z.string().cuid(),
        'cuid2': z.string().cuid2(),
        'ulid': z.string().ulid(),
        'jwt': z.string().jwt(),
        'base64': z.string().base64(),
        'hex': z.string().hex(),
        'hexColor': z.string().hexColor(),
        'emoji': z.string().emoji(),
        'json': z.string().json(),
        'nanoid': z.string().nanoid(),
      };

  final Map<String, String> _examples = {
    'email': 'user@example.com',
    'url': 'https://example.com',
    'uuid': '123e4567-e89b-12d3-a456-426614174000',
    'cuid': 'ckjf0x7qr0000qzrmn831i7rn',
    'cuid2': 'ckjf0x7qr0000qzrmn831i7rn',
    'ulid': '01ARZ3NDEKTSV4RRFFQ69G5FAV',
    'jwt':
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c',
    'base64': 'SGVsbG8gV29ybGQ=',
    'hex': '48656c6c6f20576f726c64',
    'hexColor': '#FF5733',
    'emoji': '😀',
    'json': '{"name": "John", "age": 30}',
    'nanoid': 'V1StGXR8_Z5jdHi6B-myT',
  };

  final Map<String, String> _descriptions = {
    'email': 'Valid email address format',
    'url': 'Valid URL format (http/https)',
    'uuid': 'Valid UUID v4 format',
    'cuid': 'Valid CUID format (Collision-resistant unique identifier)',
    'cuid2': 'Valid CUID2 format (Updated CUID)',
    'ulid':
        'Valid ULID format (Universally Unique Lexicographically Sortable Identifier)',
    'jwt': 'Valid JWT (JSON Web Token) format',
    'base64': 'Valid Base64 encoded string',
    'hex': 'Valid hexadecimal string',
    'hexColor': 'Valid hexadecimal color code (#RRGGBB)',
    'emoji': 'Valid single emoji character',
    'json': 'Valid JSON string format',
    'nanoid': 'Valid NanoID format (URL-safe unique ID)',
  };

  void _validate() {
    _stringFormKey.currentState?.validate();
  }

  void _clearInput() {
    _stringFormKey.currentState?.reset();
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
      title: 'Example 2: String Validations',
      description: _descriptions[_selectedValidator] ?? '',
      form: Form(
        key: _stringFormKey,
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
                      labelText: 'String Validator Type',
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
                labelText: '${_selectedValidator.toUpperCase()} Input',
                hintText: 'Enter a $_selectedValidator value',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(_getIconForValidator(_selectedValidator)),
                helperText: _descriptions[_selectedValidator],
              ),
              maxLines:
                  _selectedValidator == 'json' || _selectedValidator == 'jwt'
                      ? 3
                      : 1,
              keyboardType: _getKeyboardType(_selectedValidator),
            ),
          ],
        ),
      ),
      result: ResultDisplay(
        schema: currentSchema,
        title: '${_selectedValidator.toUpperCase()} Validation Result',
        value: _textController.text,
      ),
      schemaDisplay: SchemaDisplay(
        title: 'Current String Validator',
        code: _getSchemaCode(_selectedValidator),
        description: 'String validation schema for $_selectedValidator format.',
      ),
      onValidate: _validate,
      onClear: _clearInput,
    );
  }

  IconData _getIconForValidator(String validator) {
    switch (validator) {
      case 'email':
        return Icons.email;
      case 'url':
        return Icons.link;
      case 'uuid':
      case 'cuid':
      case 'cuid2':
      case 'ulid':
      case 'nanoid':
        return Icons.fingerprint;
      case 'jwt':
        return Icons.security;
      case 'base64':
      case 'hex':
        return Icons.code;
      case 'hexColor':
        return Icons.palette;
      case 'emoji':
        return Icons.emoji_emotions;
      case 'json':
        return Icons.data_object;
      default:
        return Icons.text_fields;
    }
  }

  TextInputType _getKeyboardType(String validator) {
    switch (validator) {
      case 'email':
        return TextInputType.emailAddress;
      case 'url':
        return TextInputType.url;
      case 'hex':
      case 'hexColor':
        return TextInputType.text;
      default:
        return TextInputType.text;
    }
  }

  String _getSchemaCode(String validator) {
    switch (validator) {
      case 'email':
        return 'final emailSchema = z.string().email();';
      case 'url':
        return 'final urlSchema = z.string().url();';
      case 'uuid':
        return 'final uuidSchema = z.string().uuid();';
      case 'cuid':
        return 'final cuidSchema = z.string().cuid();';
      case 'cuid2':
        return 'final cuid2Schema = z.string().cuid2();';
      case 'ulid':
        return 'final ulidSchema = z.string().ulid();';
      case 'jwt':
        return 'final jwtSchema = z.string().jwt();';
      case 'base64':
        return 'final base64Schema = z.string().base64();';
      case 'hex':
        return 'final hexSchema = z.string().hex();';
      case 'hexColor':
        return 'final hexColorSchema = z.string().hexColor();';
      case 'emoji':
        return 'final emojiSchema = z.string().emoji();';
      case 'json':
        return 'final jsonSchema = z.string().json();';
      case 'nanoid':
        return 'final nanoidSchema = z.string().nanoid();';
      default:
        return 'final stringSchema = z.string();';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
