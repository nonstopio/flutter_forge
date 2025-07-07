import 'package:test/test.dart';
import 'package:zod_bhai/zod_bhai.dart';

void main() {
  group('Basic Schema Tests', () {
    group('String Schema', () {
      test('validates string values', () {
        final schema = Z.string();
        final result = schema.validate('hello');

        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });

      test('rejects non-string values', () {
        final schema = Z.string();
        final result = schema.validate(123);

        expect(result.isFailure, true);
        expect(
            result.errors?.errors.first.message, contains('Expected string'));
      });

      test('validates min length', () {
        final schema = Z.string().min(3);
        final result = schema.validate('ab');

        expect(result.isFailure, true);
        expect(result.errors?.errors.first.message, contains('minimum length'));
      });

      test('validates max length', () {
        final schema = Z.string().max(5);
        final result = schema.validate('hello world');

        expect(result.isFailure, true);
        expect(result.errors?.errors.first.message, contains('maximum length'));
      });

      test('validates email', () {
        final schema = Z.string().email();
        final validResult = schema.validate('test@example.com');
        final invalidResult = schema.validate('invalid-email');

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
      });

      test('validates URL', () {
        final schema = Z.string().url();
        final validResult = schema.validate('https://example.com');
        final invalidResult = schema.validate('not-a-url');

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
      });
    });

    group('Number Schema', () {
      test('validates number values', () {
        final schema = Z.number();
        final result = schema.validate(42);

        expect(result.isSuccess, true);
        expect(result.data, 42);
      });

      test('rejects non-number values', () {
        final schema = Z.number();
        final result = schema.validate('not a number');

        expect(result.isFailure, true);
        expect(
            result.errors?.errors.first.message, contains('Expected number'));
      });

      test('validates min value', () {
        final schema = Z.number().min(10);
        final result = schema.validate(5);

        expect(result.isFailure, true);
        expect(result.errors?.errors.first.message, contains('minimum value'));
      });

      test('validates max value', () {
        final schema = Z.number().max(100);
        final result = schema.validate(150);

        expect(result.isFailure, true);
        expect(result.errors?.errors.first.message, contains('maximum value'));
      });

      test('validates positive numbers', () {
        final schema = Z.number().positive();
        final validResult = schema.validate(42);
        final invalidResult = schema.validate(-5);

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
      });

      test('validates integers', () {
        final schema = Z.number().int();
        final validResult = schema.validate(42);
        final invalidResult = schema.validate(3.14);

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
      });
    });

    group('Boolean Schema', () {
      test('validates boolean values', () {
        final schema = Z.boolean();
        final trueResult = schema.validate(true);
        final falseResult = schema.validate(false);

        expect(trueResult.isSuccess, true);
        expect(trueResult.data, true);
        expect(falseResult.isSuccess, true);
        expect(falseResult.data, false);
      });

      test('rejects non-boolean values', () {
        final schema = Z.boolean();
        final result = schema.validate('not a boolean');

        expect(result.isFailure, true);
        expect(
            result.errors?.errors.first.message, contains('Expected boolean'));
      });

      test('validates true value', () {
        final schema = Z.boolean().isTrue();
        final validResult = schema.validate(true);
        final invalidResult = schema.validate(false);

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
      });

      test('validates false value', () {
        final schema = Z.boolean().isFalse();
        final validResult = schema.validate(false);
        final invalidResult = schema.validate(true);

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
      });
    });

    group('Null Schema', () {
      test('validates null values', () {
        final schema = Z.null_();
        final result = schema.validate(null);

        expect(result.isSuccess, true);
      });

      test('rejects non-null values', () {
        final schema = Z.null_();
        final result = schema.validate('not null');

        expect(result.isFailure, true);
        expect(result.errors?.errors.first.message, contains('Expected null'));
      });
    });

    group('Literal Schema', () {
      test('validates literal values', () {
        final schema = Z.literal('hello');
        final validResult = schema.validate('hello');
        final invalidResult = schema.validate('world');

        expect(validResult.isSuccess, true);
        expect(validResult.data, 'hello');
        expect(invalidResult.isFailure, true);
      });
    });

    group('Union Schema', () {
      test('validates union of schemas', () {
        final schema = Z.union<dynamic>([Z.string(), Z.number()]);
        final stringResult = schema.validate('hello');
        final numberResult = schema.validate(42);
        final invalidResult = schema.validate(true);

        expect(stringResult.isSuccess, true);
        expect(numberResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
      });
    });

    group('Schema Composition', () {
      test('chains validation methods', () {
        final schema = Z.string().min(2).max(25).email();

        final validResult = schema.validate('test@example.com');
        final invalidResult = schema.validate('a'); // too short

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
      });

      test('uses transform method', () {
        final schema = Z.string().trim().toLowerCase();

        final result = schema.validate('  HELLO  ');

        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });

      test('uses refine method', () {
        final schema = Z.string().refine(
              (value) => value.contains('@'),
              message: 'must contain @ symbol',
            );

        final validResult = schema.validate('test@example.com');
        final invalidResult = schema.validate('test.example.com');

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
        expect(invalidResult.errors?.errors.first.message,
            'must contain @ symbol');
      });
    });

    group('Error Handling', () {
      test('provides detailed error information', () {
        final schema = Z.string().min(5).max(10);
        final result = schema.validate('abc');

        expect(result.isFailure, true);
        expect(result.errors?.errors.first.path, isEmpty);
        expect(result.errors?.errors.first.received, 'abc');
        expect(result.errors?.errors.first.expected, 'minimum length of 5');
        expect(result.errors?.errors.first.code, 'min_length');
      });

      test('handles multiple errors', () {
        final schema = Z.string().min(5).max(10).email();
        final result = schema.validate('abc');

        expect(result.isFailure, true);
        expect(result.errors?.errors.length,
            1); // stops at first error (min length)
      });
    });

    group('Convenience Methods', () {
      test('email convenience method', () {
        final schema = Z.email();
        final validResult = schema.validate('test@example.com');
        final invalidResult = schema.validate('invalid');

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
      });

      test('url convenience method', () {
        final schema = Z.url();
        final validResult = schema.validate('https://example.com');
        final invalidResult = schema.validate('not-a-url');

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
      });

      test('int convenience method', () {
        final schema = Z.integer();
        final validResult = schema.validate(42);
        final invalidResult = schema.validate(3.14);

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
      });

      test('positive convenience method', () {
        final schema = Z.positive();
        final validResult = schema.validate(42);
        final invalidResult = schema.validate(-5);

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
      });
    });
  });
}
