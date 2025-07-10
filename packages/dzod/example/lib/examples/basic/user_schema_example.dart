import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';

import '../../widgets/result_display.dart';
import '../../widgets/schema_display.dart';
import '../../widgets/validation_card.dart';

class UserSchemaExample extends StatefulWidget {
  const UserSchemaExample({super.key});

  @override
  State<UserSchemaExample> createState() => _UserSchemaExampleState();
}

class _UserSchemaExampleState extends State<UserSchemaExample> {
  final _userFormKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _themeController = TextEditingController(text: 'light');
  final _notificationsController = TextEditingController(text: 'true');
  final _createdAtController = TextEditingController();

  String _selectedRole = 'user';
  final List<String> _roles = ['admin', 'user', 'guest'];

  // Define the enterprise-grade user schema from README Example 1
  final _userSchema = Z.object({
    'id': Z.string(),
    'name': Z.string().min(2).max(50),
    'email': Z.string().email(),
    'age': Z.number().min(18).max(120),
    'role': Z.enum_(['admin', 'user', 'guest']),
    'preferences': Z.object({
      'theme': Z.enum_(['light', 'dark']),
      'notifications': Z.boolean(),
    }).partial(),
    'createdAt': Z.string(),
  });

  @override
  void initState() {
    super.initState();
    // Set default values
    _idController.text = 'ckjf0x7qr0000qzrmn831i7rn'; // Example CUID2
    _nameController.text = 'John Doe';
    _emailController.text = 'john@example.com';
    _ageController.text = '25';
    _createdAtController.text = DateTime.now().toIso8601String();
  }

  Map<String, dynamic> _getCurrentFormData() {
    return {
      'id': _idController.text,
      'name': _nameController.text,
      'email': _emailController.text,
      'age': int.tryParse(_ageController.text),
      'role': _selectedRole,
      'preferences': {
        'theme': _themeController.text,
        'notifications': _notificationsController.text.toLowerCase() == 'true',
      },
      'createdAt': _createdAtController.text,
    };
  }

  void _validate() {
    _userFormKey.currentState?.validate();
  }

  void _clearInput() {
    _userFormKey.currentState?.reset();
    _idController.clear();
    _nameController.clear();
    _emailController.clear();
    _ageController.clear();
    _themeController.text = 'light';
    _notificationsController.text = 'true';
    _createdAtController.clear();
    _selectedRole = 'user';
    setState(() {});
  }

  void _fillSampleData() {
    _idController.text = 'ckjf0x7qr0000qzrmn831i7rn';
    _nameController.text = 'John Doe';
    _emailController.text = 'john@example.com';
    _ageController.text = '25';
    _selectedRole = 'admin';
    _themeController.text = 'dark';
    _notificationsController.text = 'true';
    _createdAtController.text = '2023-01-01T00:00:00Z';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValidationCard(
      title: 'Example 1: Basic User Schema Validation',
      description:
          'Enterprise-grade user schema with nested objects, enums, and comprehensive validation',
      form: Form(
        key: _userFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sample data button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _fillSampleData,
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('Fill Sample Data'),
              ),
            ),
            const SizedBox(height: 16),

            // ID Field
            TextFormField(
              controller: _idController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'ID (CUID2)',
                hintText: 'Enter a CUID2 identifier',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fingerprint),
                helperText: 'User identifier string',
              ),
            ),
            const SizedBox(height: 16),

            // Name Field
            TextFormField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter full name (2-50 characters)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
                helperText: 'Must be 2-50 characters long',
              ),
            ),
            const SizedBox(height: 16),

            // Email Field
            TextFormField(
              controller: _emailController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter a valid email address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
                helperText: 'Must be a valid email format',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Age Field
            TextFormField(
              controller: _ageController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Age',
                hintText: 'Enter age (18-120)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
                helperText: 'Must be between 18 and 120',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Role Dropdown
            DropdownButtonFormField<String>(
              value: _selectedRole,
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.admin_panel_settings),
                helperText: 'Select user role',
              ),
              items: _roles.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role.toUpperCase()),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Preferences Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preferences (Partial Object)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Theme Field
                    TextFormField(
                      controller: _themeController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Theme',
                        hintText: 'light or dark',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.palette),
                        helperText: 'Theme preference: light or dark',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Notifications Field
                    TextFormField(
                      controller: _notificationsController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Notifications',
                        hintText: 'true or false',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notifications),
                        helperText: 'Notification preference: true or false',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Created At Field
            TextFormField(
              controller: _createdAtController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Created At (ISO DateTime)',
                hintText: 'Enter ISO 8601 datetime',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
                helperText: 'ISO 8601 datetime string',
              ),
            ),
          ],
        ),
      ),
      result: ResultDisplay(
        schema: _userSchema,
        title: 'User Schema Validation Result',
        value: _getCurrentFormData(),
      ),
      schemaDisplay: const SchemaDisplay(
        title: 'User Schema Definition',
        code: '''
final userSchema = Z.object({
  'id': Z.string(),
  'name': Z.string().min(2).max(50),
  'email': Z.string().email(),
  'age': Z.number().min(18).max(120),
  'role': Z.enum_(['admin', 'user', 'guest']),
  'preferences': Z.object({
    'theme': Z.enum_(['light', 'dark']),
    'notifications': Z.boolean(),
  }).partial(),
  'createdAt': Z.string(),
});''',
        description:
            'Enterprise-grade user schema with nested objects, enums, and comprehensive validation rules.',
      ),
      onValidate: _validate,
      onClear: _clearInput,
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _themeController.dispose();
    _notificationsController.dispose();
    _createdAtController.dispose();
    super.dispose();
  }
}
