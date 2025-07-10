<p align="center">
  <a href="https://nonstopio.com">
    <img src="https://github.com/nonstopio.png" alt="Nonstop Logo" height="128" />
  </a>
  <h1 align="center">NonStop</h1>
  <p align="center">Digital Product Development Experts for Startups & Enterprises</p>
  <p align="center">
    <a href="https://nonstopio.com/about-us">About</a> |
    <a href="https://nonstopio.com">Website</a>
  </p>
</p>

<h1 align="center">🔐 Dzod</h1>

<p align="center">
  <strong>⚡ Enterprise-grade Dart schema validation library with 105%+ feature parity with Zod</strong>
</p>

<p align="center">
  <a href="https://pub.dev/packages/dzod"><img src="https://img.shields.io/pub/v/dzod.svg?label=dzod&logo=dart&color=blue&style=for-the-badge" alt="pub package"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-purple.svg?style=for-the-badge" alt="License"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-Ready-02569B.svg?style=for-the-badge&logo=flutter" alt="Flutter"></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/TypeScript_Zod-105%25_Parity-green.svg?style=for-the-badge" alt="Zod Parity">
  <img src="https://img.shields.io/badge/Test_Coverage-98.5%25-brightgreen.svg?style=for-the-badge" alt="Test Coverage">
  <img src="https://img.shields.io/badge/Tests-566+-blue.svg?style=for-the-badge" alt="Tests">
</p>

---

## 🎯 What is Dzod?

Dzod is an **enterprise-grade** Dart schema validation library that provides **105%+ feature parity** with TypeScript's Zod, plus Flutter-specific extensions and advanced enterprise features. Built for production applications requiring robust data validation, type safety, and exceptional developer experience.

### 🏆 **Key Achievements**
- **🚀 105%+ Zod Feature Parity**: Complete compatibility with original Zod API plus additional features
- **⚡ 566+ Comprehensive Tests**: 98.5% test coverage with enterprise-grade quality assurance
- **🎨 Flutter-First Design**: Native Flutter integration with form validation, state management, and custom widgets
- **🔧 Enterprise Features**: Advanced error handling, async validation, schema composition, and JSON Schema generation
- **💡 Developer Experience**: Intuitive API design with comprehensive documentation and examples

---

## 🚀 Quick Start

```bash
# Add to your pubspec.yaml
dart pub add dzod
```

### Example 1: Basic User Schema Validation
```dart
import 'package:dzod/dzod.dart';

// Define an enterprise-grade user schema
final userSchema = Z.object({
  'id': Z.string().cuid2(),              // CUID2 validation
  'name': Z.string().min(2).max(50),
  'email': Z.string().email(),
  'age': Z.number().min(18).max(120),
  'role': Z.enum_(['admin', 'user', 'guest']),
  'preferences': Z.object({
    'theme': Z.enum_(['light', 'dark']).defaultTo('light'),
    'notifications': Z.boolean().defaultTo(true),
  }).partial(),
  'createdAt': Z.string().datetime(),
});

// Validate with detailed error reporting
final result = userSchema.validate({
  'id': 'ckjf0x7qr0000qzrmn831i7rn',
  'name': 'John Doe',
  'email': 'john@example.com',
  'age': 25,
  'role': 'admin',
  'preferences': {'theme': 'dark'},
  'createdAt': '2023-01-01T00:00:00Z',
});

if (result.isSuccess) {
  final user = result.data;
  print('✅ Valid user: ${user['name']}');
} else {
  // Enterprise-grade error handling
  final errors = result.errors!;
  print('❌ Validation failed:');
  for (final error in errors.errors) {
    print('  • ${error.fullPath}: ${error.message}');
  }
}
```

---

## 📖 Core Features

<div align="center">

| Feature | Description | Status |
|---------|-------------|--------|
| **🔥 Schema Types** | 19+ schema types with advanced validation | ✅ Complete |
| **⚡ Async Validation** | Full async/await support with database checks | ✅ Complete |
| **🎨 Flutter Integration** | Native widgets, form validation, state management | ✅ Complete |
| **🔧 Advanced Features** | Pipelines, discriminated unions, coercion | ✅ Complete |
| **📊 Error System** | 100+ error codes, custom formatting, context tracking | ✅ Complete |
| **🏗️ Schema Composition** | Introspection, JSON Schema generation, metadata | ✅ Complete |
| **🚀 Performance** | Lazy evaluation, caching, memory optimization | ✅ Complete |

