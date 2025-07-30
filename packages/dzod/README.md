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
  <strong>⚡ Enterprise-grade Dart schema validation library</strong>
</p>

<p align="center">
  <a href="https://pub.dev/packages/dzod"><img src="https://img.shields.io/pub/v/dzod.svg?label=dzod&logo=dart&color=blue&style=for-the-badge" alt="pub package"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-purple.svg?style=for-the-badge" alt="License"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-Ready-02569B.svg?style=for-the-badge&logo=flutter" alt="Flutter"></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Test_Coverage-99.3%25-darkgreen.svg?style=for-the-badge" alt="Test Coverage">
  <img src="https://img.shields.io/badge/Tests-1588+-blue.svg?style=for-the-badge" alt="Tests">
</p>

---

## 🎯 What is Dzod?

Dzod is an **enterprise-grade** Dart schema validation library heavily inspired by [Zod](https://zod.dev/) with advanced enterprise features. Built for production applications requiring robust data validation, type safety, and exceptional developer experience.

### 🏆 **Key Achievements**

- **🚀 Enterprise Features**: Advanced error handling, async validation, schema composition, and JSON Schema generation
- **⚡  1588+ Comprehensive Tests**: 99.3% test coverage with enterprise-grade quality assurance
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
final userSchema = z.object({
  'id': z.string().cuid2(), // CUID2 validation
  'name': z.string().min(2).max(50),
  'email': z.string().email(),
  'age': z.number().min(18).max(120),
  'role': z.enum_(['admin', 'user', 'guest']),
  'preferences': z.object({
    'theme': z.enum_(['light', 'dark']).defaultTo('light'),
    'notifications': z.boolean().defaultTo(true),
  }).partial(),
  'createdAt': z.string().datetime(),
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

| Feature                    | Description                                           | Status     |
|----------------------------|-------------------------------------------------------|------------|
| **🔥 Schema Types**        | 19+ schema types with advanced validation             | ✅ Complete |
| **⚡ Async Validation**     | Full async/await support with database checks         | ✅ Complete |
| **🔧 Advanced Features**   | Pipelines, discriminated unions, coercion             | ✅ Complete |
| **📊 Error System**        | 100+ error codes, custom formatting, context tracking | ✅ Complete |
| **🏗️ Schema Composition** | Introspection, JSON Schema generation, metadata       | ✅ Complete |
| **🚀 Performance**         | Lazy evaluation, caching, memory optimization         | ✅ Complete |

</div>

---

## 🔧 Schema Types

### 🎯 **Basic Types**

### Example 2: String Validations

```dart
// String validations (separate examples)
final emailSchema = z.string().min(2).max(50).email();
final urlSchema = z.string().url();
final uuidSchema = z.string().uuid();
final cuidSchema = z.string().cuid();
final cuid2Schema = z.string().cuid2();
final ulidSchema = z.string().ulid();
final jwtSchema = z.string().jwt();
final base64Schema = z.string().base64();
final hexSchema = z.string().hex();
final hexColorSchema = z.string().hexColor();
final emojiSchema = z.string().emoji();
final jsonSchema = z.string().json();
final nanoidSchema = z.string().nanoid();
```

### Example 3: Number Validations

```dart
// Number validations (separate examples)
final basicNumberSchema = z.number().min(0).max(100).integer().positive();
final stepSchema = z.number().step(0.1);
final precisionSchema = z.number().precision(2);
final safeIntSchema = z.number().safeInt();
final percentageSchema = z.number().percentage();
final probabilitySchema = z.number().probability();
final latitudeSchema = z.number().latitude();
final longitudeSchema = z.number().longitude();
final powerOfTwoSchema = z.number().powerOfTwo();
final primeSchema = z.number().prime();
final perfectSquareSchema = z.number().perfectSquare();
```

### Example 4: Boolean and Null Types

```dart
// Boolean and null types
final boolSchema = z.boolean();
final nullSchema = z.null_();
```

### 🏗️ **Complex Types**

### Example 5: Advanced Object Manipulation

```dart
// Advanced object manipulation (separate examples)
final baseUserSchema = z.object({
  'name': z.string(),
  'email': z.string().email(),
  'age': z.number().min(18),
  'address': z.object({
    'street': z.string(),
    'city': z.string(),
    'country': z.string(),
  }),
});

// Field selection and manipulation
final pickedSchema = baseUserSchema.pick(['name', 'email']);
final omittedSchema = baseUserSchema.omit(['age']);
final extendedSchema = baseUserSchema.extend({'phone': z.string()});

// Optional/required variations
final partialSchema = baseUserSchema.partial();
final deepPartialSchema = baseUserSchema.deepPartial();
final requiredSchema = partialSchema.required(['name', 'email']);

// Different handling modes for unknown properties
final strictSchema = baseUserSchema.strict();
final passthroughSchema = baseUserSchema.passthrough();
final stripSchema = baseUserSchema.strip();
final catchallSchema = baseUserSchema.catchall(z.string());
```

### Example 6: Advanced Arrays

```dart
// Advanced arrays (separate examples)
final baseArraySchema = z.array(z.string());

// Length constraints
final rangeArraySchema = baseArraySchema.min(1).max(10);
final exactLengthSchema = baseArraySchema.length(5);
final nonemptySchema = baseArraySchema.nonempty();

// Element validation
final uniqueSchema = baseArraySchema.unique();
final includesSchema = baseArraySchema.includes('required');
final excludesSchema = baseArraySchema.excludes('forbidden');

// Conditional validation
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
final tupleSchema = z.tuple([
  z.string(),
  z.number(),
  z.boolean(),
]);

// Rest elements for additional values
final tupleWithRest = tupleSchema.rest(z.string());

// Length constraints
final exactLengthTuple = tupleSchema.exactLength(3);
final minLengthTuple = tupleSchema.minLength(2);
final maxLengthTuple = tupleSchema.maxLength(5);
```

### Example 8: Flexible Enums

```dart
// Flexible enums
final roleSchema = z.enum_(['admin', 'user', 'guest']);

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
final recordSchema = z.record(z.number());

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
final messageSchema = z.discriminatedUnion('type', [
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

// Add new variants
final extendedMessages = messageSchema.extend([
  z.object({
    'type': z.literal('audio'),
    'url': z.string().url(),
    'duration': z.number(),
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

// Insert stage at specific index
final modifiedPipeline = userPipeline.insertAt(1, [z.string().min(1)]);

// Replace stage at specific index
final replacedPipeline = userPipeline.replaceStageAt(0,
    z.string().transform((s) => s.trim().toLowerCase()));
```

### Example 12: Enhanced Recursive Schemas

```dart
// Enhanced recursive schemas with circular detection
final categorySchema = z.recursive<Map<String, dynamic>>(
      () =>
      z.object({
        'name': z.string(),
        'children': z.array(z.recursive<Map<String, dynamic>>(
                () =>
                z.object({
                  'name': z.string(),
                })
        )).optional(),
      }),
  maxDepth: 100, // Prevent infinite recursion
  enableCircularDetection: true, // Detect circular references
  enableMemoization: true, // Cache validation results
);

// Modify settings with fluent API
final modifiedSchema = categorySchema
    .withMaxDepth(50) // Change max depth
    .withCircularDetection(false) // Disable circular detection
    .withMemoization(false); // Disable memoization
```

### Example 13: Automatic Type Coercion

```dart
// Automatic type coercion
final numberCoercion = z.coerce.number(); // String -> Number
final booleanCoercion = z.coerce.boolean(); // String -> Boolean
final dateCoercion = z.coerce.date(); // String -> DateTime
final listCoercion = z.coerce.list(); // String -> List

// Strict coercion mode
final strictNumberCoercion = z.coerce.number(strict: true);

// Advanced number coercion with additional validation
final advancedNumber = z.coerce.number(strict: false)
    .transform((num) => double.parse(num.toStringAsFixed(2)))
    .refine((num) => num >= 0 && num <= 100, 
        message: 'Must be between 0 and 100');
```

---

## ⚡ Async Validation

### Example 14: Database Validation

```dart
// Database validation example
final userSchema = z.object({
  'email': z.string().email().refineAsync(
    (email) async {
      final exists = await checkEmailExists(email);
      return !exists;
    },
    message: 'Email already exists',
  ),
  'username': z.string().min(3).refineAsync(
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
final apiSchema = z.string().url()
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

## 🔧 Enterprise Error Handling

### 🎯 **Advanced Error System**

### Example 20: Error Code System

```dart
// 100+ standardized error codes
final schema = z.string().email();
final result = schema.validate('invalid-email');

if (result.isFailure) {
  final errors = result.errors!;

  // Access error details
  for (final error in errors.errors) {
    print('Code: ${error.code}'); // ValidationErrorCode enum
    print('Message: ${error.message}'); // Human-readable message
    print('Path: ${error.fullPath}'); // Field path
    print('Expected: ${error.expected}'); // Expected value/type
    print('Received: ${error.received}'); // Actual value
    print('Context: ${error.context}'); // Additional context
  }

  // Error filtering (available methods)
  final emailErrors = errors.filterByPath(['email']);
  final typeErrors = errors.filterByCode(ValidationErrorCode.invalidEmail);

  // Basic error analysis
  print('Total errors: ${errors.errors.length}');
  print('Has errors: ${errors.hasErrors}');
  print('First error: ${errors.errors.first.message}');

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
// Output: "email: Invalid email format"

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
ErrorMessages.setMessages({
  'invalid_email': 'Please enter a valid email address',
  'min_length': 'Must be at least {min} characters',
  'max_length': 'Must not exceed {max} characters',
});

// Custom error formatter
// Note: ErrorFormatter.setGlobalFormatter is not directly available in the current API
// Instead, use the error formatting methods on ValidationErrorCollection:
// errors.formattedErrors - for human-readable format
// errors.toJson() - for JSON format

// Error context tracking
final context = ErrorContext.builder()
    .operation('user_registration')
    .source('api')
    .metadata({'userId': '123', 'timestamp': DateTime.now()})
    .build();

// Use the context with ErrorContext.withContext
final result = ErrorContext.withContext(context, () {
  return schema.validate('invalid');
});
```

---

## 🏗️ Schema Composition & Introspection

### 📊 **Schema Analysis**

### Example 23: Schema Introspection

```dart
// Schema introspection
final userSchema = z.object({
  'name': z.string().min(2).max(50),
  'email': z.string().email(),
  'age': z.number().min(18),
}).describe('User profile schema');

// Get schema information (using available methods)
print('Schema shape: ${userSchema.shape.keys}'); // Keys: [name, email, age]
print('Required fields: ${userSchema.requiredKeys}'); // {name, email, age}
print('Optional fields: ${userSchema.optionalKeys}'); // {}
print('Total fields: ${userSchema.shape.length}'); // 3

// Schema structure analysis
for (final entry in userSchema.shape.entries) {
  final field = entry.key;
  final schema = entry.value;
  final isRequired = userSchema.requiredKeys.contains(field);
  print('Field $field: ${schema.runtimeType} (required: $isRequired)');
}

// Schema comparison (manual equivalence check)
final otherSchema = z.object({
  'name': z.string().min(2).max(50),
  'email': z.string().email(),
  'age': z.number().min(18),
});
final sameKeys = userSchema.shape.keys.toSet()
    .difference(otherSchema.shape.keys.toSet()).isEmpty;
print('Schemas have same structure: $sameKeys');
```

### 🔧 **Schema Transformation**

### Example 24: Schema Transformation and Composition

```dart
// Note: Branded types and readonly schemas are not directly available in the current API
// Instead, use type-safe wrappers or custom validation logic:

// Type-safe ID validation
final userIdSchema = z.string().cuid2().refine(
  (id) => id.startsWith('user_'),
  message: 'User ID must start with "user_"',
);

final productIdSchema = z.string().cuid2().refine(
  (id) => id.startsWith('product_'),
  message: 'Product ID must start with "product_"',
);

// Schema composition
final basicUserSchema = z.object({
  'name': z.string(),
  'email': z.string().email(),
});

final extendedUserSchema = basicUserSchema.extend({
  'age': z.number().min(18),
  'role': z.enum_(['admin', 'user']),
});

// Conditional schemas using discriminated union
final conditionalSchema = z.discriminatedUnion('role', [
  z.object({
    'role': z.literal('admin'),
    'name': z.string(),
    'permissions': z.array(z.string()),
  }),
  z.object({
    'role': z.literal('user'),
    'name': z.string(),
    'department': z.string(),
  }),
]);
```

### 📄 **JSON Schema Generation**

### Example 25: JSON Schema Generation

```dart
// Generate JSON Schema for OpenAPI documentation
final userSchema = z.object({
  'id': z.string().cuid2(),
  'name': z.string().min(2).max(50),
  'email': z.string().email(),
  'age': z.number().min(18).optional(),
  'roles': z.array(z.enum_(['admin', 'user', 'guest'])),
}).describe('User account information');

// JSON Schema generation
final jsonSchema = userSchema.toJsonSchema();

print(jsonEncode(jsonSchema));
// Output:
// {
//   "type": "object",
//   "description": "User account information",
//   "properties": {
//     "id": {"type": "string", "pattern": "[a-z0-9]{25}"},
//     "name": {"type": "string", "minLength": 2, "maxLength": 50},
//     "email": {"type": "string", "format": "email"},
//     "age": {"type": "number", "minimum": 18},
//     "roles": {"type": "array", "items": {"enum": ["admin", "user", "guest"]}}
//   },
//   "required": ["id", "name", "email", "roles"]
// }
```

---

## 🚀 Performance & Optimization

### ⚡ **Caching & Memoization**

### Example 26: Performance Optimization

```dart
// Basic schema for repeated validations
final userSchema = z.object({
  'name': z.string().min(2).max(50),
  'email': z.string().email(),
});

// Lazy evaluation (available)
final expensiveSchema = z.lazy(() =>
    z.object({
      'data': z.array(z.string()).transform((data) => data.map((s) => s.trim()).toList()),
    })
);

// Recursive schema with built-in optimization
final treeSchema = z.recursive<Map<String, dynamic>>(
      () =>
      z.object({
        'value': z.string(),
        'children': z.array(z.recursive<Map<String, dynamic>>(
                () =>
                z.object({
                  'value': z.string(),
                })
        )).optional(),
      }),
  maxDepth: 1000, // Prevent infinite recursion
  enableCircularDetection: true, // Detect circular references
  enableMemoization: true, // Cache validation results
);
```

### 📊 **Performance Monitoring**

### Example 27: Performance Monitoring

```dart
// Performance optimization example
final schema = z.object({
  'users': z.array(z.object({
    'name': z.string(),
    'email': z.string().email(),
  })).min(1).max(1000),
});

// Measure validation performance manually
final stopwatch = Stopwatch()..start();
final result = schema.validate(data);
stopwatch.stop();

print('Validation time: ${stopwatch.elapsedMilliseconds}ms');

// Use recursive schemas with memoization for performance
final optimizedSchema = z.recursive<Map<String, dynamic>>(
  () => z.object({
    'value': z.string(),
    'children': z.array(z.lazy(() => optimizedSchema)).optional(),
  }),
  enableMemoization: true,
);
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
final userSchema = z.object({
  'name': z.string().min(1),
  'email': z.string().email(),
  'age': z.number().min(0).optional(),
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
final userSchema = z.object({
  'name': z.string().min(1),
  'email': z.string().email(),
  'age': z.number().min(0).optional(),
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
final sanitizedSchema = z.string()
    .trim() // Remove whitespace
    .max(1000) // Prevent DoS
    .refine(
      (value) => !value.contains('<script>'),
  message: 'XSS attempt detected',
);

// Rate limiting validation
final rateLimitedSchema = z.object({
  'email': z.string().email(),
  'message': z.string().max(5000),
}).refine(
      (data) => checkRateLimit(data['email'] as String),
  message: 'Rate limit exceeded',
);

// API key validation
final apiKeySchema = z.string()
    .length(32) // Exact length
    .hex() // Hexadecimal format
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
      logger.warning('Validation failed', errors.formattedErrors);

      // Return user-friendly errors
      final userErrors = errors.formattedErrors;
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

final authSchema = z.discriminatedUnion('method', [
  // Email/password authentication
  z.object({
    'method': z.literal('email'),
    'email': z.string().email(),
    'password': z.string().min(8).max(128),
  }),

  // OAuth authentication
  z.object({
    'method': z.literal('oauth'),
    'provider': z.enum_(['google', 'github', 'facebook']),
    'token': z.string().jwt(),
  }),

  // API key authentication
  z.object({
    'method': z.literal('apikey'),
    'key': z.string().length(32).hex(),
    'secret': z.string().length(64).hex(),
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
final dataProcessingPipeline = z.pipeline([
  // Stage 1: Parse JSON
  z.string().transform((json) => jsonDecode(json)),

  // Stage 2: Validate structure
  z.object({
    'users': z.array(z.object({
      'name': z.string(),
      'email': z.string(),
      'age': z.number(),
    })),
    'metadata': z.object({
      'version': z.string(),
      'timestamp': z.string().datetime(),
    }),
  }),

  // Stage 3: Transform data
  z.object({
    'users': z.array(z.object({
      'name': z.string(),
      'email': z.string().email(),
      'age': z.number().min(0).max(150),
    })),
  }).transform((data) =>
  {
    'processedUsers': data['users'],
    'count': (data['users'] as List).length,
    'processedAt': DateTime.now().toIso8601String(),
  }),

  // Stage 4: Final validation
  z.object({
    'processedUsers': z.array(z.object({
      'name': z.string().min(1),
      'email': z.string().email(),
      'age': z.number().min(0),
    })),
    'count': z.number().min(0),
    'processedAt': z.string().datetime(),
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
  final schema = z.object({
    'name': z.string().min(2).max(50),
    'email': z.string().email(),
    'age': z.number().min(18),
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
    'name': 'J', // Too short
    'email': 'invalid-email',
    'age': 17, // Too young
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
final userSchema = z.object({
  'id': z.string().cuid2().describe('Unique user identifier'),
  'name': z.string().min(2).max(50).describe('User full name'),
  'email': z.string().email().describe('User email address'),
  'age': z.number().min(18).describe('User age in years'),
  'roles': z.array(z.enum_(['admin', 'user', 'guest']))
      .describe('User roles and permissions'),
}).describe('User account schema');

// Generate JSON Schema documentation
final jsonSchema = userSchema.toJsonSchema();

print(jsonEncode(jsonSchema));

// Generate human-readable documentation by introspecting the schema
print('User Schema Documentation:');
print('Description: ${userSchema.description}');
print('Required fields: ${userSchema.requiredKeys}');
print('Optional fields: ${userSchema.optionalKeys}');
for (final entry in userSchema.shape.entries) {
  print('  - ${entry.key}: ${entry.value.runtimeType}');
}
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

>  ⭐ Star us on [GitHub](https://github.com/nonstopio/flutter_forge) if this helped you!

</div>

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Heavily inspired by [Zod](https://zod.dev/) - TypeScript-first schema validation with static type inference
- Built with ❤️ for the Dart/Flutter community
- Special thanks to all contributors and early adopters

---

<div align="center">
<strong>💡 Ready to validate with confidence? Get started with Dzod today!</strong>
</div>

<div align="center">

> 🎉 [Founded by Ajay Kumar](https://github.com/ProjectAJ14) 🎉**

</div>
