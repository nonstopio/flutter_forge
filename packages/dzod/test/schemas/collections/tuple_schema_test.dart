import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('TupleSchema', () {
    group('Basic Tuple Validation', () {
      test('validates empty tuple', () {
        final schema = z.tuple([]);
        final result = schema.validate([]);

        expect(result.isSuccess, true);
        expect(result.data, []);
      });

      test('validates single element tuple', () {
        final schema = z.tuple([z.string()]);
        final result = schema.validate(['hello']);

        expect(result.isSuccess, true);
        expect(result.data, ['hello']);
      });

      test('validates multi-element tuple', () {
        final schema = z.tuple([z.string(), z.number(), z.boolean()]);
        final result = schema.validate(['hello', 42, true]);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', 42, true]);
      });

      test('fails on non-array input', () {
        final schema = z.tuple([z.string()]);
        final result = schema.validate('not an array');

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.code, 'type_mismatch');
        expect(result.errors!.errors.first.message, contains('tuple'));
      });

      test('fails when array is too short', () {
        final schema = z.tuple([z.string(), z.number()]);
        final result = schema.validate(['hello']);

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.code, 'tuple_too_short');
        expect(result.errors!.errors.first.context!['expected'], 2);
        expect(result.errors!.errors.first.context!['actual'], 1);
      });

      test('fails when array is too long (without rest)', () {
        final schema = z.tuple([z.string(), z.number()]);
        final result = schema.validate(['hello', 42, true]);

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.code, 'tuple_too_long');
        expect(result.errors!.errors.first.context!['expected'], 2);
        expect(result.errors!.errors.first.context!['actual'], 3);
      });
    });

    group('Element Validation', () {
      test('validates each element with correct schema', () {
        final schema = z.tuple([
          z.string().min(2),
          z.number().positive(),
          z.boolean(),
        ]);
        final result1 = schema.validate(['hello', 5, true]);
        final result2 =
            schema.validate(['h', 5, true]); // first element too short
        final result3 =
            schema.validate(['hello', -1, true]); // second element negative

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
        expect(result3.isSuccess, false);
      });

      test('collects all element validation errors', () {
        final schema = z.tuple([
          z.string().min(3),
          z.number().positive(),
          z.boolean(),
        ]);
        final result = schema.validate(['hi', -1, 'not boolean']);

        expect(result.isSuccess, false);
        expect(result.errors!.errors.length, 3);

        // Check that error paths are correct
        final errorPaths = result.errors!.errors.map((e) => e.path).toList();
        expect(errorPaths.any((path) => path.contains('0')),
            true); // first element error
        expect(errorPaths.any((path) => path.contains('1')),
            true); // second element error
        expect(errorPaths.any((path) => path.contains('2')),
            true); // third element error
      });

      test('preserves validated data for successful elements', () {
        final schema = z.tuple([z.string(), z.number()]);
        final result = schema.validate(['hello', 42]);

        expect(result.isSuccess, true);
        expect(result.data![0], 'hello');
        expect(result.data![1], 42);
      });
    });

    group('Rest Schema', () {
      test('allows additional elements with rest schema', () {
        final schema = z.tuple([z.string(), z.number()]).rest(z.boolean());
        final result = schema.validate(['hello', 42, true, false, true]);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', 42, true, false, true]);
      });

      test('validates rest elements with rest schema', () {
        final schema = z.tuple([z.string()]).rest(z.number().positive());
        final result1 = schema.validate(['hello', 1, 2, 3]);
        final result2 =
            schema.validate(['hello', 1, -2, 3]); // negative number in rest

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('works with no additional elements', () {
        final schema = z.tuple([z.string(), z.number()]).rest(z.boolean());
        final result = schema.validate(['hello', 42]);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', 42]);
      });

      test('validates complex rest schema', () {
        final schema = z.tuple([z.string()]).rest(
            z.object({'type': z.string(), 'value': z.number()}));
        final result = schema.validate([
          'header',
          {'type': 'item1', 'value': 1},
          {'type': 'item2', 'value': 2},
        ]);

        expect(result.isSuccess, true);
        expect(result.data![1]['type'], 'item1');
        expect(result.data![2]['value'], 2);
      });
    });

    group('Schema Manipulation', () {
      test('appends element schema', () {
        final baseSchema = z.tuple([z.string(), z.number()]);
        final extendedSchema = baseSchema.append(z.boolean());

        final result1 = extendedSchema.validate(['hello', 42, true]);
        final result2 = extendedSchema.validate(['hello', 42]); // too short now

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('prepends element schema', () {
        final baseSchema = z.tuple([z.string(), z.number()]);
        final extendedSchema = baseSchema.prepend(z.boolean());

        final result = extendedSchema.validate([true, 'hello', 42]);

        expect(result.isSuccess, true);
        expect(result.data, [true, 'hello', 42]);
      });

      test('chaining append operations', () {
        final schema =
            z.tuple([z.string()]).append(z.number()).append(z.boolean());

        final result = schema.validate(['hello', 42, true]);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', 42, true]);
      });

      test('chaining prepend operations', () {
        final schema =
            z.tuple([z.string()]).prepend(z.number()).prepend(z.boolean());

        final result = schema.validate([true, 42, 'hello']);

        expect(result.isSuccess, true);
        expect(result.data, [true, 42, 'hello']);
      });

      test('preserves rest schema when appending', () {
        final schema =
            z.tuple([z.string()]).rest(z.number()).append(z.boolean());

        final result = schema.validate(['hello', true, 1, 2, 3]);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', true, 1, 2, 3]);
      });
    });

    group('Schema Properties and Access', () {
      test('gets first element schema', () {
        final schema = z.tuple([z.string(), z.number(), z.boolean()]);

        expect(schema.first, isA<Schema>());
        expect(schema.first.runtimeType.toString(), contains('String'));
      });

      test('gets last element schema', () {
        final schema = z.tuple([z.string(), z.number(), z.boolean()]);

        expect(schema.last, isA<Schema>());
        expect(schema.last.runtimeType.toString(), contains('Boolean'));
      });

      test('throws on first/last for empty tuple', () {
        final schema = z.tuple([]);

        expect(() => schema.first, throwsA(isA<StateError>()));
        expect(() => schema.last, throwsA(isA<StateError>()));
      });

      test('gets element at index', () {
        final schema = z.tuple([z.string(), z.number(), z.boolean()]);

        expect(schema.elementAt(0), isA<Schema>());
        expect(schema.elementAt(1), isA<Schema>());
        expect(schema.elementAt(2), isA<Schema>());
      });

      test('throws on invalid index', () {
        final schema = z.tuple([z.string(), z.number()]);

        expect(() => schema.elementAt(-1), throwsA(isA<RangeError>()));
        expect(() => schema.elementAt(2), throwsA(isA<RangeError>()));
      });

      test('gets tuple length', () {
        final schema1 = z.tuple([]);
        final schema2 = z.tuple([z.string(), z.number()]);

        expect(schema1.length, 0);
        expect(schema2.length, 2);
      });

      test('checks if has rest schema', () {
        final schema1 = z.tuple([z.string()]);
        final schema2 = z.tuple([z.string()]).rest(z.number());

        expect(schema1.hasRest, false);
        expect(schema2.hasRest, true);
      });

      test('gets rest schema', () {
        final schema1 = z.tuple([z.string()]);
        final schema2 = z.tuple([z.string()]).rest(z.number());

        expect(schema1.restSchema, null);
        expect(schema2.restSchema, isA<Schema>());
      });

      test('gets element schemas list', () {
        final elementSchemas = <Schema<dynamic>>[
          z.string(),
          z.number(),
          z.boolean()
        ];
        final schema = z.tuple(elementSchemas);

        final retrievedSchemas = schema.elementSchemas;
        expect(retrievedSchemas.length, 3);
        expect(retrievedSchemas, isA<List<Schema>>());

        // Should be unmodifiable
        expect(() => retrievedSchemas.add(z.string()),
            throwsA(isA<UnsupportedError>()));
      });
    });

    group('Length Validation Methods', () {
      test('validates exact length', () {
        final schema = z.tuple([z.string(), z.number()]).exactLength(2);

        final result1 = schema.validate(['hello', 42]);
        final result2 = schema.validate(['hello', 42, true]);

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('validates minimum length', () {
        final schema = z.tuple([z.string()]).rest(z.number()).minLength(3);

        final result1 = schema.validate(['hello', 1, 2]);
        final result2 = schema.validate(['hello', 1]);

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('validates maximum length', () {
        final schema = z.tuple([z.string()]).rest(z.number()).maxLength(3);

        final result1 = schema.validate(['hello', 1, 2]);
        final result2 = schema.validate(['hello', 1, 2, 3]);

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('validates non-empty tuple', () {
        final schema = z.tuple([]).rest(z.string()).nonempty();

        final result1 = schema.validate(['hello']);
        final result2 = schema.validate([]);

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });
    });

    group('Tuple Schema Equality', () {
      test('equality operator works correctly', () {
        final schema1 = z.tuple([z.string(), z.number()]);
        final schema2 = z.tuple([z.string(), z.number()]);
        final schema3 = z.tuple([z.string(), z.boolean()]);

        expect(schema1 == schema2, true);
        expect(schema1 == schema3, false);
        expect(schema1 == schema1, true); // Test identical
      });
    });

    group('Transformation Methods', () {
      test('maps elements after validation', () {
        final schema = z.tuple([z.string(), z.number()]).map<String>(
            (element) => element.toString());

        final result = schema.validate(['hello', 42]);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', '42']);
      });

      test('filters elements after validation', () {
        final schema = z
            .tuple([z.string(), z.number(), z.string(), z.number()]).filter(
                (element) => element is String);

        final result = schema.validate(['hello', 42, 'world', 24]);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', 'world']);
      });

      test('slices tuple after validation', () {
        final schema = z.tuple(
            [z.string(), z.number(), z.boolean(), z.string()]).slice(1, 3);

        final result = schema.validate(['hello', 42, true, 'world']);

        expect(result.isSuccess, true);
        expect(result.data, [42, true]);
      });

      test('slices tuple with start only', () {
        final schema = z.tuple([z.string(), z.number(), z.boolean()]).slice(1);

        final result = schema.validate(['hello', 42, true]);

        expect(result.isSuccess, true);
        expect(result.data, [42, true]);
      });

      test('reverses tuple after validation', () {
        final schema = z.tuple([z.string(), z.number(), z.boolean()]).reverse();

        final result = schema.validate(['hello', 42, true]);

        expect(result.isSuccess, true);
        expect(result.data, [true, 42, 'hello']);
      });

      test('transformation preserves type safety', () {
        final schema = z
            .tuple([z.string().min(2), z.number().positive()]).map<String>(
                (element) => '$element!');

        final result1 = schema.validate(['hello', 42]);
        final result2 = schema.validate(
            ['h', 42]); // should fail validation before transformation

        expect(result1.isSuccess, true);
        expect(result1.data, ['hello!', '42!']);
        expect(result2.isSuccess, false);
      });
    });

    group('Factory Methods', () {
      test('creates pair tuple', () {
        final schema = TupleFactories.pair(z.string(), z.number());

        final result1 = schema.validate(['hello', 42]);
        final result2 = schema.validate(['hello', 42, true]); // too long

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('creates triple tuple', () {
        final schema =
            TupleFactories.triple(z.string(), z.number(), z.boolean());

        final result = schema.validate(['hello', 42, true]);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', 42, true]);
      });

      test('creates quad tuple', () {
        final schema = TupleFactories.quad(
            z.string(), z.number(), z.boolean(), z.string());

        final result = schema.validate(['hello', 42, true, 'world']);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', 42, true, 'world']);
      });

      test('creates quintuple tuple', () {
        final schema = TupleFactories.quintuple(
            z.string(), z.number(), z.boolean(), z.string(), z.number());

        final result = schema.validate(['hello', 42, true, 'world', 24]);

        expect(result.isSuccess, true);
        expect(result.data, ['hello', 42, true, 'world', 24]);
      });

      test('factory methods create proper schemas', () {
        final pairSchema = TupleFactories.pair(z.string(), z.number());

        expect(pairSchema.length, 2);
        expect(pairSchema.hasRest, false);
        expect(pairSchema.elementAt(0), isA<Schema>());
        expect(pairSchema.elementAt(1), isA<Schema>());
      });
    });

    group('String Representation and Equality', () {
      test('has proper string representation', () {
        final schema = z.tuple([z.string(), z.number()]).rest(z.boolean());
        final str = schema.toString();

        expect(str, contains('TupleSchema'));
        expect(str, contains('String'));
        expect(str, contains('Number'));
        expect(str, contains('Boolean'));
      });

      test('implements equality correctly', () {
        final schema1 = z.tuple([z.string(), z.number()]);
        final schema2 = z.tuple([z.string(), z.number()]);
        final schema3 = z.tuple([z.string(), z.boolean()]);
        final schema4 = z.tuple([z.string(), z.number()]).rest(z.boolean());

        expect(schema1 == schema2, true);
        expect(schema1 == schema3, false); // different element schemas
        expect(schema1 == schema4, false); // different rest schema
        expect(schema1.hashCode == schema2.hashCode, true);
      });

      test('handles equality with empty tuples', () {
        final schema1 = z.tuple([]);
        final schema2 = z.tuple([]);
        final schema3 = z.tuple([]).rest(z.string());

        expect(schema1 == schema2, true);
        expect(schema1 == schema3, false);
      });

      test('list equality helper works correctly', () {
        // This tests the internal _listEquals method indirectly
        final schema1 = z.tuple([z.string(), z.number()]);
        final schema2 = z.tuple([z.string(), z.number()]);
        final schema3 = z.tuple([z.number(), z.string()]);

        expect(schema1 == schema2, true);
        expect(schema1 == schema3, false);
      });
    });

    group('Complex Scenarios', () {
      test('validates nested tuples', () {
        final innerTuple = z.tuple([z.string(), z.number()]);
        final outerTuple = z.tuple([innerTuple, z.boolean()]);

        final result = outerTuple.validate([
          ['hello', 42],
          true
        ]);

        expect(result.isSuccess, true);
        expect(result.data![0], ['hello', 42]);
        expect(result.data![1], true);
      });

      test('handles tuple with object elements', () {
        final schema = z.tuple([
          z.object({'name': z.string(), 'age': z.number()}),
          z.array(z.string()),
          z.boolean()
        ]);

        final result = schema.validate([
          {'name': 'John', 'age': 30},
          ['item1', 'item2'],
          true
        ]);

        expect(result.isSuccess, true);
        expect(result.data![0]['name'], 'John');
        expect(result.data![1], ['item1', 'item2']);
      });

      test('works with union types in elements', () {
        final schema = z.tuple([
          z.union([z.string(), z.number()]),
          z.union([z.boolean(), z.string()])
        ]);

        final result1 = schema.validate(['hello', true]);
        final result2 = schema.validate([42, 'world']);
        final result3 = schema.validate([42, false]);

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, true);
        expect(result3.isSuccess, true);
      });

      test('handles very large tuples', () {
        final elementSchemas =
            List<Schema<dynamic>>.generate(100, (i) => z.number());
        final schema = z.tuple(elementSchemas);
        final input = List.generate(100, (i) => i);

        final result = schema.validate(input);

        expect(result.isSuccess, true);
        expect(result.data!.length, 100);
        expect(result.data![99], 99);
      });

      test('preserves error paths in complex structures', () {
        final schema =
            z.array(z.tuple([z.string().min(3), z.number().positive()]));
        final result = schema.validate([
          ['valid', 42],
          ['xy', -1] // both elements invalid
        ]);

        expect(result.isSuccess, false);

        // Should have errors for both invalid elements in second tuple
        final errorPaths = result.errors!.errors.map((e) => e.path).toList();
        expect(
            errorPaths.any((path) => path.contains('1') && path.contains('0')),
            true); // second array, first tuple element
        expect(
            errorPaths.any((path) => path.contains('1') && path.contains('1')),
            true); // second array, second tuple element
      });

      test('works with refinements and custom validation', () {
        final schema = z.tuple([z.string(), z.number()]).refine(
            (tuple) => tuple[0].length > tuple[1],
            message: 'String length must be greater than number value');

        final result1 = schema.validate(['hello', 3]); // 5 > 3
        final result2 = schema.validate(['hi', 5]); // 2 < 5

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('handles empty input edge cases', () {
        final schema1 = z.tuple([]);
        final schema2 = z.tuple([z.string().optional()]);

        final result1 = schema1.validate([]);
        final result2 = schema2.validate([]);

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false); // required element missing
      });

      test('handles transformation with rest elements', () {
        final schema = z
            .tuple([z.string()])
            .rest(z.number())
            .map<String>((element) => element.toString().toUpperCase());

        final result = schema.validate(['hello', 1, 2, 3]);

        expect(result.isSuccess, true);
        expect(result.data, ['HELLO', '1', '2', '3']);
      });
    });

    group('Error Handling Edge Cases', () {
      test('provides detailed error messages', () {
        final schema = z.tuple([z.string().email(), z.number().min(10)]);
        final result = schema.validate(['invalid-email', 5]);

        expect(result.isSuccess, false);
        expect(result.errors!.errors.length, 2);

        // Check that each error has proper context
        for (final error in result.errors!.errors) {
          expect(error.path, isNotEmpty);
          expect(error.message, isNotEmpty);
        }
      });

      test('handles null and undefined values properly', () {
        final schema = z.tuple([z.string(), z.number().nullable()]);

        final result1 = schema.validate(['hello', null]);
        final result2 = schema.validate([null, 42]);

        expect(result1.isSuccess, true); // null allowed for nullable number
        expect(result2.isSuccess, false); // null not allowed for string
      });

      test('preserves original input in error context', () {
        final schema = z.tuple([z.string(), z.number()]);
        final invalidInput = ['hello', 'not-a-number'];
        final result = schema.validate(invalidInput);

        expect(result.isSuccess, false);
        expect(result.errors!.errors.isNotEmpty, true);
        expect(result.errors!.errors.first.message, isNotEmpty);
      });
    });
  });
}
