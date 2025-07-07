import 'error.dart';
import 'validation_result.dart';

/// Base class for all schemas in zod-bhai
///
/// This abstract class provides the foundation for type-safe schema validation,
/// parsing, and transformation. All schema types extend this class.
abstract class Schema<T> {
  /// Optional description for documentation purposes
  final String? description;

  /// Optional metadata for the schema
  final Map<String, dynamic>? metadata;

  const Schema({
    this.description,
    this.metadata,
  });

  /// Gets the type that this schema validates to
  Type get type => T;

  /// Validates the input and returns a ValidationResult
  ///
  /// This is the core validation method that all schemas must implement.
  /// It should perform type checking and any additional validation logic.
  ValidationResult<T> validate(dynamic input, [List<String> path = const []]);

  /// Parses the input, throwing an exception if validation fails
  ///
  /// This is a convenience method that unwraps the validation result.
  /// Use this when you want exceptions for validation failures.
  T parse(dynamic input, [List<String> path = const []]) {
    final result = validate(input, path);
    if (result.isSuccess) {
      return result.data!;
    }
    throw ValidationException(result.errors!.formattedErrors);
  }

  /// Safely parses the input, returning null if validation fails
  ///
  /// This is a convenience method for cases where you want to handle
  /// validation failures gracefully.
  T? safeParse(dynamic input, [List<String> path = const []]) {
    final result = validate(input, path);
    return result.data;
  }

  /// Validates the input and returns true if valid, false otherwise
  ///
  /// This is a convenience method for boolean validation checks.
  bool isValid(dynamic input, [List<String> path = const []]) {
    return validate(input, path).isSuccess;
  }

  /// Creates a new schema that applies a transformation after validation
  ///
  /// The transformation function is only called if validation succeeds.
  Schema<R> transform<R>(R Function(T value) transformer) {
    return TransformSchema<T, R>(this, transformer);
  }

  /// Creates a new schema that applies additional validation
  ///
  /// The refinement function should return true if the value is valid,
  /// false otherwise. You can provide a custom error message.
  Schema<T> refine(
    bool Function(T value) validator, {
    String? message,
    String? code,
  }) {
    return RefineSchema<T>(this, validator, message: message, code: code);
  }

  /// Creates a new schema that applies async validation
  ///
  /// The async refinement function should return true if the value is valid,
  /// false otherwise.
  Schema<T> refineAsync(
    Future<bool> Function(T value) validator, {
    String? message,
    String? code,
  }) {
    return AsyncRefineSchema<T>(this, validator, message: message, code: code);
  }

  /// Creates a new schema that provides a default value
  ///
  /// If validation fails, the default value will be used instead.
  Schema<T> defaultTo(T defaultValue) {
    return DefaultSchema<T>(this, defaultValue);
  }

  /// Creates a new schema that provides a computed default value
  ///
  /// If validation fails, the default function will be called to compute a value.
  Schema<T> defaultToComputed(T Function() defaultValue) {
    return ComputedDefaultSchema<T>(this, defaultValue);
  }

  /// Creates a new schema that is optional (nullable)
  ///
  /// This allows the schema to accept null values.
  Schema<T?> optional() {
    return OptionalSchema<T>(this);
  }

  /// Creates a new schema that is nullable
  ///
  /// This allows the schema to accept null values (alias for optional).
  Schema<T?> nullable() => optional();

  /// Creates a new schema that provides a fallback value
  ///
  /// If validation fails, the fallback value will be used.
  Schema<T> fallback(T fallbackValue) {
    return FallbackSchema<T>(this, fallbackValue);
  }

  /// Creates a new schema that provides a computed fallback value
  ///
  /// If validation fails, the fallback function will be called.
  Schema<T> fallbackComputed(
      T Function(ValidationErrorCollection errors) fallback) {
    return ComputedFallbackSchema<T>(this, fallback);
  }

  /// Creates a new schema that preprocesses the input
  ///
  /// The preprocessor function is called before validation.
  Schema<T> preprocess<R>(R Function(dynamic input) preprocessor) {
    return PreprocessSchema<T, R>(this, preprocessor);
  }

  /// Creates a new schema that postprocesses the output
  ///
  /// The postprocessor function is called after successful validation.
  Schema<T> postprocess(T Function(T value) postprocessor) {
    return PostprocessSchema<T>(this, postprocessor);
  }

  /// Creates a new schema that is lazy (evaluated only when needed)
  ///
  /// This is useful for recursive schemas or schemas that depend on runtime values.
  static Schema<T> lazy<T>(Schema<T> Function() schemaFactory) {
    return LazySchema<T>(schemaFactory);
  }

