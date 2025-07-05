# zod-bhai

A powerful Dart schema validation library inspired by Zod, providing type-safe validation, parsing, and inference with excellent developer experience.

## Features

- 🚀 **Type-safe validation** with strong type inference
- 📝 **Schema-based validation** with detailed error reporting
- 🔗 **Schema composition** and reuse
- ⚡ **High performance** with lazy validation
- 🎯 **Zod-like API** for familiar developer experience
- 🔧 **Extensible** with custom validation functions
- 📱 **Flutter ready** with no external dependencies

## Installation

Add `zod_bhai` to your `pubspec.yaml`:

```yaml
dependencies:
  zod_bhai: ^0.1.0
```

## Quick Start

```dart
import 'package:zod_bhai/zod_bhai.dart';

// Define a schema
final userSchema = z.object({
  'name': z.string().min(2).max(50),
  'email': z.string().email(),
  'age': z.number().min(18).max(120),
  'isActive': z.boolean(),
});

// Validate data
final result = userSchema.validate({
  'name': 'John Doe',
  'email': 'john@example.com',
  'age': 25,
  'isActive': true,
});

if (result.isSuccess) {
  final user = result.data; // Type-safe access
  print('Valid user: ${user['name']}');
} else {
  final errors = result.errors; // Detailed error information
  print('Validation failed: ${errors.formattedErrors}');
}
```

## Basic Schemas

### String Schema

```dart
final schema = z.string()
  .min(2)           // Minimum length
  .max(50)          // Maximum length
  .email()          // Email validation
  .trim()           // Trim whitespace
  .toLowerCase();   // Convert to lowercase

// Convenience methods
final emailSchema = z.email();
final urlSchema = z.url();
final uuidSchema = z.uuid();
final nonEmptySchema = z.nonEmptyString();
```

### Number Schema

```dart
final schema = z.number()
  .min(0)           // Minimum value
  .max(100)         // Maximum value
  .int()            // Integer validation
  .positive();      // Positive number

// Convenience methods
final intSchema = z.int();
final positiveSchema = z.positive();
final negativeSchema = z.negative();
final portSchema = z.port();
final yearSchema = z.year();
```

### Boolean Schema

```dart
final schema = z.boolean()
  .isTrue();        // Must be true

// Convenience methods
final trueSchema = z.trueValue;
final falseSchema = z.falseValue;
```

### Null Schema

```dart
final schema = z.null_();
final nullValueSchema = z.nullValue;
```

## Complex Schemas

### Object Schema

```dart
final userSchema = z.object({
  'name': z.string().min(2),
  'email': z.string().email(),
  'age': z.number().min(18),
  'address': z.object({
    'street': z.string(),
    'city': z.string(),
    'zipCode': z.string().regex(r'^\d{5}$'),
  }).optional(),
});

// Validate
final result = userSchema.validate(userData);
```

### Array Schema

```dart
final schema = z.array(z.string())
  .min(1)           // Minimum length
  .max(10)          // Maximum length
  .nonempty();      // Non-empty array

// Validate
final result = schema.validate(['item1', 'item2']);
```

### Union Schema

```dart
final schema = z.union([
  z.string(),
  z.number(),
]);

// Validate - accepts either string or number
final result1 = schema.validate('hello');
final result2 = schema.validate(42);
```

### Tuple Schema

```dart
final schema = z.tuple([
  z.string(),
  z.number(),
  z.boolean(),
]);

// Validate - fixed-length array with specific types
final result = schema.validate(['hello', 42, true]);
```

## Schema Composition

### Chaining Methods

```dart
final schema = z.string()
  .min(2)
  .max(50)
  .email()
  .trim()
  .toLowerCase();
```

### Refinement

```dart
final schema = z.string().refine(
  (value) => value.contains('@'),
  message: 'must contain @ symbol',
);
```

### Transformation

```dart
final schema = z.string()
  .trim()
  .transform((value) => value.toUpperCase());
```

### Default Values

```dart
final schema = z.string()
  .defaultTo('default value');

// Or computed default
final schema = z.string()
  .defaultToComputed(() => DateTime.now().toString());
```

