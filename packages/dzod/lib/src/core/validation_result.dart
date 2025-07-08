import 'error.dart';

/// Represents the result of a validation operation
///
/// This class provides a type-safe way to handle validation results,
/// similar to Rust's Result type or functional programming patterns.
sealed class ValidationResult<T> {
  const ValidationResult._();

  /// Creates a successful validation result
  const factory ValidationResult.success(T data) = ValidationSuccess<T>;

  /// Creates a failed validation result
  const factory ValidationResult.failure(ValidationErrorCollection errors) =
      ValidationFailure<T>;

  /// Checks if the validation was successful
  bool get isSuccess;

  /// Checks if the validation failed
  bool get isFailure;

  /// Gets the validated data (only available on success)
  T? get data;

  /// Gets the validation errors (only available on failure)
  ValidationErrorCollection? get errors;

  /// Maps the success value to a new type
  ValidationResult<R> map<R>(R Function(T data) mapper);

  /// Maps the success value to a new type, or handles errors
  ValidationResult<R> mapOr<R>(
    R Function(T data) mapper,
    R Function(ValidationErrorCollection errors) errorMapper,
  );

  /// Maps the success value to a new ValidationResult
  ValidationResult<R> flatMap<R>(ValidationResult<R> Function(T data) mapper);

  /// Executes a function on success
  ValidationResult<T> onSuccess(void Function(T data) callback);

  /// Executes a function on failure
  ValidationResult<T> onFailure(
      void Function(ValidationErrorCollection errors) callback);

  /// Unwraps the value, throwing an exception if validation failed
  T unwrap();

  /// Unwraps the value, returning a default if validation failed
  T unwrapOr(T defaultValue);

  /// Unwraps the value, computing a default if validation failed
  T unwrapOrElse(T Function(ValidationErrorCollection errors) defaultValue);

  /// Converts to a nullable value
  T? toNullable();

  /// Converts to an Either-like structure
  Either<T, ValidationErrorCollection> toEither();
}

/// Successful validation result
class ValidationSuccess<T> extends ValidationResult<T> {
  final T _data;

  const ValidationSuccess(this._data) : super._();

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;

  @override
  T get data => _data;

  @override
  ValidationErrorCollection? get errors => null;

  @override
  ValidationResult<R> map<R>(R Function(T data) mapper) {
    return ValidationResult.success(mapper(_data));
  }

  @override
  ValidationResult<R> mapOr<R>(
    R Function(T data) mapper,
    R Function(ValidationErrorCollection errors) errorMapper,
  ) {
    return ValidationResult.success(mapper(_data));
  }

  @override
  ValidationResult<R> flatMap<R>(ValidationResult<R> Function(T data) mapper) {
    return mapper(_data);
  }

  @override
  ValidationResult<T> onSuccess(void Function(T data) callback) {
    callback(_data);
    return this;
  }

  @override
  ValidationResult<T> onFailure(
      void Function(ValidationErrorCollection errors) callback) {
    return this;
  }

  @override
  T unwrap() => _data;

  @override
  T unwrapOr(T defaultValue) => _data;

  @override
  T unwrapOrElse(T Function(ValidationErrorCollection errors) defaultValue) =>
      _data;

  @override
  T? toNullable() => _data;

  @override
  Either<T, ValidationErrorCollection> toEither() => Either.left(_data);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidationSuccess<T> && other._data == _data;
  }

  @override
  int get hashCode => Object.hash(ValidationSuccess, _data);

  @override
  String toString() => 'ValidationSuccess($_data)';
}

/// Failed validation result
class ValidationFailure<T> extends ValidationResult<T> {
  final ValidationErrorCollection _errors;

  const ValidationFailure(this._errors) : super._();

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;

  @override
  T? get data => null;

  @override
  ValidationErrorCollection get errors => _errors;

  @override
  ValidationResult<R> map<R>(R Function(T data) mapper) {
    return ValidationResult.failure(_errors);
  }

  @override
  ValidationResult<R> mapOr<R>(
    R Function(T data) mapper,
    R Function(ValidationErrorCollection errors) errorMapper,
  ) {
    return ValidationResult.success(errorMapper(_errors));
  }

  @override
  ValidationResult<R> flatMap<R>(ValidationResult<R> Function(T data) mapper) {
    return ValidationResult.failure(_errors);
  }

  @override
  ValidationResult<T> onSuccess(void Function(T data) callback) {
    return this;
  }