  /// Creates a union schema from multiple schemas
  ///
  /// The input will be validated against each schema in order.
  static Schema<T> union<T>(List<Schema<T>> schemas) {
    return UnionSchema<T>(schemas);
  }

  /// Creates an intersection schema from multiple schemas
  ///
  /// The input must pass validation for all schemas.
  static Schema<T> intersection<T>(List<Schema<T>> schemas) {
    return IntersectionSchema<T>(schemas);
  }

  /// Gets a string representation of the schema type
  String get schemaType => runtimeType.toString();

  @override
  String toString() {
    final desc = description != null ? ' ($description)' : '';
    return '$schemaType$desc';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Schema<T> &&
        other.runtimeType == runtimeType &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(runtimeType, description);
}

/// Schema that applies a transformation after validation
class TransformSchema<T, R> extends Schema<R> {
  final Schema<T> _schema;
  final R Function(T value) _transformer;

  const TransformSchema(this._schema, this._transformer);

  @override
  ValidationResult<R> validate(dynamic input, [List<String> path = const []]) {
    final result = _schema.validate(input, path);
    if (result.isSuccess) {
      try {
        final transformed = _transformer(result.data as T);
        return ValidationResult.success(transformed);
      } catch (e) {
        return ValidationResult.failure(
          ValidationErrorCollection.single(
            ValidationError.simple(
              message: 'Transformation failed: $e',
              path: path,
              received: result.data,
            ),
          ),
        );
      }
    }
    return ValidationResult.failure(result.errors!);
  }
}

/// Schema that applies additional validation
class RefineSchema<T> extends Schema<T> {
  final Schema<T> _schema;
  final bool Function(T value) _validator;
  final String? _message;
  final String? _code;

  const RefineSchema(
    this._schema,
    this._validator, {
    String? message,
    String? code,
  })  : _message = message,
        _code = code;

  @override
  ValidationResult<T> validate(dynamic input, [List<String> path = const []]) {
    final result = _schema.validate(input, path);
    if (result.isSuccess) {
      final value = result.data as T;
      if (_validator(value)) {
        return result;
      } else {
        return ValidationResult.failure(
          ValidationErrorCollection.single(
            ValidationError.constraintViolation(
              path: path,
              received: value,
              constraint: _message ?? 'Custom validation failed',
              code: _code ?? 'refinement_failed',
            ),
          ),
        );
      }
    }
    return result;
  }
}

/// Schema that applies async validation
class AsyncRefineSchema<T> extends Schema<T> {
  final Schema<T> _schema;
  final Future<bool> Function(T value) _validator;
  final String? _message;
  final String? _code;

  const AsyncRefineSchema(
    this._schema,
    this._validator, {
    String? message,
    String? code,
  })  : _message = message,
        _code = code;

  @override
  ValidationResult<T> validate(dynamic input, [List<String> path = const []]) {
    final result = _schema.validate(input, path);
    if (result.isSuccess) {
      final value = result.data as T;
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.simple(
            message: 'Async validation not supported in sync context',
            path: path,
            received: value,
            code: 'async_validation_in_sync_context',
          ),
        ),
      );
    }
    return result;
  }

  /// Async validation method
  Future<ValidationResult<T>> validateAsync(dynamic input,
      [List<String> path = const []]) async {
    final result = _schema.validate(input, path);
    if (result.isSuccess) {
      final value = result.data as T;
      final isValid = await _validator(value);
      if (isValid) {
        return result;
      } else {
        return ValidationResult.failure(
          ValidationErrorCollection.single(
            ValidationError.constraintViolation(
              path: path,
              received: value,
              constraint: _message ?? 'Async validation failed',
              code: _code ?? 'async_refinement_failed',
            ),
          ),
        );
      }
    }
    return result;
  }
}

/// Schema that provides a default value
class DefaultSchema<T> extends Schema<T> {
  final Schema<T> _schema;
  final T _defaultValue;

  const DefaultSchema(this._schema, this._defaultValue);

  @override
  ValidationResult<T> validate(dynamic input, [List<String> path = const []]) {
    if (input == null) {
      return ValidationResult.success(_defaultValue);
    }
    final result = _schema.validate(input, path);
    if (result.isSuccess) {
      return result;
    }
    return ValidationResult.success(_defaultValue);
  }
}

/// Schema that provides a computed default value
class ComputedDefaultSchema<T> extends Schema<T> {
  final Schema<T> _schema;
  final T Function() _defaultValue;

  const ComputedDefaultSchema(this._schema, this._defaultValue);

