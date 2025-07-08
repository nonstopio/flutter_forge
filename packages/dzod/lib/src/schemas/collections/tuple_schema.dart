import '../../core/error.dart';
import '../../core/schema.dart';
import '../../core/validation_result.dart';

/// Schema for validating tuple values with fixed-length and typed elements
class TupleSchema<T extends List<dynamic>> extends Schema<T> {
  /// Schemas for validating each element in the tuple
  final List<Schema<dynamic>> _elementSchemas;

  /// Optional rest schema for additional elements
  final Schema<dynamic>? _restSchema;

  const TupleSchema(
    this._elementSchemas, {
    super.description,
    super.metadata,
    Schema<dynamic>? restSchema,
  }) : _restSchema = restSchema;

  @override
  ValidationResult<T> validate(dynamic input, [List<String> path = const []]) {
    // Type check
    if (input is! List) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.typeMismatch(
            path: path,
            received: input,
            expected: 'tuple',
          ),
        ),
      );
    }

    List<dynamic> array = input;

    // Check minimum length requirement
    if (array.length < _elementSchemas.length) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: array,
            constraint: 'minimum length of ${_elementSchemas.length}',
            code: 'tuple_too_short',
            context: {
              'expected': _elementSchemas.length,
              'actual': array.length,
            },
          ),
        ),
      );
    }

    // Check maximum length if no rest schema
    if (_restSchema == null && array.length > _elementSchemas.length) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: array,
            constraint: 'exact length of ${_elementSchemas.length}',
            code: 'tuple_too_long',
            context: {
              'expected': _elementSchemas.length,
              'actual': array.length,
            },
          ),
        ),
      );
    }

    final validatedElements = <dynamic>[];
    final errors = <ValidationError>[];

    // Validate required elements
    for (int i = 0; i < _elementSchemas.length; i++) {
      final elementResult = _elementSchemas[i].validate(
        array[i],
        [...path, i.toString()],
      );
      if (elementResult.isSuccess) {
        validatedElements.add(elementResult.data);
      } else {
        errors.addAll(elementResult.errors!.errors);
      }
    }

    // Validate rest elements if rest schema exists
    if (_restSchema != null) {
      for (int i = _elementSchemas.length; i < array.length; i++) {
        final elementResult = _restSchema!.validate(
          array[i],
          [...path, i.toString()],
        );
        if (elementResult.isSuccess) {
          validatedElements.add(elementResult.data);
        } else {
          errors.addAll(elementResult.errors!.errors);
        }
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(ValidationErrorCollection(errors));
    }

    return ValidationResult.success(validatedElements as T);
  }

  /// Adds a rest schema for additional elements beyond the fixed tuple
  TupleSchema<List<dynamic>> rest(Schema<dynamic> restSchema) {
    return TupleSchema<List<dynamic>>(
      _elementSchemas,
      description: description,
      metadata: metadata,
      restSchema: restSchema,
    );
  }

  /// Creates a new tuple schema with an additional element schema
  TupleSchema<List<dynamic>> append<U>(Schema<U> elementSchema) {
    return TupleSchema<List<dynamic>>(
      [..._elementSchemas, elementSchema],
      description: description,
      metadata: metadata,
      restSchema: _restSchema,
    );
  }

  /// Creates a new tuple schema with an element schema prepended
  TupleSchema<List<dynamic>> prepend<U>(Schema<U> elementSchema) {
    return TupleSchema<List<dynamic>>(
      [elementSchema, ..._elementSchemas],
      description: description,
      metadata: metadata,
      restSchema: _restSchema,
    );
  }

  /// Gets the first element schema
  Schema<dynamic> get first {
    if (_elementSchemas.isEmpty) {
      throw StateError('Tuple has no elements');
    }
    return _elementSchemas.first;
  }

  /// Gets the last element schema
  Schema<dynamic> get last {
    if (_elementSchemas.isEmpty) {
      throw StateError('Tuple has no elements');
    }
    return _elementSchemas.last;
  }

  /// Gets the element schema at the specified index
  Schema<dynamic> elementAt(int index) {
    if (index < 0 || index >= _elementSchemas.length) {
      throw RangeError.index(index, _elementSchemas);
    }
    return _elementSchemas[index];
  }

  /// Gets the number of required elements in the tuple
  int get length => _elementSchemas.length;

  /// Checks if the tuple has a rest schema
  bool get hasRest => _restSchema != null;

  /// Gets the rest schema if it exists
  Schema<dynamic>? get restSchema => _restSchema;

  /// Gets all element schemas
  List<Schema<dynamic>> get elementSchemas =>
      List.unmodifiable(_elementSchemas);

  /// Validates that the tuple has a specific length
  Schema<T> exactLength(int expectedLength) {
    return refine(
      (tuple) => tuple.length == expectedLength,
      message: 'tuple must have exactly $expectedLength elements',
      code: 'invalid_tuple_length',
    );
  }

  /// Validates that the tuple has at least a minimum length
  Schema<T> minLength(int minLength) {
    return refine(
      (tuple) => tuple.length >= minLength,
      message: 'tuple must have at least $minLength elements',
      code: 'tuple_too_short',
    );
  }

  /// Validates that the tuple has at most a maximum length
  Schema<T> maxLength(int maxLength) {
    return refine(
      (tuple) => tuple.length <= maxLength,
      message: 'tuple must have at most $maxLength elements',
      code: 'tuple_too_long',
    );
  }

  /// Validates that the tuple is not empty
  Schema<T> nonempty() {
    return refine(
      (tuple) => tuple.isNotEmpty,
      message: 'tuple must not be empty',
      code: 'empty_tuple',
    );
  }

  /// Transforms the tuple after validation
  Schema<List<R>> map<R>(R Function(dynamic element) mapper) {
    return transform<List<R>>((tuple) => tuple.map(mapper).toList());
  }

  /// Filters the tuple elements after validation
  Schema<List<dynamic>> filter(bool Function(dynamic element) predicate) {
    return transform((tuple) => tuple.where(predicate).toList());
  }

  /// Gets a slice of the tuple
  Schema<List<dynamic>> slice(int start, [int? end]) {
    return transform((tuple) => tuple.sublist(start, end));
  }

  /// Reverses the tuple
  Schema<List<dynamic>> reverse() {
    return transform((tuple) => tuple.reversed.toList());
  }

  @override
  String toString() {
    final elementTypes = _elementSchemas
        .map((schema) => schema.runtimeType.toString())
        .join(', ');
    final restStr =
        _restSchema != null ? ', ...${_restSchema.runtimeType}' : '';
    return 'TupleSchema<[$elementTypes$restStr]>';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TupleSchema<T> &&
        _listEquals(_elementSchemas, other._elementSchemas) &&
        _restSchema == other._restSchema;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(_elementSchemas),
        _restSchema,
      );

  /// Helper method to compare lists for equality
  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

