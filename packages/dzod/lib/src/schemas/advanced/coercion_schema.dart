import 'dart:convert';

import '../../core/error.dart';
import '../../core/error_codes.dart';
import '../../core/schema.dart';
import '../../core/validation_result.dart';
import '../primitive/boolean_schema.dart';
import '../primitive/number_schema.dart';
import '../primitive/string_schema.dart';

/// Simple schema class for DateTime validation
class _DateTimeSchema extends Schema<DateTime> {
  const _DateTimeSchema();

  @override
  ValidationResult<DateTime> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is DateTime) {
      return ValidationResult.success(input);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.typeMismatch(
          expected: 'DateTime',
          received: input,
          path: path,
        ),
      ),
    );
  }
}

/// Simple schema class for List validation
class _ListSchema extends Schema<List<dynamic>> {
  const _ListSchema();

  @override
  ValidationResult<List<dynamic>> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is List) {
      return ValidationResult.success(input);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.typeMismatch(
          expected: 'List',
          received: input,
          path: path,
        ),
      ),
    );
  }
}

/// Simple schema class for Set validation
class _SetSchema extends Schema<Set<dynamic>> {
  const _SetSchema();

  @override
  ValidationResult<Set<dynamic>> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is Set) {
      return ValidationResult.success(input);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.typeMismatch(
          expected: 'Set',
          received: input,
          path: path,
        ),
      ),
    );
  }
}

/// Simple schema class for Map validation
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
          expected: 'Map<String, dynamic>',
          received: input,
          path: path,
        ),
      ),
    );
  }
}

/// Simple schema class for BigInt validation
class _BigIntSchema extends Schema<BigInt> {
  const _BigIntSchema();

  @override
  ValidationResult<BigInt> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is BigInt) {
      return ValidationResult.success(input);
    }
    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.typeMismatch(
          expected: 'BigInt',
          received: input,
          path: path,
        ),
      ),
    );
  }
}

/// Schema for automatic type coercion during validation
///
/// Coercion schemas attempt to convert input values to the target type
/// before applying validation. This is useful for parsing strings to numbers,
/// converting booleans to strings, etc.
///
/// Example:
/// ```dart
/// final schema = z.coerce.number();
/// schema.parse('123'); // Returns 123 (number)
/// schema.parse(true);  // Returns 1 (number)
/// ```
class CoercionSchema<T> extends Schema<T> {
  final Schema<T> _targetSchema;
  final T Function(dynamic input) _coercer;
  final bool _strict;

  /// Creates a coercion schema
  ///
  /// [targetSchema] - The schema to validate the coerced value against
  /// [coercer] - Function that performs the type coercion
  /// [strict] - Whether to fail if coercion is not possible (default: false)
  const CoercionSchema(
    this._targetSchema,
    this._coercer, {
    bool strict = false,
    super.description,
    super.metadata,
  }) : _strict = strict;

  @override
  ValidationResult<T> validate(dynamic input, [List<String> path = const []]) {
    try {
      final coercedValue = _coercer(input);
      return _targetSchema.validate(coercedValue, path);
    } catch (e) {
      if (_strict) {
        return ValidationResult.failure(
          ValidationErrorCollection.single(
            ValidationError.constraintViolation(
              constraint: 'Coercion failed: $e',
              received: input,
              path: path,
              code: ValidationErrorCode.coercionFailed.code,
            ),
          ),
        );
      }

      // Fall back to validating original value
      return _targetSchema.validate(input, path);
    }
  }

  @override
  Future<ValidationResult<T>> validateAsync(dynamic input,
      [List<String> path = const []]) async {
    try {
      final coercedValue = _coercer(input);
      return await _targetSchema.validateAsync(coercedValue, path);
    } catch (e) {
      if (_strict) {
        return ValidationResult.failure(
          ValidationErrorCollection.single(
            ValidationError.constraintViolation(
              constraint: 'Coercion failed: $e',
              received: input,
              path: path,
              code: ValidationErrorCode.coercionFailed.code,
            ),
          ),
        );
      }

      // Fall back to validating original value
      return await _targetSchema.validateAsync(input, path);
    }
  }

  /// Gets the target schema
  Schema<T> get targetSchema => _targetSchema;

  /// Checks if strict mode is enabled
  bool get isStrict => _strict;