  @override
  ValidationResult<T> validate(dynamic input, [List<String> path = const []]) {
    if (input == null) {
      return ValidationResult.success(_defaultValue());
    }
    final result = _schema.validate(input, path);
    if (result.isSuccess) {
      return result;
    }
    return ValidationResult.success(_defaultValue());
  }
}

/// Schema that makes the value optional (nullable)
class OptionalSchema<T> extends Schema<T?> {
  final Schema<T> _schema;

  const OptionalSchema(this._schema);

  @override
  ValidationResult<T?> validate(dynamic input, [List<String> path = const []]) {
    if (input == null) {
      return ValidationResult.success(null);
    }
    final result = _schema.validate(input, path);
    if (result.isSuccess) {
      return ValidationResult.success(result.data);
    }
    return ValidationResult.failure(result.errors!);
  }
}

/// Schema that provides a fallback value
class FallbackSchema<T> extends Schema<T> {
  final Schema<T> _schema;
  final T _fallbackValue;

  const FallbackSchema(this._schema, this._fallbackValue);

  @override
  ValidationResult<T> validate(dynamic input, [List<String> path = const []]) {
    final result = _schema.validate(input, path);
    if (result.isSuccess) {
      return result;
    }
    return ValidationResult.success(_fallbackValue);
  }
}

/// Schema that provides a computed fallback value
class ComputedFallbackSchema<T> extends Schema<T> {
  final Schema<T> _schema;
  final T Function(ValidationErrorCollection errors) _fallback;

  const ComputedFallbackSchema(this._schema, this._fallback);

  @override
  ValidationResult<T> validate(dynamic input, [List<String> path = const []]) {
    final result = _schema.validate(input, path);
    if (result.isSuccess) {
      return result;
    }
    return ValidationResult.success(_fallback(result.errors!));
  }
}

/// Schema that preprocesses the input
class PreprocessSchema<T, R> extends Schema<T> {
  final Schema<T> _schema;
  final R Function(dynamic input) _preprocessor;

  const PreprocessSchema(this._schema, this._preprocessor);

  @override
  ValidationResult<T> validate(dynamic input, [List<String> path = const []]) {
    try {
      final preprocessed = _preprocessor(input);
      return _schema.validate(preprocessed, path);
    } catch (e) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.simple(
            message: 'Preprocessing failed: $e',
            path: path,
            received: input,
          ),
        ),
      );
    }
  }
}

/// Schema that postprocesses the output
class PostprocessSchema<T> extends Schema<T> {
  final Schema<T> _schema;
  final T Function(T value) _postprocessor;

  const PostprocessSchema(this._schema, this._postprocessor);

  @override
  ValidationResult<T> validate(dynamic input, [List<String> path = const []]) {
    final result = _schema.validate(input, path);
    if (result.isSuccess) {
      try {
        final postprocessed = _postprocessor(result.data as T);
        return ValidationResult.success(postprocessed);
      } catch (e) {
        return ValidationResult.failure(
          ValidationErrorCollection.single(
            ValidationError.simple(
              message: 'Postprocessing failed: $e',
              path: path,
              received: result.data,
            ),
          ),
        );
      }
    }
    return result;
  }
}

/// Schema that is lazy (evaluated only when needed)
class LazySchema<T> extends Schema<T> {
  final Schema<T> Function() _schemaFactory;
  Schema<T>? _cachedSchema;

  LazySchema(this._schemaFactory);

  Schema<T> get _schema {
    _cachedSchema ??= _schemaFactory();
    return _cachedSchema!;
  }

  @override
  ValidationResult<T> validate(dynamic input, [List<String> path = const []]) {
    return _schema.validate(input, path);
  }
}

/// Schema that validates against multiple schemas (union)
class UnionSchema<T> extends Schema<T> {
  final List<Schema<T>> _schemas;

  const UnionSchema(this._schemas);

  @override
  ValidationResult<T> validate(dynamic input, [List<String> path = const []]) {
    ValidationErrorCollection allErrors = ValidationErrorCollection.empty();

    for (final schema in _schemas) {
      final result = schema.validate(input, path);
      if (result.isSuccess) {
        return result;
      }
      allErrors = allErrors.merge(result.errors!);
    }

    return ValidationResult.failure(allErrors);
  }
}

/// Schema that validates against multiple schemas (intersection)
class IntersectionSchema<T> extends Schema<T> {
  final List<Schema<T>> _schemas;

  const IntersectionSchema(this._schemas);

  @override
  ValidationResult<T> validate(dynamic input, [List<String> path = const []]) {
    T? lastValidValue;

    for (final schema in _schemas) {
      final result = schema.validate(input, path);
      if (result.isFailure) {
        return result;
      }
      lastValidValue = result.data;
    }

    return ValidationResult.success(lastValidValue as T);
  }
}
