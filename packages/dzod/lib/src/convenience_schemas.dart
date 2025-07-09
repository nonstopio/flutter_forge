import 'package:dzod/dzod.dart';

/// Convenience class that provides factory methods for creating schemas
///
/// This class provides a Zod-like API for creating schemas:
/// ```dart
/// final userSchema = Z.object({
///   'name': Z.string().min(2).max(50),
///   'email': Z.string().email(),
///   'age': Z.number().min(18).max(120),
///   'isActive': Z.boolean(),
/// });
/// ```
class Z {
  const Z._();

  /// Creates a string schema
  static StringSchema string() => const StringSchema();

  /// Creates a number schema
  static NumberSchema number() => const NumberSchema();

  /// Creates a boolean schema
  static BooleanSchema boolean() => const BooleanSchema();

  /// Creates a null schema
  static NullSchema null_() => const NullSchema();

  /// Creates a null schema (alias for null_)
  static NullSchema get nullValue => const NullSchema();

  /// Creates an array schema with element validation
  static ArraySchema<T> array<T>(Schema<T> elementSchema) =>
      ArraySchema<T>(elementSchema);

  /// Creates a tuple schema with fixed-length typed elements
  static TupleSchema<List<dynamic>> tuple(
          List<Schema<dynamic>> elementSchemas) =>
      TupleSchema<List<dynamic>>(elementSchemas);

  /// Creates an enum schema from a list of values
  static EnumSchema<T> enum_<T>(List<T> values) => EnumSchema<T>(values);

  /// Creates a true boolean schema
  static BooleanSchema get trueValue =>
      const BooleanSchema(expectedValue: true);

  /// Creates a false boolean schema
  static BooleanSchema get falseValue =>
      const BooleanSchema(expectedValue: false);

  /// Creates a literal schema for any value
  static Schema<T> literal<T>(T value) {
    return _LiteralSchema<T>(value);
  }

  /// Creates a union schema from multiple schemas
  static Schema<T> union<T>(List<Schema<T>> schemas) {
    return Schema.union(schemas);
  }