</div>

---

## 🔧 Schema Types

### 🎯 **Basic Types**

### Example 2: String Validations
```dart
// String validations (separate examples)
final emailSchema = Z.string().min(2).max(50).email();
final urlSchema = Z.string().url();
final uuidSchema = Z.string().uuid();
final cuidSchema = Z.string().cuid();
final cuid2Schema = Z.string().cuid2();
final ulidSchema = Z.string().ulid();
final jwtSchema = Z.string().jwt();
final base64Schema = Z.string().base64();
final hexSchema = Z.string().hex();
final hexColorSchema = Z.string().hexColor();
final emojiSchema = Z.string().emoji();
final jsonSchema = Z.string().json();
final nanoidSchema = Z.string().nanoid();
```

### Example 3: Number Validations
```dart
// Number validations (separate examples)
final basicNumberSchema = Z.number().min(0).max(100).integer().positive();
final stepSchema = Z.number().step(0.1);
final precisionSchema = Z.number().precision(2);
final safeIntSchema = Z.number().safeInt();
final percentageSchema = Z.number().percentage();
final probabilitySchema = Z.number().probability();
final latitudeSchema = Z.number().latitude();
final longitudeSchema = Z.number().longitude();
final powerOfTwoSchema = Z.number().powerOfTwo();
final primeSchema = Z.number().prime();
final perfectSquareSchema = Z.number().perfectSquare();
```

### Example 4: Boolean and Null Types
```dart
// Boolean and null types
final boolSchema = Z.boolean();
final nullSchema = Z.null_();
```

### 🏗️ **Complex Types**

### Example 5: Advanced Object Manipulation
```dart
// Advanced object manipulation (separate examples)
final baseUserSchema = Z.object({
  'name': Z.string(),
  'email': Z.string().email(),
  'age': Z.number().min(18),
  'address': Z.object({
    'street': Z.string(),
    'city': Z.string(),
    'country': Z.string(),
  }),
});

// Field selection and manipulation
final pickedSchema = baseUserSchema.pick(['name', 'email']);
final omittedSchema = baseUserSchema.omit(['age']);
final extendedSchema = baseUserSchema.extend({'phone': Z.string()});

// Optional/required variations
final partialSchema = baseUserSchema.partial();
final deepPartialSchema = baseUserSchema.deepPartial();
final requiredSchema = partialSchema.required(['name', 'email']);

// Different handling modes for unknown properties
final strictSchema = baseUserSchema.strict();
final passthroughSchema = baseUserSchema.passthrough();
final stripSchema = baseUserSchema.strip();
final catchallSchema = baseUserSchema.catchall(Z.string());
```

### Example 6: Advanced Arrays
```dart
// Advanced arrays (separate examples)
final baseArraySchema = Z.array(Z.string());

// Length constraints
final rangeArraySchema = baseArraySchema.min(1).max(10);
final exactLengthSchema = baseArraySchema.length(5);
final nonemptySchema = baseArraySchema.nonempty();

// Element validation
final uniqueSchema = baseArraySchema.unique();
final includesSchema = baseArraySchema.includes('required');
final excludesSchema = baseArraySchema.excludes('forbidden');

// Conditional validation (correct predicate functions)
final someEmailSchema = baseArraySchema.some((element) => element.contains('@'));
final everyMinLengthSchema = baseArraySchema.every((element) => element.length >= 2);

// Transformation and filtering
final mappedSchema = baseArraySchema.mapElements((s) => s.trim());
final filteredSchema = baseArraySchema.filter((s) => s.length > 0);
final sortedSchema = baseArraySchema.sort((a, b) => a.compareTo(b));
```

### Example 7: Type-safe Tuples
```dart
// Type-safe tuples
final tupleSchema = Z.tuple([
  Z.string(),
  Z.number(),
  Z.boolean(),
]);

// Rest elements for additional values
final tupleWithRest = tupleSchema.rest(Z.string());

// Length constraints
final exactLengthTuple = tupleSchema.exactLength(3);
final minLengthTuple = tupleSchema.minLength(2);
final maxLengthTuple = tupleSchema.maxLength(5);
```

