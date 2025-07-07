import '../../core/error.dart';
import '../../core/schema.dart';
import '../../core/validation_result.dart';

/// Schema for validating null values
class NullSchema extends Schema<Null> {
  const NullSchema({
    super.description,
    super.metadata,
  });

  @override
  ValidationResult<Null> validate(dynamic input,
      [List<String> path = const []]) {
    // Type check
    if (input != null) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.typeMismatch(
            path: path,
            received: input,
            expected: 'null',
          ),
        ),
      );
    }

    return ValidationResult.success(null);
  }

  @override
  String toString() => 'NullSchema';
}
