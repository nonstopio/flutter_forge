/// Function type for custom error message generation
///
/// Takes a [ValidationIssue] containing context about the validation failure
/// and returns either a custom error message string or null to use the default message.
///
/// This matches the TypeScript Zod error customization API:
/// ```dart
/// z.string({
///   error: (issue) => issue.input == null
///     ? "Field is required"
///     : "Invalid string: ${issue.input}"
/// });
/// ```
typedef ErrorMessageFunction = String? Function(ValidationIssue issue);

/// Represents a validation error with detailed information
class ValidationError {
  /// The error message
  final String message;

  /// The path to the field that caused the error
  final List<String> path;

  /// The actual value that failed validation
  final dynamic received;

  /// The expected type or constraint
  final String expected;

  /// Additional error code for programmatic handling
  final String? code;

  /// Additional context information
  final Map<String, dynamic>? context;

  const ValidationError({
    required this.message,
    required this.path,
    required this.received,
    required this.expected,
    this.code,
    this.context,
  });

  /// Creates a validation error with a simple message
  factory ValidationError.simple({
    required String message,
    required List<String> path,
    required dynamic received,
    String? code,
  }) {
    return ValidationError(
      message: message,
      path: path,
      received: received,
      expected: 'valid value',
      code: code,
    );
  }

  /// Creates a validation error for type mismatch
  factory ValidationError.typeMismatch({
    required List<String> path,
    required dynamic received,
    required String expected,
    String? code,
    ErrorMessageFunction? customErrorGenerator,
  }) {
    final defaultMessage =
        'Expected $expected, but received ${ValidationError._getTypeName(received)}';
    String message = defaultMessage;

    // Generate custom error message if provided
    if (customErrorGenerator != null) {
      final issue = ValidationIssue.typeMismatch(
        input: received,
        path: path,
        expected: expected,
        customMessage: defaultMessage,
      );
      final customMessage = customErrorGenerator(issue);
      if (customMessage != null) {
        message = customMessage;
      }
    }

    return ValidationError(
      message: message,
      path: path,
      received: received,
      expected: expected,
      code: code ?? 'type_mismatch',
    );
  }

  /// Creates a validation error for constraint violation
  factory ValidationError.constraintViolation({
    required List<String> path,
    required dynamic received,
    required String constraint,
    String? code,
    Map<String, dynamic>? context,
    ErrorMessageFunction? customErrorGenerator,
  }) {
    final defaultMessage = constraint;
    String message = defaultMessage;

    // Generate custom error message if provided
    if (customErrorGenerator != null) {
      final issue = ValidationIssue.constraint(
        input: received,
        path: path,
        code: code ?? 'constraint_violation',
        constraint: constraint,
        additionalContext: context,
        customMessage: defaultMessage,
      );
      final customMessage = customErrorGenerator(issue);
      if (customMessage != null) {
        message = customMessage;
      }
    }

    return ValidationError(
      message: message,
      path: path,
      received: received,
      expected: constraint,
      code: code ?? 'constraint_violation',
      context: context,
    );
  }

  /// Creates a validation error for missing property
  factory ValidationError.missingProperty({
    required String property,
    required List<String> path,
    String? code,
    Map<String, dynamic>? context,
  }) {
    return ValidationError(
      message: 'Missing required property: $property',
      path: path,
      received: null,
      expected: property,
      code: code ?? 'missing_property',
      context: context,
    );
  }

  /// Gets the full path as a string (e.g., "user.address.street")
  String get fullPath => path.join('.');

  /// Creates a copy of this error with additional path segments
  ValidationError withPath(List<String> additionalPath) {
    return ValidationError(
      message: message,
      path: [...path, ...additionalPath],
      received: received,
      expected: expected,
      code: code,
      context: context,
    );
  }

  /// Creates a copy of this error with additional context
  ValidationError withContext(Map<String, dynamic> additionalContext) {
    return ValidationError(
      message: message,
      path: path,
      received: received,
      expected: expected,
      code: code,
      context: {...?context, ...additionalContext},
    );
  }

  @override
  String toString() {
    final pathStr = path.isEmpty ? 'root' : fullPath;
    return 'ValidationError at $pathStr: $message (received: $received, expected: $expected)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidationError &&
        other.message == message &&
        other.path.length == path.length &&
        other.received == received &&
        other.expected == expected &&
        other.code == code;
  }

  @override
  int get hashCode {
    return Object.hash(message, path.length, received, expected, code);
  }

  static String _getTypeName(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return 'string';
    if (value is num) return 'number';
    if (value is bool) return 'boolean';
    if (value is List) return 'array';
    if (value is Map) return 'object';
    return value.runtimeType.toString();
  }
}

/// Collection of validation errors
class ValidationErrorCollection {
  final List<ValidationError> _errors;

  const ValidationErrorCollection(this._errors);

  /// Creates an empty error collection
  factory ValidationErrorCollection.empty() =>
      const ValidationErrorCollection([]);

  /// Creates an error collection with a single error
  factory ValidationErrorCollection.single(ValidationError error) =>
      ValidationErrorCollection([error]);

  /// Gets all errors
  List<ValidationError> get errors => List.unmodifiable(_errors);