  @override
  ValidationResult<T> onFailure(
      void Function(ValidationErrorCollection errors) callback) {
    callback(_errors);
    return this;
  }

  @override
  T unwrap() {
    throw ValidationException('Validation failed: ${_errors.formattedErrors}');
  }

  @override
  T unwrapOr(T defaultValue) => defaultValue;

  @override
  T unwrapOrElse(T Function(ValidationErrorCollection errors) defaultValue) =>
      defaultValue(_errors);

  @override
  T? toNullable() => null;

  @override
  Either<T, ValidationErrorCollection> toEither() => Either.right(_errors);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidationFailure<T> && other._errors == _errors;
  }

  @override
  int get hashCode => Object.hash(ValidationFailure, _errors);

  @override
  String toString() => 'ValidationFailure($_errors)';
}

/// Exception thrown when unwrapping a failed validation result
class ValidationException implements Exception {
  final String message;

  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

/// Simple Either-like structure for functional programming patterns
class Either<L, R> {
  final L? _left;
  final R? _right;
  final bool _isLeft;

  const Either._left(this._left)
      : _right = null,
        _isLeft = true;
  const Either._right(this._right)
      : _left = null,
        _isLeft = false;

  /// Creates an Either with a left value
  factory Either.left(L value) => Either._left(value);

  /// Creates an Either with a right value
  factory Either.right(R value) => Either._right(value);

  /// Checks if this is a left value
  bool get isLeft => _isLeft;

  /// Checks if this is a right value
  bool get isRight => !_isLeft;

  /// Gets the left value (throws if this is a right)
  L get left {
    if (!_isLeft) throw StateError('This is a right value');
    return _left!;
  }

  /// Gets the right value (throws if this is a left)
  R get right {
    if (_isLeft) throw StateError('This is a left value');
    return _right!;
  }

  /// Maps the left value
  Either<L2, R> mapLeft<L2>(L2 Function(L value) mapper) {
    if (_isLeft) {
      return Either.left(mapper(_left as L));
    }
    return Either.right(_right as R);
  }

  /// Maps the right value
  Either<L, R2> mapRight<R2>(R2 Function(R value) mapper) {
    if (_isLeft) {
      return Either.left(_left as L);
    }
    return Either.right(mapper(_right as R));
  }

  /// Folds both values into a single result
  T fold<T>(T Function(L left) leftMapper, T Function(R right) rightMapper) {
    if (_isLeft) {
      return leftMapper(_left as L);
    }
    return rightMapper(_right as R);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Either<L, R> &&
        other._isLeft == _isLeft &&
        other._left == _left &&
        other._right == _right;
  }

  @override
  int get hashCode => Object.hash(_isLeft, _left, _right);

  @override
  String toString() =>
      _isLeft ? 'Either.left($_left)' : 'Either.right($_right)';
}

/// Extension on ValidationResult to provide human-readable output
extension ValidationResultExtensions<T> on ValidationResult<T> {
  /// Generates a clean, human-readable validation result message
  ///
  /// For successful validation, shows a simple success indicator.
  /// For failed validation, shows formatted error messages without the input value.
  String toHumanReadable() {
    if (isSuccess) {
      return '✅ Validation successful';
    } else {
      final errorMessages = errors!.errors.map((e) => '• ${e.message}').join('\n');
      return '❌ Validation failed:\n$errorMessages';
    }
  }
}

/// Extension on ValidationErrorCollection to provide detailed error information
extension ValidationErrorCollectionExtensions on ValidationErrorCollection {
  /// Provides detailed error information including the input value
  ///
  /// Shows comprehensive information including:
  /// - Input value and its type
  /// - Formatted list of all errors with paths
  /// - Human-readable error summaries
  String details(dynamic value) {
    final buffer = StringBuffer();
    buffer.writeln('❌ Validation failed for input: "$value"');
    buffer.writeln('Input type: ${value.runtimeType}');
    buffer.writeln();
    buffer.writeln('Errors:');
    
    for (final error in errors) {
      final pathStr = error.path.isEmpty ? 'root' : error.fullPath;
      buffer.writeln('• At $pathStr: ${error.message}');
      if (error.expected != 'valid value') {
        buffer.writeln('  Expected: ${error.expected}');
      }
      if (error.received != value) {
        buffer.writeln('  Received: ${error.received}');
      }
    }
    
    return buffer.toString().trim();
  }
}
