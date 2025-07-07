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
/// final schema = Z.coerce.number();
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

  /// Coerces input to string
  static String coerceToString(dynamic input) {
    if (input == null) return '';
    if (input is String) return input;
    if (input is bool) return input ? 'true' : 'false';
    if (input is num) return input.toString();
    if (input is List) return input.join(',');
    if (input is Map) return input.toString();
    return input.toString();
  }

  /// Coerces input to number
  static num coerceToNumber(dynamic input) {
    if (input is num) return input;
    if (input is bool) return input ? 1 : 0;
    if (input is String) {
      final trimmed = input.trim();
      if (trimmed.isEmpty) return 0;

      // Try integer first
      final intValue = int.tryParse(trimmed);
      if (intValue != null) return intValue;

      // Try double
      final doubleValue = double.tryParse(trimmed);
      if (doubleValue != null) return doubleValue;

      throw FormatException('Cannot coerce "$input" to number');
    }
    throw FormatException('Cannot coerce ${input.runtimeType} to number');
  }

  /// Coerces input to integer
  static int coerceToInt(dynamic input) {
    if (input is int) return input;
    if (input is double) return input.round();
    if (input is bool) return input ? 1 : 0;
    if (input is String) {
      final trimmed = input.trim();
      if (trimmed.isEmpty) return 0;

      final intValue = int.tryParse(trimmed);
      if (intValue != null) return intValue;

      // Try parsing as double and converting
      final doubleValue = double.tryParse(trimmed);
      if (doubleValue != null) return doubleValue.round();

      throw FormatException('Cannot coerce "$input" to integer');
    }
    throw FormatException('Cannot coerce ${input.runtimeType} to integer');
  }

  /// Coerces input to double
  static double coerceToDouble(dynamic input) {
    if (input is double) return input;
    if (input is int) return input.toDouble();
    if (input is bool) return input ? 1.0 : 0.0;
    if (input is String) {
      final trimmed = input.trim();
      if (trimmed.isEmpty) return 0.0;

      final doubleValue = double.tryParse(trimmed);
      if (doubleValue != null) return doubleValue;

      throw FormatException('Cannot coerce "$input" to double');
    }
    throw FormatException('Cannot coerce ${input.runtimeType} to double');
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
}

/// Coercion factory methods
class Coerce {
  const Coerce();

  /// Creates a string coercion schema
  CoercionSchema<String> string({
    bool strict = false,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return CoercionSchema<String>(
      const StringSchema(),
      CoercionUtils.coerceToString,
      strict: strict,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a number coercion schema
  CoercionSchema<num> number({
    bool strict = false,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return CoercionSchema<num>(
      const NumberSchema(),
      CoercionUtils.coerceToNumber,
      strict: strict,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates an integer coercion schema
  CoercionSchema<int> integer({
    bool strict = false,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return CoercionSchema<int>(
      const NumberSchema().transform((n) => n.round()),
      CoercionUtils.coerceToInt,
      strict: strict,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a double coercion schema
  CoercionSchema<double> decimal({
    bool strict = false,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return CoercionSchema<double>(
      const NumberSchema().transform((n) => n.toDouble()),
      CoercionUtils.coerceToDouble,
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
}
