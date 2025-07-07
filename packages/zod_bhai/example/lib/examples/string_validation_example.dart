import 'package:flutter/material.dart';
import 'package:zod_bhai/zod_bhai.dart';

import '../utils/form_validation_extensions.dart';
import '../widgets/result_display.dart';
import '../widgets/validation_card.dart';

class StringValidationExample extends StatefulWidget {
  const StringValidationExample({super.key});

  @override
  State<StringValidationExample> createState() =>
      _StringValidationExampleState();
}

class _StringValidationExampleState extends State<StringValidationExample> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  final _emailSchema = Z.string().min(5).max(50).email();

  void _validate() {
    // First validate using Form's built-in validation
    _formKey.currentState?.validate() ?? false;
  }

  void _clearInput() {
    _formKey.currentState?.reset();
    _textController.clear();
    setState(() {
      // Trigger rebuild to clear validation result
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValidationCard(
      title: 'String Validation',
      description:
          'Validate email strings with length constraints (5-50 characters)',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _textController,
              onChanged: (_) {
                setState(() {
                  // Trigger rebuild to update validation result
                });
              },
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter a valid email (e.g., user@example.com)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
                helperText: 'Must be 5-50 characters and valid email format',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: _emailSchema.validator,
            ),
          ],
        ),
      ),
      result: ResultDisplay(
        schema: _emailSchema,
        title: 'Email Detailed Validation Result',
        value: _textController.text,
      ),
      onValidate: _validate,
      onClear: _clearInput,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
