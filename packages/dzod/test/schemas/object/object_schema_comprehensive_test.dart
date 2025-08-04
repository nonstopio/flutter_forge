import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('ObjectSchema Comprehensive Tests', () {
    group('Object Modes', () {
      test('passthrough mode allows unknown properties by default', () {
        final schema = z.object({
          'name': z.string(),
        });

        final result = schema.validate({
          'name': 'John',
          'age': 25,
          'unknown': 'value',
        });

        expect(result.isSuccess, true);
        expect(result.data!['name'], 'John');
        expect(result.data!['age'], 25);
        expect(result.data!['unknown'], 'value');
      });

      test('strict mode rejects unknown properties', () {
        final schema = z.object({
          'name': z.string(),
        }).strict();

        final result = schema.validate({
          'name': 'John',
          'age': 25,
        });

        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'unknown_property');
        expect(result.errors?.first?.context?['allowedKeys'], ['name']);
      });

      test('strip mode removes unknown properties', () {
        final schema = z.object({
          'name': z.string(),
        }).strip();

        final result = schema.validate({
          'name': 'John',
          'age': 25,
          'unknown': 'value',
        });

        expect(result.isSuccess, true);
        expect(result.data!['name'], 'John');
        expect(result.data!.containsKey('age'), false);
        expect(result.data!.containsKey('unknown'), false);
      });

      test('passthrough mode with catchall schema validates unknown properties',
          () {
        final schema = z.object({
          'name': z.string(),
        }).passthrough(z.number());

        final result1 = schema.validate({
          'name': 'John',
          'age': 25,
        });

        final result2 = schema.validate({
          'name': 'John',
          'invalid': 'not a number',
        });

        expect(result1.isSuccess, true);
        expect(result1.data!['age'], 25);

        expect(result2.isFailure, true);
      });

      test('catchall method sets passthrough mode with catchall schema', () {
        final schema = z.object({
          'name': z.string(),
        }).catchall(z.string());

        final result = schema.validate({
          'name': 'John',
          'description': 'A person',
          'note': 'Additional info',
        });

        expect(result.isSuccess, true);
        expect(result.data!['description'], 'A person');
        expect(result.data!['note'], 'Additional info');
      });
    });

    group('Partial and Deep Partial', () {
      test('partial makes all properties optional', () {
        final schema = z.object({
          'name': z.string(),
          'age': z.number(),
          'email': z.string(),
        }).partial();

        final result1 = schema.validate({});
        final result2 = schema.validate({'name': 'John'});
        final result3 = schema.validate({'name': 'John', 'age': 25});

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, true);
        expect(result3.isSuccess, true);
      });

      test('deepPartial makes nested objects partial too', () {
        final schema = z.object({
          'user': z.object({
            'name': z.string(),
            'profile': z.object({
              'bio': z.string(),
              'website': z.string(),
            }),
          }),
        }).deepPartial();

        final result = schema.validate({
          'user': {
            'profile': {
              'bio': 'Developer',
            },
          },
        });

        expect(result.isSuccess, true);
        expect(result.data!['user']['profile']['bio'], 'Developer');
      });

      test('isPartial and isDeepPartial getters work correctly', () {
        final baseSchema = z.object({'name': z.string()});
        final partialSchema = baseSchema.partial();
        final deepPartialSchema = baseSchema.deepPartial();

        expect(baseSchema.isPartial, false);
        expect(baseSchema.isDeepPartial, false);
        expect(partialSchema.isPartial, true);
        expect(partialSchema.isDeepPartial, false);
        expect(deepPartialSchema.isPartial, true);
        expect(deepPartialSchema.isDeepPartial, true);
      });
    });

    group('Required Method', () {
      test('required makes all properties required', () {
        final schema = z.object({
          'name': z.string(),
          'age': z.number(),
        }, optionalKeys: {
          'age'
        }).required();

        final result = schema.validate({'name': 'John'});

        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'missing_required_property');
      });

      test('required with specific keys makes only those required', () {
        final schema = z.object({
          'name': z.string(),
          'age': z.number(),
          'email': z.string(),
        }, optionalKeys: {
          'age',
          'email'
        }).required(['age']);

        final result1 = schema.validate({'name': 'John', 'age': 25});
        final result2 = schema.validate({'name': 'John'});

        expect(result1.isSuccess, true);
        expect(result2.isFailure, true);
      });
    });

    group('Pick and Omit', () {
      test('pick creates schema with only specified properties', () {
        final baseSchema = z.object({
          'name': z.string(),
          'age': z.number(),
          'email': z.string(),
        }, optionalKeys: {
          'email'
        });

        final pickedSchema = baseSchema.pick(['name', 'email']);

        final result = pickedSchema.validate({
          'name': 'John',
          'email': 'john@example.com',
        });

        expect(result.isSuccess, true);
        expect(pickedSchema.shape.keys, {'name', 'email'});
        expect(pickedSchema.optionalKeys, {'email'});
      });

      test('omit creates schema excluding specified properties', () {
        final baseSchema = z.object({
          'name': z.string(),
          'age': z.number(),
          'email': z.string(),
        }, optionalKeys: {
          'email'
        });

        final omittedSchema = baseSchema.omit(['email']);

        final result = omittedSchema.validate({
          'name': 'John',
          'age': 25,
        });

        expect(result.isSuccess, true);
        expect(omittedSchema.shape.keys, {'name', 'age'});
        expect(omittedSchema.optionalKeys.contains('email'), false);
      });
    });

    group('Extend and Merge', () {
      test('extend adds new properties to schema', () {
        final baseSchema = z.object({
          'name': z.string(),
        });

        final extendedSchema = baseSchema.extend({
          'age': z.number(),
          'email': z.string(),
        }, additionalOptionalKeys: {
          'email'
        });

        final result = extendedSchema.validate({
          'name': 'John',
          'age': 25,
        });

        expect(result.isSuccess, true);
        expect(extendedSchema.shape.keys, {'name', 'age', 'email'});
        expect(extendedSchema.optionalKeys, {'email'});
      });

      test('merge combines two object schemas', () {
        final schema1 = z.object({
          'name': z.string(),
          'age': z.number(),
        }, optionalKeys: {
          'age'
        });

        final schema2 = z.object({
          'email': z.string(),
          'phone': z.string(),
        }, optionalKeys: {
          'phone'
        });

        final mergedSchema = schema1.merge(schema2);

        final result = mergedSchema.validate({
          'name': 'John',
          'email': 'john@example.com',
        });

        expect(result.isSuccess, true);
        expect(mergedSchema.shape.keys, {'name', 'age', 'email', 'phone'});
        expect(mergedSchema.optionalKeys, {'age', 'phone'});
      });

      test('merge preserves partial mode from either schema', () {
        final schema1 = z.object({'name': z.string()});
        final schema2 = z.object({'age': z.number()}).partial();

        final mergedSchema = schema1.merge(schema2);

        expect(mergedSchema.isPartial, true);
      });
    });

    group('Property Validation Methods', () {
      test('containsKeys validates required keys presence', () {
        final schema = z
            .object({
              'name': z.string(),
            }, optionalKeys: {})
            .passthrough()
            .containsKeys(['name', 'description']);

        final result1 =
            schema.validate({'name': 'John', 'description': 'A person'});
        final result2 = schema.validate({'name': 'John'});

        expect(result1.isSuccess, true);
        expect(result2.isFailure, true);
        expect(result2.errors?.first?.code, 'missing_keys');
      });

      test('minProperties validates minimum property count', () {
        final schema = z.object({
          'name': z.string(),
          'age': z.number(),
        }, optionalKeys: {
          'age'
        }).minProperties(2);

        final result1 = schema.validate({'name': 'John', 'age': 25});
        final result2 = schema.validate({'name': 'John'});

        expect(result1.isSuccess, true);
        expect(result2.isFailure, true);
        expect(result2.errors?.first?.code, 'too_few_properties');
      });

      test('maxProperties validates maximum property count', () {
        final schema = z.object({}).passthrough().maxProperties(2);

        final result1 = schema.validate({'a': 1, 'b': 2});
        final result2 = schema.validate({'a': 1, 'b': 2, 'c': 3});

        expect(result1.isSuccess, true);
        expect(result2.isFailure, true);
        expect(result2.errors?.first?.code, 'too_many_properties');
      });

      test('nonempty validates non-empty objects', () {
        final schema = z.object({}, optionalKeys: {}).nonempty();

        final result1 = schema.validate({'key': 'value'});
        final result2 = schema.validate({});

        expect(result1.isSuccess, true);
        expect(result2.isFailure, true);
      });
    });

    group('Transformation Methods', () {
      test('mapValues transforms all values', () {
        final schema = z.object({
          'name': z.string(),
          'age': z.number(),
        }).mapValues<String>((value) => value.toString());

        final result = schema.validate({'name': 'John', 'age': 25});

        expect(result.isSuccess, true);
        expect(result.data!['name'], 'John');
        expect(result.data!['age'], '25');
      });

      test('filterKeys filters properties based on predicate', () {
        final schema = z.object({}).passthrough().filterKeys(
              (key, value) => key.startsWith('keep'),
            );

        final result = schema.validate({
          'keepThis': 'value1',
          'keepThat': 'value2',
          'removeThis': 'value3',
        });

        expect(result.isSuccess, true);
        expect(result.data!.keys, {'keepThis', 'keepThat'});
        expect(result.data!.containsKey('removeThis'), false);
      });
    });

    group('Getters and Properties', () {
      test('shape getter returns unmodifiable shape', () {
        final schema = z.object({
          'name': z.string(),
          'age': z.number(),
        });

        final shape = schema.shape;
        expect(shape.keys, {'name', 'age'});
        expect(() => shape['newKey'] = z.string(), throwsUnsupportedError);
      });

      test('optionalKeys getter returns unmodifiable set', () {
        final schema = z.object({
          'name': z.string(),
          'age': z.number(),
        }, optionalKeys: {
          'age'
        });

        final optionalKeys = schema.optionalKeys;
        expect(optionalKeys, {'age'});
        expect(() => optionalKeys.add('name'), throwsUnsupportedError);
      });

      test('requiredKeys getter returns correct keys', () {
        final schema = z.object({
          'name': z.string(),
          'age': z.number(),
          'email': z.string(),
        }, optionalKeys: {
          'email'
        });

        expect(schema.requiredKeys, {'name', 'age'});
      });

      test('mode getter returns current mode', () {
        final schema = z.object({'name': z.string()});
        final strictSchema = schema.strict();
        final stripSchema = schema.strip();

        expect(schema.mode, ObjectMode.passthrough);
        expect(strictSchema.mode, ObjectMode.strict);
        expect(stripSchema.mode, ObjectMode.strip);
      });

      test('catchallSchema getter returns catchall schema', () {
        final catchallSchema = z.string();
        final schema = z.object({'name': z.string()}).catchall(catchallSchema);

        expect(schema.catchallSchema, catchallSchema);
      });
    });

    group('Async Validation', () {
      test('validateAsync works with async schemas', () async {
        final schema = z.object({
          'name': z.string(),
          'age': z.number(),
        });

        final result = await schema.validateAsync({
          'name': 'John',
          'age': 25,
        });

        expect(result.isSuccess, true);
        expect(result.data!['name'], 'John');
      });

      test('validateAsync handles missing required properties', () async {
        final schema = z.object({
          'name': z.string(),
          'age': z.number(),
        });

        final result = await schema.validateAsync({'name': 'John'});

        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'missing_required_property');
      });

      test('validateAsync handles strict mode', () async {
        final schema = z.object({
          'name': z.string(),
        }).strict();

        final result = await schema.validateAsync({
          'name': 'John',
          'age': 25,
        });

        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'unknown_property');
      });

      test('validateAsync handles strip mode', () async {
        final schema = z.object({
          'name': z.string(),
        }).strip();

        final result = await schema.validateAsync({
          'name': 'John',
          'age': 25,
        });

        expect(result.isSuccess, true);
        expect(result.data!.containsKey('age'), false);
      });

      test('validateAsync handles catchall schema', () async {
        final schema = z.object({
          'name': z.string(),
        }).catchall(z.number());

        final result = await schema.validateAsync({
          'name': 'John',
          'age': 25,
        });

        expect(result.isSuccess, true);
        expect(result.data!['age'], 25);
      });

      test('validateAsync handles deep partial mode', () async {
        final schema = z.object({
          'user': z.object({
            'name': z.string(),
            'profile': z.object({
              'bio': z.string(),
            }),
          }),
        }).deepPartial();

        final result = await schema.validateAsync({
          'user': {
            'profile': {},
          },
        });

        expect(result.isSuccess, true);
      });
    });

    group('toString Method', () {
      test('displays correct information', () {
        final schema1 = z.object({
          'name': z.string(),
          'age': z.number(),
        });

        final schema2 = z.object({
          'name': z.string(),
          'age': z.number(),
          'email': z.string(),
        }, optionalKeys: {
          'email'
        }).strict();

        final schema3 = z.object({
          'name': z.string(),
        }).partial();

        expect(schema1.toString(), 'ObjectSchema{required: 2, optional: 0}');
        expect(schema2.toString(),
            'ObjectSchema{required: 2, optional: 1 (strict)}');
        expect(schema3.toString(),
            'ObjectSchema{required: 0, optional: 1 partial}');
      });

      test('displays deep partial mode', () {
        final schema = z.object({
          'name': z.string(),
        }).deepPartial();

        expect(schema.toString(), contains('deep-partial'));
      });
    });

    group('Equality and HashCode', () {
      test('equal schemas have same equality and hash', () {
        final schema1 = z.object({
          'name': z.string(),
          'age': z.number(),
        }, optionalKeys: {
          'age'
        });

        final schema2 = z.object({
          'name': z.string(),
          'age': z.number(),
        }, optionalKeys: {
          'age'
        });

        expect(schema1 == schema2, true);
        expect(schema1.hashCode == schema2.hashCode, true);
      });

      test('different schemas are not equal', () {
        final schema1 = z.object({'name': z.string()});
        final schema2 = z.object({'age': z.number()});
        final schema3 = z.object({'name': z.string()}).strict();

        expect(schema1 == schema2, false);
        expect(schema1 == schema3, false);
      });

      test('identical schemas are equal', () {
        final schema = z.object({'name': z.string()});

        expect(schema == schema, true);
      });
    });

    group('Error Handling and Context', () {
      test('provides detailed error paths for nested validation', () {
        final schema = z.object({
          'user': z.object({
            'profile': z.object({
              'age': z.number(),
            }),
          }),
        });

        final result = schema.validate({
          'user': {
            'profile': {
              'age': 'not a number',
            },
          },
        });

        expect(result.isFailure, true);
        expect(result.errors?.first?.path, ['user', 'profile', 'age']);
      });

      test('provides context for missing required properties', () {
        final schema = z.object({
          'name': z.string(),
          'age': z.number(),
        });

        final result = schema.validate({'name': 'John'});

        expect(result.isFailure, true);
        expect(result.errors?.first?.context?['missingKey'], 'age');
      });

      test('provides context for unknown properties in strict mode', () {
        final schema = z.object({
          'name': z.string(),
        }).strict();

        final result = schema.validate({
          'name': 'John',
          'unknown': 'value',
        });

        expect(result.isFailure, true);
        expect(result.errors?.first?.context?['allowedKeys'], ['name']);
      });
    });

    group('Factory Methods', () {
      test('ObjectFactories.simple creates basic object schema', () {
        final schema = ObjectFactories.simple({
          'name': z.string(),
          'age': z.number(),
        });

        final result = schema.validate({'name': 'John', 'age': 25});

        expect(result.isSuccess, true);
        expect(schema.mode, ObjectMode.passthrough);
      });

      test('ObjectFactories.withOptional creates schema with optional keys',
          () {
        final schema = ObjectFactories.withOptional({
          'name': z.string(),
          'age': z.number(),
        }, {
          'age'
        });

        final result = schema.validate({'name': 'John'});

        expect(result.isSuccess, true);
        expect(schema.optionalKeys, {'age'});
      });

      test('ObjectFactories.strictObject creates strict schema', () {
        final schema = ObjectFactories.strictObject({
          'name': z.string(),
        });

        final result = schema.validate({
          'name': 'John',
          'age': 25,
        });

        expect(result.isFailure, true);
        expect(schema.mode, ObjectMode.strict);
      });

      test('ObjectFactories.partialObject creates partial schema', () {
        final schema = ObjectFactories.partialObject({
          'name': z.string(),
          'age': z.number(),
        });

        final result = schema.validate({});

        expect(result.isSuccess, true);
        expect(schema.isPartial, true);
      });

      test('ObjectFactories.empty creates empty schema', () {
        final schema = ObjectFactories.empty();

        final result = schema.validate({});

        expect(result.isSuccess, true);
        expect(schema.shape.isEmpty, true);
      });
    });

    group('Edge Cases', () {
      test('handles null input correctly', () {
        final schema = z.object({'name': z.string()});

        final result = schema.validate(null);

        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'type_mismatch');
      });

      test('handles empty object validation', () {
        final schema = z.object({});

        final result = schema.validate({});

        expect(result.isSuccess, true);
        expect(result.data, {});
      });

      test('preserves original Map type information where possible', () {
        final schema = z.object({'name': z.string()});

        final result = schema.validate({'name': 'John', 'age': 25});

        expect(result.isSuccess, true);
        expect(result.data, isA<Map<String, dynamic>>());
      });
    });
  });
}
