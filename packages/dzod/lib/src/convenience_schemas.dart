import 'package:dzod/dzod.dart';

/// Convenience class that provides factory methods for creating schemas
///
/// This class provides a Zod-like API for creating schemas:
/// ```dart
/// final userSchema = z.object({
///   'name': z.string().min(2).max(50),
///   'email': z.string().email(),
///   'age': z.number().min(18).max(120),
///   'isActive': z.boolean(),
/// });
/// ```
class DZod {
  DZod._();

  static DZod instance = DZod._();

  /// Creates a string schema
  ///
  /// Supports TypeScript Zod-style custom error messages:
  /// ```dart
  /// z.string(error: (issue) => issue.input == null
  ///   ? "String is required"
  ///   : "Invalid string: ${issue.input}");
  /// ```
  StringSchema string({ErrorMessageFunction? error}) {
    return StringSchema(customErrorGenerator: error);
  }

  /// Creates a number schema
  ///
  /// Supports TypeScript Zod-style custom error messages:
  /// ```dart
  /// z.number(error: (issue) => "Expected number, got: ${issue.input}");
  /// ```
  NumberSchema number({ErrorMessageFunction? error}) {
    return NumberSchema(customErrorGenerator: error);
  }

  /// Creates a boolean schema
  ///
  /// Supports TypeScript Zod-style custom error messages:
  /// ```dart
  /// z.boolean(error: (issue) => "Expected true or false, got: ${issue.input}");
  /// ```
  BooleanSchema boolean({ErrorMessageFunction? error}) {
    return BooleanSchema(customErrorGenerator: error);
  }

  /// Creates a null schema
  NullSchema null_() => const NullSchema();

  /// Creates a null schema (alias for null_)
  NullSchema get nullValue => const NullSchema();

  /// Creates an array schema with element validation
  ArraySchema<T> array<T>(Schema<T> elementSchema) =>
      ArraySchema<T>(elementSchema);

  /// Creates a tuple schema with fixed-length typed elements
  TupleSchema<List<dynamic>> tuple(List<Schema<dynamic>> elementSchemas) =>
      TupleSchema<List<dynamic>>(elementSchemas);

  /// Creates an enum schema from a list of values
  EnumSchema<T> enum_<T>(List<T> values) => EnumSchema<T>(values);

  /// Creates a true boolean schema
  BooleanSchema get trueValue => const BooleanSchema(expectedValue: true);

  /// Creates a false boolean schema
  BooleanSchema get falseValue => const BooleanSchema(expectedValue: false);

  /// Creates a literal schema for any value
  Schema<T> literal<T>(T value) {
    return _LiteralSchema<T>(value);
  }

  /// Creates a union schema from multiple schemas
  Schema<T> union<T>(List<Schema<T>> schemas) {
    return Schema.union(schemas);
  }