  /// Gets the number of errors
  int get length => _errors.length;

  /// Checks if there are any errors
  bool get isEmpty => _errors.isEmpty;

  /// Checks if there are errors
  bool get isNotEmpty => _errors.isNotEmpty;

  /// Gets the first error
  ValidationError? get first => _errors.isNotEmpty ? _errors.first : null;

  /// Gets the last error
  ValidationError? get last => _errors.isNotEmpty ? _errors.last : null;

  /// Adds an error to the collection
  ValidationErrorCollection add(ValidationError error) {
    return ValidationErrorCollection([..._errors, error]);
  }

  /// Adds multiple errors to the collection
  ValidationErrorCollection addAll(List<ValidationError> errors) {
    return ValidationErrorCollection([..._errors, ...errors]);
  }

  /// Merges this collection with another
  ValidationErrorCollection merge(ValidationErrorCollection other) {
    return ValidationErrorCollection([..._errors, ...other._errors]);
  }

  /// Filters errors by path prefix
  ValidationErrorCollection filterByPath(List<String> pathPrefix) {
    return ValidationErrorCollection(
      _errors.where((error) {
        if (error.path.length < pathPrefix.length) return false;
        for (int i = 0; i < pathPrefix.length; i++) {
          if (error.path[i] != pathPrefix[i]) return false;
        }
        return true;
      }).toList(),
    );
  }

  /// Filters errors by error code
  ValidationErrorCollection filterByCode(String code) {
    return ValidationErrorCollection(
      _errors.where((error) => error.code == code).toList(),
    );
  }

  /// Gets a formatted string representation of all errors
  String get formattedErrors {
    if (_errors.isEmpty) return 'No validation errors';

    return _errors.map((error) => error.toString()).join('\n');
  }

  /// Converts errors to a JSON-serializable format
  List<Map<String, dynamic>> toJson() {
    return _errors
        .map((error) => {
              'message': error.message,
              'path': error.path,
              'received': error.received,
              'expected': error.expected,
              'code': error.code,
              'context': error.context,
            })
        .toList();
  }

  @override
  String toString() {
    return 'ValidationErrorCollection(${_errors.length} errors)';
  }
}

/// Represents an issue context for custom error message generation
/// This is used to provide detailed context to custom error message functions,
/// similar to TypeScript Zod's issue object.
class ValidationIssue {
  /// The specific error code (e.g., "invalid_type", "too_small", "too_big")
  final String code;

  /// The input value that failed validation
  final dynamic input;

  /// The path to the field that caused the error
  final List<String> path;

  /// The default error message that would be used
  final String message;

  /// Additional context information specific to the validation type
  final Map<String, dynamic> context;

  /// The expected type or constraint description
  final String expected;

  /// The received type or value description
  final String received;

  const ValidationIssue({
    required this.code,
    required this.input,
    required this.path,
    required this.message,
    required this.context,
    required this.expected,
    required this.received,
  });

  /// Creates a ValidationIssue from a ValidationError
  factory ValidationIssue.fromError(ValidationError error) {
    return ValidationIssue(
      code: error.code ?? 'validation_error',
      input: error.received,
      path: error.path,
      message: error.message,
      context: error.context ?? {},
      expected: error.expected,
      received: ValidationError._getTypeName(error.received),
    );
  }

  /// Creates a ValidationIssue for type mismatch errors
  factory ValidationIssue.typeMismatch({
    required dynamic input,
    required List<String> path,
    required String expected,
    String? customMessage,
  }) {
    final defaultMessage =
        'Expected $expected, but received ${ValidationError._getTypeName(input)}';
    return ValidationIssue(
      code: 'invalid_type',
      input: input,
      path: path,
      message: customMessage ?? defaultMessage,
      context: {
        'expected': expected,
        'received': ValidationError._getTypeName(input)
      },
      expected: expected,
      received: ValidationError._getTypeName(input),
    );
  }

  /// Creates a ValidationIssue for constraint violations
  factory ValidationIssue.constraint({
    required dynamic input,
    required List<String> path,
    required String code,
    required String constraint,
    Map<String, dynamic>? additionalContext,
    String? customMessage,
  }) {
    return ValidationIssue(
      code: code,
      input: input,
      path: path,
      message: customMessage ?? constraint,
      context: additionalContext ?? {},
      expected: constraint,
      received: input?.toString() ?? 'null',
    );
  }

  /// Gets the full path as a string (e.g., "user.address.street")
  String get fullPath => path.join('.');

  /// Creates a copy with modified properties
  ValidationIssue copyWith({
    String? code,
    dynamic input,
    List<String>? path,
    String? message,
    Map<String, dynamic>? context,
    String? expected,
    String? received,
  }) {
    return ValidationIssue(
      code: code ?? this.code,
      input: input ?? this.input,
      path: path ?? this.path,
      message: message ?? this.message,
      context: context ?? this.context,
      expected: expected ?? this.expected,
      received: received ?? this.received,
    );
  }

  @override
  String toString() {
    return 'ValidationIssue(code: $code, path: ${fullPath.isEmpty ? 'root' : fullPath}, message: $message)';
  }
}