/// Factory methods for creating common tuple schemas
extension TupleFactories on Never {
  /// Creates a tuple schema for a pair (2 elements)
  static TupleSchema<List<dynamic>> pair<T1, T2>(
    Schema<T1> first,
    Schema<T2> second,
  ) {
    return TupleSchema<List<dynamic>>([first, second]);
  }

  /// Creates a tuple schema for a triple (3 elements)
  static TupleSchema<List<dynamic>> triple<T1, T2, T3>(
    Schema<T1> first,
    Schema<T2> second,
    Schema<T3> third,
  ) {
    return TupleSchema<List<dynamic>>([first, second, third]);
  }

  /// Creates a tuple schema for a quad (4 elements)
  static TupleSchema<List<dynamic>> quad<T1, T2, T3, T4>(
    Schema<T1> first,
    Schema<T2> second,
    Schema<T3> third,
    Schema<T4> fourth,
  ) {
    return TupleSchema<List<dynamic>>([first, second, third, fourth]);
  }

  /// Creates a tuple schema for 5 elements
  static TupleSchema<List<dynamic>> quintuple<T1, T2, T3, T4, T5>(
    Schema<T1> first,
    Schema<T2> second,
    Schema<T3> third,
    Schema<T4> fourth,
    Schema<T5> fifth,
  ) {
    return TupleSchema<List<dynamic>>([first, second, third, fourth, fifth]);
  }
}
