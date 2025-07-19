import '../../core/error.dart';
import '../../core/schema.dart';
import '../../core/validation_result.dart';

/// Schema for validating array values with element validation
class ArraySchema<T> extends Schema<List<T>> {
  /// Schema for validating array elements
  final Schema<T> _elementSchema;

  /// Minimum length constraint
  final int? _minLength;

  /// Maximum length constraint
  final int? _maxLength;

  /// Exact length constraint
  final int? _exactLength;

  /// Whether array must be non-empty
  final bool _nonempty;

  const ArraySchema(
    this._elementSchema, {
    super.description,
    super.metadata,
    int? minLength,
    int? maxLength,
    int? exactLength,
    bool nonempty = false,
  })  : _minLength = minLength,
        _maxLength = maxLength,
        _exactLength = exactLength,
        _nonempty = nonempty;

  @override
  ValidationResult<List<T>> validate(dynamic input,
      [List<String> path = const []]) {
    // Type check
    if (input is! List) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.typeMismatch(
            path: path,
            received: input,
            expected: 'array',
          ),
        ),
      );
    }

    List<dynamic> array = input;

    // Length validations
    if (_exactLength != null && array.length != _exactLength) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: array,
            constraint: 'exact length of $_exactLength',
            code: 'exact_length',
            context: {'expected': _exactLength, 'actual': array.length},
          ),
        ),
      );
    }

    if (_minLength != null && array.length < _minLength!) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: array,
            constraint: 'minimum length of $_minLength',
            code: 'min_length',
            context: {'expected': _minLength, 'actual': array.length},
          ),
        ),
      );
    }

    if (_maxLength != null && array.length > _maxLength!) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: array,
            constraint: 'maximum length of $_maxLength',
            code: 'max_length',
            context: {'expected': _maxLength, 'actual': array.length},
          ),
        ),
      );
    }

    // Non-empty validation
    if (_nonempty && array.isEmpty) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: array,
            constraint: 'non-empty array',
            code: 'empty_array',
          ),
        ),
      );
    }

    // Validate each element
    final validatedElements = <T>[];
    final errors = <ValidationError>[];

    for (int i = 0; i < array.length; i++) {
      final elementResult =
          _elementSchema.validate(array[i], [...path, i.toString()]);
      if (elementResult.isSuccess) {
        validatedElements.add(elementResult.data as T);
      } else {
        errors.addAll(elementResult.errors!.errors);
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(ValidationErrorCollection(errors));
    }

    return ValidationResult.success(validatedElements);
  }

  @override
  Future<ValidationResult<List<T>>> validateAsync(dynamic input,
      [List<String> path = const []]) async {
    // Type check
    if (input is! List) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.typeMismatch(
            path: path,
            received: input,
            expected: 'array',
          ),
        ),
      );
    }

    List<dynamic> array = input;

    // Length validations (same as sync)
    if (_exactLength != null && array.length != _exactLength) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: array,
            constraint: 'exact length of $_exactLength',
            code: 'exact_length',
            context: {'expected': _exactLength, 'actual': array.length},
          ),
        ),
      );
    }

    if (_minLength != null && array.length < _minLength!) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: array,
            constraint: 'minimum length of $_minLength',
            code: 'min_length',
            context: {'expected': _minLength, 'actual': array.length},
          ),
        ),
      );
    }

    if (_maxLength != null && array.length > _maxLength!) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: array,
            constraint: 'maximum length of $_maxLength',
            code: 'max_length',
            context: {'expected': _maxLength, 'actual': array.length},
          ),
        ),
      );
    }

    if (_nonempty && array.isEmpty) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: array,
            constraint: 'non-empty array',
            code: 'empty_array',
          ),
        ),
      );
    }

    // Validate each element asynchronously
    final validatedElements = <T>[];
    final errors = <ValidationError>[];

    for (int i = 0; i < array.length; i++) {
      final elementResult =
          await _elementSchema.validateAsync(array[i], [...path, i.toString()]);
      if (elementResult.isSuccess) {
        validatedElements.add(elementResult.data as T);
      } else {
        errors.addAll(elementResult.errors!.errors);
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(ValidationErrorCollection(errors));
    }

    return ValidationResult.success(validatedElements);
  }

  /// Sets minimum length constraint
  ArraySchema<T> min(int length) {
    return ArraySchema<T>(
      _elementSchema,
      description: description,
      metadata: metadata,
      minLength: length,
      maxLength: _maxLength,
      exactLength: _exactLength,
      nonempty: _nonempty,
    );
  }

  /// Sets maximum length constraint
  ArraySchema<T> max(int length) {
    return ArraySchema<T>(
      _elementSchema,
      description: description,
      metadata: metadata,
      minLength: _minLength,
      maxLength: length,
      exactLength: _exactLength,
      nonempty: _nonempty,
    );
  }

  /// Sets exact length constraint
  ArraySchema<T> length(int length) {
    return ArraySchema<T>(
      _elementSchema,
      description: description,
      metadata: metadata,
      minLength: _minLength,
      maxLength: _maxLength,
      exactLength: length,
      nonempty: _nonempty,
    );
  }

  /// Ensures array is non-empty
  ArraySchema<T> nonempty() {
    return ArraySchema<T>(
      _elementSchema,
      description: description,
      metadata: metadata,
      minLength: _minLength,
      maxLength: _maxLength,
      exactLength: _exactLength,
      nonempty: true,
    );
  }

  /// Ensures array contains only unique elements
  Schema<List<T>> unique() {
    return refine(
      (array) {
        final seen = <T>{};
        for (final element in array) {
          if (seen.contains(element)) {
            return false;
          }
          seen.add(element);
        }
        return true;
      },
      message: 'array must contain only unique elements',
      code: 'duplicate_elements',
    );
  }

  /// Ensures array has elements within the specified range
  ArraySchema<T> range(int min, int max) {
    return ArraySchema<T>(
      _elementSchema,
      description: description,
      metadata: metadata,
      minLength: min,
      maxLength: max,
      exactLength: _exactLength,
      nonempty: _nonempty,
    );
  }

  /// Checks if array includes a specific element
  Schema<List<T>> includes(T element) {
    return refine(
      (array) => array.contains(element),
      message: 'array must include $element',
      code: 'missing_element',
    );
  }

  /// Checks if array excludes a specific element
  Schema<List<T>> excludes(T element) {
    return refine(
      (array) => !array.contains(element),
      message: 'array must not include $element',
      code: 'forbidden_element',
    );
  }

  /// Validates that array has at least one element matching a condition
  Schema<List<T>> some(bool Function(T element) predicate, {String? message}) {
    return refine(
      (array) => array.any(predicate),
      message:
          message ?? 'array must have at least one element matching condition',
      code: 'some_failed',
    );
  }

  /// Validates that all array elements match a condition
  Schema<List<T>> every(bool Function(T element) predicate, {String? message}) {
    return refine(
      (array) => array.every(predicate),
      message: message ?? 'all array elements must match condition',
      code: 'every_failed',
    );
  }

  /// Creates a typed array schema with element refinement
  ArraySchema<T> element(Schema<T> elementSchema) {
    return ArraySchema<T>(
      elementSchema,
      description: description,
      metadata: metadata,
      minLength: _minLength,
      maxLength: _maxLength,
      exactLength: _exactLength,
      nonempty: _nonempty,
    );
  }

  /// Transforms the array after validation
  Schema<List<R>> mapElements<R>(R Function(T element) mapper) {
    return transform<List<R>>((array) => array.map(mapper).toList());
  }

  /// Filters the array after validation
  Schema<List<T>> filter(bool Function(T element) predicate) {
    return transform((array) => array.where(predicate).toList());
  }

  /// Sorts the array after validation
  Schema<List<T>> sort([int Function(T a, T b)? compare]) {
    return transform((array) {
      final sorted = List<T>.from(array);
      sorted.sort(compare);
      return sorted;
    });
  }

  /// Gets the element schema for this array
  Schema<T> get elementSchema => _elementSchema;

  @override
  String toString() {
    final constraints = <String>[];

    if (_minLength != null) constraints.add('min: $_minLength');
    if (_maxLength != null) constraints.add('max: $_maxLength');
    if (_exactLength != null) constraints.add('length: $_exactLength');
    if (_nonempty) constraints.add('nonempty');

    final constraintStr =
        constraints.isNotEmpty ? ' (${constraints.join(', ')})' : '';
    return 'ArraySchema<${_elementSchema.runtimeType}>$constraintStr';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArraySchema<T> &&
        other._elementSchema == _elementSchema &&
        other._minLength == _minLength &&
        other._maxLength == _maxLength &&
        other._exactLength == _exactLength &&
        other._nonempty == _nonempty;
  }

  @override
  int get hashCode => Object.hash(
        _elementSchema,
        _minLength,
        _maxLength,
        _exactLength,
        _nonempty,
      );

  /// Public getters for JSON schema generation
  int? get minItems => _minLength;
  int? get maxItems => _maxLength;
  int? get exactItems => _exactLength;
  bool? get uniqueItems => null; // ArraySchema doesn't have unique constraint yet
}