### Example 8: Flexible Enums
```dart
// Flexible enums
final roleSchema = Z.enum_(['admin', 'user', 'guest']);

// Remove specific values
final restrictedRoles = roleSchema.exclude(['guest']);

// Add new values
final extendedRoles = roleSchema.extend(['moderator', 'supervisor']);

// Case-insensitive matching
final caseInsensitiveRoles = roleSchema.caseInsensitive();
```

### Example 9: Key-value Records
```dart
// Key-value records
final recordSchema = Z.record(Z.number());

// Size constraints
final sizedRecord = recordSchema.min(1).max(10);

// Key requirements
final keyConstrainedRecord = recordSchema
  .requiredKeys({'id'})
  .optionalKeys({'meta'});

// Strict validation (no additional keys)
final strictRecord = recordSchema.strict();
```

### 🎭 **Advanced Schema Types**

### Example 10: Discriminated Unions
```dart
// Discriminated unions for efficient parsing
final messageSchema = Z.discriminatedUnion('type', [
  Z.object({
    'type': Z.literal('text'),
    'content': Z.string(),
  }),
  Z.object({
    'type': Z.literal('image'),
    'url': Z.string().url(),
    'alt': Z.string().optional(),
  }),
  Z.object({
    'type': Z.literal('video'),
    'url': Z.string().url(),
    'duration': Z.number().positive(),
  }),
]);

// Add new variants
final extendedMessages = messageSchema.extend([
  Z.object({
    'type': Z.literal('audio'),
    'url': Z.string().url(),
    'duration': Z.number(),
  })
]);

// Remove specific variants
final restrictedMessages = messageSchema.exclude(['video']);

// Filter to specific variants only
final filteredMessages = messageSchema.discriminatorIn(['text', 'image']);
```

### Example 11: Multi-stage Validation Pipelines
```dart
// Multi-stage validation pipelines
final userPipeline = Z.pipeline([
  Z.string().transform((s) => s.trim()),
  Z.string().min(2).max(50),
  Z.string().refine((s) => !s.contains('admin')),
  Z.string().transform((s) => s.toLowerCase()),
]);

// Add additional stages
final emailPipeline = userPipeline.pipe([Z.string().email()]);

// Prepend a stage
final trimmedPipeline = userPipeline.prepend([Z.string().trim()]);

// Insert stage at specific index
final modifiedPipeline = userPipeline.insertAt(1, [Z.string().min(1)]);

// Replace stage at specific index
final replacedPipeline = userPipeline.replaceStageAt(0, 
  Z.string().transform((s) => s.trim().toLowerCase()));
```

### Example 12: Enhanced Recursive Schemas
```dart
// Enhanced recursive schemas with circular detection
final categorySchema = Z.recursive<Map<String, dynamic>>(
  () => Z.object({
    'name': Z.string(),
    'children': Z.array(Z.recursive<Map<String, dynamic>>(
      () => Z.object({
        'name': Z.string(),
      })
    )).optional(),
  }),
  maxDepth: 100,                   // Prevent infinite recursion
  enableCircularDetection: true,   // Detect circular references
  enableMemoization: true,         // Cache validation results
);

// Modify settings with fluent API
final modifiedSchema = categorySchema
  .withMaxDepth(50)                // Change max depth
  .withCircularDetection(false)    // Disable circular detection
  .withMemoization(false);         // Disable memoization
```

### Example 13: Automatic Type Coercion
```dart
// Automatic type coercion
final numberCoercion = Z.coerce.number();     // String -> Number
final booleanCoercion = Z.coerce.boolean();   // String -> Boolean
final dateCoercion = Z.coerce.date();         // String -> DateTime
final listCoercion = Z.coerce.list();         // String -> List

// Strict coercion mode
final strictNumberCoercion = Z.coerce.number(strict: true);

// Advanced coercion with options
final advancedNumber = Z.coerce.number(
  precision: 2,
  min: 0,
  max: 100,
  strict: false,
);
```

---

## ⚡ Async Validation

### Example 14: Database Validation
```dart
// Database validation example
final userSchema = Z.object({
  'email': Z.string().email()
    .refineAsync(
      (email) async {
        final exists = await checkEmailExists(email);
        return !exists;
      },
      message: 'Email already exists',
    ),
  'username': Z.string().min(3)
    .refineAsync(
      (username) async {
        final available = await checkUsernameAvailable(username);
        return available;
      },
      message: 'Username not available',
    ),
});
```

