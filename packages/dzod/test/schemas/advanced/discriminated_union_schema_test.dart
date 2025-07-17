import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('DiscriminatedUnionSchema', () {
    group('Basic Validation', () {
      test('should validate correct discriminated union values', () {
        final schema = Z.discriminatedUnion('type', [
          Z.object({
            'type': Z.literal('user'),
            'name': Z.string(),
          }),
          Z.object({
            'type': Z.literal('admin'),
            'role': Z.string(),
          }),
        ]);

        // Test user type
        final userResult = schema.parse({
          'type': 'user',
          'name': 'John Doe',
        });
        expect(userResult['type'], equals('user'));
        expect(userResult['name'], equals('John Doe'));

        // Test admin type
        final adminResult = schema.parse({
          'type': 'admin',
          'role': 'super',
        });
        expect(adminResult['type'], equals('admin'));
        expect(adminResult['role'], equals('super'));
      });

      test('should fail validation with missing discriminator', () {
        final schema = Z.discriminatedUnion('type', [
          Z.object({
            'type': Z.literal('user'),
            'name': Z.string(),
          }),
        ]);

        expect(
          () => schema.parse({'name': 'John'}),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should fail validation with invalid discriminator value', () {
        final schema = Z.discriminatedUnion('type', [
          Z.object({
            'type': Z.literal('user'),
            'name': Z.string(),
          }),
        ]);

        expect(
          () => schema.parse({
            'type': 'invalid',
            'name': 'John',
          }),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should fail validation with non-object input', () {
        final schema = Z.discriminatedUnion('type', [
          Z.object({
            'type': Z.literal('user'),
            'name': Z.string(),
          }),
        ]);

        expect(
          () => schema.parse('invalid'),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('Advanced Features', () {
      test('should work with numeric discriminators', () {
        final schema = Z.discriminatedUnion('status', [
          Z.object({
            'status': Z.literal(1),
            'active': Z.boolean(),
          }),
          Z.object({
            'status': Z.literal(2),
            'pending': Z.boolean(),
          }),
        ]);

        final result = schema.parse({
          'status': 1,
          'active': true,
        });
        expect(result['status'], equals(1));
        expect(result['active'], equals(true));
      });

      test('should work with multiple schemas per discriminator', () {
        final schema = Z.discriminatedUnion('category', [
          Z.object({
            'category': Z.literal('product'),
            'name': Z.string(),
            'price': Z.number(),
          }),
          Z.object({
            'category': Z.literal('service'),
            'name': Z.string(),
            'duration': Z.number(),
          }),
          Z.object({
            'category': Z.literal('digital'),
            'name': Z.string(),
            'downloadUrl': Z.string(),
          }),
        ]);

        // Test all variants
        expect(
          schema.parse({
            'category': 'product',
            'name': 'Widget',
            'price': 99.99,
          })['category'],
          equals('product'),
        );

        expect(
          schema.parse({
            'category': 'service',
            'name': 'Consultation',
            'duration': 60,
          })['category'],
          equals('service'),
        );

        expect(
          schema.parse({
            'category': 'digital',
            'name': 'E-book',
            'downloadUrl': 'https://example.com/ebook.pdf',
          })['category'],
          equals('digital'),
        );
      });
    });

    group('Schema Methods', () {
      late DiscriminatedUnionSchema<Map<String, dynamic>> baseSchema;

      setUp(() {
        baseSchema = Z.discriminatedUnion('type', [
          Z.object({
            'type': Z.literal('user'),
            'name': Z.string(),
          }),
          Z.object({
            'type': Z.literal('admin'),
            'role': Z.string(),
          }),
          Z.object({
            'type': Z.literal('guest'),
            'permissions': Z.array(Z.string()),
          }),
        ]);
      });

      test('should get discriminator field name', () {
        expect(baseSchema.discriminator, equals('type'));
      });

      test('should get valid discriminator values', () {
        final values = baseSchema.validDiscriminatorValues;
        expect(values, containsAll(['user', 'admin', 'guest']));
      });

      test('should check if discriminator value is valid', () {
        expect(baseSchema.hasDiscriminatorValue('user'), isTrue);
        expect(baseSchema.hasDiscriminatorValue('admin'), isTrue);
        expect(baseSchema.hasDiscriminatorValue('invalid'), isFalse);
      });

      test('should get schema for specific discriminator value', () {
        final userSchema = baseSchema.getSchemaForDiscriminator('user');
        expect(userSchema, isNotNull);

        final invalidSchema = baseSchema.getSchemaForDiscriminator('invalid');
        expect(invalidSchema, isNull);
      });

      test('should extend with additional schemas', () {
        final extendedSchema = baseSchema.extend([
          Z.object({
            'type': Z.literal('moderator'),
            'level': Z.number(),
          }),
        ]);

        expect(extendedSchema.validDiscriminatorValues,
            containsAll(['user', 'admin', 'guest', 'moderator']));
        expect(extendedSchema.hasDiscriminatorValue('moderator'), isTrue);
      });

      test('should exclude schemas by discriminator values', () {
        final excludedSchema = baseSchema.exclude(['guest']);

        expect(excludedSchema.validDiscriminatorValues,
            containsAll(['user', 'admin']));
        expect(excludedSchema.hasDiscriminatorValue('guest'), isFalse);
      });

      test('should include only specific schemas', () {
        final includedSchema = baseSchema.include(['user', 'admin']);

        expect(includedSchema.validDiscriminatorValues,
            containsAll(['user', 'admin']));
        expect(includedSchema.hasDiscriminatorValue('guest'), isFalse);
      });

      test('should filter by discriminator values (discriminatorIn)', () {
        final filteredSchema = baseSchema.discriminatorIn(['user']);

        expect(filteredSchema.validDiscriminatorValues, contains('user'));
        expect(filteredSchema.hasDiscriminatorValue('admin'), isFalse);
      });

      test('should exclude discriminator values (discriminatorNotIn)', () {
        final filteredSchema = baseSchema.discriminatorNotIn(['guest']);

        expect(filteredSchema.validDiscriminatorValues,
            containsAll(['user', 'admin']));
        expect(filteredSchema.hasDiscriminatorValue('guest'), isFalse);
      });
    });

    group('Async Validation', () {
      test('should support async validation', () async {
        final schema = Z.discriminatedUnion('type', [
          Z.object({
            'type': Z.literal('user'),
            'email': Z.string().email(),
          }),
        ]);

        final result = await schema.parseAsync({
          'type': 'user',
          'email': 'test@example.com',
        });

        expect(result['type'], equals('user'));
        expect(result['email'], equals('test@example.com'));
      });

      test('should handle async validation errors', () async {
        final schema = Z.discriminatedUnion('type', [
          Z.object({
            'type': Z.literal('user'),
            'email': Z.string().email(),
          }),
        ]);

        await expectLater(
          schema.parseAsync({
            'type': 'invalid',
            'email': 'test@example.com',
          }),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('Error Handling', () {
      test('should provide detailed error messages for missing discriminator',
          () {
        final schema = Z.discriminatedUnion('category', [
          Z.object({
            'category': Z.literal('A'),
            'value': Z.string(),
          }),
        ]);

        final result = schema.validate({'value': 'test'});
        expect(result.isFailure, isTrue);

        final errors = result.errors!.errors;
        expect(errors.length, equals(1));
        expect(
            errors.first.code,
            equals(ValidationErrorCode
                .discriminatedUnionMissingDiscriminator.code));
      });

      test('should provide detailed error messages for invalid discriminator',
          () {
        final schema = Z.discriminatedUnion('category', [
          Z.object({
            'category': Z.literal('A'),
            'value': Z.string(),
          }),
        ]);

        final result = schema.validate({
          'category': 'invalid',
          'value': 'test',
        });
        expect(result.isFailure, isTrue);

        final errors = result.errors!.errors;
        expect(errors.length, equals(1));
        expect(
            errors.first.code,
            equals(ValidationErrorCode
                .discriminatedUnionInvalidDiscriminator.code));
      });
    });

    group('Metadata and Statistics', () {
      test('should provide schema statistics', () {
        final schema = Z.discriminatedUnion('type', [
          Z.object({'type': Z.literal('A'), 'value': Z.string()}),
          Z.object({'type': Z.literal('B'), 'value': Z.number()}),
        ]);

        final stats = schema.statistics;
        expect(stats['discriminator'], equals('type'));
        expect(stats['schemaCount'], equals(2));
        expect(stats['validDiscriminatorValues'], containsAll(['A', 'B']));
        expect(stats['schemaTypes'], hasLength(2));
      });

      test('should provide schema mapping', () {
        final schema = Z.discriminatedUnion('type', [
          Z.object({'type': Z.literal('A'), 'value': Z.string()}),
        ]);

        final mapping = schema.schemaMapping;
        expect(mapping.containsKey('A'), isTrue);
        expect(mapping['A'], isNotNull);
      });

      test('should have correct schema type', () {
        final schema = Z.discriminatedUnion('type', [
          Z.object({'type': Z.literal('A'), 'value': Z.string()}),
        ]);

        expect(schema.schemaType, equals('DiscriminatedUnionSchema'));
      });

      test('should have proper string representation', () {
        final schema = Z.discriminatedUnion('type', [
          Z.object({'type': Z.literal('A'), 'value': Z.string()}),
          Z.object({'type': Z.literal('B'), 'value': Z.number()}),
        ]);

        final str = schema.toString();
        expect(str, contains('DiscriminatedUnionSchema'));
        expect(str, contains('type'));
        expect(str, contains('2 schemas'));
      });
    });

    group('Equality and Hash Code', () {
      test('should implement equality correctly', () {
        final schema1 = Z.discriminatedUnion('type', [
          Z.object({'type': Z.literal('A'), 'value': Z.string()}),
        ]);

        final schema2 = Z.discriminatedUnion('type', [
          Z.object({'type': Z.literal('A'), 'value': Z.string()}),
        ]);

        final schema3 = Z.discriminatedUnion('category', [
          Z.object({'category': Z.literal('A'), 'value': Z.string()}),
        ]);

        expect(schema1, equals(schema1)); // Same instance
        expect(schema1 == schema2, isTrue); // Same structure
        expect(schema1 == schema3, isFalse); // Different discriminator
      });

      test('should implement hash code correctly', () {
        final schema1 = Z.discriminatedUnion('type', [
          Z.object({'type': Z.literal('A'), 'value': Z.string()}),
        ]);

        final schema2 = Z.discriminatedUnion('type', [
          Z.object({'type': Z.literal('A'), 'value': Z.string()}),
        ]);

        expect(schema1.hashCode, equals(schema2.hashCode));
      });
    });

    group('Complex Scenarios', () {
      test('should handle nested discriminated unions', () {
        final innerUnion = Z.discriminatedUnion('subtype', [
          Z.object({
            'subtype': Z.literal('text'),
            'content': Z.string(),
          }),
          Z.object({
            'subtype': Z.literal('image'),
            'url': Z.string(),
          }),
        ]);

        final outerUnion = Z.discriminatedUnion('type', [
          Z.object({
            'type': Z.literal('content'),
            'data': innerUnion,
          }),
          Z.object({
            'type': Z.literal('metadata'),
            'info': Z.string(),
          }),
        ]);

        final result = outerUnion.parse({
          'type': 'content',
          'data': {
            'subtype': 'text',
            'content': 'Hello World',
          },
        });

        expect(result['type'], equals('content'));
        expect(result['data']['subtype'], equals('text'));
        expect(result['data']['content'], equals('Hello World'));
      });

      test('should work with array of discriminated union items', () {
        final itemSchema = Z.discriminatedUnion('type', [
          Z.object({
            'type': Z.literal('product'),
            'name': Z.string(),
            'price': Z.number(),
          }),
          Z.object({
            'type': Z.literal('service'),
            'name': Z.string(),
            'duration': Z.number(),
          }),
        ]);

        final listSchema = Z.array(itemSchema);

        final result = listSchema.parse([
          {
            'type': 'product',
            'name': 'Widget',
            'price': 10.99,
          },
          {
            'type': 'service',
            'name': 'Consultation',
            'duration': 60,
          },
        ]);

        expect(result, hasLength(2));
        expect(result[0]['type'], equals('product'));
        expect(result[1]['type'], equals('service'));
      });

      test('should work with transformation chains', () {
        final schema = Z.discriminatedUnion('type', [
          Z.object({
            'type': Z.literal('user'),
            'name': Z.string(),
          }),
        ]).transform((data) => {
              ...data,
              'processed': true,
            });

        final result = schema.parse({
          'type': 'user',
          'name': 'John',
        });

        expect(result['type'], equals('user'));
        expect(result['name'], equals('John'));
        expect(result['processed'], equals(true));
      });
    });

    group('Boolean Discriminator Edge Cases', () {
      test('should handle boolean discriminators', () {
        final schema = Z.discriminatedUnion('isActive', [
          Z.object({
            'isActive': Z.literal(true),
            'activeData': Z.string(),
          }),
          Z.object({
            'isActive': Z.literal(false),
            'inactiveData': Z.string(),
          }),
        ]);

        final activeResult = schema.parse({
          'isActive': true,
          'activeData': 'active content',
        });
        expect(activeResult['isActive'], equals(true));
        expect(activeResult['activeData'], equals('active content'));

        final inactiveResult = schema.parse({
          'isActive': false,
          'inactiveData': 'inactive content',
        });
        expect(inactiveResult['isActive'], equals(false));
        expect(inactiveResult['inactiveData'], equals('inactive content'));
      });

      test('should handle boolean schemas with mixed literal values', () {
        final schema = Z.discriminatedUnion('flag', [
          Z.object({
            'flag': Z
                .boolean()
                .refine((val) => val == true, message: 'Must be true'),
            'trueData': Z.string(),
          }),
          Z.object({
            'flag': Z
                .boolean()
                .refine((val) => val == false, message: 'Must be false'),
            'falseData': Z.string(),
          }),
        ]);

        final trueResult = schema.parse({
          'flag': true,
          'trueData': 'true content',
        });
        expect(trueResult['flag'], equals(true));
        expect(trueResult['trueData'], equals('true content'));

        final falseResult = schema.parse({
          'flag': false,
          'falseData': 'false content',
        });
        expect(falseResult['flag'], equals(false));
        expect(falseResult['falseData'], equals('false content'));
      });
    });

    group('Literal Value Extraction Edge Cases', () {
      test('should handle schemas without literal values', () {
        // This tests the fallback when no literal value can be extracted
        final schema = Z.discriminatedUnion('type', [
          Z.object({
            'type': Z.string(), // Non-literal schema
            'data': Z.string(),
          }),
        ]);

        // This should still work because the discriminator extraction falls back
        final result = schema.parse({
          'type': 'any-value',
          'data': 'test data',
        });
        expect(result['type'], equals('any-value'));
        expect(result['data'], equals('test data'));
      });

      test('should handle non-object schemas', () {
        // This tests when schema is not an ObjectSchema
        final schema = Z.discriminatedUnion('type', [
          Z.string(), // Non-object schema
        ]);

        // This should handle gracefully
        expect(schema.validDiscriminatorValues, isEmpty);
      });

      test('should handle literal extraction from string schemas', () {
        final schema = Z.discriminatedUnion('mode', [
          Z.object({
            'mode': Z.literal('read'),
            'file': Z.string(),
          }),
          Z.object({
            'mode': Z.literal('write'),
            'content': Z.string(),
          }),
        ]);

        final readResult = schema.parse({
          'mode': 'read',
          'file': 'test.txt',
        });
        expect(readResult['mode'], equals('read'));
        expect(readResult['file'], equals('test.txt'));
      });

      test('should handle candidate value testing', () {
        // This tests the candidate value testing logic
        final schema = Z.discriminatedUnion('status', [
          Z.object({
            'status': Z.literal('pending'),
            'message': Z.string(),
          }),
          Z.object({
            'status': Z.literal('approved'),
            'approvedBy': Z.string(),
          }),
          Z.object({
            'status': Z.literal('rejected'),
            'reason': Z.string(),
          }),
        ]);

        expect(schema.hasDiscriminatorValue('pending'), isTrue);
        expect(schema.hasDiscriminatorValue('approved'), isTrue);
        expect(schema.hasDiscriminatorValue('rejected'), isTrue);
        expect(schema.hasDiscriminatorValue('unknown'), isFalse);
      });
    });

    group('Schema Manipulation Edge Cases', () {
      test('should handle extending with duplicate discriminator values', () {
        final baseSchema = Z.discriminatedUnion('type', [
          Z.object({
            'type': Z.literal('user'),
            'name': Z.string(),
          }),
        ]);

        final extendedSchema = baseSchema.extend([
          Z.object({
            'type': Z.literal('user'), // Duplicate discriminator value
            'email': Z.string(),
          }),
        ]);

        // The last schema with the same discriminator should win
        final result = extendedSchema.parse({
          'type': 'user',
          'email': 'test@example.com',
        });
        expect(result['type'], equals('user'));
        expect(result['email'], equals('test@example.com'));
      });

      test('should handle strict mode', () {
        final schema = Z.discriminatedUnion('type', [
          Z.object({
            'type': Z.literal('user'),
            'name': Z.string(),
          }),
        ]).strict();

        final result = schema.parse({
          'type': 'user',
          'name': 'John',
        });
        expect(result['type'], equals('user'));
        expect(result['name'], equals('John'));
      });

      test('should handle empty schema list', () {
        final schema =
            Z.discriminatedUnion('type', <Schema<Map<String, dynamic>>>[]);

        expect(schema.validDiscriminatorValues, isEmpty);
        expect(schema.schemas, isEmpty);
        expect(schema.schemaMapping, isEmpty);
      });

      test('should handle single schema list', () {
        final schema = Z.discriminatedUnion('type', [
          Z.object({
            'type': Z.literal('single'),
            'value': Z.string(),
          }),
        ]);

        expect(schema.validDiscriminatorValues, contains('single'));
        expect(schema.schemas, hasLength(1));
        expect(schema.schemaMapping, hasLength(1));
      });
    });

    group('Error Path Testing', () {
      test('should provide correct error paths for missing discriminator', () {
        final schema = Z.discriminatedUnion('category', [
          Z.object({
            'category': Z.literal('A'),
            'value': Z.string(),
          }),
        ]);

        final result = schema.validate({'value': 'test'});
        expect(result.isFailure, isTrue);
        expect(result.errors!.errors.first.path, isEmpty);
      });

      test('should provide correct error paths for invalid discriminator', () {
        final schema = Z.discriminatedUnion('category', [
          Z.object({
            'category': Z.literal('A'),
            'value': Z.string(),
          }),
        ]);

        final result = schema.validate({
          'category': 'invalid',
          'value': 'test',
        });
        expect(result.isFailure, isTrue);
        expect(result.errors!.errors.first.path, equals(['category']));
      });

      test('should provide correct error paths for nested validation', () {
        final schema = Z.discriminatedUnion('type', [
          Z.object({
            'type': Z.literal('user'),
            'profile': Z.object({
              'name': Z.string(),
              'age': Z.number(),
            }),
          }),
        ]);

        final result = schema.validate({
          'type': 'user',
          'profile': {
            'name': 'John',
            'age': 'invalid', // Should be number
          },
        });
        expect(result.isFailure, isTrue);
        expect(result.errors!.errors.first.path, equals(['profile', 'age']));
      });
    });

    group('Comprehensive Type Testing', () {
      test('should handle all supported discriminator types', () {
        final stringSchema = Z.discriminatedUnion('stringType', [
          Z.object({
            'stringType': Z.literal('string'),
            'value': Z.string(),
          }),
        ]);

        final numberSchema = Z.discriminatedUnion('numberType', [
          Z.object({
            'numberType': Z.literal(42),
            'value': Z.number(),
          }),
        ]);

        final booleanSchema = Z.discriminatedUnion('booleanType', [
          Z.object({
            'booleanType': Z.literal(true),
            'value': Z.boolean(),
          }),
        ]);

        expect(stringSchema.hasDiscriminatorValue('string'), isTrue);
        expect(numberSchema.hasDiscriminatorValue(42), isTrue);
        expect(booleanSchema.hasDiscriminatorValue(true), isTrue);
      });

      test('should handle negative number discriminators', () {
        final schema = Z.discriminatedUnion('id', [
          Z.object({
            'id': Z.literal(-1),
            'errorType': Z.string(),
          }),
          Z.object({
            'id': Z.literal(-2),
            'warningType': Z.string(),
          }),
        ]);

        final result = schema.parse({
          'id': -1,
          'errorType': 'fatal',
        });
        expect(result['id'], equals(-1));
        expect(result['errorType'], equals('fatal'));
      });

      test('should handle zero as discriminator', () {
        final schema = Z.discriminatedUnion('level', [
          Z.object({
            'level': Z.literal(0),
            'message': Z.string(),
          }),
        ]);

        final result = schema.parse({
          'level': 0,
          'message': 'baseline',
        });
        expect(result['level'], equals(0));
        expect(result['message'], equals('baseline'));
      });
    });

    group('Schema Properties Access', () {
      test('should provide access to all schema properties', () {
        final schema = Z.discriminatedUnion('type', [
          Z.object({
            'type': Z.literal('A'),
            'value': Z.string(),
          }),
          Z.object({
            'type': Z.literal('B'),
            'value': Z.number(),
          }),
        ]);

        expect(schema.schemas, hasLength(2));
        expect(schema.discriminator, equals('type'));
        expect(schema.validDiscriminatorValues, containsAll(['A', 'B']));
        expect(schema.schemaMapping, hasLength(2));
        expect(schema.statistics['discriminator'], equals('type'));
        expect(schema.statistics['schemaCount'], equals(2));
      });

      test('should handle schema with description and metadata', () {
        final schema = Z.discriminatedUnion(
          'type',
          [
            Z.object({
              'type': Z.literal('test'),
              'value': Z.string(),
            }),
          ],
          description: 'Test discriminated union',
          metadata: {'version': '1.0'},
        );

        expect(schema.description, equals('Test discriminated union'));
        expect(schema.metadata, equals({'version': '1.0'}));
        expect(schema.toString(), contains('Test discriminated union'));
      });
    });
  });
}
