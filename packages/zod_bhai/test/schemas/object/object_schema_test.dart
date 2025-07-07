import 'package:test/test.dart';
import 'package:zod_bhai/zod_bhai.dart';

void main() {
  group('Object Schema Tests', () {
    group('Basic Object Validation', () {
      test('validates simple object with string and number properties', () {
        final schema = Z.object({
          'name': Z.string(),
          'age': Z.number(),
        });

        final result = schema.validate({
          'name': 'John',
          'age': 25,
        });

        expect(result.isSuccess, true);
        expect(result.data, equals({'name': 'John', 'age': 25}));
      });

      test('validates object with optional properties', () {
        final schema = Z.object({
          'name': Z.string(),
          'age': Z.number(),
          'email': Z.string(),
        }, optionalKeys: {
          'email'
        });

        final result1 = schema.validate({
          'name': 'John',
          'age': 25,
        });

        final result2 = schema.validate({
          'name': 'John',
          'age': 25,
          'email': 'john@example.com',
        });

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, true);
        expect(result2.data!['email'], equals('john@example.com'));
      });

      test('rejects non-object values', () {
        final schema = Z.object({'name': Z.string()});

        final result = schema.validate('not an object');

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.code, equals('type_mismatch'));
      });

      test('rejects object missing required properties', () {
        final schema = Z.object({
          'name': Z.string(),
          'age': Z.number(),
        });

        final result = schema.validate({'name': 'John'});

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.code,
            equals('missing_required_property'));
      });

      test('validates nested objects', () {
        final schema = Z.object({
          'user': Z.object({
            'name': Z.string(),
            'profile': Z.object({
              'bio': Z.string(),
            }),
          }),
        });

        final result = schema.validate({
          'user': {
            'name': 'John',
            'profile': {
              'bio': 'Developer',
            },
          },
        });

        expect(result.isSuccess, true);
        expect(result.data!['user']['profile']['bio'], equals('Developer'));
      });
    });

    group('Object Manipulation Methods', () {
      late ObjectSchema baseSchema;

      setUp(() {
        baseSchema = Z.object({
          'name': Z.string(),
          'age': Z.number(),
          'email': Z.string(),
          'phone': Z.string(),
        });
      });

      test('pick() selects only specified properties', () {
        final pickedSchema = baseSchema.pick(['name', 'email']);

        final result = pickedSchema.validate({
          'name': 'John',
          'email': 'john@example.com',
        });

        expect(result.isSuccess, true);
        expect(
            result.data, equals({'name': 'John', 'email': 'john@example.com'}));

        // Should fail if age is provided since it's not picked
        final resultWithAge = pickedSchema.validate({
          'name': 'John',
          'email': 'john@example.com',
          'age': 25,
        });

        expect(resultWithAge.isSuccess,
            true); // Unknown properties are ignored by default
      });

      test('omit() excludes specified properties', () {
        final omittedSchema = baseSchema.omit(['phone']);

        final result = omittedSchema.validate({
          'name': 'John',
          'age': 25,
          'email': 'john@example.com',
        });

        expect(result.isSuccess, true);
        expect(
            result.data,
            equals({
              'name': 'John',
              'age': 25,
              'email': 'john@example.com',
            }));
      });

      test('partial() makes all properties optional', () {
        final partialSchema = baseSchema.partial();

        final result1 = partialSchema.validate({'name': 'John'});
        final result2 = partialSchema.validate({});

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, true);
        expect(result1.data, equals({'name': 'John'}));
        expect(result2.data, equals({}));
      });

      test('deepPartial() makes nested objects partial', () {
        final nestedSchema = Z.object({
          'user': Z.object({
            'name': Z.string(),
            'profile': Z.object({
              'bio': Z.string(),
              'age': Z.number(),
            }),
          }),
          'id': Z.number(),
        });

        final deepPartialSchema = nestedSchema.deepPartial();

        final result = deepPartialSchema.validate({
          'user': {
            'name': 'John',
            'profile': {
              'bio': 'Developer',
            },
          },
        });

        expect(result.isSuccess, true);
      });

      test('required() makes optional properties required', () {
        final schemaWithOptional = Z.object({
          'name': Z.string(),
          'email': Z.string(),
        }, optionalKeys: {
          'email'
        });

        final requiredSchema = schemaWithOptional.required(['email']);

        final result = requiredSchema.validate({'name': 'John'});

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.code,
            equals('missing_required_property'));
      });

      test('extend() adds new properties', () {
        final extendedSchema = baseSchema.extend({
          'address': Z.string(),
          'city': Z.string(),
        });

        final result = extendedSchema.validate({
          'name': 'John',
          'age': 25,
          'email': 'john@example.com',
          'phone': '123-456-7890',
          'address': '123 Main St',
          'city': 'New York',
        });

        expect(result.isSuccess, true);
        expect(result.data!['address'], equals('123 Main St'));
        expect(result.data!['city'], equals('New York'));
      });

      test('merge() combines two object schemas', () {
        final schema1 = Z.object({
          'name': Z.string(),
          'age': Z.number(),
        });

        final schema2 = Z.object({
          'email': Z.string(),
          'phone': Z.string(),
        });

        final mergedSchema = schema1.merge(schema2);

        final result = mergedSchema.validate({
          'name': 'John',
          'age': 25,
          'email': 'john@example.com',
          'phone': '123-456-7890',
        });

        expect(result.isSuccess, true);
        expect(result.data!.keys.length, equals(4));
      });
    });

    group('Advanced Object Features', () {
      test('passthrough() allows unknown properties', () {
        final schema = Z.object({
          'name': Z.string(),
        }).passthrough();

        final result = schema.validate({
          'name': 'John',
          'extraProperty': 'extra value',
          'anotherExtra': 42,
        });

        expect(result.isSuccess, true);
        expect(result.data!['extraProperty'], equals('extra value'));
        expect(result.data!['anotherExtra'], equals(42));
      });

      test('strict() rejects unknown properties', () {
        final schema = Z.object({
          'name': Z.string(),
        }).strict();

        final result = schema.validate({
          'name': 'John',
          'extraProperty': 'extra value',
        });

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.code, equals('unknown_property'));
      });

      test('strip() removes unknown properties', () {
        final schema = Z.object({
          'name': Z.string(),
        }).strip();

        final result = schema.validate({
          'name': 'John',
          'extraProperty': 'extra value',
        });

        expect(result.isSuccess, true);
        expect(result.data, equals({'name': 'John'}));
        expect(result.data!.containsKey('extraProperty'), false);
      });

      test('catchall() validates unknown properties', () {
        final schema = Z.object({
          'name': Z.string(),
        }).catchall(Z.number());

        final result1 = schema.validate({
          'name': 'John',
          'score': 85,
          'rating': 95,
        });

        final result2 = schema.validate({
          'name': 'John',
          'invalidExtra': 'not a number',
        });

        expect(result1.isSuccess, true);
        expect(result1.data!['score'], equals(85));
        expect(result1.data!['rating'], equals(95));

        expect(result2.isSuccess, false);
      });
    });

    group('Object Constraints', () {
      test('containsKeys() validates presence of specific keys', () {
        final schema = Z.object({
          'name': Z.string(),
          'age': Z.number(),
          'email': Z.string(),
        }).containsKeys(['name', 'email']);

        final result1 = schema.validate({
          'name': 'John',
          'age': 25,
          'email': 'john@example.com',
        });

        final result2 = schema.validate({
          'name': 'John',
          'age': 25,
        });

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('minProperties() validates minimum number of properties', () {
        final schema = Z
            .object({
              'name': Z.string(),
              'age': Z.number(),
            })
            .partial()
            .minProperties(1);

        final result1 = schema.validate({'name': 'John'});
        final result2 = schema.validate({});

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('maxProperties() validates maximum number of properties', () {
        final schema = Z
            .object({
              'name': Z.string(),
            })
            .passthrough()
            .maxProperties(2);

        final result1 = schema.validate({
          'name': 'John',
          'extra': 'value',
        });

        final result2 = schema.validate({
          'name': 'John',
          'extra1': 'value1',
          'extra2': 'value2',
        });

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('nonempty() rejects empty objects', () {
        final schema = Z
            .object({
              'name': Z.string(),
            })
            .partial()
            .nonempty();

        final result1 = schema.validate({'name': 'John'});
        final result2 = schema.validate({});

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });
    });

    group('Object Transformations', () {
      test('mapValues() transforms all object values', () {
        final schema = Z.object({
          'count1': Z.number(),
          'count2': Z.number(),
        }).mapValues<int>((value) => (value as num).toInt() * 2);

        final result = schema.validate({
          'count1': 5.5,
          'count2': 10.7,
        });

        expect(result.isSuccess, true);
        expect(result.data!['count1'], equals(10));
        expect(result.data!['count2'], equals(20));
      });

      test('filterKeys() removes properties based on predicate', () {
        final schema = Z.object({
          'name': Z.string(),
          'age': Z.number(),
          'email': Z.string(),
        }).filterKeys(
            (key, value) => key.startsWith('n') || key.startsWith('e'));

        final result = schema.validate({
          'name': 'John',
          'age': 25,
          'email': 'john@example.com',
        });

        expect(result.isSuccess, true);
        expect(result.data!.keys, equals(['name', 'email']));
        expect(result.data!.containsKey('age'), false);
      });
    });

    group('Error Handling', () {
      test('provides detailed error paths for nested objects', () {
        final schema = Z.object({
          'user': Z.object({
            'profile': Z.object({
              'name': Z.string(),
            }),
          }),
        });

        final result = schema.validate({
          'user': {
            'profile': {
              'name': 123, // Should be string
            },
          },
        });

        expect(result.isSuccess, false);
        final error = result.errors!.errors.first;
        expect(error.path, equals(['user', 'profile', 'name']));
      });

      test('handles multiple validation errors', () {
        final schema = Z.object({
          'name': Z.string(),
          'age': Z.number(),
          'email': Z.string(),
        });

        final result = schema.validate({
          'name': 123, // Should be string
          'age': 'not a number', // Should be number
          'email': 'john@example.com',
        });

        expect(result.isSuccess, false);
        expect(result.errors!.errors.length, equals(2));
      });
    });

    group('Type Safety and Metadata', () {
      test('maintains type safety with generics', () {
        final schema = Z.object({
          'name': Z.string(),
          'age': Z.number(),
        });

        final result = schema.validate({
          'name': 'John',
          'age': 25,
        });

        expect(result.isSuccess, true);
        expect(result.data!['name'] is String, true);
        expect(result.data!['age'] is num, true);
      });

      test('provides access to shape and metadata', () {
        final schema = Z.object({
          'name': Z.string(),
          'age': Z.number(),
        }, optionalKeys: {
          'age'
        });

        expect(schema.shape.keys, equals(['name', 'age']));
        expect(schema.requiredKeys, equals({'name'}));
        expect(schema.optionalKeys, equals({'age'}));
        expect(schema.mode, equals(ObjectMode.passthrough));
      });
    });

    group('toString and Equality', () {
      test('provides meaningful toString representation', () {
        final schema = Z.object({
          'name': Z.string(),
          'age': Z.number(),
          'email': Z.string(),
        }, optionalKeys: {
          'email'
        }).strict();

        final str = schema.toString();
        expect(str, contains('ObjectSchema'));
        expect(str, contains('required: 2'));
        expect(str, contains('optional: 1'));
        expect(str, contains('strict'));
      });

      test('supports equality comparison', () {
        final schema1 = Z.object({
          'name': Z.string(),
          'age': Z.number(),
        });

        final schema2 = Z.object({
          'name': Z.string(),
          'age': Z.number(),
        });

        final schema3 = Z.object({
          'name': Z.string(),
          'email': Z.string(),
        });

        expect(schema1 == schema2, true);
        expect(schema1 == schema3, false);
      });
    });

    group('Factory Methods', () {
      test('creates simple object schema', () {
        final schema = ObjectFactories.simple({
          'name': Z.string(),
        });

        final result = schema.validate({'name': 'John'});
        expect(result.isSuccess, true);
      });

      test('creates object schema with optional properties', () {
        final schema = ObjectFactories.withOptional({
          'name': Z.string(),
          'email': Z.string(),
        }, {
          'email'
        });

        final result = schema.validate({'name': 'John'});
        expect(result.isSuccess, true);
      });

      test('creates strict object schema', () {
        final schema = ObjectFactories.strictObject({
          'name': Z.string(),
        });

        final result = schema.validate({
          'name': 'John',
          'extra': 'value',
        });

        expect(result.isSuccess, false);
      });

      test('creates partial object schema', () {
        final schema = ObjectFactories.partialObject({
          'name': Z.string(),
          'age': Z.number(),
        });

        final result = schema.validate({});
        expect(result.isSuccess, true);
      });

      test('creates empty object schema', () {
        final schema = ObjectFactories.empty();

        final result = schema.validate({});
        expect(result.isSuccess, true);
      });
    });
  });
}
