# CLAUDE.md - Dzod Package

This file provides guidance to Claude Code when working with the Dzod schema validation library.

## Overview

Dzod is an enterprise-grade Dart schema validation library that provides type-safe validation, parsing, and inference with excellent developer experience for Flutter and Dart applications.

## Package Structure

```
lib/
├── dzod.dart                     # Main library export
├── src/
│   ├── convenience_schemas.dart  # z.* factory methods
│   ├── core/                    # Core validation system
│   │   ├── error.dart           # Error handling classes
│   │   ├── error_codes.dart     # ValidationErrorCode enum
│   │   ├── error_context.dart   # Error context tracking
│   │   ├── error_formatter.dart # Error formatting utilities
│   │   ├── error_utils.dart     # Error utility functions
│   │   ├── json_schema.dart     # JSON Schema generation
│   │   ├── parser.dart          # Parsing utilities
│   │   ├── schema.dart          # Base Schema<T> class
│   │   ├── schema_composition.dart # Schema composition helpers
│   │   └── validation_result.dart  # ValidationResult<T> class
│   ├── flutter/                 # Flutter-specific integrations
│   │   ├── form_integration.dart    # Form validation helpers
│   │   ├── state_management.dart   # State management integration
│   │   ├── validation_widgets.dart # Validation UI widgets
│   │   ├── widget_schemas.dart     # Flutter widget schemas
│   │   └── z_flutter_extensions.dart # Flutter extensions
│   └── schemas/                 # Schema implementations
│       ├── advanced/           # Advanced schema types
│       │   ├── coercion_schema.dart
│       │   ├── discriminated_union_schema.dart
│       │   ├── pipeline_schema.dart
│       │   └── recursive_schema.dart
│       ├── collections/        # Collection schema types
│       │   ├── array_schema.dart
│       │   ├── record_schema.dart
│       │   └── tuple_schema.dart
│       ├── object/             # Object schema implementation
│       │   └── object_schema.dart
│       ├── primitive/          # Primitive schema types
│       │   ├── boolean_schema.dart
│       │   ├── null_schema.dart
│       │   ├── number_schema.dart
│       │   └── string_schema.dart
│       └── specialized/        # Specialized schema types
│           └── enum_schema.dart
```

## Development Commands

### Testing
```bash
# Run all tests
dart test

# Run tests with coverage
dart test --coverage=coverage

# Run specific test file
dart test test/schemas/primitive/string_schema_test.dart

# Run tests for specific category
dart test test/schemas/collections/
```

### Code Quality
```bash
# Run linting
dart analyze

# Format code
dart format .

# Check for dependencies
dart pub deps
```

### Examples
```bash
# Run example app
cd example && flutter run

# Run example tests
cd example && flutter test
```

## Key Classes and APIs

### Core Classes
- `Schema<T>` - Base class for all schema types
- `ValidationResult<T>` - Result wrapper with success/failure states
- `ValidationError` - Individual validation error
- `ValidationErrorCollection` - Collection of validation errors
- `ValidationException` - Exception thrown during validation

### Factory Methods (z.*)
All schema creation uses the `Z` class factory methods:
- `z.string()` - String schema
- `z.number()` - Number schema  
- `z.boolean()` - Boolean schema
- `z.object({})` - Object schema
- `z.array()` - Array schema
- `z.enum_()` - Enum schema
- `z.union()` - Union schema
- `z.discriminatedUnion()` - Discriminated union schema
- `z.pipeline()` - Pipeline schema
- `z.recursive()` - Recursive schema
- `z.coerce.*` - Coercion schemas

### Validation Methods
- `validate(data)` - Synchronous validation
- `validateAsync(data)` - Asynchronous validation
- `parse(data)` - Parse and return data or throw exception
- `safeParse(data)` - Safe parsing that returns null on failure
- `parseAsync(data)` - Async parse with exception on failure
- `safeParseAsync(data)` - Async safe parse returning null on failure

### Error Handling
- `ValidationResult.isSuccess` - Check if validation succeeded
- `ValidationResult.isFailure` - Check if validation failed
- `ValidationResult.data` - Get validated data (if successful)
- `ValidationResult.errors` - Get validation errors (if failed)
- `ValidationErrorCollection.errors` - List of individual errors
- `ValidationError.message` - Human-readable error message
- `ValidationError.code` - Error code enum
- `ValidationError.fullPath` - Full path to error field

## Common Patterns

### Basic Validation
```dart
final schema = z.string().min(2).max(50);
final result = schema.validate('hello');
if (result.isSuccess) {
  print('Valid: ${result.data}');
} else {
  print('Errors: ${result.errors}');
}
```