  /// Creates a discriminated union schema for efficient union parsing
  DiscriminatedUnionSchema<T> discriminatedUnion<T>(
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
  PipelineSchema<TInput, TOutput> pipeline<TInput, TOutput>(
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
  RecursiveSchema<T> recursive<T>(
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
  Coerce coerce = const Coerce();

  /// Creates an intersection schema from multiple schemas
  Schema<T> intersection<T>(List<Schema<T>> schemas) {
    return Schema.intersection(schemas);
  }

  /// Creates a lazy schema that is evaluated only when needed
  Schema<T> lazy<T>(Schema<T> Function() schemaFactory) {
    return Schema.lazy(schemaFactory);
  }

  /// Creates a custom schema with a validation function
  Schema<T> custom<T>(
      ValidationResult<T> Function(dynamic input, List<String> path)
          validator) {
    return _CustomSchema<T>(validator);
  }

  /// Creates an object schema with comprehensive manipulation methods
  ObjectSchema object(
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
  Schema<dynamic> any() => const _AnySchema();

  /// Creates an unknown schema that accepts any value but provides better type safety
  Schema<dynamic> unknown() => const _UnknownSchema();

  /// Creates a never schema that never accepts any value
  Schema<Never> never() => const _NeverSchema();

  /// Creates a void schema that only accepts undefined/null
  Schema<void> void_() => const _VoidSchema();

  /// Creates a void schema (alias for void_)
  Schema<void> get voidValue => const _VoidSchema();

  /// Creates a date schema
  Schema<DateTime> date() => const _DateSchema();

  /// Creates a bigint schema
  Schema<BigInt> bigint() => const _BigIntSchema();

  /// Creates a symbol schema
  Schema<Symbol> symbol() => const _SymbolSchema();

  /// Creates a function schema
  Schema<Function> function() => const _FunctionSchema();

  /// Creates a regex schema
  Schema<RegExp> regex() => const _RegexSchema();

  /// Creates a map schema
  Schema<Map<String, dynamic>> map() => const _MapSchema();

  /// Creates a set schema
  Schema<Set<dynamic>> set() => const _SetSchema();

  /// Creates a record schema for key-value pairs
  RecordSchema<String, dynamic> record([Schema<dynamic>? valueSchema]) =>
      RecordSchema<String, dynamic>(valueSchema: valueSchema);

  /// Creates a promise schema (for async values)
  Schema<Future<dynamic>> promise() => const _PromiseSchema();

  /// Creates an undefined schema
  Schema<void> undefined() => const _UndefinedSchema();

  /// Creates a nan schema
  Schema<double> nan() => const _NanSchema();

  /// Creates an infinity schema
  Schema<double> infinity() => const _InfinitySchema();

  /// Creates a negative infinity schema
  Schema<double> negativeInfinity() => const _NegativeInfinitySchema();

  /// Creates a positive infinity schema
  Schema<double> positiveInfinity() => const _PositiveInfinitySchema();

  /// Creates a zero schema
  Schema<num> zero() => const _ZeroSchema();

  /// Creates a one schema
  Schema<num> one() => const _OneSchema();

  /// Creates a negative one schema
  Schema<num> negativeOne() => const _NegativeOneSchema();

  /// Creates an empty string schema
  StringSchema emptyString() => const StringSchema(exactLength: 0);

  /// Creates a non-empty string schema
  Schema<String> nonEmptyString() => const StringSchema().nonempty();

  /// Creates an email string schema
  StringSchema email() => const StringSchema(isEmail: true);

  /// Creates a URL string schema
  StringSchema url() => const StringSchema(isUrl: true);

  /// Creates a UUID string schema
  StringSchema uuid() => const StringSchema(isUuid: true);

  /// Creates an integer schema
  NumberSchema integer() => const NumberSchema(isInt: true);

  /// Creates a positive number schema
  NumberSchema positive() => const NumberSchema(isPositive: true);

  /// Creates a negative number schema
  NumberSchema negative() => const NumberSchema(isNegative: true);

  /// Creates a non-negative number schema
  NumberSchema nonNegative() => const NumberSchema(isNonNegative: true);

  /// Creates a non-positive number schema
  NumberSchema nonPositive() => const NumberSchema(isNonPositive: true);

  /// Creates a finite number schema
  NumberSchema finite() => const NumberSchema(isFinite: true);

  /// Creates a safe integer schema
  NumberSchema safeInt() => const NumberSchema(isSafeInt: true);

  /// Creates a port number schema
  Schema<num> port() => const NumberSchema().port();

  /// Creates a year schema
  Schema<num> year() => const NumberSchema().year();

  /// Creates a month schema
  Schema<num> month() => const NumberSchema().month();

  /// Creates a day schema
  Schema<num> day() => const NumberSchema().day();

  /// Creates an hour schema
  Schema<num> hour() => const NumberSchema().hour();

  /// Creates a minute schema
  Schema<num> minute() => const NumberSchema().minute();

  /// Creates a second schema
  Schema<num> second() => const NumberSchema().second();

  /// Creates a transform schema that can be used in pipelines
  TransformSchema<T, R> transform<T, R>(R Function(T) transformer) =>
      TransformSchema<T, R>(_TypedSchema<T>(), transformer);

  /// Creates a refine schema that can be used in pipelines
  RefineSchema<T> refine<T>(bool Function(T) validator,
          {String? message, String? code}) =>
      RefineSchema<T>(_TypedSchema<T>(), validator,
          message: message, code: code);

  /// Creates an async refine schema that can be used in pipelines
  AsyncRefineSchema<T> refineAsync<T>(Future<bool> Function(T) validator,
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
