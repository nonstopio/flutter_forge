import '../../core/error.dart';
import '../../core/schema.dart';
import '../../core/validation_result.dart';

/// Schema for validating enum values from a predefined set of options
class EnumSchema<T> extends Schema<T> {
  /// The valid enum values
  final List<T> _values;

  /// Whether to allow case-insensitive matching for strings
  final bool _caseInsensitive;

  const EnumSchema(
    this._values, {
    super.description,
    super.metadata,
    bool caseInsensitive = false,
  }) : _caseInsensitive = caseInsensitive;

  @override
  ValidationResult<T> validate(dynamic input, [List<String> path = const []]) {
    // Direct value check
    if (_values.contains(input)) {
      return ValidationResult.success(input as T);
    }

    // Case-insensitive string matching if enabled
    if (_caseInsensitive && input is String && T == String) {
      final lowerInput = input.toLowerCase();
      for (final value in _values) {
        if (value is String && value.toLowerCase() == lowerInput) {
          return ValidationResult.success(value);
        }
      }
    }

    return ValidationResult.failure(
      ValidationErrorCollection.single(
        ValidationError.constraintViolation(
          path: path,
          received: input,
          constraint: 'one of ${_values.join(', ')}',
          code: 'invalid_enum_value',
          context: {
            'allowedValues': _values,
            'caseInsensitive': _caseInsensitive,
          },
        ),
      ),
    );
  }

  /// Creates a case-insensitive enum schema (for string enums only)
  EnumSchema<T> caseInsensitive() {
    return EnumSchema<T>(
      _values,
      description: description,
      metadata: metadata,
      caseInsensitive: true,
    );
  }

  /// Excludes specific values from the enum
  EnumSchema<T> exclude(List<T> excludeValues) {
    final filteredValues =
        _values.where((v) => !excludeValues.contains(v)).toList();
    if (filteredValues.isEmpty) {
      throw ArgumentError('Cannot exclude all enum values');
    }
    return EnumSchema<T>(
      filteredValues,
      description: description,
      metadata: metadata,
      caseInsensitive: _caseInsensitive,
    );
  }

  /// Includes only specific values from the enum
  EnumSchema<T> include(List<T> includeValues) {
    final filteredValues =
        _values.where((v) => includeValues.contains(v)).toList();
    if (filteredValues.isEmpty) {
      throw ArgumentError(
          'Include values must contain at least one valid enum value');
    }
    return EnumSchema<T>(
      filteredValues,
      description: description,
      metadata: metadata,
      caseInsensitive: _caseInsensitive,
    );
  }

  /// Adds additional values to the enum
  EnumSchema<T> extend(List<T> additionalValues) {
    return EnumSchema<T>(
      [..._values, ...additionalValues],
      description: description,
      metadata: metadata,
      caseInsensitive: _caseInsensitive,
    );
  }

  /// Gets the allowed values
  List<T> get values => List.unmodifiable(_values);

  /// Gets the number of allowed values
  int get length => _values.length;

  /// Checks if the enum contains a specific value
  bool contains(T value) => _values.contains(value);

  /// Checks if the enum is empty
  bool get isEmpty => _values.isEmpty;

  /// Checks if the enum is not empty
  bool get isNotEmpty => _values.isNotEmpty;

  /// Gets the first value
  T get first {
    if (_values.isEmpty) {
      throw StateError('Enum has no values');
    }
    return _values.first;
  }

  /// Gets the last value
  T get last {
    if (_values.isEmpty) {
      throw StateError('Enum has no values');
    }
    return _values.last;
  }

  /// Transforms enum values after validation
  Schema<R> map<R>(R Function(T value) mapper) {
    return transform<R>((value) => mapper(value));
  }

  /// Filters enum based on a condition after validation
  Schema<T> where(bool Function(T value) predicate) {
    return refine(
      predicate,
      message: 'enum value must satisfy condition',
      code: 'enum_condition_failed',
    );
  }

  /// Creates a nullable version of this enum
  @override
  Schema<T?> nullable() {
    return super.nullable();
  }

  /// Creates an optional version of this enum (allows null/undefined)
  @override
  Schema<T?> optional() {
    return super.optional();
  }

  @override
  String toString() {
    final valueStr = _values.take(3).join(', ');
    final suffix = _values.length > 3 ? ', ...' : '';
    final caseStr = _caseInsensitive ? ' (case-insensitive)' : '';
    return 'EnumSchema<$T>[$valueStr$suffix]$caseStr';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EnumSchema<T> &&
        _listEquals(_values, other._values) &&
        _caseInsensitive == other._caseInsensitive;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(_values),
        _caseInsensitive,
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

/// Factory methods for creating common enum schemas
extension EnumFactories on Never {
  /// Creates a string enum schema
  static EnumSchema<String> stringEnum(List<String> values) {
    if (values.isEmpty) {
      throw ArgumentError('String enum must have at least one value');
    }
    return EnumSchema<String>(values);
  }

  /// Creates a numeric enum schema
  static EnumSchema<num> numericEnum(List<num> values) {
    if (values.isEmpty) {
      throw ArgumentError('Numeric enum must have at least one value');
    }
    return EnumSchema<num>(values);
  }

  /// Creates an integer enum schema
  static EnumSchema<int> intEnum(List<int> values) {
    if (values.isEmpty) {
      throw ArgumentError('Integer enum must have at least one value');
    }
    return EnumSchema<int>(values);
  }

  /// Creates a boolean enum schema (typically just true/false)
  static EnumSchema<bool> boolEnum([List<bool>? values]) {
    return EnumSchema<bool>(values ?? [true, false]);
  }

  /// Creates an enum from Dart enum values
  static EnumSchema<T> fromEnum<T extends Enum>(List<T> enumValues) {
    if (enumValues.isEmpty) {
      throw ArgumentError('Enum must have at least one value');
    }
    return EnumSchema<T>(enumValues);
  }

  /// Creates a native values enum (for any type)
  static EnumSchema<T> nativeEnum<T>(List<T> values) {
    if (values.isEmpty) {
      throw ArgumentError('Native enum must have at least one value');
    }
    return EnumSchema<T>(values);
  }
}