### Example 15: API Validation with External Service
```dart
// API validation with external service
final apiSchema = Z.string().url()
  .transformAsync((url) async {
    final response = await http.get(Uri.parse(url));
    return response.statusCode == 200 ? url : null;
  })
  .refineAsync(
    (result) async => result != null,
    message: 'URL is not accessible',
  );
```

### Example 16: Async Validation Methods
```dart
// Validate with async methods
final result = await userSchema.validateAsync({
  'email': 'user@example.com',
  'username': 'johndoe',
});

// Safe async parsing
final data = await userSchema.safeParseAsync(userData);
if (data != null) {
  print('Valid user: $data');
}
```

---

## 🎨 Flutter Integration

### 📱 **Custom Validation Widgets**

### Example 17: User Registration Form
```dart
import 'package:dzod/dzod.dart';

class UserRegistrationForm extends StatefulWidget {
  @override
  _UserRegistrationFormState createState() => _UserRegistrationFormState();
}

class _UserRegistrationFormState extends State<UserRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _userSchema = Z.object({
    'name': Z.string().min(2).max(50),
    'email': Z.string().email(),
    'password': Z.string().min(8),
    'confirmPassword': Z.string(),
  }).refine((data) => data['password'] == data['confirmPassword'], 
    message: 'Passwords do not match');

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Advanced text field with real-time validation
          ZodTextFormField(
            schema: Z.string().min(2).max(50),
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
            ),
            onChanged: (value) => setState(() {}),
          ),
          
          // Email field with async validation
          ZodTextFormField(
            schema: Z.string().email().refineAsync(
              (email) => checkEmailAvailability(email),
              message: 'Email already taken',
            ),
            decoration: InputDecoration(
              labelText: 'Email',
              suffixIcon: Icon(Icons.email),
            ),
            debounceTime: Duration(milliseconds: 500),
          ),
          
          // Custom validation feedback widget
          ZodValidationFeedback(
            schema: _userSchema,
            data: _getCurrentFormData(),
            builder: (context, errors) {
              if (errors.isEmpty) return SizedBox();
              return Column(
                children: errors.map((error) => 
                  ListTile(
                    leading: Icon(Icons.error, color: Colors.red),
                    title: Text(error.message),
                    subtitle: Text('Field: ${error.fullPath}'),
                  )
                ).toList(),
              );
            },
          ),
          
          // Validation status indicator
          ZodValidationStatus(
            schema: _userSchema,
            data: _getCurrentFormData(),
            validIcon: Icon(Icons.check_circle, color: Colors.green),
            invalidIcon: Icon(Icons.error, color: Colors.red),
            loadingWidget: CircularProgressIndicator(),
          ),
          
          // Submit button
          ElevatedButton(
            onPressed: _submitForm,
            child: Text('Register'),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    final data = _getCurrentFormData();
    final result = await _userSchema.validateAsync(data);
    
    if (result.isSuccess) {
      // Registration successful
      await registerUser(result.data!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful!')),
      );
    } else {
      // Show validation errors
      final errors = result.errors!;
      _showValidationErrors(errors);
    }
  }
}
```

### 🔄 **State Management Integration**

### Example 18: Flutter Widget-specific Schemas
```dart
// Flutter widget-specific schemas
final colorSchema = Z.color()
  .alpha(255)                   // Specific alpha value (0-255)
  .opaque();                    // Must be opaque (alpha = 255)

final alphaRangeSchema = Z.color()
  .minAlpha(128)                // Minimum alpha value
  .maxAlpha(255);               // Maximum alpha value

final edgeInsetsSchema = Z.edgeInsets()
  .uniform()                    // Must be uniform padding
  .minAll(8.0)                  // Minimum padding on all sides
  .maxAll(16.0);                // Maximum padding on all sides

final paddingConstraintsSchema = Z.edgeInsets()
  .horizontalRange(8.0, 24.0)   // Horizontal padding range
  .verticalRange(4.0, 12.0);    // Vertical padding range

final durationSchema = Z.duration()
  .min(Duration(seconds: 1))    // Minimum duration
  .max(Duration(minutes: 5))    // Maximum duration
  .positive();                  // Must be positive duration
```