### Optional Fields

```dart
final schema = z.object({
  'required': z.string(),
  'optional': z.string().optional(),
});
```

## Error Handling

### Detailed Error Information

```dart
final result = schema.validate(invalidData);

if (result.isFailure) {
  final errors = result.errors!;
  
  for (final error in errors.errors) {
    print('Path: ${error.fullPath}');
    print('Message: ${error.message}');
    print('Received: ${error.received}');
    print('Expected: ${error.expected}');
    print('Code: ${error.code}');
  }
}
```

### Error Filtering

```dart
final errors = result.errors!;

// Filter by path
final fieldErrors = errors.filterByPath(['user', 'email']);

// Filter by error code
final typeErrors = errors.filterByCode('type_mismatch');
```

### Safe Parsing

```dart
// Throws exception on validation failure
final data = schema.parse(input);

// Returns null on validation failure
final data = schema.safeParse(input);

// Returns ValidationResult
final result = schema.validate(input);
```

## Advanced Features

### Custom Validation

```dart
final schema = z.custom<String>((input, path) {
  if (input is String && input.startsWith('custom:')) {
    return ValidationResult.success(input);
  }
  return ValidationResult.failure(
    ValidationErrorCollection.single(
      ValidationError.simple(
        message: 'must start with "custom:"',
        path: path,
        received: input,
      ),
    ),
  );
});
```

### Lazy Schemas

```dart
final recursiveSchema = z.lazy(() => z.object({
  'value': z.string(),
  'children': z.array(recursiveSchema).optional(),
}));
```

### Async Validation

```dart
final schema = z.string().refineAsync(
  (value) async {
    // Check if email exists in database
    return await checkEmailExists(value);
  },
  message: 'email already exists',
);

// Use async validation
final result = await schema.validateAsync('test@example.com');
```

## Flutter Integration

### Form Validation

```dart
class UserForm extends StatefulWidget {
  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  final _userSchema = z.object({
    'name': z.string().min(2).max(50),
    'email': z.string().email(),
  });

  void _submitForm() {
    final data = {
      'name': _nameController.text,
      'email': _emailController.text,
    };

    final result = _userSchema.validate(data);
    
    if (result.isSuccess) {
      // Handle success
      print('Form is valid: ${result.data}');
    } else {
      // Handle errors
      setState(() {
        // Update UI with error messages
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

### State Management Integration

```dart
// With Riverpod
class UserNotifier extends StateNotifier<AsyncValue<User>> {
  final _userSchema = z.object({
    'name': z.string().min(2),
    'email': z.string().email(),
  });

  Future<void> updateUser(Map<String, dynamic> data) async {
    final result = _userSchema.validate(data);
    
    if (result.isSuccess) {
      state = AsyncValue.data(User.fromJson(result.data!));
    } else {
      state = AsyncValue.error(
        ValidationException(result.errors!.formattedErrors),
        StackTrace.current,
      );
    }
  }
}
```

## Performance Considerations

- **Lazy Validation**: Schemas are only validated when `.validate()` is called
- **Error Caching**: Validation errors are cached for repeated failures
- **Schema Reuse**: Schema instances can be reused across multiple validations
- **Memory Management**: Efficient error object creation and management

## Migration from Other Libraries

### From json_annotation

```dart
// Before (json_annotation)
@JsonSerializable()
class User {
  final String name;
  final String email;
  
  User({required this.name, required this.email});
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

// After (zod-bhai)
final userSchema = z.object({
  'name': z.string().min(2),
  'email': z.string().email(),
});

final result = userSchema.validate(json);
if (result.isSuccess) {
  final user = result.data;
}
```

### From validators

```dart
// Before (validators)
final errors = validate({
  'email': [isEmail, isRequired],
  'password': [isLength(8), isRequired],
}, data);

// After (zod-bhai)
final schema = z.object({
  'email': z.string().email(),
  'password': z.string().min(8),
});

final result = schema.validate(data);
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by [Zod](https://github.com/colinhacks/zod) for TypeScript
- Built with ❤️ for the Dart/Flutter community 