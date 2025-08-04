import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';

import '../../widgets/result_display.dart';
import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class DiscriminatedUnionExample extends StatefulWidget {
  const DiscriminatedUnionExample({super.key});

  @override
  State<DiscriminatedUnionExample> createState() =>
      _DiscriminatedUnionExampleState();
}

class _DiscriminatedUnionExampleState extends State<DiscriminatedUnionExample> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'text';

  // Controllers for different message types
  final _textController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _imageAltController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _videoDurationController = TextEditingController();
  final _audioUrlController = TextEditingController();
  final _audioDurationController = TextEditingController();

  // Example 10: Discriminated Unions
  final messageSchema = z.discriminatedUnion('type', [
    z.object({
      'type': z.literal('text'),
      'content': z.string().min(1).max(1000),
    }),
    z.object({
      'type': z.literal('image'),
      'url': z.string().url(),
      'alt': z.string().optional(),
    }),
    z.object({
      'type': z.literal('video'),
      'url': z.string().url(),
      'duration': z.number().positive(),
    }),
  ]);

  // Extended with audio
  late final extendedMessageSchema = messageSchema.extend([
    z.object({
      'type': z.literal('audio'),
      'url': z.string().url(),
      'duration': z.number().positive(),
    })
  ]);

  Map<String, dynamic> _buildMessageData() {
    switch (_selectedType) {
      case 'text':
        return {
          'type': 'text',
          'content': _textController.text,
        };
      case 'image':
        final data = {
          'type': 'image',
          'url': _imageUrlController.text,
        };
        if (_imageAltController.text.isNotEmpty) {
          data['alt'] = _imageAltController.text;
        }
        return data;
      case 'video':
        return {
          'type': 'video',
          'url': _videoUrlController.text,
          'duration': double.tryParse(_videoDurationController.text) ?? 0,
        };
      case 'audio':
        return {
          'type': 'audio',
          'url': _audioUrlController.text,
          'duration': double.tryParse(_audioDurationController.text) ?? 0,
        };
      default:
        return {};
    }
  }

  void _fillExample() {
    setState(() {
      switch (_selectedType) {
        case 'text':
          _textController.text = 'Hello, this is a text message!';
          break;
        case 'image':
          _imageUrlController.text = 'https://example.com/image.jpg';
          _imageAltController.text = 'A beautiful sunset';
          break;
        case 'video':
          _videoUrlController.text = 'https://example.com/video.mp4';
          _videoDurationController.text = '120.5';
          break;
        case 'audio':
          _audioUrlController.text = 'https://example.com/audio.mp3';
          _audioDurationController.text = '180';
          break;
      }
    });
  }

  void _clearInputs() {
    setState(() {
      _textController.clear();
      _imageUrlController.clear();
      _imageAltController.clear();
      _videoUrlController.clear();
      _videoDurationController.clear();
      _audioUrlController.clear();
      _audioDurationController.clear();
    });
  }

  Widget _buildMessageTypeForm() {
    switch (_selectedType) {
      case 'text':
        return TextFormField(
          controller: _textController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Message Content',
            hintText: 'Enter your text message',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.text_fields),
          ),
        );

      case 'image':
        return Column(
          children: [
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                hintText: 'https://example.com/image.jpg',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _imageAltController,
              decoration: const InputDecoration(
                labelText: 'Alt Text (Optional)',
                hintText: 'Image description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
          ],
        );

      case 'video':
        return Column(
          children: [
            TextFormField(
              controller: _videoUrlController,
              decoration: const InputDecoration(
                labelText: 'Video URL',
                hintText: 'https://example.com/video.mp4',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _videoDurationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duration (seconds)',
                hintText: 'e.g., 120.5',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
              ),
            ),
          ],
        );

      case 'audio':
        return Column(
          children: [
            TextFormField(
              controller: _audioUrlController,
              decoration: const InputDecoration(
                labelText: 'Audio URL',
                hintText: 'https://example.com/audio.mp3',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _audioDurationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duration (seconds)',
                hintText: 'e.g., 180',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use extended schema if audio is selected
    final currentSchema =
        _selectedType == 'audio' ? extendedMessageSchema : messageSchema;

    return ValidationCard(
      title: 'Example 10: Discriminated Unions',
      description:
          'Efficient parsing with type-based discrimination for message types.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message type selector
            DropdownButtonFormField<String>(
              value: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                  _clearInputs();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Message Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'text',
                  child: Row(
                    children: [
                      Icon(Icons.text_fields, size: 20),
                      SizedBox(width: 8),
                      Text('Text Message'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'image',
                  child: Row(
                    children: [
                      Icon(Icons.image, size: 20),
                      SizedBox(width: 8),
                      Text('Image Message'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'video',
                  child: Row(
                    children: [
                      Icon(Icons.videocam, size: 20),
                      SizedBox(width: 8),
                      Text('Video Message'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'audio',
                  child: Row(
                    children: [
                      Icon(Icons.audiotrack, size: 20),
                      SizedBox(width: 8),
                      Text('Audio Message (Extended)'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dynamic form based on message type
            _buildMessageTypeForm(),
            const SizedBox(height: 16),

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
        schema: currentSchema,
        title: 'Message Validation Result',
        value: _buildMessageData(),
      ),
      schemaDisplay: const SchemaDisplay(
        title: 'Discriminated Union Schema',
        code: '''final messageSchema = z.discriminatedUnion('type', [
  z.object({
    'type': z.literal('text'),
    'content': z.string(),
  }),
  z.object({
    'type': z.literal('image'),
    'url': z.string().url(),
    'alt': z.string().optional(),
  }),
  z.object({
    'type': z.literal('video'),
    'url': z.string().url(),
    'duration': z.number().positive(),
  }),
]);

// Extend with new variants
final extended = messageSchema.extend([
  z.object({
    'type': z.literal('audio'),
    'url': z.string().url(),
    'duration': z.number(),
  })
]);''',
        description:
            'Discriminated unions provide efficient parsing by checking the discriminator field first.',
      ),
      onValidate: () {
        _formKey.currentState?.validate();
      },
      onClear: _clearInputs,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _imageUrlController.dispose();
    _imageAltController.dispose();
    _videoUrlController.dispose();
    _videoDurationController.dispose();
    _audioUrlController.dispose();
    _audioDurationController.dispose();
    super.dispose();
  }
}