  /// Creates a discriminated union schema for efficient union parsing
  static DiscriminatedUnionSchema<T> discriminatedUnion<T>(
    String discriminator,
    List<Schema<T>> schemas, {
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return DiscriminatedUnionSchema<T>(
      discriminator,
      schemas,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a pipeline schema for multi-stage validation
  static PipelineSchema<TInput, TOutput> pipeline<TInput, TOutput>(
    List<Schema<dynamic>> stages, {
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    if (stages.isEmpty) {
      throw ArgumentError('Pipeline must have at least one stage');
    }
    return PipelineSchema<TInput, TOutput>(
      stages,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a recursive schema with enhanced circular reference handling
  static RecursiveSchema<T> recursive<T>(
    Schema<T> Function() schemaFactory, {
    int maxDepth = 1000,
    bool enableCircularDetection = true,
    bool enableMemoization = true,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return RecursiveSchema<T>(
      schemaFactory,
      maxDepth: maxDepth,
      enableCircularDetection: enableCircularDetection,
      enableMemoization: enableMemoization,
      description: description,
      metadata: metadata,
    );
  }

  /// Access to coercion schemas
  static const Coerce coerce = Coerce();

  /// Creates an intersection schema from multiple schemas
  static Schema<T> intersection<T>(List<Schema<T>> schemas) {
    return Schema.intersection(schemas);
  }

  /// Creates a lazy schema that is evaluated only when needed
  static Schema<T> lazy<T>(Schema<T> Function() schemaFactory) {
    return Schema.lazy(schemaFactory);
  }

  /// Creates a custom schema with a validation function
  static Schema<T> custom<T>(
      ValidationResult<T> Function(dynamic input, List<String> path)
          validator) {
    return _CustomSchema<T>(validator);
  }

  /// Creates an object schema with comprehensive manipulation methods
  static ObjectSchema object(
    Map<String, Schema<dynamic>> shape, {
    Set<String>? optionalKeys,
  }) {
    // Auto-detect optional keys from OptionalSchema instances
    final autoOptionalKeys = <String>{};
    for (final entry in shape.entries) {
      if (entry.value is OptionalSchema) {
        autoOptionalKeys.add(entry.key);
      }
    }

    // Combine explicit and auto-detected optional keys
    final combinedOptionalKeys = <String>{
      ...autoOptionalKeys,
      if (optionalKeys != null) ...optionalKeys,
    };

    return ObjectSchema(shape, optionalKeys: combinedOptionalKeys);
  }

  /// Creates an any schema that accepts any value
  static Schema<dynamic> any() => const _AnySchema();

  /// Creates an unknown schema that accepts any value but provides better type safety
  static Schema<dynamic> unknown() => const _UnknownSchema();

  /// Creates a never schema that never accepts any value
  static Schema<Never> never() => const _NeverSchema();

  /// Creates a void schema that only accepts undefined/null
  static Schema<void> void_() => const _VoidSchema();

  /// Creates a void schema (alias for void_)
  static Schema<void> get voidValue => const _VoidSchema();

  /// Creates a date schema
  static Schema<DateTime> date() => const _DateSchema();

  /// Creates a bigint schema
  static Schema<BigInt> bigint() => const _BigIntSchema();

  /// Creates a symbol schema
  static Schema<Symbol> symbol() => const _SymbolSchema();

  /// Creates a function schema
  static Schema<Function> function() => const _FunctionSchema();

  /// Creates a regex schema
  static Schema<RegExp> regex() => const _RegexSchema();

  /// Creates a map schema
  static Schema<Map<String, dynamic>> map() => const _MapSchema();

  /// Creates a set schema
  static Schema<Set<dynamic>> set() => const _SetSchema();

  /// Creates a record schema for key-value pairs
  static RecordSchema<String, dynamic> record([Schema<dynamic>? valueSchema]) =>
      RecordSchema<String, dynamic>(valueSchema: valueSchema);

  /// Creates a promise schema (for async values)
  static Schema<Future<dynamic>> promise() => const _PromiseSchema();

  /// Creates an undefined schema
  static Schema<void> undefined() => const _UndefinedSchema();

  /// Creates a nan schema
  static Schema<double> nan() => const _NanSchema();

  /// Creates an infinity schema
  static Schema<double> infinity() => const _InfinitySchema();

  /// Creates a negative infinity schema
  static Schema<double> negativeInfinity() => const _NegativeInfinitySchema();

  /// Creates a positive infinity schema
  static Schema<double> positiveInfinity() => const _PositiveInfinitySchema();

  /// Creates a zero schema
  static Schema<num> zero() => const _ZeroSchema();

  /// Creates a one schema
  static Schema<num> one() => const _OneSchema();

  /// Creates a negative one schema
  static Schema<num> negativeOne() => const _NegativeOneSchema();

  /// Creates an empty string schema
  static StringSchema emptyString() => const StringSchema(exactLength: 0);

  /// Creates a non-empty string schema
  static StringSchema nonEmptyString() => const StringSchema().nonempty();

  /// Creates an email string schema
  static StringSchema email() => const StringSchema(isEmail: true);

  /// Creates a URL string schema
  static StringSchema url() => const StringSchema(isUrl: true);

  /// Creates a UUID string schema
  static StringSchema uuid() => const StringSchema(isUuid: true);

  /// Creates an integer schema
  static NumberSchema integer() => const NumberSchema(isInt: true);

  /// Creates a positive number schema
  static NumberSchema positive() => const NumberSchema(isPositive: true);

  /// Creates a negative number schema
  static NumberSchema negative() => const NumberSchema(isNegative: true);

  /// Creates a non-negative number schema
  static NumberSchema nonNegative() => const NumberSchema(isNonNegative: true);

  /// Creates a non-positive number schema
  static NumberSchema nonPositive() => const NumberSchema(isNonPositive: true);

  /// Creates a finite number schema
  static NumberSchema finite() => const NumberSchema(isFinite: true);

  /// Creates a safe integer schema
  static NumberSchema safeInt() => const NumberSchema(isSafeInt: true);

  /// Creates a port number schema
  static Schema<num> port() => const NumberSchema().port();

  /// Creates a year schema
  static Schema<num> year() => const NumberSchema().year();

  /// Creates a month schema
  static Schema<num> month() => const NumberSchema().month();

  /// Creates a day schema
  static Schema<num> day() => const NumberSchema().day();

  /// Creates an hour schema
  static Schema<num> hour() => const NumberSchema().hour();

  /// Creates a minute schema
  static Schema<num> minute() => const NumberSchema().minute();

  /// Creates a second schema
  static Schema<num> second() => const NumberSchema().second();

  /// Creates a transform schema that can be used in pipelines
  static TransformSchema<T, R> transform<T, R>(R Function(T) transformer) =>
      TransformSchema<T, R>(_TypedSchema<T>(), transformer);

  /// Creates a refine schema that can be used in pipelines
  static RefineSchema<T> refine<T>(bool Function(T) validator,
          {String? message, String? code}) =>
      RefineSchema<T>(_TypedSchema<T>(), validator,
          message: message, code: code);

  /// Creates an async refine schema that can be used in pipelines
  static AsyncRefineSchema<T> refineAsync<T>(Future<bool> Function(T) validator,
          {String? message, String? code}) =>
      AsyncRefineSchema<T>(_TypedSchema<T>(), validator,
          message: message, code: code);
}

// Implementation classes for convenience schemas

/// A typed schema that accepts any value of type T
class _TypedSchema<T> extends Schema<T> {
  const _TypedSchema();

  @override
  ValidationResult<T> validate(dynamic input, [List<String> path = const []]) {
    if (input is T) {
      return ValidationResult.success(input);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.typeMismatch(
          expected: '$T',
          received: input,
          path: path,
        ),
      ),
    );
  }
}

/// Schema for literal values
class _LiteralSchema<T> extends Schema<T> {
  final T _value;

  const _LiteralSchema(this._value);

  /// Gets the literal value this schema validates against
  T get value => _value;

  @override
  ValidationResult<T> validate(dynamic input, [List<String> path = const []]) {
    if (input == _value) {
      return ValidationResult.success(_value);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.constraintViolation(
          path: path,
          received: input,
          constraint: 'literal value $_value',
          code: 'literal_mismatch',
        ),
      ),
    );
  }
}

/// Schema for any value
class _AnySchema extends Schema<dynamic> {
  const _AnySchema();

  @override
  ValidationResult<dynamic> validate(dynamic input,
      [List<String> path = const []]) {
    return ValidationResult.success(input);
  }
}

/// Schema for unknown values
class _UnknownSchema extends Schema<dynamic> {
  const _UnknownSchema();

  @override
  ValidationResult<dynamic> validate(dynamic input,
      [List<String> path = const []]) {
    return ValidationResult.success(input);
  }
}

/// Schema that never accepts any value
class _NeverSchema extends Schema<Never> {
  const _NeverSchema();

  @override
  ValidationResult<Never> validate(dynamic input,
      [List<String> path = const []]) {
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.constraintViolation(
          path: path,
          received: input,
          constraint: 'never',
          code: 'never_schema',
        ),
      ),
    );
  }
}

/// Schema for void values (null/undefined)
class _VoidSchema extends Schema<void> {
  const _VoidSchema();

  @override
  ValidationResult<void> validate(dynamic input,
      [List<String> path = const []]) {
    if (input == null) {
      return const ValidationResult.success(null);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.typeMismatch(
          path: path,
          received: input,
          expected: 'void',
        ),
      ),
    );
  }
}

/// Schema for date values
class _DateSchema extends Schema<DateTime> {
  const _DateSchema();

  @override
  ValidationResult<DateTime> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is DateTime) {
      return ValidationResult.success(input);
    }
    if (input is String) {
      final date = DateTime.tryParse(input);
      if (date != null) {
        return ValidationResult.success(date);
      }
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.typeMismatch(
          path: path,
          received: input,
          expected: 'date',
        ),
      ),
    );
  }
}

