import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';

import '../../widgets/result_display.dart';
import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class PipelineExample extends StatefulWidget {
  const PipelineExample({super.key});

  @override
  State<PipelineExample> createState() => _PipelineExampleState();
}

class _PipelineExampleState extends State<PipelineExample> {
  final _formKey = GlobalKey<FormState>();
  final _userInputController = TextEditingController();
  final _emailInputController = TextEditingController();

  String _selectedExample = 'user';

  // Example 11: Multi-stage Validation Pipelines
  final userPipeline = z.pipeline([
    z.string().transform((s) => s.trim()),
    z.string().min(2).max(50),
    z.string().refine((s) => !s.contains('admin')),
    z.string().transform((s) => s.toLowerCase()),
  ]);

  // Email pipeline extending user pipeline
  late final emailPipeline = userPipeline.pipe([z.string().email()]);

  // Example with prepend
  late final trimmedPipeline = userPipeline.prepend([z.string().trim()]);

  // Custom pipeline for demonstration
  final customPipeline = z.pipeline([
    // Stage 1: Basic validation
    z.string().min(1),
    // Stage 2: Transform to uppercase
    z.string().transform((s) => s.toUpperCase()),
    // Stage 3: Validate format
    z.string().regex(RegExp(r'^[A-Z0-9_]+$')),
    // Stage 4: Add prefix
    z.string().transform((s) => 'USER_$s'),
  ]);

  Widget _buildPipelineStages() {
    final stages = _selectedExample == 'user'
        ? [
            'Stage 1: Trim whitespace',
            'Stage 2: Validate length (2-50)',
            'Stage 3: Check no "admin" in username',
            'Stage 4: Convert to lowercase',
          ]
        : _selectedExample == 'email'
            ? [
                'Stage 1: Trim whitespace',
                'Stage 2: Validate length (2-50)',
                'Stage 3: Check no "admin" in username',
                'Stage 4: Convert to lowercase',
                'Stage 5: Validate email format',
              ]
            : [
                'Stage 1: Validate not empty',
                'Stage 2: Convert to uppercase',
                'Stage 3: Validate format (A-Z, 0-9, _)',
                'Stage 4: Add USER_ prefix',
              ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pipeline Stages:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...stages.asMap().entries.map((entry) {
              final index = entry.key;
              final stage = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(stage)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTransformationPreview() {
    final input = _selectedExample == 'email'
        ? _emailInputController.text
        : _userInputController.text;

    if (input.isEmpty) return const SizedBox.shrink();

    List<String> transformations = [];

    if (_selectedExample == 'user' || _selectedExample == 'email') {
      transformations = [
        'Input: "$input"',
        'After trim: "${input.trim()}"',
        'After lowercase: "${input.trim().toLowerCase()}"',
      ];
    } else {
      transformations = [
        'Input: "$input"',
        'After uppercase: "${input.toUpperCase()}"',
        'After prefix: "USER_${input.toUpperCase()}"',
      ];
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transformation Preview:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...transformations.map((t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    t,
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Schema get _currentSchema {
    switch (_selectedExample) {
      case 'email':
        return emailPipeline;
      case 'custom':
        return customPipeline;
      default:
        return userPipeline;
    }
  }

  String get _currentInput {
    return _selectedExample == 'email'
        ? _emailInputController.text
        : _userInputController.text;
  }

  void _fillExample() {
    setState(() {
      switch (_selectedExample) {
        case 'user':
          _userInputController.text = '  JohnDoe123  ';
          break;
        case 'email':
          _emailInputController.text = '  USER@EXAMPLE.COM  ';
          break;
        case 'custom':
          _userInputController.text = 'test_user_123';
          break;
      }
    });
  }

  void _fillInvalidExample() {
    setState(() {
      switch (_selectedExample) {
        case 'user':
          _userInputController.text = 'admin_user';
          break;
        case 'email':
          _emailInputController.text = 'not-an-email';
          break;
        case 'custom':
          _userInputController.text = 'test user!';
          break;
      }
    });
  }

  void _clearInputs() {
    setState(() {
      _userInputController.clear();
      _emailInputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValidationCard(
      title: 'Example 11: Validation Pipelines',
      description:
          'Multi-stage validation with transformations and refinements.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pipeline selector
            DropdownButtonFormField<String>(
              value: _selectedExample,
              onChanged: (value) {
                setState(() {
                  _selectedExample = value!;
                  _clearInputs();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Pipeline',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.settings_input_component),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'user',
                  child: Text('Username Pipeline'),
                ),
                DropdownMenuItem(
                  value: 'email',
                  child: Text('Email Pipeline (Extended)'),
                ),
                DropdownMenuItem(
                  value: 'custom',
                  child: Text('Custom Pipeline'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pipeline stages display
            _buildPipelineStages(),
            const SizedBox(height: 16),

            // Input field
            if (_selectedExample == 'email')
              TextFormField(
                controller: _emailInputController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Email Input',
                  hintText: 'Enter email address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              )
            else
              TextFormField(
                controller: _userInputController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: _selectedExample == 'custom'
                      ? 'Custom Input'
                      : 'Username Input',
                  hintText: _selectedExample == 'custom'
                      ? 'Enter text'
                      : 'Enter username',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(_selectedExample == 'custom'
                      ? Icons.text_fields
                      : Icons.person),
                ),
              ),
            const SizedBox(height: 16),

            // Transformation preview
            _buildTransformationPreview(),
            const SizedBox(height: 16),

            // Action buttons
            Wrap(
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _fillExample,
                  icon: const Icon(Icons.check),
                  label: const Text('Valid Example'),
                ),
                OutlinedButton.icon(
                  onPressed: _fillInvalidExample,
                  icon: const Icon(Icons.close),
                  label: const Text('Invalid Example'),
                ),
                OutlinedButton.icon(
                  onPressed: _clearInputs,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
      result: ResultDisplay(
        schema: _currentSchema,
        title: 'Pipeline Validation Result',
        value: _currentInput,
      ),
      schemaDisplay: const SchemaDisplay(
        title: 'Pipeline Schema Methods',
        code: '''// Multi-stage validation
final userPipeline = z.pipeline([
  z.string().transform((s) => s.trim()),
  z.string().min(2).max(50),
  z.string().refine((s) => !s.contains('admin')),
  z.string().transform((s) => s.toLowerCase()),
]);

// Add additional stages
final emailPipeline = userPipeline.pipe([z.string().email()]);

// Prepend a stage
final trimmedPipeline = userPipeline.prepend([z.string().trim()]);

// Insert stage at index
final modified = userPipeline.insertAt(1, [z.string().min(1)]);

// Replace stage at index
final replaced = userPipeline.replaceStageAt(0,
    z.string().transform((s) => s.trim().toLowerCase()));''',
        description:
            'Pipelines allow complex multi-stage validation with transformations.',
      ),
      onValidate: () {
        _formKey.currentState?.validate();
      },
      onClear: _clearInputs,
    );
  }

  @override
  void dispose() {
    _userInputController.dispose();
    _emailInputController.dispose();
    super.dispose();
  }
}