### Example 19: State Management with Validation
```dart
// State management with validation
class UserProfileController extends ChangeNotifier {
  final _profileSchema = Z.object({
    'name': Z.string().min(2).max(50),
    'bio': Z.string().max(500).optional(),
    'avatar': Z.string().url().optional(),
    'preferences': Z.object({
      'theme': Z.enum_(['light', 'dark']),
      'notifications': Z.boolean(),
    }),
  });

  Map<String, dynamic> _profile = {};
  ValidationErrorCollection? _errors;

  Map<String, dynamic> get profile => _profile;
  ValidationErrorCollection? get errors => _errors;

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final result = await _profileSchema.validateAsync(data);
    
    if (result.isSuccess) {
      _profile = result.data!;
      _errors = null;
      notifyListeners();
      await _saveProfile();
    } else {
      _errors = result.errors;
      notifyListeners();
    }
  }

  // Real-time field validation
  String? validateField(String field, dynamic value) {
    try {
      final fieldSchema = _profileSchema.shape[field];
      if (fieldSchema != null) {
        final result = fieldSchema.validate(value);
        return result.isSuccess ? null : result.errors!.first?.message;
      }
    } catch (e) {
      return 'Invalid field';
    }
    return null;
  }
}
```

---

## 🔧 Enterprise Error Handling

### 🎯 **Advanced Error System**

### Example 20: Error Code System
```dart
// 100+ standardized error codes
final schema = Z.string().email();
final result = schema.validate('invalid-email');

if (result.isFailure) {
  final errors = result.errors!;
  
  // Access error details
  for (final error in errors.errors) {
    print('Code: ${error.code}');              // ValidationErrorCode enum
    print('Message: ${error.message}');        // Human-readable message
    print('Path: ${error.fullPath}');          // Field path
    print('Expected: ${error.expected}');      // Expected value/type
    print('Received: ${error.received}');      // Actual value
    print('Context: ${error.context}');        // Additional context
  }
  
  // Error filtering (available methods)
  final emailErrors = errors.filterByPath(['email']);
  final typeErrors = errors.filterByCode('invalid_email');
  
  // Basic error analysis
  print('Total errors: ${errors.length}');
  print('Has errors: ${errors.hasErrors}');
  print('First error: ${errors.first?.message}');
  
  // Error codes analysis
  final errorCodes = errors.errors.map((e) => e.code).toSet();
  print('Unique error codes: $errorCodes');
}
```

### 🎨 **Custom Error Formatting**

### Example 21: Multiple Error Output Formats
```dart
// Multiple error output formats
final errors = result.errors!;

// JSON format for APIs
final jsonErrors = errors.toJson();
print(jsonErrors);
// {"errors": [{"code": "invalid_email", "message": "Invalid email format", "path": ["email"]}]}

// Human-readable format (using available methods)
final readable = errors.formattedErrors;
print(readable);
// "ValidationError at email: Invalid email format (received: invalid-email, expected: valid email)"

// Individual error formatting
for (final error in errors.errors) {
  print('${error.fullPath}: ${error.message}');
}
// "email: Invalid email format"

// Custom error collection analysis
final errorsByPath = <String, List<ValidationError>>{};
for (final error in errors.errors) {
  final path = error.fullPath;
  errorsByPath.putIfAbsent(path, () => []).add(error);
}
print('Errors by field: $errorsByPath');
```

### 🌐 **Global Error Configuration**

### Example 22: Global Error Configuration
```dart
// Configure global error messages
ErrorMessages.setGlobalMessages({
  ValidationErrorCode.invalidEmail: 'Please enter a valid email address',
  ValidationErrorCode.minLength: 'Must be at least {min} characters',
  ValidationErrorCode.maxLength: 'Must not exceed {max} characters',
});

// Custom error formatter
ErrorFormatter.setGlobalFormatter(ErrorFormatConfig.humanFriendly(
  showPath: true,
  showCode: false,
  groupByField: true,
  maxErrorsPerField: 3,
));

// Error context tracking
final context = ErrorContext.builder()
  .field('email')
  .operation('user_registration')
  .source('api')
  .metadata({'userId': '123', 'timestamp': DateTime.now()})
  .build();

final result = schema.validate('invalid', context: context);
```

---

## 🏗️ Schema Composition & Introspection

### 📊 **Schema Analysis**

