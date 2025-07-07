import 'package:test/test.dart';
import 'package:zod_bhai/zod_bhai.dart';

void main() {
  group('Tuple Schema Tests', () {
    group('Basic Tuple Validation', () {
      test('validates tuple with string and number', () {
        final schema = Z.tuple([Z.string(), Z.number()]);
        final result = schema.validate(['hello', 42]);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', 42]);
      });

      test('validates tuple with mixed types', () {
        final schema = Z.tuple([Z.string(), Z.number(), Z.boolean()]);
        final result = schema.validate(['test', 123, true]);

        expect(result.isSuccess, true);
        expect(result.data, ['test', 123, true]);
      });

      test('validates empty tuple', () {
        final schema = Z.tuple([]);
        final result = schema.validate([]);

        expect(result.isSuccess, true);
        expect(result.data, []);
      });

      test('fails on non-array input', () {
        final schema = Z.tuple([Z.string()]);
        final result = schema.validate('not an array');

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.code, 'type_mismatch');
      });
    });

    group('Tuple Length Validation', () {
      test('fails when tuple is too short', () {
        final schema = Z.tuple([Z.string(), Z.number()]);
        final result = schema.validate(['hello']);

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.code, 'tuple_too_short');
      });

      test('fails when tuple is too long without rest schema', () {
        final schema = Z.tuple([Z.string(), Z.number()]);
        final result = schema.validate(['hello', 42, 'extra']);

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.code, 'tuple_too_long');
      });

      test('validates exact length when specified', () {
        final schema = Z.tuple([Z.string(), Z.number()]);
        final result = schema.validate(['hello', 42]);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', 42]);
      });
    });

    group('Tuple Element Validation', () {
      test('fails when first element is wrong type', () {
        final schema = Z.tuple([Z.string(), Z.number()]);
        final result = schema.validate([123, 456]);

        expect(result.isSuccess, false);
        expect(result.errors!.errors.any((e) => e.path.contains('0')), true);
      });

      test('fails when second element is wrong type', () {
        final schema = Z.tuple([Z.string(), Z.number()]);
        final result = schema.validate(['hello', 'world']);

        expect(result.isSuccess, false);
        expect(result.errors!.errors.any((e) => e.path.contains('1')), true);
      });

      test('validates nested tuple elements', () {
        final schema = Z.tuple([
          Z.string(),
          Z.tuple([Z.number(), Z.boolean()])
        ]);
        final result = schema.validate([
          'hello',
          [42, true]
        ]);

        expect(result.isSuccess, true);
        expect(result.data, [
          'hello',
          [42, true]
        ]);
      });

      test('fails with multiple element validation errors', () {
        final schema = Z.tuple([Z.string(), Z.number(), Z.boolean()]);
        final result = schema.validate([123, 'not a number', 'not a boolean']);

        expect(result.isSuccess, false);
        expect(result.errors!.errors.length, 3);
      });
    });

    group('Tuple Rest Schema', () {
      test('validates tuple with rest schema', () {
        final schema = Z.tuple([Z.string(), Z.number()]).rest(Z.boolean());
        final result = schema.validate(['hello', 42, true, false]);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', 42, true, false]);
      });

      test('validates tuple with no rest elements', () {
        final schema = Z.tuple([Z.string(), Z.number()]).rest(Z.boolean());
        final result = schema.validate(['hello', 42]);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', 42]);
      });

      test('fails when rest elements are wrong type', () {
        final schema = Z.tuple([Z.string(), Z.number()]).rest(Z.boolean());
        final result = schema.validate(['hello', 42, 'not a boolean']);

        expect(result.isSuccess, false);
        expect(result.errors!.errors.any((e) => e.path.contains('2')), true);
      });
    });

    group('Tuple Manipulation Methods', () {
      test('append adds new element schema', () {
        final schema = Z.tuple([Z.string()]).append(Z.number());
        final result = schema.validate(['hello', 42]);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', 42]);
      });

      test('prepend adds element schema at beginning', () {
        final schema = Z.tuple([Z.string()]).prepend(Z.number());
        final result = schema.validate([42, 'hello']);

        expect(result.isSuccess, true);
        expect(result.data, [42, 'hello']);
      });

      test('chaining append and prepend', () {
        final schema =
            Z.tuple([Z.string()]).append(Z.number()).prepend(Z.boolean());
        final result = schema.validate([true, 'hello', 42]);

        expect(result.isSuccess, true);
        expect(result.data, [true, 'hello', 42]);
      });
    });

    group('Tuple Property Access', () {
      test('gets first element schema', () {
        final schema = Z.tuple([Z.string(), Z.number()]);
        expect(schema.first, isA<StringSchema>());
      });

      test('gets last element schema', () {
        final schema = Z.tuple([Z.string(), Z.number()]);
        expect(schema.last, isA<NumberSchema>());
      });

      test('gets element at index', () {
        final schema = Z.tuple([Z.string(), Z.number(), Z.boolean()]);
        expect(schema.elementAt(0), isA<StringSchema>());
        expect(schema.elementAt(1), isA<NumberSchema>());
        expect(schema.elementAt(2), isA<BooleanSchema>());
      });

      test('throws error when getting first of empty tuple', () {
        final schema = Z.tuple([]);
        expect(() => schema.first, throwsStateError);
      });

      test('throws error when getting last of empty tuple', () {
        final schema = Z.tuple([]);
        expect(() => schema.last, throwsStateError);
      });

      test('throws error when index out of bounds', () {
        final schema = Z.tuple([Z.string()]);
        expect(() => schema.elementAt(1), throwsRangeError);
      });

      test('gets correct length', () {
        final schema = Z.tuple([Z.string(), Z.number(), Z.boolean()]);
        expect(schema.length, 3);
      });

      test('checks rest schema existence', () {
        final schema1 = Z.tuple([Z.string()]);
        final schema2 = Z.tuple([Z.string()]).rest(Z.number());

        expect(schema1.hasRest, false);
        expect(schema2.hasRest, true);
      });
    });

    group('Tuple Constraint Methods', () {
      test('exactLength validates specific length', () {
        final schema = Z.tuple([Z.string(), Z.number()]).exactLength(2);
        final result1 = schema.validate(['hello', 42]);
        final result2 = schema.validate(['hello', 42, 'extra']);

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('minLength validates minimum length', () {
        final schema = Z.tuple([Z.string()]).rest(Z.number()).minLength(2);
        final result1 = schema.validate(['hello', 42]);
        final result2 = schema.validate(['hello']);

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('maxLength validates maximum length', () {
        final schema = Z.tuple([Z.string()]).rest(Z.number()).maxLength(3);
        final result1 = schema.validate(['hello', 42, 99]);
        final result2 = schema.validate(['hello', 42, 99, 123]);

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('nonempty validates non-empty tuple', () {
        final schema = Z.tuple([]).rest(Z.string()).nonempty();
        final result1 = schema.validate(['hello']);
        final result2 = schema.validate([]);

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });
    });

    group('Tuple Transformation Methods', () {
      test('map transforms tuple elements', () {
        final schema = Z.tuple([Z.string(), Z.number()]).map<String>(
            (element) => element.toString());
        final result = schema.validate(['hello', 42]);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', '42']);
      });

      test('filter filters tuple elements', () {
        final schema = Z.tuple([Z.string(), Z.number(), Z.string()]).filter(
            (element) => element is String);
        final result = schema.validate(['hello', 42, 'world']);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', 'world']);
      });

      test('slice extracts tuple portion', () {
        final schema =
            Z.tuple([Z.string(), Z.number(), Z.boolean()]).slice(1, 3);
        final result = schema.validate(['hello', 42, true]);

        expect(result.isSuccess, true);
        expect(result.data, [42, true]);
      });

      test('reverse reverses tuple elements', () {
        final schema = Z.tuple([Z.string(), Z.number(), Z.boolean()]).reverse();
        final result = schema.validate(['hello', 42, true]);

        expect(result.isSuccess, true);
        expect(result.data, [true, 42, 'hello']);
      });
    });

    group('Tuple Factory Methods', () {
      test('creates pair tuple', () {
        final schema = TupleFactories.pair(Z.string(), Z.number());
        final result = schema.validate(['hello', 42]);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', 42]);
      });

      test('creates triple tuple', () {
        final schema =
            TupleFactories.triple(Z.string(), Z.number(), Z.boolean());
        final result = schema.validate(['hello', 42, true]);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', 42, true]);
      });

      test('creates quad tuple', () {
        final schema = TupleFactories.quad(
            Z.string(), Z.number(), Z.boolean(), Z.string());
        final result = schema.validate(['hello', 42, true, 'world']);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', 42, true, 'world']);
      });

      test('creates quintuple tuple', () {
        final schema = TupleFactories.quintuple(
            Z.string(), Z.number(), Z.boolean(), Z.string(), Z.number());
        final result = schema.validate(['hello', 42, true, 'world', 99]);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', 42, true, 'world', 99]);
      });
    });

    group('Tuple Schema Equality and HashCode', () {
      test('schemas with same elements are equal', () {
        final schema1 = Z.tuple([Z.string(), Z.number()]);
        final schema2 = Z.tuple([Z.string(), Z.number()]);

        expect(schema1 == schema2, true);
        expect(schema1.hashCode == schema2.hashCode, true);
      });

      test('schemas with different elements are not equal', () {
        final schema1 = Z.tuple([Z.string(), Z.number()]);
        final schema2 = Z.tuple([Z.string(), Z.boolean()]);

        expect(schema1 == schema2, false);
      });

      test('schemas with different rest schemas are not equal', () {
        final schema1 = Z.tuple([Z.string()]).rest(Z.number());
        final schema2 = Z.tuple([Z.string()]).rest(Z.boolean());

        expect(schema1 == schema2, false);
      });
    });

    group('Tuple Schema toString', () {
      test('displays element types correctly', () {
        final schema = Z.tuple([Z.string(), Z.number()]);
        final str = schema.toString();

        expect(str, contains('TupleSchema'));
        expect(str, contains('StringSchema'));
        expect(str, contains('NumberSchema'));
      });

      test('displays rest schema in toString', () {
        final schema = Z.tuple([Z.string()]).rest(Z.number());
        final str = schema.toString();

        expect(str, contains('TupleSchema'));
        expect(str, contains('...'));
      });
    });

    group('Tuple Schema Error Handling', () {
      test('provides detailed error paths for nested validation', () {
        final schema = Z.tuple([
          Z.string(),
          Z.tuple([Z.number(), Z.boolean()])
        ]);
        final result = schema.validate([
          'hello',
          [42, 'not a boolean']
        ]);

        expect(result.isSuccess, false);
        expect(
            result.errors!.errors
                .any((e) => e.path.contains('1') && e.path.contains('1')),
            true);
      });

      test('preserves error context in refinement', () {
        final schema = Z.tuple([Z.string(), Z.number()]).refine(
            (tuple) => tuple[1] > 0,
            message: 'number must be positive');
        final result = schema.validate(['hello', -5]);

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.message, 'number must be positive');
      });
    });
  });
}