### Complex Object Validation
```dart
final userSchema = z.object({
  'name': z.string().min(2).max(50),
  'email': z.string().email(),
  'age': z.number().min(18).max(120),
  'role': z.enum_(['admin', 'user', 'guest']),
});
```

### Async Validation
```dart
final schema = z.string().email().refineAsync(
  (email) => checkEmailExists(email),
  message: 'Email already exists',
);
final result = await schema.validateAsync('user@example.com');
```

### Flutter Integration
```dart
ZodTextFormField(
  schema: z.string().min(2).max(50),
  decoration: InputDecoration(labelText: 'Name'),
  onChanged: (value) => setState(() {}),
)
```

## Testing Guidelines

### Test Structure
- Tests are organized by schema type in `test/schemas/`
- Core functionality tests in `test/core/`
- Each schema type has comprehensive test coverage
- Tests cover both success and failure scenarios

### Common Test Patterns
```dart
group('StringSchema', () {
  test('should validate valid string', () {
    final schema = z.string();
    final result = schema.validate('hello');
    expect(result.isSuccess, true);
    expect(result.data, 'hello');
  });

  test('should fail on invalid type', () {
    final schema = z.string();
    final result = schema.validate(123);
    expect(result.isFailure, true);
    expect(result.errors?.first.code, ValidationErrorCode.invalidType);
  });
});
```

## Performance Considerations

### Optimization Features
- Lazy evaluation for complex schemas
- Memoization for recursive schemas
- Circular reference detection
- Performance monitoring capabilities

### Best Practices
- Reuse schema instances instead of creating new ones
- Use `lazy()` for expensive validations
- Enable memoization for recursive schemas
- Consider using `pipeline()` for multi-stage validation

## Flutter-Specific Features

### Widgets
- `ZodTextFormField` - Text input with validation
- `ZodValidationFeedback` - Display validation errors
- `ZodValidationStatus` - Show validation status

### Widget Schemas
- `z.color()` - Flutter Color validation
- `z.edgeInsets()` - EdgeInsets validation
- `z.duration()` - Duration validation

### Form Integration
- Real-time validation
- Debounced async validation
- State management integration
- Custom error display

## Error Handling Best Practices

### Error Codes
Use the `ValidationErrorCode` enum for consistent error handling:
- `ValidationErrorCode.invalidType`
- `ValidationErrorCode.invalidEmail`
- `ValidationErrorCode.minLength`
- `ValidationErrorCode.maxLength`
- And 100+ more standardized codes

### Error Formatting
```dart
// Get human-readable errors
final errors = result.errors!;
final humanReadable = errors.formattedErrors;

// Get JSON format for APIs
final jsonErrors = errors.toJson();

// Filter errors by field
final fieldErrors = errors.filterByPath(['email']);
```

### Global Error Configuration
```dart
ErrorMessages.setGlobalMessages({
  ValidationErrorCode.invalidEmail: 'Please enter a valid email',
  ValidationErrorCode.minLength: 'Must be at least {min} characters',
});
```

## Important Notes

### Schema Creation
- Always use `z.*` factory methods for schema creation
- Schemas are immutable - methods return new schema instances
- Chain validation methods for complex requirements

### Type Safety
- All schemas are generically typed `Schema<T>`
- ValidationResult provides type-safe access to validated data
- Use branded types for additional type safety

### Async Operations
- Use `*Async` methods for async validation
- Async validation supports database checks, API calls, etc.
- Always handle async validation errors appropriately

### JSON Schema Generation
- Use `toOpenApiSchema()` for OpenAPI documentation
- Use `toJsonSchema()` for general JSON Schema needs
- Supports comprehensive schema metadata

## Contributing Guidelines

### Code Style
- Follow standard Dart formatting (`dart format`)
- Use meaningful variable and method names
- Add comprehensive documentation for public APIs
- Include examples in documentation

### Testing Requirements
- All new features must have tests
- Maintain >95% test coverage
- Include both positive and negative test cases
- Test async functionality thoroughly

### Documentation
- Update README.md for new features
- Add examples to the example app
- Document breaking changes
- Update this CLAUDE.md file for structural changes

## Common Issues and Solutions

### Schema Composition
- Use `extend()` to add fields to object schemas
- Use `pick()` and `omit()` for field selection
- Use `partial()` for optional fields
- Use `merge()` for combining schemas

### Performance Issues
- Enable memoization for recursive schemas
- Use `lazy()` for expensive operations
- Consider schema caching for frequently used schemas
- Monitor validation performance in production

### Error Handling
- Always check `isSuccess` before accessing `data`
- Use `safeParse()` for non-throwing validation
- Provide meaningful error messages for custom validation
- Handle async validation errors appropriately

This documentation should help you understand and work effectively with the Dzod schema validation library.