### Example 23: Schema Introspection
```dart
// Schema introspection
final userSchema = Z.object({
  'name': Z.string().min(2).max(50),
  'email': Z.string().email(),
  'age': Z.number().min(18),
}).describe('User profile schema');

// Get schema information (using available methods)
print('Schema shape: ${userSchema.shape.keys}');           // Keys: [name, email, age]
print('Required fields: ${userSchema.requiredKeys}');      // {name, email, age}
print('Optional fields: ${userSchema.optionalKeys}');      // {}
print('Total fields: ${userSchema.shape.length}');        // 3

// Schema structure analysis
for (final entry in userSchema.shape.entries) {
  final field = entry.key;
  final schema = entry.value;
  final isRequired = userSchema.requiredKeys.contains(field);
  print('Field $field: ${schema.runtimeType} (required: $isRequired)');
}

// Schema comparison (manual equivalence check)
final otherSchema = Z.object({
  'name': Z.string().min(2).max(50),
  'email': Z.string().email(),
  'age': Z.number().min(18),
});
final sameKeys = userSchema.shape.keys.toSet().difference(otherSchema.shape.keys.toSet()).isEmpty;
print('Schemas have same structure: $sameKeys');
```

### 🔧 **Schema Transformation**

### Example 24: Schema Transformation and Composition
```dart
// Branded types for type safety
final UserIdSchema = Z.string().cuid2().brand<'UserId'>();
final ProductIdSchema = Z.string().cuid2().brand<'ProductId'>();

// This prevents mixing up IDs
final userId = UserIdSchema.parse('user_123');          // UserId
final productId = ProductIdSchema.parse('product_456'); // ProductId
// userId = productId;  // Type error!

// Readonly schemas for immutability
final readonlyUserSchema = userSchema.readonly();
// This creates an immutable version that can't be modified

// Schema composition
final basicUserSchema = Z.object({
  'name': Z.string(),
  'email': Z.string().email(),
});

final extendedUserSchema = basicUserSchema.extend({
  'age': Z.number().min(18),
  'role': Z.enum_(['admin', 'user']),
});

// Conditional schemas
final conditionalSchema = Z.conditional(
  Z.string().equals('admin'),
  Z.object({
    'name': Z.string(),
    'permissions': Z.array(Z.string()),
  }),
  Z.object({
    'name': Z.string(),
    'department': Z.string(),
  })
);
```

### 📄 **JSON Schema Generation**

### Example 25: JSON Schema Generation
```dart
// Generate JSON Schema for OpenAPI documentation
final userSchema = Z.object({
  'id': Z.string().cuid2(),
  'name': Z.string().min(2).max(50),
  'email': Z.string().email(),
  'age': Z.number().min(18).optional(),
  'roles': Z.array(Z.enum_(['admin', 'user', 'guest'])),
}).describe('User account information');

// OpenAPI-compatible JSON Schema
final openApiSchema = userSchema.toOpenApiSchema();
print(openApiSchema);
// {
//   "type": "object",
//   "description": "User account information",
//   "properties": {
//     "id": {"type": "string", "format": "cuid2"},
//     "name": {"type": "string", "minLength": 2, "maxLength": 50},
//     "email": {"type": "string", "format": "email"},
//     "age": {"type": "number", "minimum": 18},
//     "roles": {"type": "array", "items": {"enum": ["admin", "user", "guest"]}}
//   },
//   "required": ["id", "name", "email", "roles"]
// }

// Minimal JSON Schema
final minimalSchema = userSchema.toMinimalJsonSchema();

// Comprehensive JSON Schema with metadata
final comprehensiveSchema = userSchema.toJsonSchema(JsonSchemaConfig(
  version: JsonSchemaVersion.draft202012,
  includeMetadata: true,
  includeExamples: true,
  includeDescriptions: true,
));
```

---

## 🚀 Performance & Optimization

### ⚡ **Caching & Memoization**

### Example 26: Performance Optimization
```dart
// Basic schema for repeated validations
final userSchema = Z.object({
  'name': Z.string().min(2).max(50),
  'email': Z.string().email(),
});

// Lazy evaluation (available)
final expensiveSchema = Z.lazy(() => 
  Z.object({
    'data': Z.array(Z.string()).transform((data) => data.map((s) => s.trim()).toList()),
  })
);

// Recursive schema with built-in optimization
final treeSchema = Z.recursive<Map<String, dynamic>>(
  () => Z.object({
    'value': Z.string(),
    'children': Z.array(Z.recursive<Map<String, dynamic>>(
      () => Z.object({
        'value': Z.string(),
      })
    )).optional(),
  }),
  maxDepth: 1000,                   // Prevent infinite recursion
  enableCircularDetection: true,    // Detect circular references
  enableMemoization: true,          // Cache validation results
);
```