/// Schema for bigint values
class _BigIntSchema extends Schema<BigInt> {
  const _BigIntSchema();

  @override
  ValidationResult<BigInt> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is BigInt) {
      return ValidationResult.success(input);
    }
    if (input is String) {
      try {
        final bigInt = BigInt.parse(input);
        return ValidationResult.success(bigInt);
      } catch (e) {
        // Continue to error
      }
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.typeMismatch(
          path: path,
          received: input,
          expected: 'bigint',
        ),
      ),
    );
  }
}

/// Schema for symbol values
class _SymbolSchema extends Schema<Symbol> {
  const _SymbolSchema();

  @override
  ValidationResult<Symbol> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is Symbol) {
      return ValidationResult.success(input);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.typeMismatch(
          path: path,
          received: input,
          expected: 'symbol',
        ),
      ),
    );
  }
}

/// Schema for function values
class _FunctionSchema extends Schema<Function> {
  const _FunctionSchema();

  @override
  ValidationResult<Function> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is Function) {
      return ValidationResult.success(input);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.typeMismatch(
          path: path,
          received: input,
          expected: 'function',
        ),
      ),
    );
  }
}

/// Schema for regex values
class _RegexSchema extends Schema<RegExp> {
  const _RegexSchema();

  @override
  ValidationResult<RegExp> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is RegExp) {
      return ValidationResult.success(input);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.typeMismatch(
          path: path,
          received: input,
          expected: 'regex',
        ),
      ),
    );
  }
}

