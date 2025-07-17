import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('ValidationResult', () {
    group('ValidationSuccess', () {
      test('should create successful result with data', () {
        const result = ValidationResult.success('test');
        expect(result.isSuccess, true);
        expect(result.isFailure, false);
        expect(result.data, 'test');
        expect(result.errors, null);
      });

      test('should map successful result', () {
        const result = ValidationResult.success('test');
        final mapped = result.map((data) => data.toUpperCase());
        expect(mapped.isSuccess, true);
        expect(mapped.data, 'TEST');
      });

      test('should mapOr successful result', () {
        const result = ValidationResult.success('test');
        final mapped = result.mapOr(
          (data) => data.toUpperCase(),
          (errors) => 'ERROR',
        );
        expect(mapped.isSuccess, true);
        expect(mapped.data, 'TEST');
      });

      test('should flatMap successful result', () {
        const result = ValidationResult.success('test');
        final mapped =
            result.flatMap((data) => ValidationResult.success(data.length));
        expect(mapped.isSuccess, true);
        expect(mapped.data, 4);
      });

      test('should flatMap to failure result', () {
        const result = ValidationResult.success('test');
        final errorCollection = ValidationErrorCollection.single(
          ValidationError.simple(
              message: 'error', path: [], received: 'invalid'),
        );
        final mapped =
            result.flatMap((data) => ValidationResult.failure(errorCollection));
        expect(mapped.isFailure, true);
        expect(mapped.errors, errorCollection);
      });

      test('should execute onSuccess callback', () {
        const result = ValidationResult.success('test');
        String? capturedData;
        final returned = result.onSuccess((data) {
          capturedData = data;
        });
        expect(capturedData, 'test');
        expect(returned, result);
      });

      test('should not execute onFailure callback', () {
        const result = ValidationResult.success('test');
        bool callbackExecuted = false;
        final returned = result.onFailure((errors) {
          callbackExecuted = true;
        });
        expect(callbackExecuted, false);
        expect(returned, result);
      });

      test('should unwrap successfully', () {
        const result = ValidationResult.success('test');
        expect(result.unwrap(), 'test');
      });

      test('should unwrapOr return data', () {
        const result = ValidationResult.success('test');
        expect(result.unwrapOr('default'), 'test');
      });

      test('should unwrapOrElse return data', () {
        const result = ValidationResult.success('test');
        expect(result.unwrapOrElse((errors) => 'default'), 'test');
      });

      test('should convert to nullable', () {
        const result = ValidationResult.success('test');
        expect(result.toNullable(), 'test');
      });

      test('should convert to Either left', () {
        const result = ValidationResult.success('test');
        final either = result.toEither();
        expect(either.isLeft, true);
        expect(either.left, 'test');
      });

      test('should implement equality correctly', () {
        const result1 = ValidationResult.success('test');
        const result2 = ValidationResult.success('test');
        const result3 = ValidationResult.success('different');

        expect(result1 == result2, true);
        expect(result1 == result3, false);
      });

      test('should implement hashCode correctly', () {
        const result1 = ValidationResult.success('test');
        const result2 = ValidationResult.success('test');
        const result3 = ValidationResult.success('different');

        expect(result1.hashCode == result2.hashCode, true);
        expect(result1.hashCode == result3.hashCode, false);
      });

      test('should implement toString correctly', () {
        const result = ValidationResult.success('test');
        expect(result.toString(), 'ValidationSuccess(test)');
      });
    });

    group('ValidationFailure', () {
      late ValidationErrorCollection errorCollection;

      setUp(() {
        errorCollection = ValidationErrorCollection.single(
          ValidationError.simple(
              message: 'test error', path: [], received: 'invalid'),
        );
      });

      test('should create failed result with errors', () {
        final result = ValidationResult.failure(errorCollection);
        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.data, null);
        expect(result.errors, errorCollection);
      });

      test('should map failed result to failure', () {
        final result = ValidationResult.failure(errorCollection);
        final mapped = result.map((data) => data.toString().toUpperCase());
        expect(mapped.isFailure, true);
        expect(mapped.errors, errorCollection);
      });

      test('should mapOr failed result using errorMapper', () {
        final result = ValidationResult.failure(errorCollection);
        final mapped = result.mapOr(
          (data) => data.toString().toUpperCase(),
          (errors) => 'ERROR_MAPPED',
        );
        expect(mapped.isSuccess, true);
        expect(mapped.data, 'ERROR_MAPPED');
      });

      test('should flatMap failed result to failure', () {
        final result = ValidationResult.failure(errorCollection);
        final mapped = result.flatMap(
            (data) => ValidationResult.success(data.toString().length));
        expect(mapped.isFailure, true);
        expect(mapped.errors, errorCollection);
      });

      test('should not execute onSuccess callback', () {
        final result = ValidationResult.failure(errorCollection);
        bool callbackExecuted = false;
        final returned = result.onSuccess((data) {
          callbackExecuted = true;
        });
        expect(callbackExecuted, false);
        expect(returned, result);
      });

      test('should execute onFailure callback', () {
        final result = ValidationResult.failure(errorCollection);
        ValidationErrorCollection? capturedErrors;
        final returned = result.onFailure((errors) {
          capturedErrors = errors;
        });
        expect(capturedErrors, errorCollection);
        expect(returned, result);
      });

      test('should throw ValidationException on unwrap', () {
        final result = ValidationResult.failure(errorCollection);
        expect(() => result.unwrap(), throwsA(isA<ValidationException>()));
      });

      test('should unwrapOr return default value', () {
        final result = ValidationResult.failure(errorCollection);
        expect(result.unwrapOr('default'), 'default');
      });

      test('should unwrapOrElse return computed default', () {
        final result = ValidationResult.failure(errorCollection);
        expect(result.unwrapOrElse((errors) => 'computed_default'),
            'computed_default');
      });

      test('should convert to null', () {
        final result = ValidationResult.failure(errorCollection);
        expect(result.toNullable(), null);
      });

      test('should convert to Either right', () {
        final result = ValidationResult.failure(errorCollection);
        final either = result.toEither();
        expect(either.isRight, true);
        expect(either.right, errorCollection);
      });

      test('should implement equality correctly', () {
        final result1 = ValidationResult.failure(errorCollection);
        final result2 = ValidationResult.failure(errorCollection);
        final otherErrorCollection = ValidationErrorCollection.single(
          ValidationError.simple(
              message: 'other error', path: [], received: 'invalid'),
        );
        final result3 = ValidationResult.failure(otherErrorCollection);

        expect(result1 == result2, true);
        expect(result1 == result3, false);
      });

      test('should implement hashCode correctly', () {
        final result1 = ValidationResult.failure(errorCollection);
        final result2 = ValidationResult.failure(errorCollection);
        final otherErrorCollection = ValidationErrorCollection.single(
          ValidationError.simple(
              message: 'other error', path: [], received: 'invalid'),
        );
        final result3 = ValidationResult.failure(otherErrorCollection);

        expect(result1.hashCode == result2.hashCode, true);
        expect(result1.hashCode == result3.hashCode, false);
      });

      test('should implement toString correctly', () {
        final result = ValidationResult.failure(errorCollection);
        expect(result.toString(), 'ValidationFailure($errorCollection)');
      });
    });
  });

  group('ValidationException', () {
    test('should create with message', () {
      const exception = ValidationException('test message');
      expect(exception.message, 'test message');
    });

    test('should implement toString correctly', () {
      const exception = ValidationException('test message');
      expect(exception.toString(), 'ValidationException: test message');
    });
  });

  group('Either', () {
    group('left', () {
      test('should create left value', () {
        final either = Either.left('left_value');
        expect(either.isLeft, true);
        expect(either.isRight, false);
        expect(either.left, 'left_value');
      });

      test('should throw when accessing right value', () {
        final either = Either.left('left_value');
        expect(() => either.right, throwsA(isA<StateError>()));
      });

      test('should map left value', () {
        final either = Either.left('left_value');
        final mapped = either.mapLeft((value) => value.toUpperCase());
        expect(mapped.isLeft, true);
        expect(mapped.left, 'LEFT_VALUE');
      });

      test('should not map right value', () {
        final either = Either.left('left_value');
        final mapped =
            either.mapRight((value) => value.toString().toUpperCase());
        expect(mapped.isLeft, true);
        expect(mapped.left, 'left_value');
      });

      test('should fold using left mapper', () {
        final either = Either.left('left_value');
        final result = either.fold(
          (left) => left.toUpperCase(),
          (right) => right.toString(),
        );
        expect(result, 'LEFT_VALUE');
      });

      test('should implement equality correctly', () {
        final either1 = Either.left('left_value');
        final either2 = Either.left('left_value');
        final either3 = Either.left('different');
        final either4 = Either.right('left_value');

        expect(either1 == either2, true);
        expect(either1 == either3, false);
        expect(either1 == either4, false);
      });

      test('should implement hashCode correctly', () {
        final either1 = Either.left('left_value');
        final either2 = Either.left('left_value');
        final either3 = Either.left('different');

        expect(either1.hashCode == either2.hashCode, true);
        expect(either1.hashCode == either3.hashCode, false);
      });

      test('should implement toString correctly', () {
        final either = Either.left('left_value');
        expect(either.toString(), 'Either.left(left_value)');
      });
    });

    group('right', () {
      test('should create right value', () {
        final either = Either.right('right_value');
        expect(either.isLeft, false);
        expect(either.isRight, true);
        expect(either.right, 'right_value');
      });

      test('should throw when accessing left value', () {
        final either = Either.right('right_value');
        expect(() => either.left, throwsA(isA<StateError>()));
      });

      test('should not map left value', () {
        final either = Either.right('right_value');
        final mapped =
            either.mapLeft((value) => value.toString().toUpperCase());
        expect(mapped.isRight, true);
        expect(mapped.right, 'right_value');
      });

      test('should map right value', () {
        final either = Either.right('right_value');
        final mapped = either.mapRight((value) => value.toUpperCase());
        expect(mapped.isRight, true);
        expect(mapped.right, 'RIGHT_VALUE');
      });

      test('should fold using right mapper', () {
        final either = Either.right('right_value');
        final result = either.fold(
          (left) => left.toString(),
          (right) => right.toUpperCase(),
        );
        expect(result, 'RIGHT_VALUE');
      });

      test('should implement equality correctly', () {
        final either1 = Either.right('right_value');
        final either2 = Either.right('right_value');
        final either3 = Either.right('different');
        final either4 = Either.left('right_value');

        expect(either1 == either2, true);
        expect(either1 == either3, false);
        expect(either1 == either4, false);
      });

      test('should implement hashCode correctly', () {
        final either1 = Either.right('right_value');
        final either2 = Either.right('right_value');
        final either3 = Either.right('different');

        expect(either1.hashCode == either2.hashCode, true);
        expect(either1.hashCode == either3.hashCode, false);
      });

      test('should implement toString correctly', () {
        final either = Either.right('right_value');
        expect(either.toString(), 'Either.right(right_value)');
      });
    });
  });

  group('ValidationResultExtensions', () {
    test('should provide human-readable success message', () {
      const result = ValidationResult.success('test');
      expect(result.toHumanReadable(), '✅ Validation successful');
    });

    test('should provide human-readable failure message', () {
      final errorCollection = ValidationErrorCollection.single(
        ValidationError.simple(
            message: 'test error', path: [], received: 'invalid'),
      );
      final result = ValidationResult.failure(errorCollection);
      final readable = result.toHumanReadable();
      expect(readable, contains('❌ Validation failed:'));
      expect(readable, contains('• test error'));
    });

    test('should handle multiple errors in human-readable format', () {
      final errors = [
        ValidationError.simple(
            message: 'first error', path: [], received: 'invalid1'),
        ValidationError.simple(
            message: 'second error', path: [], received: 'invalid2'),
      ];
      final errorCollection = ValidationErrorCollection(errors);
      final result = ValidationResult.failure(errorCollection);
      final readable = result.toHumanReadable();
      expect(readable, contains('• first error'));
      expect(readable, contains('• second error'));
    });
  });

  group('ValidationErrorCollectionExtensions', () {
    test('should provide detailed error information', () {
      const error = ValidationError(
        message: 'test error',
        path: ['field'],
        received: 'invalid_value',
        expected: 'valid_value',
      );
      final errorCollection = ValidationErrorCollection.single(error);
      final details = errorCollection.details('input_value');

      expect(details, contains('❌ Validation failed for input: "input_value"'));
      expect(details, contains('Input type: String'));
      expect(details, contains('At field: test error'));
      expect(details, contains('Expected: valid_value'));
      expect(details, contains('Received: invalid_value'));
    });

    test('should handle root path errors', () {
      final error = ValidationError.simple(
        message: 'root error',
        path: [],
        received: 'invalid_value',
      );
      final errorCollection = ValidationErrorCollection.single(error);
      final details = errorCollection.details('input_value');

      expect(details, contains('At root: root error'));
    });

    test('should handle errors with expected "valid value"', () {
      final error = ValidationError.simple(
        message: 'test error',
        path: ['field'],
        received: 'invalid_value',
      );
      final errorCollection = ValidationErrorCollection.single(error);
      final details = errorCollection.details('input_value');

      expect(details, contains('At field: test error'));
      expect(details, isNot(contains('Expected: valid value')));
    });

    test('should handle errors where received equals input value', () {
      const error = ValidationError(
        message: 'test error',
        path: ['field'],
        received: 'input_value',
        expected: 'valid_value',
      );
      final errorCollection = ValidationErrorCollection.single(error);
      final details = errorCollection.details('input_value');

      expect(details, contains('At field: test error'));
      expect(details, contains('Expected: valid_value'));
      expect(details, isNot(contains('Received: input_value')));
    });

    test('should handle multiple errors with different paths', () {
      final errors = [
        const ValidationError(
          message: 'first error',
          path: ['field1'],
          received: 'invalid1',
          expected: 'valid1',
        ),
        const ValidationError(
          message: 'second error',
          path: ['field2', 'nested'],
          received: 'invalid2',
          expected: 'valid2',
        ),
      ];
      final errorCollection = ValidationErrorCollection(errors);
      final details = errorCollection.details('input_value');

      expect(details, contains('At field1: first error'));
      expect(details, contains('At field2.nested: second error'));
      expect(details, contains('Expected: valid1'));
      expect(details, contains('Expected: valid2'));
    });
  });
}