  /// Creates a copy with strict mode enabled/disabled
  CoercionSchema<T> withStrict(bool strict) {
    return CoercionSchema<T>(
      _targetSchema,
      _coercer,
      strict: strict,
      description: description,
      metadata: metadata,
    );
  }

  @override
  String get schemaType => 'CoercionSchema';

  @override
  String toString() {
    final desc = description != null ? ' ($description)' : '';
    final strictStr = _strict ? ' strict' : '';
    return 'CoercionSchema<$T>$strictStr$desc';
  }
}

/// Coercion utilities for common type conversions
class CoercionUtils {
  const CoercionUtils._();

  /// Coerces input to string with advanced parsing options
  static String coerceToString(
    dynamic input, {
    bool preserveWhitespace = false,
    bool trimWhitespace = false,
    String? joinSeparator,
    bool formatNumbers = false,
    int? numberPrecision,
    bool prettifyJson = false,
  }) {
    if (input == null) return '';
    if (input is String) {
      String result = input;
      if (trimWhitespace) result = result.trim();
      if (!preserveWhitespace) result = result.replaceAll(RegExp(r'\s+'), ' ');
      return result;
    }
    if (input is bool) return input ? 'true' : 'false';
    if (input is num) {
      if (formatNumbers && numberPrecision != null) {
        return input.toStringAsFixed(numberPrecision);
      }
      return input.toString();
    }
    if (input is List) {
      final separator = joinSeparator ?? ',';
      return input
          .map((e) => coerceToString(
                e,
                preserveWhitespace: preserveWhitespace,
                trimWhitespace: trimWhitespace,
                joinSeparator: joinSeparator,
                formatNumbers: formatNumbers,
                numberPrecision: numberPrecision,
                prettifyJson: prettifyJson,
              ))
          .join(separator);
    }
    if (input is Map) {
      if (prettifyJson) {
        try {
          const encoder = JsonEncoder.withIndent('  ');
          return encoder.convert(input);
        } catch (e) {
          return input.toString();
        }
      }
      return input.toString();
    }
    return input.toString();
  }

  /// Advanced string coercion with fallback strategies
  static String coerceToStringAdvanced(
    dynamic input, {
    List<String Function(dynamic)> fallbackStrategies = const [],
    bool strict = false,
  }) {
    try {
      return coerceToString(input);
    } catch (e) {
      if (strict) rethrow;

      // Try fallback strategies
      for (final strategy in fallbackStrategies) {
        try {
          return strategy(input);
        } catch (_) {
          continue;
        }
      }

      // Ultimate fallback
      return input.toString();
    }
  }

  /// Coerces input to number with advanced parsing and validation
  static num coerceToNumber(
    dynamic input, {
    int? precision,
    num? step,
    bool allowInfinity = false,
    bool allowNaN = false,
    num? min,
    num? max,
    bool strict = false,
  }) {
    if (input is num) {
      num value = input;

      // Handle special values
      if (!allowInfinity && value.isInfinite) {
        throw const FormatException('Infinity not allowed');
      }
      if (!allowNaN && value.isNaN) {
        throw const FormatException('NaN not allowed');
      }

      // Apply precision
      if (precision != null && value is double) {
        value = double.parse(value.toStringAsFixed(precision));
      }

      // Apply step validation
      if (step != null && step > 0) {
        final remainder = value % step;
        if (remainder != 0) {
          if (strict) {
            throw FormatException('Value $value does not match step $step');
          }
          // Round to nearest step
          value = (value / step).round() * step;
        }
      }

      // Apply range validation
      if (min != null && value < min) {
        if (strict) {
          throw FormatException('Value $value is below minimum $min');
        }
        value = min;
      }
      if (max != null && value > max) {
        if (strict) {
          throw FormatException('Value $value is above maximum $max');
        }
        value = max;
      }

      return value;
    }

    if (input is bool) return input ? 1 : 0;
    if (input is String) {
      final trimmed = input.trim();
      if (trimmed.isEmpty) return 0;

      // Handle special string values
      if (trimmed.toLowerCase() == 'infinity' || trimmed == '∞') {
        if (allowInfinity) return double.infinity;
        throw const FormatException('Infinity not allowed');
      }
      if (trimmed.toLowerCase() == '-infinity' || trimmed == '-∞') {
        if (allowInfinity) return double.negativeInfinity;
        throw const FormatException('Negative infinity not allowed');
      }
      if (trimmed.toLowerCase() == 'nan') {
        if (allowNaN) return double.nan;
        throw const FormatException('NaN not allowed');
      }

      // Try integer first
      final intValue = int.tryParse(trimmed);
      if (intValue != null) {
        return coerceToNumber(
          intValue,
          precision: precision,
          step: step,
          allowInfinity: allowInfinity,
          allowNaN: allowNaN,
          min: min,
          max: max,
          strict: strict,
        );
      }

      // Try double
      final doubleValue = double.tryParse(trimmed);
      if (doubleValue != null) {
        return coerceToNumber(
          doubleValue,
          precision: precision,
          step: step,
          allowInfinity: allowInfinity,
          allowNaN: allowNaN,
          min: min,
          max: max,
          strict: strict,
        );
      }

      throw FormatException('Cannot coerce "$input" to number');
    }
    throw FormatException('Cannot coerce ${input.runtimeType} to number');
  }