/// Schema for map values
class _MapSchema extends Schema<Map<String, dynamic>> {
  const _MapSchema();

  @override
  ValidationResult<Map<String, dynamic>> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is Map<String, dynamic>) {
      return ValidationResult.success(input);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.typeMismatch(
          path: path,
          received: input,
          expected: 'map',
        ),
      ),
    );
  }
}

/// Schema for set values
class _SetSchema extends Schema<Set<dynamic>> {
  const _SetSchema();

  @override
  ValidationResult<Set<dynamic>> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is Set<dynamic>) {
      return ValidationResult.success(input);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.typeMismatch(
          path: path,
          received: input,
          expected: 'set',
        ),
      ),
    );
  }
}

/// Schema for promise values
class _PromiseSchema extends Schema<Future<dynamic>> {
  const _PromiseSchema();

  @override
  ValidationResult<Future<dynamic>> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is Future<dynamic>) {
      return ValidationResult.success(input);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.typeMismatch(
          path: path,
          received: input,
          expected: 'promise',
        ),
      ),
    );
  }
}

/// Schema for undefined values
class _UndefinedSchema extends Schema<void> {
  const _UndefinedSchema();

  @override
  ValidationResult<void> validate(dynamic input,
      [List<String> path = const []]) {
    if (input == null) {
      return const ValidationResult.success(null);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.typeMismatch(
          path: path,
          received: input,
          expected: 'undefined',
        ),
      ),
    );
  }
}

/// Schema for NaN values
class _NanSchema extends Schema<double> {
  const _NanSchema();

  @override
  ValidationResult<double> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is num && input.isNaN) {
      return const ValidationResult.success(double.nan);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.constraintViolation(
          path: path,
          received: input,
          constraint: 'NaN',
          code: 'not_nan',
        ),
      ),
    );
  }
}

/// Schema for infinity values
class _InfinitySchema extends Schema<double> {
  const _InfinitySchema();

  @override
  ValidationResult<double> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is num && input.isInfinite) {
      return const ValidationResult.success(double.infinity);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.constraintViolation(
          path: path,
          received: input,
          constraint: 'infinity',
          code: 'not_infinity',
        ),
      ),
    );
  }
}

/// Schema for negative infinity values
class _NegativeInfinitySchema extends Schema<double> {
  const _NegativeInfinitySchema();

  @override
  ValidationResult<double> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is num && input.isInfinite && input.isNegative) {
      return const ValidationResult.success(double.negativeInfinity);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.constraintViolation(
          path: path,
          received: input,
          constraint: 'negative infinity',
          code: 'not_negative_infinity',
        ),
      ),
    );
  }
}

/// Schema for positive infinity values
class _PositiveInfinitySchema extends Schema<double> {
  const _PositiveInfinitySchema();

  @override
  ValidationResult<double> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is num && input.isInfinite && !input.isNegative) {
      return const ValidationResult.success(double.infinity);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.constraintViolation(
          path: path,
          received: input,
          constraint: 'positive infinity',
          code: 'not_positive_infinity',
        ),
      ),
    );
  }
}

/// Schema for zero values
class _ZeroSchema extends Schema<num> {
  const _ZeroSchema();

  @override
  ValidationResult<num> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is num && input == 0) {
      return ValidationResult.success(input);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.constraintViolation(
          path: path,
          received: input,
          constraint: 'zero',
          code: 'not_zero',
        ),
      ),
    );
  }
}

/// Schema for one values
class _OneSchema extends Schema<num> {
  const _OneSchema();

  @override
  ValidationResult<num> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is num && input == 1) {
      return ValidationResult.success(input);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.constraintViolation(
          path: path,
          received: input,
          constraint: 'one',
          code: 'not_one',
        ),
      ),
    );
  }
}

/// Schema for negative one values
class _NegativeOneSchema extends Schema<num> {
  const _NegativeOneSchema();

  @override
  ValidationResult<num> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is num && input == -1) {
      return ValidationResult.success(input);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.constraintViolation(
          path: path,
          received: input,
          constraint: 'negative one',
          code: 'not_negative_one',
        ),
      ),
    );
  }
}

/// Schema for custom validation
class _CustomSchema<T> extends Schema<T> {
  final ValidationResult<T> Function(dynamic input, List<String> path)
      _validator;

  const _CustomSchema(this._validator);

  @override
  ValidationResult<T> validate(dynamic input, [List<String> path = const []]) {
    return _validator(input, path);
  }
}
