import 'package:test/test.dart';
import 'package:zod_bhai/zod_bhai.dart';

void main() {
  group('Array Schema Tests', () {
    group('Basic Array Validation', () {
      test('validates array of strings', () {
        final schema = Z.array(Z.string());
        final result = schema.validate(['hello', 'world']);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', 'world']);
      });

      test('validates array of numbers', () {
        final schema = Z.array(Z.number());
        final result = schema.validate([1, 2, 3, 4.5]);

        expect(result.isSuccess, true);
        expect(result.data, [1, 2, 3, 4.5]);
      });

      test('validates empty array', () {
        final schema = Z.array(Z.string());
        final result = schema.validate([]);

        expect(result.isSuccess, true);
        expect(result.data, <String>[]);
      });

      test('rejects non-array values', () {
        final schema = Z.array(Z.string());
        final result = schema.validate('not an array');

        expect(result.isFailure, true);
        expect(result.errors?.errors.first.message, contains('Expected array'));
      });

      test('validates mixed valid elements with union', () {
        final schema = Z.array(Z.union<dynamic>([Z.string(), Z.number()]));
        final result = schema.validate(['hello', 42, 'world', 3.14]);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', 42, 'world', 3.14]);
      });

      test('rejects arrays with invalid elements', () {
        final schema = Z.array(Z.string());
        final result = schema.validate(['hello', 42, 'world']);

        expect(result.isFailure, true);
        expect(result.errors?.errors.length, greaterThan(0));
        expect(result.errors?.errors.first.path,
            ['1']); // Index 1 has invalid element
      });
    });

    group('Length Constraints', () {
      test('validates min length constraint', () {
        final schema = Z.array(Z.string()).min(2);
        final validResult = schema.validate(['a', 'b', 'c']);
        final invalidResult = schema.validate(['a']);

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
        expect(invalidResult.errors?.errors.first.message,
            contains('minimum length'));
      });

      test('validates max length constraint', () {
        final schema = Z.array(Z.string()).max(2);
        final validResult = schema.validate(['a', 'b']);
        final invalidResult = schema.validate(['a', 'b', 'c']);

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
        expect(invalidResult.errors?.errors.first.message,
            contains('maximum length'));
      });

      test('validates exact length constraint', () {
        final schema = Z.array(Z.string()).length(3);
        final validResult = schema.validate(['a', 'b', 'c']);
        final invalidShortResult = schema.validate(['a', 'b']);
        final invalidLongResult = schema.validate(['a', 'b', 'c', 'd']);

        expect(validResult.isSuccess, true);
        expect(invalidShortResult.isFailure, true);
        expect(invalidLongResult.isFailure, true);
        expect(invalidShortResult.errors?.errors.first.message,
            contains('exact length'));
      });

      test('validates range constraint', () {
        final schema = Z.array(Z.string()).range(2, 4);

        expect(schema.validate(['a']).isFailure, true); // Too short
        expect(schema.validate(['a', 'b']).isSuccess, true); // Valid
        expect(schema.validate(['a', 'b', 'c']).isSuccess, true); // Valid
        expect(schema.validate(['a', 'b', 'c', 'd']).isSuccess, true); // Valid
        expect(schema.validate(['a', 'b', 'c', 'd', 'e']).isFailure,
            true); // Too long
      });
    });

    group('Non-empty Validation', () {
      test('validates non-empty constraint', () {
        final schema = Z.array(Z.string()).nonempty();
        final validResult = schema.validate(['a']);
        final invalidResult = schema.validate([]);

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
        expect(
            invalidResult.errors?.errors.first.message, contains('non-empty'));
      });
    });

    group('Advanced Array Methods', () {
      test('validates unique elements', () {
        final schema = Z.array(Z.string()).unique();
        final validResult = schema.validate(['a', 'b', 'c']);
        final invalidResult = schema.validate(['a', 'b', 'a']);

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
        expect(invalidResult.errors?.errors.first.message,
            contains('unique elements'));
      });

      test('validates includes constraint', () {
        final schema = Z.array(Z.string()).includes('required');
        final validResult = schema.validate(['a', 'required', 'b']);
        final invalidResult = schema.validate(['a', 'b']);

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
        expect(invalidResult.errors?.errors.first.message,
            contains('must include'));
      });

      test('validates excludes constraint', () {
        final schema = Z.array(Z.string()).excludes('forbidden');
        final validResult = schema.validate(['a', 'b', 'c']);
        final invalidResult = schema.validate(['a', 'forbidden', 'c']);

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
        expect(invalidResult.errors?.errors.first.message,
            contains('must not include'));
      });

      test('validates some constraint', () {
        final schema = Z.array(Z.number()).some(
              (n) => n > 10,
              message: 'must have at least one number > 10',
            );
        final validResult = schema.validate([1, 5, 15, 3]);
        final invalidResult = schema.validate([1, 5, 8, 3]);

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
        expect(invalidResult.errors?.errors.first.message,
            contains('number > 10'));
      });

      test('validates every constraint', () {
        final schema = Z.array(Z.number()).every(
              (n) => n > 0,
              message: 'all numbers must be positive',
            );
        final validResult = schema.validate([1, 5, 15, 3]);
        final invalidResult = schema.validate([1, -5, 15, 3]);

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
        expect(
            invalidResult.errors?.errors.first.message, contains('positive'));
      });
    });

    group('Array Transformations', () {
      test('transforms array elements', () {
        final schema = Z.array(Z.string()).mapElements((s) => s.toUpperCase());
        final result = schema.validate(['hello', 'world']);

        expect(result.isSuccess, true);
        expect(result.data, ['HELLO', 'WORLD']);
      });

      test('filters array elements', () {
        final schema = Z.array(Z.number()).filter((n) => n > 5);
        final result = schema.validate([1, 10, 3, 8, 2]);

        expect(result.isSuccess, true);
        expect(result.data, [10, 8]);
      });

      test('sorts array elements', () {
        final schema = Z.array(Z.number()).sort();
        final result = schema.validate([3, 1, 4, 1, 5]);

        expect(result.isSuccess, true);
        expect(result.data, [1, 1, 3, 4, 5]);
      });

      test('sorts array with custom comparator', () {
        final schema =
            Z.array(Z.string()).sort((a, b) => b.compareTo(a)); // Reverse order
        final result = schema.validate(['c', 'a', 'b']);

        expect(result.isSuccess, true);
        expect(result.data, ['c', 'b', 'a']);
      });
    });

    group('Nested Arrays', () {
      test('validates nested arrays', () {
        final schema = Z.array(Z.array(Z.string()));
        final result = schema.validate([
          ['a', 'b'],
          ['c', 'd', 'e'],
          []
        ]);

        expect(result.isSuccess, true);
        expect(result.data, [
          ['a', 'b'],
          ['c', 'd', 'e'],
          []
        ]);
      });

      test('provides nested error paths', () {
        final schema = Z.array(Z.array(Z.string()));
        final result = schema.validate([
          ['a', 'b'],
          ['c', 42, 'e'], // Invalid element at [1][1]
        ]);

        expect(result.isFailure, true);
        expect(result.errors?.errors.first.path, ['1', '1']); // Nested path
      });
    });

    group('Schema Composition', () {
      test('chains multiple constraints', () {
        final schema =
            Z.array(Z.string().min(2)).min(1).max(3).nonempty().unique();

        final validResult = schema.validate(['ab', 'cd']);
        final invalidResult = schema.validate(['a', 'b']); // Strings too short

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
      });

      test('works with refinements', () {
        final schema = Z.array(Z.string()).refine(
              (arr) => arr.isNotEmpty && arr.first.startsWith('prefix_'),
              message: 'first element must start with prefix_',
            );

        final validResult = schema.validate(['prefix_hello', 'world']);
        final invalidResult = schema.validate(['hello', 'world']);

        expect(validResult.isSuccess, true);
        expect(invalidResult.isFailure, true);
        expect(invalidResult.errors?.errors.first.message, contains('prefix_'));
      });
    });

    group('Error Handling', () {
      test('provides detailed error information', () {
        final schema = Z.array(Z.string().min(3)).min(2);
        final result = schema.validate(['ab']); // Too short array and string

        expect(result.isFailure, true);
        expect(result.errors?.errors.length, greaterThan(0));

        // Should have array length error
        final lengthError = result.errors?.errors.firstWhere(
          (e) => e.code == 'min_length',
        );
        expect(lengthError?.context?['expected'], 2);
        expect(lengthError?.context?['actual'], 1);
      });

      test('handles multiple element errors', () {
        final schema = Z.array(Z.string().min(3));
        final result =
            schema.validate(['ab', 'cd', 'efg']); // First two strings too short

        expect(result.isFailure, true);
        expect(result.errors?.errors.length, 2); // Two validation errors

        // Check error paths
        expect(result.errors?.errors[0].path, ['0']);
        expect(result.errors?.errors[1].path, ['1']);
      });
    });

    group('Type Safety', () {
      test('maintains type safety with generics', () {
        final stringArraySchema = Z.array(Z.string());
        final numberArraySchema = Z.array(Z.number());

        // This should work fine
        final stringResult = stringArraySchema.validate(['a', 'b']);
        final numberResult = numberArraySchema.validate([1, 2]);

        expect(stringResult.data.runtimeType, List<String>);
        expect(numberResult.data.runtimeType, List<num>);
      });

      test('provides correct element schema access', () {
        final schema = Z.array(Z.string().email());
        final elementSchema = schema.elementSchema;

        expect(elementSchema.runtimeType, StringSchema);
      });
    });

    group('toString and Equality', () {
      test('provides meaningful toString', () {
        final schema = Z.array(Z.string()).min(1).max(5).nonempty();
        final string = schema.toString();

        expect(string, contains('ArraySchema'));
        expect(string, contains('StringSchema'));
        expect(string, contains('min: 1'));
        expect(string, contains('max: 5'));
        expect(string, contains('nonempty'));
      });

      test('supports equality comparison', () {
        final schema1 = Z.array(Z.string()).min(1);
        final schema2 = Z.array(Z.string()).min(1);
        final schema3 = Z.array(Z.string()).min(2);

        expect(schema1 == schema2, true);
        expect(schema1 == schema3, false);
      });
    });
  });
}
