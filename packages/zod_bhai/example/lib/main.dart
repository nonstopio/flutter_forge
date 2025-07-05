import 'package:flutter/material.dart';
import 'package:zod_bhai/zod_bhai.dart';

void main() {
  runApp(const ZodBhaiExampleApp());
}

class ZodBhaiExampleApp extends StatelessWidget {
  const ZodBhaiExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zod-Bhai Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ValidationExamplePage(),
    );
  }
}

class ValidationExamplePage extends StatefulWidget {
  const ValidationExamplePage({super.key});

  @override
  State<ValidationExamplePage> createState() => _ValidationExamplePageState();
}

class _ValidationExamplePageState extends State<ValidationExamplePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  
  String? _validationResult;
  bool _isValid = false;

  // Define the user schema
  final _userSchema = z.object({
    'name': z.string().min(2).max(50),
    'email': z.string().email(),
    'age': z.number().min(18).max(120).int(),
  });

  void _validateForm() {
    final data = {
      'name': _nameController.text,
      'email': _emailController.text,
      'age': int.tryParse(_ageController.text) ?? 0,
    };

    final result = _userSchema.validate(data);
    
    setState(() {
      if (result.isSuccess) {
        _validationResult = '✅ Validation successful!\nData: ${result.data}';
        _isValid = true;
      } else {
        _validationResult = '❌ Validation failed:\n${result.errors?.formattedErrors ?? 'Unknown error'}';
        _isValid = false;
      }
    });
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _ageController.clear();
    setState(() {
      _validationResult = null;
      _isValid = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zod-Bhai Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'User Validation Example',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name (2-50 characters)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Email field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              // Age field
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  hintText: 'Enter your age (18-120)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              
              // Validation buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _validateForm,
                      child: const Text('Validate'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearForm,
                      child: const Text('Clear'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Validation result
              if (_validationResult != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isValid ? Colors.green.shade50 : Colors.red.shade50,
                    border: Border.all(
                      color: _isValid ? Colors.green : Colors.red,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _validationResult!,
                    style: TextStyle(
                      color: _isValid ? Colors.green.shade800 : Colors.red.shade800,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Schema information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schema Definition:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '''final userSchema = z.object({
  'name': z.string().min(2).max(50),
  'email': z.string().email(),
  'age': z.number().min(18).max(120).int(),
});''',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }
} 