import '../../core/error.dart';
import '../../core/schema.dart';
import '../../core/validation_result.dart';

/// Schema for validating boolean values
class BooleanSchema extends Schema<bool> {
  /// Expected boolean value (if specified)
  final bool? _expectedValue;

  const BooleanSchema({
    super.description,
    super.metadata,
    bool? expectedValue,
  }) : _expectedValue = expectedValue;

  @override
  ValidationResult<bool> validate(dynamic input,
      [List<String> path = const []]) {
    // Type check
    if (input is! bool) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.typeMismatch(
            path: path,
            received: input,
            expected: 'boolean',
          ),
        ),
      );
    }

    // Expected value validation
    if (_expectedValue != null && input != _expectedValue) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: input,
            constraint: 'value must be $_expectedValue',
            code: 'unexpected_boolean_value',
            context: {'expected': _expectedValue, 'actual': input},
          ),
        ),
      );
    }

    return ValidationResult.success(input);
  }

  /// Creates a schema that only accepts true
  BooleanSchema get trueValue => BooleanSchema(
        description: description,
        metadata: metadata,
        expectedValue: true,
      );

  /// Creates a schema that only accepts false
  BooleanSchema get falseValue => BooleanSchema(
        description: description,
        metadata: metadata,
        expectedValue: false,
      );

  /// Checks if boolean is true
  Schema<bool> isTrue() {
    return refine(
      (value) => value == true,
      message: 'must be true',
      code: 'not_true',
    );
  }

  /// Checks if boolean is false
  Schema<bool> isFalse() {
    return refine(
      (value) => value == false,
      message: 'must be false',
      code: 'not_false',
    );
  }

  /// Checks if boolean is truthy (true)
  Schema<bool> truthy() {
    return refine(
      (value) => value == true,
      message: 'must be truthy',
      code: 'not_truthy',
    );
  }

  /// Checks if boolean is falsy (false)
  Schema<bool> falsy() {
    return refine(
      (value) => value == false,
      message: 'must be falsy',
      code: 'not_falsy',
    );
  }

  @override
  String toString() {
    final constraints = <String>[];

    if (_expectedValue != null) constraints.add('expected: $_expectedValue');

    final constraintStr =
        constraints.isNotEmpty ? ' (${constraints.join(', ')})' : '';
    return 'BooleanSchema$constraintStr';
  }
}
