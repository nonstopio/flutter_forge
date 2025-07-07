import '../../core/error.dart';
import '../../core/schema.dart';
import '../../core/validation_result.dart';

/// Schema for validating number values
class NumberSchema extends Schema<num> {
  /// Minimum value constraint
  final num? _min;

  /// Maximum value constraint
  final num? _max;

  /// Exact value constraint
  final num? _exact;

  /// Integer validation flag
  final bool _isInt;

  /// Positive validation flag
  final bool _isPositive;

  /// Negative validation flag
  final bool _isNegative;

  /// Non-negative validation flag
  final bool _isNonNegative;

  /// Non-positive validation flag
  final bool _isNonPositive;

  /// Finite validation flag
  final bool _isFinite;

  /// Safe integer validation flag
  final bool _isSafeInt;

  const NumberSchema({
    super.description,
    super.metadata,
    num? min,
    num? max,
    num? exact,
    bool isInt = false,
    bool isPositive = false,
    bool isNegative = false,
    bool isNonNegative = false,
    bool isNonPositive = false,
    bool isFinite = false,
    bool isSafeInt = false,
  })  : _min = min,
        _max = max,
        _exact = exact,
        _isInt = isInt,
        _isPositive = isPositive,
        _isNegative = isNegative,
        _isNonNegative = isNonNegative,
        _isNonPositive = isNonPositive,
        _isFinite = isFinite,
        _isSafeInt = isSafeInt;