  /// Advanced number coercion with fallback strategies
  static num coerceToNumberAdvanced(
    dynamic input, {
    List<num Function(dynamic)> fallbackStrategies = const [],
    bool strict = false,
  }) {
    try {
      return coerceToNumber(input);
    } catch (e) {
      if (strict) rethrow;

      // Try fallback strategies
      for (final strategy in fallbackStrategies) {
        try {
          return strategy(input);
        } catch (_) {
          continue;
        }
      }

      // Ultimate fallback
      return 0;
    }
  }

  /// Coerces input to integer with advanced options
  static int coerceToInt(
    dynamic input, {
    int? step,
    int? min,
    int? max,
    bool strict = false,
  }) {
    final numValue = coerceToNumber(
      input,
      step: step?.toDouble(),
      min: min?.toDouble(),
      max: max?.toDouble(),
      strict: strict,
    );

    if (numValue is int) return numValue;
    if (numValue is double) return numValue.round();

    throw FormatException('Cannot convert $numValue to integer');
  }

  /// Coerces input to double with advanced precision and validation
  static double coerceToDouble(
    dynamic input, {
    int? precision,
    double? step,
    double? min,
    double? max,
    bool allowInfinity = false,
    bool allowNaN = false,
    bool strict = false,
  }) {
    final numValue = coerceToNumber(
      input,
      precision: precision,
      step: step,
      min: min,
      max: max,
      allowInfinity: allowInfinity,
      allowNaN: allowNaN,
      strict: strict,
    );

    if (numValue is double) return numValue;
    if (numValue is int) return numValue.toDouble();

    throw FormatException('Cannot convert $numValue to double');
  }

  /// Coerces input to boolean
  static bool coerceToBoolean(dynamic input) {
    if (input is bool) return input;
    if (input is num) return input != 0;
    if (input is String) {
      final lower = input.toLowerCase().trim();
      if (lower == 'true' || lower == '1' || lower == 'yes' || lower == 'on') {
        return true;
      }
      if (lower == 'false' ||
          lower == '0' ||
          lower == 'no' ||
          lower == 'off' ||
          lower.isEmpty) {
        return false;
      }
      throw FormatException('Cannot coerce "$input" to boolean');
    }
    if (input == null) return false;
    throw FormatException('Cannot coerce ${input.runtimeType} to boolean');
  }

  /// Coerces input to DateTime
  static DateTime coerceToDateTime(dynamic input) {
    if (input is DateTime) return input;
    if (input is String) {
      final trimmed = input.trim();
      if (trimmed.isEmpty) {
        throw const FormatException('Cannot coerce empty string to DateTime');
      }

      final dateTime = DateTime.tryParse(trimmed);
      if (dateTime != null) return dateTime;

      throw FormatException('Cannot coerce "$input" to DateTime');
    }
    if (input is int) {
      // Assume milliseconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(input);
    }
    throw FormatException('Cannot coerce ${input.runtimeType} to DateTime');
  }

  /// Coerces input to List
  static List<dynamic> coerceToList(dynamic input) {
    if (input is List) return input;
    if (input is String) {
      if (input.isEmpty) return [];
      return input.split(',').map((s) => s.trim()).toList();
    }
    if (input is Set) return input.toList();
    if (input is Map) return input.values.toList();
    return [input];
  }

