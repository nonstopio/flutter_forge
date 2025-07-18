import 'package:dzod/dzod.dart';
import 'package:test/test.dart' show contains, expect, group, test;

void main() {
  group('Record Schema Tests', () {
    group('Basic Record Validation', () {
      test('validates simple string-to-dynamic record', () {
        final schema = Z.record();
        final result = schema.validate({'name': 'John', 'age': 30});

        expect(result.isSuccess, true);
        expect(result.data, {'name': 'John', 'age': 30});
      });

      test('validates empty record', () {
        final schema = Z.record();
        final result = schema.validate({});

        expect(result.isSuccess, true);
        expect(result.data, {});
      });

      test('fails on non-map input', () {
        final schema = Z.record();
        final result = schema.validate('not a map');

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.code, 'type_mismatch');
      });

      test('validates with typed key and value schemas', () {
        final schema = RecordSchema<String, num>(
          keySchema: Z.string(),
          valueSchema: Z.number(),
        );
        final result = schema.validate({'count': 5, 'total': 10});

        expect(result.isSuccess, true);
        expect(result.data, {'count': 5, 'total': 10});
      });
    });

    group('Key and Value Schema Validation', () {
      test('validates keys with key schema', () {
        final schema = RecordSchema<String, dynamic>(
          keySchema: Z.string().min(2),
        );
        final result1 = schema.validate({'hello': 'world'});
        final result2 = schema.validate({'a': 'world'});

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('validates values with value schema', () {
        final schema = RecordSchema<String, num>(
          valueSchema: Z.number().min(0),
        );
        final result1 = schema.validate({'count': 5});
        final result2 = schema.validate({'count': -1});

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('validates both keys and values together', () {
        final schema = RecordSchema<String, num>(
          keySchema: Z.string().min(3),
          valueSchema: Z.number().positive(),
        );
        final result1 = schema.validate({'count': 5, 'total': 10});
        final result2 = schema.validate({'ab': 5}); // key too short
        final result3 = schema.validate({'count': -1}); // value invalid

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
        expect(result3.isSuccess, false);
      });

      test('provides detailed error paths for key/value validation', () {
        final schema = RecordSchema<String, num>(
          keySchema: Z.string().min(3),
          valueSchema: Z.number().positive(),
        );
        final result = schema.validate({'ab': -1});

        expect(result.isSuccess, false);
        expect(result.errors!.errors.length, 1); // Only one error per entry
      });
    });

    group('Required and Optional Keys', () {
      test('validates required keys', () {
        final schema = const RecordSchema<String, dynamic>()
            .requiredKeys({'name', 'email'});
        final result1 =
            schema.validate({'name': 'John', 'email': 'john@example.com'});
        final result2 = schema.validate({'name': 'John'}); // missing email

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('validates optional keys', () {
        final schema = const RecordSchema<String, dynamic>()
            .optionalKeys({'age', 'phone'});
        final result1 = schema.validate({'age': 30});
        final result2 = schema.validate({'phone': '123-456-7890'});
        final result3 = schema.validate({}); // no optional keys

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, true);
        expect(result3.isSuccess, true);
      });

      test('validates combination of required and optional keys', () {
        final schema = const RecordSchema<String, dynamic>()
            .requiredKeys({'name'}).optionalKeys({'age', 'email'});
        final result1 = schema.validate({'name': 'John', 'age': 30});
        final result2 = schema.validate({'name': 'John'});
        final result3 = schema.validate({'age': 30}); // missing required

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, true);
        expect(result3.isSuccess, false);
      });

      test('strict mode rejects additional keys', () {
        final schema = const RecordSchema<String, dynamic>()
            .requiredKeys({'name'}).optionalKeys({'age'}).strict();
        final result1 = schema.validate({'name': 'John', 'age': 30});
        final result2 = schema.validate({'name': 'John', 'extra': 'data'});

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });
    });

    group('Size Constraints', () {
      test('validates minimum entries', () {
        final schema = Z.record().min(2);
        final result1 = schema.validate({'a': 1, 'b': 2});
        final result2 = schema.validate({'a': 1});

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('validates maximum entries', () {
        final schema = Z.record().max(2);
        final result1 = schema.validate({'a': 1, 'b': 2});
        final result2 = schema.validate({'a': 1, 'b': 2, 'c': 3});

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('validates exact length', () {
        final schema = Z.record().length(2);
        final result1 = schema.validate({'a': 1, 'b': 2});
        final result2 = schema.validate({'a': 1});
        final result3 = schema.validate({'a': 1, 'b': 2, 'c': 3});

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
        expect(result3.isSuccess, false);
      });

      test('validates non-empty record', () {
        final schema = Z.record().nonempty();
        final result1 = schema.validate({'a': 1});
        final result2 = schema.validate({});

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('chaining size constraints', () {
        final schema = Z.record().min(2).max(4);
        final result1 = schema.validate({'a': 1, 'b': 2, 'c': 3});
        final result2 = schema.validate({'a': 1});
        final result3 =
            schema.validate({'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5});

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
        expect(result3.isSuccess, false);
      });
    });

    group('Record Constraint Methods', () {
      test('containsKeys validates required keys presence', () {
        final schema = Z.record().containsKeys({'name', 'email'});
        final result1 = schema
            .validate({'name': 'John', 'email': 'john@example.com', 'age': 30});
        final result2 = schema.validate({'name': 'John', 'age': 30});

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('containsValues validates required values presence', () {
        final schema = Z.record().containsValues({'admin', 'user'});
        final result1 = schema
            .validate({'role1': 'admin', 'role2': 'user', 'extra': 'data'});
        final result2 = schema.validate({'role1': 'admin', 'role2': 'guest'});

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });
    });

    group('Record Transformation Methods', () {
      test('mapEntries transforms key-value pairs', () {
        final schema = Z.record().mapEntries<String, String>(
              (key, value) =>
                  MapEntry('prefix_$key', value.toString().toUpperCase()),
            );
        final result = schema.validate({'name': 'john', 'city': 'nyc'});

        expect(result.isSuccess, true);
        expect(result.data, {'prefix_name': 'JOHN', 'prefix_city': 'NYC'});
      });

      test('mapKeys transforms only keys', () {
        final schema = Z.record().mapKeys<String>(
              (key) => key.toUpperCase(),
            );
        final result = schema.validate({'name': 'john', 'city': 'nyc'});

        expect(result.isSuccess, true);
        expect(result.data, {'NAME': 'john', 'CITY': 'nyc'});
      });

      test('mapValues transforms only values', () {
        final schema = Z.record().mapValues<String>(
              (value) => value.toString().toUpperCase(),
            );
        final result = schema.validate({'name': 'john', 'city': 'nyc'});

        expect(result.isSuccess, true);
        expect(result.data, {'name': 'JOHN', 'city': 'NYC'});
      });

      test('filterEntries filters key-value pairs', () {
        final schema = Z.record().filterEntries(
              (key, value) => key.length > 3,
            );
        final result = schema.validate({'name': 'john', 'age': 30, 'id': 1});

        expect(result.isSuccess, true);
        expect(result.data, {'name': 'john'});
      });
    });

    group('Record Schema Builder Methods', () {
      test('keySchema sets key validation', () {
        final schema =
            const RecordSchema<String, dynamic>().keySchema(Z.string().min(3));
        final result1 = schema.validate({'name': 'john'});
        final result2 = schema.validate({'ab': 'short'});

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('valueSchema sets value validation', () {
        final schema = const RecordSchema<String, num>()
            .valueSchema(Z.number().positive());
        final result1 = schema.validate({'count': 5});
        final result2 = schema.validate({'count': -1});

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('chaining builder methods', () {
        final schema = const RecordSchema<String, num>()
            .keySchema(Z.string().min(2))
            .valueSchema(Z.number().positive())
            .min(1)
            .max(3)
            .strict();

        final result1 = schema.validate({'count': 5, 'total': 10});
        final result2 = schema.validate({'a': 5}); // key too short
        final result3 = schema.validate({}); // too few entries
        final result4 = schema.validate(
            {'count': 5, 'total': 10, 'avg': 7, 'max': 15}); // too many

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
        expect(result3.isSuccess, false);
        expect(result4.isSuccess, false);
      });
    });

    group('Record Property Access', () {
      test('gets constraint properties', () {
        final schema = const RecordSchema<String, dynamic>()
            .min(2)
            .max(5)
            .requiredKeys({'name'}).optionalKeys({'age'}).strict();

        expect(schema.minEntries, 2);
        expect(schema.maxEntries, 5);
        expect(schema.isStrict, true);
        expect(schema.requiredKeySet, {'name'});
        expect(schema.optionalKeySet, {'age'});
      });

      test('gets null values for unset constraints', () {
        const schema = RecordSchema<String, dynamic>();

        expect(schema.minEntries, null);
        expect(schema.maxEntries, null);
        expect(schema.isStrict, false);
        expect(schema.requiredKeySet, null);
        expect(schema.optionalKeySet, null);
      });
    });

    group('Record Factory Methods', () {
      test('creates string record with typed values', () {
        final schema = RecordFactories.stringRecord<num>(Z.number());
        final result = schema.validate({'count': 5, 'total': 10});

        expect(result.isSuccess, true);
        expect(result.data, {'count': 5, 'total': 10});
      });

      test('creates string-to-string map', () {
        final schema = RecordFactories.stringMap();
        final result = schema.validate({'name': 'john', 'city': 'nyc'});

        expect(result.isSuccess, true);
        expect(result.data, {'name': 'john', 'city': 'nyc'});
      });

      test('creates dynamic record', () {
        final schema = RecordFactories.dynamicRecord();
        final result =
            schema.validate({'name': 'john', 'age': 30, 'active': true});

        expect(result.isSuccess, true);
        expect(result.data, {'name': 'john', 'age': 30, 'active': true});
      });

      test('creates typed record', () {
        final schema = RecordFactories.typedRecord<String, num>(
          keySchema: Z.string(),
          valueSchema: Z.number(),
        );
        final result = schema.validate({'count': 5, 'total': 10});

        expect(result.isSuccess, true);
        expect(result.data, {'count': 5, 'total': 10});
      });
    });

    group('Record Schema Equality and HashCode', () {
      test('schemas with same configuration are equal', () {
        final schema1 = const RecordSchema<String, num>()
            .keySchema(Z.string())
            .valueSchema(Z.number())
            .min(1);
        final schema2 = const RecordSchema<String, num>()
            .keySchema(Z.string())
            .valueSchema(Z.number())
            .min(1);

        expect(schema1 == schema2, true);
        expect(schema1.hashCode == schema2.hashCode, true);
      });

      test('schemas with different configuration are not equal', () {
        final schema1 = const RecordSchema<String, dynamic>().min(1);
        final schema2 = const RecordSchema<String, dynamic>().min(2);

        expect(schema1 == schema2, false);
      });

      test('schemas with different required keys are not equal', () {
        final schema1 =
            const RecordSchema<String, dynamic>().requiredKeys({'name'});
        final schema2 =
            const RecordSchema<String, dynamic>().requiredKeys({'email'});

        expect(schema1 == schema2, false);
      });
    });

    group('Record Schema toString', () {
      test('displays basic record schema', () {
        const schema = RecordSchema<String, num>();
        final str = schema.toString();

        expect(str, contains('RecordSchema<String, num>'));
      });

      test('displays constraints in toString', () {
        final schema = const RecordSchema<String, dynamic>()
            .min(2)
            .max(5)
            .strict()
            .requiredKeys({'name', 'email'});
        final str = schema.toString();

        expect(str, contains('min: 2'));
        expect(str, contains('max: 5'));
        expect(str, contains('strict'));
        expect(str, contains('required'));
      });

      test('truncates long required keys list', () {
        final schema = const RecordSchema<String, dynamic>()
            .requiredKeys({'a', 'b', 'c', 'd', 'e'});
        final str = schema.toString();

        expect(str, contains('required'));
        // Should only show first 2 keys
        expect(str, contains('a, b'));
      });
    });

    group('Record Schema Error Handling', () {
      test('provides detailed error information for type mismatch', () {
        final schema = Z.record();
        final result = schema.validate('not a map');

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.code, 'type_mismatch');
        expect(result.errors!.errors.first.message, contains('record'));
      });

      test('provides error context for size violations', () {
        final schema = Z.record().min(2);
        final result = schema.validate({'a': 1});

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.code, 'record_too_small');
      });

      test('provides error context for missing required keys', () {
        final schema = const RecordSchema<String, dynamic>()
            .requiredKeys({'name', 'email'});
        final result = schema.validate({'name': 'john'});

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.code, 'missing_required_key');
      });

      test('provides error context for strict mode violations', () {
        final schema = const RecordSchema<String, dynamic>()
            .requiredKeys({'name'}).strict();
        final result = schema.validate({'name': 'john', 'extra': 'data'});

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.code, 'unexpected_key');
      });

      test('preserves error paths in nested validation', () {
        final schema = Z.array(Z.record().min(1));
        final result = schema.validate([
          {'a': 1},
          {}
        ]);

        expect(result.isSuccess, false);
        expect(result.errors!.errors.any((e) => e.path.contains('1')), true);
      });
    });

    group('Record Schema Complex Scenarios', () {
      test('validates nested records', () {
        final schema = RecordSchema<String, Map<String, dynamic>>(
          valueSchema: Z.record().min(1),
        );
        final result = schema.validate({
          'user': {'name': 'john', 'age': 30},
          'settings': {'theme': 'dark'}
        });

        expect(result.isSuccess, true);
        expect(result.data!['user'], {'name': 'john', 'age': 30});
      });

      test('validates without schemas using type checking', () {
        // Test direct type checking for keys when no keySchema is provided
        const schema = RecordSchema<String, int>();

        // This should pass type checking
        final validResult = schema.validate({'count': 42, 'total': 100});
        expect(validResult.isSuccess, true);

        // This should fail key type checking
        final invalidKeyResult = schema.validate({123: 42});
        expect(invalidKeyResult.isSuccess, false);
        expect(
            invalidKeyResult.errors!.errors.any((e) => e.path.contains('key')),
            true);

        // This should fail value type checking
        final invalidValueResult = schema.validate({'count': 'not a number'});
        expect(invalidValueResult.isSuccess, false);
        expect(
            invalidValueResult.errors!.errors
                .any((e) => e.path.contains('count')),
            true);
      });

      test('type checking edge cases with mixed types', () {
        // Test with Object keys and dynamic values to force type checking paths
        const schema = RecordSchema<Object, String>();

        final validResult = schema.validate({'key': 'value', 123: 'another'});
        expect(validResult.isSuccess, true);

        final invalidValueResult = schema.validate({'key': 42});
        expect(invalidValueResult.isSuccess, false);
      });

      test('works with refinement chains', () {
        final schema = Z
            .record()
            .min(1)
            .refine((record) => record.containsKey('id'),
                message: 'must have id')
            .refine((record) => record['id'] is int,
                message: 'id must be integer');

        final result1 = schema.validate({'id': 123, 'name': 'test'});
        final result2 = schema.validate({'name': 'test'});
        final result3 = schema.validate({'id': 'invalid'});

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false); // missing id
        expect(result3.isSuccess, false); // id not integer
      });

      test('handles complex transformation chains', () {
        // Test individual transformations since they can't be chained
        final schema1 = const RecordSchema<String, dynamic>()
            .mapKeys<String>((key) => key.toUpperCase());
        final result1 = schema1.validate({'name': 'john', 'age': 30});

        final schema2 = const RecordSchema<String, dynamic>()
            .mapValues<String>((value) => value.toString());
        final result2 = schema2.validate({'name': 'john', 'age': 30});

        final schema3 = const RecordSchema<String, dynamic>()
            .filterEntries((key, value) => key.length > 2);
        final result3 = schema3.validate({'id': 1, 'name': 'john', 'age': 30});

        expect(result1.isSuccess, true);
        expect(result1.data, {'NAME': 'john', 'AGE': 30});

        expect(result2.isSuccess, true);
        expect(result2.data, {'name': 'john', 'age': '30'});

        expect(result3.isSuccess, true);
        expect(result3.data, {'name': 'john', 'age': 30});
      });

      test('validates with mixed constraint types', () {
        final schema = const RecordSchema<String, dynamic>()
            .keySchema(Z.string().min(2))
            .valueSchema(Z.union([Z.string(), Z.number()]))
            .requiredKeys({'name'})
            .optionalKeys({'age', 'email'})
            .min(1)
            .max(5)
            .strict();

        final result1 = schema.validate({'name': 'john', 'age': 30});
        final result2 = schema.validate({'name': 'john', 'invalid': 'value'});
        final result3 = schema.validate({'ab': 'too', 'short': 'key'});

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false); // invalid key not in optional
        expect(result3.isSuccess, false); // 'ab' key too short
      });
    });
  });
}