  @override
  ValidationResult<num> validate(dynamic input,
      [List<String> path = const []]) {
    // Type check
    if (input is! num) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.typeMismatch(
            path: path,
            received: input,
            expected: 'number',
          ),
        ),
      );
    }

    num value = input;

    // Exact value validation
    if (_exact != null && value != _exact) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: value,
            constraint: 'exact value of $_exact',
            code: 'exact_value',
            context: {'expected': _exact, 'actual': value},
          ),
        ),
      );
    }

    // Range validations
    if (_min != null && value < _min!) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: value,
            constraint: 'minimum value of $_min',
            code: 'min_value',
            context: {'expected': _min, 'actual': value},
          ),
        ),
      );
    }

    if (_max != null && value > _max!) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: value,
            constraint: 'maximum value of $_max',
            code: 'max_value',
            context: {'expected': _max, 'actual': value},
          ),
        ),
      );
    }

    // Integer validation
    if (_isInt && value != value.toInt()) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: value,
            constraint: 'integer value',
            code: 'not_integer',
          ),
        ),
      );
    }

    // Sign validations
    if (_isPositive && value <= 0) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: value,
            constraint: 'positive value',
            code: 'not_positive',
          ),
        ),
      );
    }

    if (_isNegative && value >= 0) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: value,
            constraint: 'negative value',
            code: 'not_negative',
          ),
        ),
      );
    }

    if (_isNonNegative && value < 0) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: value,
            constraint: 'non-negative value',
            code: 'negative',
          ),
        ),
      );
    }

    if (_isNonPositive && value > 0) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: value,
            constraint: 'non-positive value',
            code: 'positive',
          ),
        ),
      );
    }

    // Finite validation
    if (_isFinite && !value.isFinite) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: value,
            constraint: 'finite value',
            code: 'not_finite',
          ),
        ),
      );
    }

    // Safe integer validation
    if (_isSafeInt && !_isSafeInteger(value)) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: value,
            constraint: 'safe integer value',
            code: 'not_safe_integer',
            context: {
              'min_safe': -9007199254740991,
              'max_safe': 9007199254740991
            },
          ),
        ),
      );
    }

    return ValidationResult.success(value);
  }

  /// Sets minimum value constraint
  NumberSchema min(num value) {
    return NumberSchema(
      description: description,
      metadata: metadata,
      min: value,
      max: _max,
      exact: _exact,
      isInt: _isInt,
      isPositive: _isPositive,
      isNegative: _isNegative,
      isNonNegative: _isNonNegative,
      isNonPositive: _isNonPositive,
      isFinite: _isFinite,
      isSafeInt: _isSafeInt,
    );
  }

  /// Sets maximum value constraint
  NumberSchema max(num value) {
    return NumberSchema(
      description: description,
      metadata: metadata,
      min: _min,
      max: value,
      exact: _exact,
      isInt: _isInt,
      isPositive: _isPositive,
      isNegative: _isNegative,
      isNonNegative: _isNonNegative,
      isNonPositive: _isNonPositive,
      isFinite: _isFinite,
      isSafeInt: _isSafeInt,
    );
  }

  /// Sets exact value constraint
  NumberSchema exact(num value) {
    return NumberSchema(
      description: description,
      metadata: metadata,
      min: _min,
      max: _max,
      exact: value,
      isInt: _isInt,
      isPositive: _isPositive,
      isNegative: _isNegative,
      isNonNegative: _isNonNegative,
      isNonPositive: _isNonPositive,
      isFinite: _isFinite,
      isSafeInt: _isSafeInt,
    );
  }

  /// Sets integer validation
  NumberSchema int() {
    return NumberSchema(
      description: description,
      metadata: metadata,
      min: _min,
      max: _max,
      exact: _exact,
      isInt: true,
      isPositive: _isPositive,
      isNegative: _isNegative,
      isNonNegative: _isNonNegative,
      isNonPositive: _isNonPositive,
      isFinite: _isFinite,
      isSafeInt: _isSafeInt,
    );
  }

  /// Sets positive validation
  NumberSchema positive() {
    return NumberSchema(
      description: description,
      metadata: metadata,
      min: _min,
      max: _max,
      exact: _exact,
      isInt: _isInt,
      isPositive: true,
      isNegative: _isNegative,
      isNonNegative: _isNonNegative,
      isNonPositive: _isNonPositive,
      isFinite: _isFinite,
      isSafeInt: _isSafeInt,
    );
  }

  /// Sets negative validation
  NumberSchema negative() {
    return NumberSchema(
      description: description,
      metadata: metadata,
      min: _min,
      max: _max,
      exact: _exact,
      isInt: _isInt,
      isPositive: _isPositive,
      isNegative: true,
      isNonNegative: _isNonNegative,
      isNonPositive: _isNonPositive,
      isFinite: _isFinite,
      isSafeInt: _isSafeInt,
    );
  }

  /// Sets non-negative validation
  NumberSchema nonNegative() {
    return NumberSchema(
      description: description,
      metadata: metadata,
      min: _min,
      max: _max,
      exact: _exact,
      isInt: _isInt,
      isPositive: _isPositive,
      isNegative: _isNegative,
      isNonNegative: true,
      isNonPositive: _isNonPositive,
      isFinite: _isFinite,
      isSafeInt: _isSafeInt,
    );
  }

  /// Sets non-positive validation
  NumberSchema nonPositive() {
    return NumberSchema(
      description: description,
      metadata: metadata,
      min: _min,
      max: _max,
      exact: _exact,
      isInt: _isInt,
      isPositive: _isPositive,
      isNegative: _isNegative,
      isNonNegative: _isNonNegative,
      isNonPositive: true,
      isFinite: _isFinite,
      isSafeInt: _isSafeInt,
    );
  }

  /// Sets finite validation
  NumberSchema finite() {
    return NumberSchema(
      description: description,
      metadata: metadata,
      min: _min,
      max: _max,
      exact: _exact,
      isInt: _isInt,
      isPositive: _isPositive,
      isNegative: _isNegative,
      isNonNegative: _isNonNegative,
      isNonPositive: _isNonPositive,
      isFinite: true,
      isSafeInt: _isSafeInt,
    );
  }

  /// Sets safe integer validation
  NumberSchema safeInt() {
    return NumberSchema(
      description: description,
      metadata: metadata,
      min: _min,
      max: _max,
      exact: _exact,
      isInt: _isInt,
      isPositive: _isPositive,
      isNegative: _isNegative,
      isNonNegative: _isNonNegative,
      isNonPositive: _isNonPositive,
      isFinite: _isFinite,
      isSafeInt: true,
    );
  }

  /// Sets range validation (min and max)
  NumberSchema range(num min, num max) {
    return NumberSchema(
      description: description,
      metadata: metadata,
      min: min,
      max: max,
      exact: _exact,
      isInt: _isInt,
      isPositive: _isPositive,
      isNegative: _isNegative,
      isNonNegative: _isNonNegative,
      isNonPositive: _isNonPositive,
      isFinite: _isFinite,
      isSafeInt: _isSafeInt,
    );
  }

  /// Checks if number is even
  NumberSchema even() {
    return refine(
      (value) => value % 2 == 0,
      message: 'must be even',
      code: 'not_even',
    ) as NumberSchema;
  }

  /// Checks if number is odd
  NumberSchema odd() {
    return refine(
      (value) => value % 2 != 0,
      message: 'must be odd',
      code: 'not_odd',
    ) as NumberSchema;
  }

  /// Checks if number is a multiple of the given value
  NumberSchema multipleOf(num value) {
    return refine(
      (num n) => n % value == 0,
      message: 'must be a multiple of $value',
      code: 'not_multiple_of',
    ) as NumberSchema;
  }

  /// Checks if number is within the given range (inclusive)
  NumberSchema between(num min, num max) {
    return refine(
      (value) => value >= min && value <= max,
      message: 'must be between $min and $max',
      code: 'not_between',
    ) as NumberSchema;
  }

  /// Checks if number is greater than the given value
  NumberSchema gt(num value) {
    return refine(
      (n) => n > value,
      message: 'must be greater than $value',
      code: 'not_greater_than',
    ) as NumberSchema;
  }

  /// Checks if number is greater than or equal to the given value
  NumberSchema gte(num value) {
    return refine(
      (n) => n >= value,
      message: 'must be greater than or equal to $value',
      code: 'not_greater_than_or_equal',
    ) as NumberSchema;
  }

  /// Checks if number is less than the given value
  NumberSchema lt(num value) {
    return refine(
      (n) => n < value,
      message: 'must be less than $value',
      code: 'not_less_than',
    ) as NumberSchema;
  }

  /// Checks if number is less than or equal to the given value
  NumberSchema lte(num value) {
    return refine(
      (n) => n <= value,
      message: 'must be less than or equal to $value',
      code: 'not_less_than_or_equal',
    ) as NumberSchema;
  }

  /// Checks if number is zero
  NumberSchema zero() {
    return refine(
      (value) => value == 0,
      message: 'must be zero',
      code: 'not_zero',
    ) as NumberSchema;
  }

  /// Checks if number is not zero
  NumberSchema nonZero() {
    return refine(
      (value) => value != 0,
      message: 'must not be zero',
      code: 'zero',
    ) as NumberSchema;
  }

  /// Checks if number is a valid port number (1-65535)
  NumberSchema port() {
    return refine(
      (value) => value >= 1 && value <= 65535 && value == value.toInt(),
      message: 'must be a valid port number (1-65535)',
      code: 'invalid_port',
    ) as NumberSchema;
  }

  /// Checks if number is a valid year (1900-2100)
  NumberSchema year() {
    return refine(
      (value) => value >= 1900 && value <= 2100 && value == value.toInt(),
      message: 'must be a valid year (1900-2100)',
      code: 'invalid_year',
    ) as NumberSchema;
  }

  /// Checks if number is a valid month (1-12)
  NumberSchema month() {
    return refine(
      (value) => value >= 1 && value <= 12 && value == value.toInt(),
      message: 'must be a valid month (1-12)',
      code: 'invalid_month',
    ) as NumberSchema;
  }

  /// Checks if number is a valid day (1-31)
  NumberSchema day() {
    return refine(
      (value) => value >= 1 && value <= 31 && value == value.toInt(),
      message: 'must be a valid day (1-31)',
      code: 'invalid_day',
    ) as NumberSchema;
  }

  /// Checks if number is a valid hour (0-23)
  NumberSchema hour() {
    return refine(
      (value) => value >= 0 && value <= 23 && value == value.toInt(),
      message: 'must be a valid hour (0-23)',
      code: 'invalid_hour',
    ) as NumberSchema;
  }

  /// Checks if number is a valid minute (0-59)
  NumberSchema minute() {
    return refine(
      (value) => value >= 0 && value <= 59 && value == value.toInt(),
      message: 'must be a valid minute (0-59)',
      code: 'invalid_minute',
    ) as NumberSchema;
  }

  /// Checks if number is a valid second (0-59)
  NumberSchema second() {
    return refine(
      (value) => value >= 0 && value <= 59 && value == value.toInt(),
      message: 'must be a valid second (0-59)',
      code: 'invalid_second',
    ) as NumberSchema;
  }

  // Helper methods

  bool _isSafeInteger(num value) {
    return value >= -9007199254740991 &&
        value <= 9007199254740991 &&
        value == value.toInt();
  }

  @override
  String toString() {
    final constraints = <String>[];

    if (_min != null) constraints.add('min: $_min');
    if (_max != null) constraints.add('max: $_max');
    if (_exact != null) constraints.add('exact: $_exact');
    if (_isInt) constraints.add('int');
    if (_isPositive) constraints.add('positive');
    if (_isNegative) constraints.add('negative');
    if (_isNonNegative) constraints.add('nonNegative');
    if (_isNonPositive) constraints.add('nonPositive');
    if (_isFinite) constraints.add('finite');
    if (_isSafeInt) constraints.add('safeInt');

    final constraintStr =
        constraints.isNotEmpty ? ' (${constraints.join(', ')})' : '';
    return 'NumberSchema$constraintStr';
  }
}