  /// Coerces input to Set
  static Set<dynamic> coerceToSet(dynamic input) {
    if (input is Set) return input;
    if (input is List) return input.toSet();
    if (input is String) {
      if (input.isEmpty) return <dynamic>{};
      return input.split(',').map((s) => s.trim()).toSet();
    }
    if (input is Map) return input.values.toSet();
    return {input};
  }

  /// Coerces input to Map
  static Map<String, dynamic> coerceToMap(dynamic input) {
    if (input is Map<String, dynamic>) return input;
    if (input is Map) {
      return input.map((key, value) => MapEntry(key.toString(), value));
    }
    if (input is List) {
      final map = <String, dynamic>{};
      for (int i = 0; i < input.length; i++) {
        map[i.toString()] = input[i];
      }
      return map;
    }
    if (input is String && input.isNotEmpty) {
      // Try to parse as JSON
      try {
        // This is a simplified approach - in practice you'd use dart:convert
        throw const FormatException(
            'JSON parsing not implemented in this example');
      } catch (e) {
        return {'value': input};
      }
    }
    throw FormatException('Cannot coerce ${input.runtimeType} to Map');
  }

  /// Coerces input to BigInt
  static BigInt coerceToBigInt(dynamic input) {
    if (input is BigInt) return input;
    if (input is int) return BigInt.from(input);
    if (input is double && input.isFinite) return BigInt.from(input.round());
    if (input is String) {
      final trimmed = input.trim();
      if (trimmed.isEmpty) return BigInt.zero;

      final bigInt = BigInt.tryParse(trimmed);
      if (bigInt != null) return bigInt;

      throw FormatException('Cannot coerce "$input" to BigInt');
    }
    throw FormatException('Cannot coerce ${input.runtimeType} to BigInt');
  }

  /// Automatic type conversion with intelligent fallback strategies
  static T coerceToType<T>(
    dynamic input, {
    required T Function(dynamic) primaryCoercer,
    List<T Function(dynamic)> fallbackStrategies = const [],
    T? defaultValue,
    bool strict = false,
  }) {
    try {
      return primaryCoercer(input);
    } catch (e) {
      if (strict) rethrow;

      // Try fallback strategies
      for (final strategy in fallbackStrategies) {
        try {
          return strategy(input);
        } catch (_) {
          continue;
        }
      }

      // Use default value if provided
      if (defaultValue != null) {
        return defaultValue;
      }

      // Re-throw original error if no fallback worked
      rethrow;
    }
  }

  /// Smart type detection and conversion
  static T smartCoerce<T>(dynamic input, Type targetType) {
    switch (targetType) {
      case const (String):
        return coerceToString(input) as T;
      case const (int):
        return coerceToInt(input) as T;
      case const (double):
        return coerceToDouble(input) as T;
      case const (num):
        return coerceToNumber(input) as T;
      case const (bool):
        return coerceToBoolean(input) as T;
      case const (DateTime):
        return coerceToDateTime(input) as T;
      case const (BigInt):
        return coerceToBigInt(input) as T;
      case const (List):
        return coerceToList(input) as T;
      case const (Set):
        return coerceToSet(input) as T;
      case const (Map):
        return coerceToMap(input) as T;
      default:
        throw FormatException('Cannot coerce to type $targetType');
    }
  }
}

/// Coercion factory methods
class Coerce {
  const Coerce();