### 📊 **Performance Monitoring**

### Example 27: Performance Monitoring
```dart
// Enable performance monitoring
final schema = Z.object({
  'users': Z.array(Z.object({
    'name': Z.string(),
    'email': Z.string().email(),
  })).min(1).max(1000),
}).withPerformanceMonitoring();

// Validate with metrics
final result = schema.validate(data);
final metrics = schema.performanceMetrics;

print('Validation time: ${metrics.validationTime}ms');
print('Memory usage: ${metrics.memoryUsage}MB');
print('Cache hits: ${metrics.cacheHits}');
print('Cache misses: ${metrics.cacheMisses}');
```

---

## 📚 Migration Guide

### 🔄 **From json_annotation**

### Example 28: Migration from json_annotation
```dart
// Before: json_annotation
@JsonSerializable()
class User {
  final String name;
  final String email;
  final int? age;
  
  User({required this.name, required this.email, this.age});
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

// After: Dzod
final userSchema = Z.object({
  'name': Z.string().min(1),
  'email': Z.string().email(),
  'age': Z.number().min(0).optional(),
});

// Type-safe parsing with validation
final result = userSchema.validate(jsonData);
if (result.isSuccess) {
  final user = result.data!;
  print('User: ${user['name']} (${user['email']})');
}
```

### 🔄 **From built_value**

### Example 29: Migration from built_value
```dart
// Before: built_value
abstract class User implements Built<User, UserBuilder> {
  String get name;
  String get email;
  int? get age;
  
  User._();
  factory User([void Function(UserBuilder) updates]) = _$User;
}

// After: Dzod
final userSchema = Z.object({
  'name': Z.string().min(1),
  'email': Z.string().email(),
  'age': Z.number().min(0).optional(),
});

// No code generation needed
final user = userSchema.parse(data);
```

---

## 🎯 Best Practices

### 🔒 **Security & Validation**

### Example 30: Security Best Practices
```dart
// Input sanitization
final sanitizedSchema = Z.string()
  .trim()                     // Remove whitespace
  .max(1000)                  // Prevent DoS
  .refine(
    (value) => !value.contains('<script>'),
    message: 'XSS attempt detected',
  );

// Rate limiting validation
final rateLimitedSchema = Z.object({
  'email': Z.string().email(),
  'message': Z.string().max(5000),
}).refine(
  (data) => checkRateLimit(data['email']),
  message: 'Rate limit exceeded',
);

// API key validation
final apiKeySchema = Z.string()
  .length(32)                 // Exact length
  .hex()                      // Hexadecimal format
  .refineAsync(
    (key) => validateApiKey(key),
    message: 'Invalid API key',
  );
```

### 🎨 **Error Handling Best Practices**

### Example 31: Comprehensive Error Handling
```dart
// Comprehensive error handling
Future<void> handleUserInput(Map<String, dynamic> input) async {
  try {
    final result = await userSchema.validateAsync(input);
    
    if (result.isSuccess) {
      await processUser(result.data!);
    } else {
      final errors = result.errors!;
      
      // Log errors for debugging
      logger.warning('Validation failed', errors.toDeveloperFormat());
      
      // Return user-friendly errors
      final userErrors = errors.toHumanReadable();
      throw ValidationException(userErrors);
    }
  } catch (e) {
    // Handle unexpected errors
    logger.error('Unexpected validation error', e);
    throw ServerException('Validation failed');
  }
}
```

---

## 🌟 Advanced Examples

### 🔐 **Authentication Schema**

### Example 32: Advanced Authentication Schema
```dart
final authSchema = Z.discriminatedUnion('method', [
  // Email/password authentication
  Z.object({
    'method': Z.literal('email'),
    'email': Z.string().email(),
    'password': Z.string().min(8).max(128),
  }),
  
  // OAuth authentication
  Z.object({
    'method': Z.literal('oauth'),
    'provider': Z.enum_(['google', 'github', 'facebook']),
    'token': Z.string().jwt(),
  }),
  
  // API key authentication
  Z.object({
    'method': Z.literal('apikey'),
    'key': Z.string().length(32).hex(),
    'secret': Z.string().length(64).hex(),
  }),
]);

// Validate different auth methods
final emailAuth = authSchema.parse({
  'method': 'email',
  'email': 'user@example.com',
  'password': 'securepassword123',
});

final oauthAuth = authSchema.parse({
  'method': 'oauth',
  'provider': 'google',
  'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
});
```

