import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('Async Validation Tests', () {
    group('Base Async Methods', () {
      test('parseAsync should work with valid input', () async {
        final schema = z.string();
        final result = await schema.parseAsync('hello');
        expect(result, equals('hello'));
      });

      test('parseAsync should throw exception with invalid input', () async {
        final schema = z.string();
        await expectLater(
          () => schema.parseAsync(123),
          throwsA(isA<ValidationException>()),
        );
      });

      test('safeParseAsync should return value with valid input', () async {
        final schema = z.string();
        final result = await schema.safeParseAsync('hello');
        expect(result, equals('hello'));
      });

      test('safeParseAsync should return null with invalid input', () async {
        final schema = z.string();
        final result = await schema.safeParseAsync(123);
        expect(result, isNull);
      });

      test('validateAsync should return success result with valid input',
          () async {
        final schema = z.string();
        final result = await schema.validateAsync('hello');
        expect(result.isSuccess, isTrue);
        expect(result.data, equals('hello'));
      });

      test('validateAsync should return failure result with invalid input',
          () async {
        final schema = z.string();
        final result = await schema.validateAsync(123);
        expect(result.isFailure, isTrue);
        expect(result.errors, isNotNull);
      });
    });

    group('Async Refinement', () {
      test('async refinement should work with valid value', () async {
        final schema = z.string().refineAsync(
          (value) async {
            // Simulate async validation (e.g., API call)
            await Future.delayed(const Duration(milliseconds: 10));
            return value.length > 3;
          },
          message: 'String must be longer than 3 characters',
        );

        final result = await schema.validateAsync('hello');
        expect(result.isSuccess, isTrue);
        expect(result.data, equals('hello'));
      });

      test('async refinement should fail with invalid value', () async {
        final schema = z.string().refineAsync(
          (value) async {
            await Future.delayed(const Duration(milliseconds: 10));
            return value.length > 3;
          },
          message: 'String must be longer than 3 characters',
        );

        final result = await schema.validateAsync('hi');
        expect(result.isFailure, isTrue);
        expect(result.errors!.formattedErrors,
            contains('String must be longer than 3 characters'));
      });

      test('async refinement should fail in sync context', () async {
        final schema = z.string().refineAsync(
          (value) async {
            await Future.delayed(const Duration(milliseconds: 10));
            return value.length > 3;
          },
          message: 'String must be longer than 3 characters',
        );

        final result = schema.validate('hello');
        expect(result.isFailure, isTrue);
        expect(result.errors!.formattedErrors,
            contains('Async validation not supported in sync context'));
      });
    });

    group('Async Transform', () {
      test('async transform should work with valid input', () async {
        final schema = z.string().transformAsync<int>(
          (value) async {
            await Future.delayed(const Duration(milliseconds: 10));
            return int.parse(value);
          },
        );

        final result = await schema.validateAsync('123');
        expect(result.isSuccess, isTrue);
        expect(result.data, equals(123));
      });

      test('async transform should handle errors', () async {
        final schema = z.string().transformAsync<int>(
          (value) async {
            await Future.delayed(const Duration(milliseconds: 10));
            return int.parse(value); // Will throw for non-numeric strings
          },
        );

        final result = await schema.validateAsync('not-a-number');
        expect(result.isFailure, isTrue);
        expect(result.errors!.formattedErrors,
            contains('Async transformation failed'));
      });

      test('async transform should fail in sync context', () async {
        final schema = z.string().transformAsync<int>(
          (value) async {
            await Future.delayed(const Duration(milliseconds: 10));
            return int.parse(value);
          },
        );

        final result = schema.validate('123');
        expect(result.isFailure, isTrue);
        expect(result.errors!.formattedErrors,
            contains('Async transformation not supported in sync context'));
      });
    });

    group('Array Async Validation', () {
      test('async array validation should work with valid elements', () async {
        final asyncStringSchema = z.string().refineAsync(
          (value) async {
            await Future.delayed(const Duration(milliseconds: 5));
            return value.isNotEmpty;
          },
          message: 'String cannot be empty',
        );

        final arraySchema = z.array(asyncStringSchema);
        final result = await arraySchema.validateAsync(['hello', 'world']);

        expect(result.isSuccess, isTrue);
        expect(result.data, equals(['hello', 'world']));
      });

      test('async array validation should fail with invalid elements',
          () async {
        final asyncStringSchema = z.string().refineAsync(
          (value) async {
            await Future.delayed(const Duration(milliseconds: 5));
            return value.length > 3;
          },
          message: 'String must be longer than 3 characters',
        );

        final arraySchema = z.array(asyncStringSchema);
        final result = await arraySchema.validateAsync(['hello', 'hi']);

        expect(result.isFailure, isTrue);
        expect(result.errors!.formattedErrors,
            contains('String must be longer than 3 characters'));
      });
    });

    group('Object Async Validation', () {
      test('async object validation should work with valid properties',
          () async {
        final asyncStringSchema = z.string().refineAsync(
          (value) async {
            await Future.delayed(const Duration(milliseconds: 5));
            return value.isNotEmpty;
          },
          message: 'String cannot be empty',
        );

        final objectSchema = z.object({
          'name': asyncStringSchema,
          'email': asyncStringSchema,
        });

        final result = await objectSchema.validateAsync({
          'name': 'John',
          'email': 'john@example.com',
        });

        expect(result.isSuccess, isTrue);
        expect(result.data!['name'], equals('John'));
        expect(result.data!['email'], equals('john@example.com'));
      });

      test('async object validation should fail with invalid properties',
          () async {
        final asyncStringSchema = z.string().refineAsync(
          (value) async {
            await Future.delayed(const Duration(milliseconds: 5));
            return value.isNotEmpty;
          },
          message: 'String cannot be empty',
        );

        final objectSchema = z.object({
          'name': asyncStringSchema,
          'email': asyncStringSchema,
        });

        final result = await objectSchema.validateAsync({
          'name': 'John',
          'email': '', // Empty string should fail
        });

        expect(result.isFailure, isTrue);
        expect(
            result.errors!.formattedErrors, contains('String cannot be empty'));
      });
    });

    group('Complex Async Scenarios', () {
      test('nested async validation should work', () async {
        final asyncStringSchema = z.string().refineAsync(
          (value) async {
            await Future.delayed(const Duration(milliseconds: 5));
            return value.length > 2;
          },
          message: 'String must be longer than 2 characters',
        );

        final nestedSchema = z.object({
          'users': z.array(z.object({
            'name': asyncStringSchema,
            'email': asyncStringSchema,
          })),
        });

        final result = await nestedSchema.validateAsync({
          'users': [
            {'name': 'John', 'email': 'john@example.com'},
            {'name': 'Jane', 'email': 'jane@example.com'},
          ],
        });

        expect(result.isSuccess, isTrue);
        expect(result.data!['users'], hasLength(2));
      });

      test('union with async schemas should work', () async {
        final asyncStringSchema = z.string().refineAsync(
          (value) async {
            await Future.delayed(const Duration(milliseconds: 5));
            return value.startsWith('str_');
          },
          message: 'String must start with str_',
        );

        final unionSchema = Schema.union<dynamic>([
          z.number(),
          asyncStringSchema,
        ]);

        // Should pass with number
        final numberResult = await unionSchema.validateAsync(123);
        expect(numberResult.isSuccess, isTrue);
        expect(numberResult.data, equals(123));

        // Should pass with valid string
        final stringResult = await unionSchema.validateAsync('str_test');
        expect(stringResult.isSuccess, isTrue);
        expect(stringResult.data, equals('str_test'));

        // Should fail with invalid string
        final invalidResult = await unionSchema.validateAsync('invalid');
        expect(invalidResult.isFailure, isTrue);
      });
    });
  });
}