  /// Creates a string coercion schema with advanced parsing options
  CoercionSchema<String> string({
    bool strict = false,
    bool preserveWhitespace = false,
    bool trimWhitespace = false,
    String? joinSeparator,
    bool formatNumbers = false,
    int? numberPrecision,
    bool prettifyJson = false,
    List<String Function(dynamic)> fallbackStrategies = const [],
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return CoercionSchema<String>(
      const StringSchema(),
      (input) => CoercionUtils.coerceToString(
        input,
        preserveWhitespace: preserveWhitespace,
        trimWhitespace: trimWhitespace,
        joinSeparator: joinSeparator,
        formatNumbers: formatNumbers,
        numberPrecision: numberPrecision,
        prettifyJson: prettifyJson,
      ),
      strict: strict,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a number coercion schema with advanced parsing and validation
  CoercionSchema<num> number({
    bool strict = false,
    int? precision,
    num? step,
    bool allowInfinity = false,
    bool allowNaN = false,
    num? min,
    num? max,
    List<num Function(dynamic)> fallbackStrategies = const [],
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return CoercionSchema<num>(
      const NumberSchema(),
      (input) => CoercionUtils.coerceToNumber(
        input,
        precision: precision,
        step: step,
        allowInfinity: allowInfinity,
        allowNaN: allowNaN,
        min: min,
        max: max,
        strict: strict,
      ),
      strict: strict,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates an integer coercion schema with advanced validation
  CoercionSchema<int> integer({
    bool strict = false,
    int? step,
    int? min,
    int? max,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return CoercionSchema<int>(
      const NumberSchema().transform((n) => n.round()),
      (input) => CoercionUtils.coerceToInt(
        input,
        step: step,
        min: min,
        max: max,
        strict: strict,
      ),
      strict: strict,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a double coercion schema with precision and validation
  CoercionSchema<double> decimal({
    bool strict = false,
    int? precision,
    double? step,
    double? min,
    double? max,
    bool allowInfinity = false,
    bool allowNaN = false,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return CoercionSchema<double>(
      const NumberSchema().transform((n) => n.toDouble()),
      (input) => CoercionUtils.coerceToDouble(
        input,
        precision: precision,
        step: step,
        min: min,
        max: max,
        allowInfinity: allowInfinity,
        allowNaN: allowNaN,
        strict: strict,
      ),
      strict: strict,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a boolean coercion schema
  CoercionSchema<bool> boolean({
    bool strict = false,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return CoercionSchema<bool>(
      const BooleanSchema(),
      CoercionUtils.coerceToBoolean,
      strict: strict,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a DateTime coercion schema
  CoercionSchema<DateTime> date({
    bool strict = false,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return CoercionSchema<DateTime>(
      const _DateTimeSchema(),
      CoercionUtils.coerceToDateTime,
      strict: strict,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a BigInt coercion schema
  CoercionSchema<BigInt> bigInt({
    bool strict = false,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return CoercionSchema<BigInt>(
      const _BigIntSchema(),
      CoercionUtils.coerceToBigInt,
      strict: strict,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a List coercion schema
  CoercionSchema<List<dynamic>> list({
    bool strict = false,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return CoercionSchema<List<dynamic>>(
      const _ListSchema(),
      CoercionUtils.coerceToList,
      strict: strict,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a Set coercion schema
  CoercionSchema<Set<dynamic>> set({
    bool strict = false,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return CoercionSchema<Set<dynamic>>(
      const _SetSchema(),
      CoercionUtils.coerceToSet,
      strict: strict,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a Map coercion schema
  CoercionSchema<Map<String, dynamic>> map({
    bool strict = false,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return CoercionSchema<Map<String, dynamic>>(
      const _MapSchema(),
      CoercionUtils.coerceToMap,
      strict: strict,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a smart coercion schema that automatically detects target type
  CoercionSchema<T> smart<T>(
    Type targetType, {
    bool strict = false,
    List<T Function(dynamic)> fallbackStrategies = const [],
    T? defaultValue,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return CoercionSchema<T>(
      _createTargetSchema<T>(targetType),
      (input) => CoercionUtils.coerceToType<T>(
        input,
        primaryCoercer: (inp) => CoercionUtils.smartCoerce<T>(inp, targetType),
        fallbackStrategies: fallbackStrategies,
        defaultValue: defaultValue,
        strict: strict,
      ),
      strict: strict,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a target schema for the given type
  Schema<T> _createTargetSchema<T>(Type targetType) {
    switch (targetType) {
      case const (String):
        return const StringSchema() as Schema<T>;
      case const (int):
        return const NumberSchema().transform((n) => n.round()) as Schema<T>;
      case const (double):
        return const NumberSchema().transform((n) => n.toDouble()) as Schema<T>;
      case const (num):
        return const NumberSchema() as Schema<T>;
      case const (bool):
        return const BooleanSchema() as Schema<T>;
      case const (DateTime):
        return const _DateTimeSchema() as Schema<T>;
      case const (BigInt):
        return const _BigIntSchema() as Schema<T>;
      case const (List):
        return const _ListSchema() as Schema<T>;
      case const (Set):
        return const _SetSchema() as Schema<T>;
      case const (Map):
        return const _MapSchema() as Schema<T>;
      default:
        throw ArgumentError('Unsupported target type: $targetType');
    }
  }
}