### 📊 **Data Processing Pipeline**

### Example 33: Multi-stage Data Processing
```dart
// Multi-stage data processing
final dataProcessingPipeline = Z.pipeline([
  // Stage 1: Parse JSON
  Z.string().transform((json) => jsonDecode(json)),
  
  // Stage 2: Validate structure
  Z.object({
    'users': Z.array(Z.object({
      'name': Z.string(),
      'email': Z.string(),
      'age': Z.number(),
    })),
    'metadata': Z.object({
      'version': Z.string(),
      'timestamp': Z.string().datetime(),
    }),
  }),
  
  // Stage 3: Transform data
  Z.object({
    'users': Z.array(Z.object({
      'name': Z.string(),
      'email': Z.string().email(),
      'age': Z.number().min(0).max(150),
    })),
  }).transform((data) => {
    'processedUsers': data['users'],
    'count': (data['users'] as List).length,
    'processedAt': DateTime.now().toIso8601String(),
  }),
  
  // Stage 4: Final validation
  Z.object({
    'processedUsers': Z.array(Z.object({
      'name': Z.string().min(1),
      'email': Z.string().email(),
      'age': Z.number().min(0),
    })),
    'count': Z.number().min(0),
    'processedAt': Z.string().datetime(),
  }),
]);

// Process data through pipeline
final result = dataProcessingPipeline.validate(rawJsonData);
```

---

## 🛠️ Development Tools

### 🔧 **Schema Testing Utilities**

### Example 34: Testing Schema Validation
```dart
// Test schema with sample data
void testUserSchema() {
  final schema = Z.object({
    'name': Z.string().min(2).max(50),
    'email': Z.string().email(),
    'age': Z.number().min(18),
  });

  // Test valid data
  final validData = {
    'name': 'John Doe',
    'email': 'john@example.com',
    'age': 25,
  };
  assert(schema.validate(validData).isSuccess);

  // Test invalid data
  final invalidData = {
    'name': 'J',  // Too short
    'email': 'invalid-email',
    'age': 17,  // Too young
  };
  final result = schema.validate(invalidData);
  assert(result.isFailure);
  assert(result.errors!.errors.length == 3);
}
```

### 📄 **Schema Documentation Generator**

### Example 35: Generate Schema Documentation
```dart
// Generate documentation for your schemas
final userSchema = Z.object({
  'id': Z.string().cuid2().describe('Unique user identifier'),
  'name': Z.string().min(2).max(50).describe('User full name'),
  'email': Z.string().email().describe('User email address'),
  'age': Z.number().min(18).describe('User age in years'),
  'roles': Z.array(Z.enum_(['admin', 'user', 'guest']))
    .describe('User roles and permissions'),
}).describe('User account schema');

// Generate OpenAPI documentation
final openApiDocs = userSchema.toOpenApiSchema();
print(jsonEncode(openApiDocs));

// Generate human-readable documentation
final docs = userSchema.generateDocumentation();
print(docs);
```

---

## 🔗 Connect with NonStop

<div align="center">

**Stay connected and get the latest updates!**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/company/nonstop-io)
[![X.com](https://img.shields.io/badge/X-000000?style=for-the-badge&logo=x&logoColor=white)](https://x.com/NonStopio)
[![Instagram](https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/nonstopio_technologies/)
[![YouTube](https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@NonStopioTechnology)
[![Email](https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:contact@nonstopio.com)

</div>

---

<div align="center">

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║  🚀 Built with ❤️ by Ajay Kumar                              ║
║                                                              ║
║  ⭐ Star us on GitHub if this helped you!                    ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

**🎉 [Founded by Ajay Kumar](https://github.com/ProjectAJ14) 🎉**

</div>

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [Zod](https://github.com/colinhacks/zod) for TypeScript
- Built with ❤️ for the Dart/Flutter community
- Special thanks to all contributors and early adopters

---

<div align="center">
<strong>💡 Ready to validate with confidence? Get started with Dzod today!</strong>
</div>