import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('DiscriminatedUnionSchema', () {
    group('Basic Validation', () {
      test('should validate correct discriminated union values', () {
        final schema = z.discriminatedUnion('type', [
          z.object({
            'type': z.literal('user'),
            'name': z.string(),
          }),
          z.object({
            'type': z.literal('admin'),
            'role': z.string(),
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
        final schema = z.discriminatedUnion('type', [
          z.object({
            'type': z.literal('user'),
            'name': z.string(),
          }),
        ]);

        expect(
          () => schema.parse({'name': 'John'}),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should fail validation with invalid discriminator value', () {
        final schema = z.discriminatedUnion('type', [
          z.object({
            'type': z.literal('user'),
            'name': z.string(),
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
        final schema = z.discriminatedUnion('type', [
          z.object({
            'type': z.literal('user'),
            'name': z.string(),
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
        final schema = z.discriminatedUnion('status', [
          z.object({
            'status': z.literal(1),
            'active': z.boolean(),
          }),
          z.object({
            'status': z.literal(2),
            'pending': z.boolean(),
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
        final schema = z.discriminatedUnion('category', [
          z.object({
            'category': z.literal('product'),
            'name': z.string(),
            'price': z.number(),
          }),
          z.object({
            'category': z.literal('service'),
            'name': z.string(),
            'duration': z.number(),
          }),
          z.object({
            'category': z.literal('digital'),
            'name': z.string(),
            'downloadUrl': z.string(),
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
        baseSchema = z.discriminatedUnion('type', [
          z.object({
            'type': z.literal('user'),
            'name': z.string(),
          }),
          z.object({
            'type': z.literal('admin'),
            'role': z.string(),
          }),
          z.object({
            'type': z.literal('guest'),
            'permissions': z.array(z.string()),
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
          z.object({
            'type': z.literal('moderator'),
            'level': z.number(),
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
        final schema = z.discriminatedUnion('type', [
          z.object({
            'type': z.literal('user'),
            'email': z.string().email(),
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
        final schema = z.discriminatedUnion('type', [
          z.object({
            'type': z.literal('user'),
            'email': z.string().email(),
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

      test('should handle async validation with non-object input', () async {
        final schema = z.discriminatedUnion('type', [
          z.object({
            'type': z.literal('user'),
            'email': z.string().email(),
          }),
        ]);

        final result = await schema.validateAsync('invalid_input');
        expect(result.isFailure, isTrue);
        expect(result.errors!.errors.first.code,
            equals(ValidationErrorCode.invalidType.code));
      });

      test('should handle async validation with missing discriminator',
          () async {
        final schema = z.discriminatedUnion('type', [
          z.object({
            'type': z.literal('user'),
            'email': z.string().email(),
          }),
        ]);

        final result =
            await schema.validateAsync({'email': 'test@example.com'});
        expect(result.isFailure, isTrue);
        expect(
            result.errors!.errors.first.code,
            equals(ValidationErrorCode
                .discriminatedUnionMissingDiscriminator.code));
      });

      test('should handle async validation fallback when schema map is empty',
          () async {
        // Create a schema with non-literal discriminators to force empty schema map
        final schema = z.discriminatedUnion('type', [
          z.object({
            'type': z.string(), // Non-literal schema
            'data': z.string(),
          }),
        ]);

        final result = await schema.validateAsync({
          'type': 'any-value',
          'data': 'test data',
        });
        expect(result.isSuccess, isTrue);
        expect(result.data!['type'], equals('any-value'));
        expect(result.data!['data'], equals('test data'));
      });

      test(
          'should handle async validation fallback when schema map is empty with failing schemas',
          () async {
        // Create a schema with non-literal discriminators that will fail validation
        final schema = z.discriminatedUnion('type', [
          z.object({
            'type': z.string(), // Non-literal schema
            'data': z.number(), // This will fail with string input
          }),
        ]);

        final result = await schema.validateAsync({
          'type': 'any-value',
          'data': 'invalid-number', // Should fail number validation
        });
        expect(result.isFailure, isTrue);
      });
    });

    group('Error Handling', () {
      test('should provide detailed error messages for missing discriminator',
          () {
        final schema = z.discriminatedUnion('category', [
          z.object({
            'category': z.literal('A'),
            'value': z.string(),
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
        final schema = z.discriminatedUnion('category', [
          z.object({
            'category': z.literal('A'),
            'value': z.string(),
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
        final schema = z.discriminatedUnion('type', [
          z.object({'type': z.literal('A'), 'value': z.string()}),
          z.object({'type': z.literal('B'), 'value': z.number()}),
        ]);

        final stats = schema.statistics;
        expect(stats['discriminator'], equals('type'));
        expect(stats['schemaCount'], equals(2));
        expect(stats['validDiscriminatorValues'], containsAll(['A', 'B']));
        expect(stats['schemaTypes'], hasLength(2));
      });

      test('should provide schema mapping', () {
        final schema = z.discriminatedUnion('type', [
          z.object({'type': z.literal('A'), 'value': z.string()}),
        ]);

        final mapping = schema.schemaMapping;
        expect(mapping.containsKey('A'), isTrue);
        expect(mapping['A'], isNotNull);
      });

      test('should have correct schema type', () {
        final schema = z.discriminatedUnion('type', [
          z.object({'type': z.literal('A'), 'value': z.string()}),
        ]);

        expect(schema.schemaType, equals('DiscriminatedUnionSchema'));
      });

      test('should have proper string representation', () {
        final schema = z.discriminatedUnion('type', [
          z.object({'type': z.literal('A'), 'value': z.string()}),
          z.object({'type': z.literal('B'), 'value': z.number()}),
        ]);

        final str = schema.toString();
        expect(str, contains('DiscriminatedUnionSchema'));
        expect(str, contains('type'));
        expect(str, contains('2 schemas'));
      });
    });

    group('Equality and Hash Code', () {
      test('should implement equality correctly', () {
        final schema1 = z.discriminatedUnion('type', [
          z.object({'type': z.literal('A'), 'value': z.string()}),
        ]);

        final schema2 = z.discriminatedUnion('type', [
          z.object({'type': z.literal('A'), 'value': z.string()}),
        ]);

        final schema3 = z.discriminatedUnion('category', [
          z.object({'category': z.literal('A'), 'value': z.string()}),
        ]);

        expect(schema1, equals(schema1)); // Same instance
        expect(schema1 == schema2, isTrue); // Same structure
        expect(schema1 == schema3, isFalse); // Different discriminator
      });

      test('should implement hash code correctly', () {
        final schema1 = z.discriminatedUnion('type', [
          z.object({'type': z.literal('A'), 'value': z.string()}),
        ]);

        final schema2 = z.discriminatedUnion('type', [
          z.object({'type': z.literal('A'), 'value': z.string()}),
        ]);

        expect(schema1.hashCode, equals(schema2.hashCode));
      });
    });

    group('Complex Scenarios', () {
      test('should handle nested discriminated unions', () {
        final innerUnion = z.discriminatedUnion('subtype', [
          z.object({
            'subtype': z.literal('text'),
            'content': z.string(),
          }),
          z.object({
            'subtype': z.literal('image'),
            'url': z.string(),
          }),
        ]);

        final outerUnion = z.discriminatedUnion('type', [
          z.object({
            'type': z.literal('content'),
            'data': innerUnion,
          }),
          z.object({
            'type': z.literal('metadata'),
            'info': z.string(),
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
        final itemSchema = z.discriminatedUnion('type', [
          z.object({
            'type': z.literal('product'),
            'name': z.string(),
            'price': z.number(),
          }),
          z.object({
            'type': z.literal('service'),
            'name': z.string(),
            'duration': z.number(),
          }),
        ]);

        final listSchema = z.array(itemSchema);

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
        final schema = z.discriminatedUnion('type', [
          z.object({
            'type': z.literal('user'),
            'name': z.string(),
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
        final schema = z.discriminatedUnion('isActive', [
          z.object({
            'isActive': z.literal(true),
            'activeData': z.string(),
          }),
          z.object({
            'isActive': z.literal(false),
            'inactiveData': z.string(),
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
        final schema = z.discriminatedUnion('flag', [
          z.object({
            'flag': z
                .boolean()
                .refine((val) => val == true, message: 'Must be true'),
            'trueData': z.string(),
          }),
          z.object({
            'flag': z
                .boolean()
                .refine((val) => val == false, message: 'Must be false'),
            'falseData': z.string(),
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

      test(
          'should handle boolean schema literal value extraction for true-only',
          () {
        // This tests the boolean schema literal extraction path (lines 87-93)
        final schema = z.discriminatedUnion('enabled', [
          z.object({
            'enabled': z
                .boolean()
                .refine((val) => val == true, message: 'Must be enabled'),
            'config': z.string(),
          }),
        ]);

        final result = schema.parse({
          'enabled': true,
          'config': 'active',
        });
        expect(result['enabled'], equals(true));
        expect(result['config'], equals('active'));
      });

      test(
          'should handle boolean schema literal value extraction for false-only',
          () {
        // This tests the boolean schema literal extraction path (lines 87-93)
        final schema = z.discriminatedUnion('disabled', [
          z.object({
            'disabled': z
                .boolean()
                .refine((val) => val == false, message: 'Must be disabled'),
            'reason': z.string(),
          }),
        ]);

        final result = schema.parse({
          'disabled': false,
          'reason': 'maintenance',
        });
        expect(result['disabled'], equals(false));
        expect(result['reason'], equals('maintenance'));
      });

      test(
          'should extract literal value from BooleanSchema that only accepts true',
          () {
        // This specifically targets the boolean schema literal extraction (lines 87-89)
        final schema = z.discriminatedUnion('onlyTrue', [
          z.object({
            'onlyTrue': z
                .boolean()
                .refine((val) => val == true, message: 'Must be true'),
            'data': z.string(),
          }),
        ]);

        expect(schema.hasDiscriminatorValue(true), isTrue);
        expect(schema.hasDiscriminatorValue(false), isFalse);

        final result = schema.parse({
          'onlyTrue': true,
          'data': 'test',
        });
        expect(result['onlyTrue'], equals(true));
        expect(result['data'], equals('test'));
      });

      test(
          'should extract literal value from BooleanSchema that only accepts false',
          () {
        // This specifically targets the boolean schema literal extraction (lines 90-92)
        final schema = z.discriminatedUnion('onlyFalse', [
          z.object({
            'onlyFalse': z
                .boolean()
                .refine((val) => val == false, message: 'Must be false'),
            'data': z.string(),
          }),
        ]);

        expect(schema.hasDiscriminatorValue(false), isTrue);
        expect(schema.hasDiscriminatorValue(true), isFalse);

        final result = schema.parse({
          'onlyFalse': false,
          'data': 'test',
        });
        expect(result['onlyFalse'], equals(false));
        expect(result['data'], equals('test'));
      });

      test('should use BooleanSchema path for literal value extraction', () {
        // This specifically targets lines 87-91 by creating a BooleanSchema that only accepts true
        final trueBooleanSchema =
            z.boolean().refine((val) => val == true, message: 'Must be true');
        final schema = z.discriminatedUnion('boolFlag', [
          z.object({
            'boolFlag': trueBooleanSchema,
            'data': z.string(),
          }),
        ]);

        // The schema should have extracted true as the discriminator value
        expect(schema.hasDiscriminatorValue(true), isTrue);
        expect(schema.hasDiscriminatorValue(false), isFalse);

        final result = schema.parse({
          'boolFlag': true,
          'data': 'test',
        });
        expect(result['boolFlag'], equals(true));
        expect(result['data'], equals('test'));
      });

      test(
          'should use BooleanSchema path for false-only literal value extraction',
          () {
        // This specifically targets lines 90-91 by creating a BooleanSchema that only accepts false
        final falseBooleanSchema =
            z.boolean().refine((val) => val == false, message: 'Must be false');
        final schema = z.discriminatedUnion('boolFlag', [
          z.object({
            'boolFlag': falseBooleanSchema,
            'data': z.string(),
          }),
        ]);

        // The schema should have extracted false as the discriminator value
        expect(schema.hasDiscriminatorValue(false), isTrue);
        expect(schema.hasDiscriminatorValue(true), isFalse);

        final result = schema.parse({
          'boolFlag': false,
          'data': 'test',
        });
        expect(result['boolFlag'], equals(false));
        expect(result['data'], equals('test'));
      });

      test(
          'should trigger BooleanSchema path with direct BooleanSchema for true',
          () {
        // This creates a BooleanSchema that only accepts true using the internal constructor
        final booleanSchema = BooleanSchema(expectedValue: true);
        final schema = z.discriminatedUnion('onlyTrue', [
          z.object({
            'onlyTrue': booleanSchema,
            'data': z.string(),
          }),
        ]);

        // This should trigger the BooleanSchema path in _findLiteralValueByTesting
        expect(schema.hasDiscriminatorValue(true), isTrue);
        expect(schema.hasDiscriminatorValue(false), isFalse);

        final result = schema.parse({
          'onlyTrue': true,
          'data': 'test',
        });
        expect(result['onlyTrue'], equals(true));
        expect(result['data'], equals('test'));
      });

      test(
          'should trigger BooleanSchema path with direct BooleanSchema for false',
          () {
        // This creates a BooleanSchema that only accepts false using the internal constructor
        final booleanSchema = BooleanSchema(expectedValue: false);
        final schema = z.discriminatedUnion('onlyFalse', [
          z.object({
            'onlyFalse': booleanSchema,
            'data': z.string(),
          }),
        ]);

        // This should trigger the BooleanSchema path in _findLiteralValueByTesting
        expect(schema.hasDiscriminatorValue(false), isTrue);
        expect(schema.hasDiscriminatorValue(true), isFalse);

        final result = schema.parse({
          'onlyFalse': false,
          'data': 'test',
        });
        expect(result['onlyFalse'], equals(false));
        expect(result['data'], equals('test'));
      });
    });

    group('Literal Value Extraction Edge Cases', () {
      test('should handle schemas without literal values', () {
        // This tests the fallback when no literal value can be extracted
        final schema = z.discriminatedUnion('type', [
          z.object({
            'type': z.string(), // Non-literal schema
            'data': z.string(),
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
        final schema = z.discriminatedUnion('type', [
          z.string(), // Non-object schema
        ]);

        // This should handle gracefully
        expect(schema.validDiscriminatorValues, isEmpty);
      });

      test('should handle literal extraction from string schemas', () {
        final schema = z.discriminatedUnion('mode', [
          z.object({
            'mode': z.literal('read'),
            'file': z.string(),
          }),
          z.object({
            'mode': z.literal('write'),
            'content': z.string(),
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
        final schema = z.discriminatedUnion('status', [
          z.object({
            'status': z.literal('pending'),
            'message': z.string(),
          }),
          z.object({
            'status': z.literal('approved'),
            'approvedBy': z.string(),
          }),
          z.object({
            'status': z.literal('rejected'),
            'reason': z.string(),
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
        final baseSchema = z.discriminatedUnion('type', [
          z.object({
            'type': z.literal('user'),
            'name': z.string(),
          }),
        ]);

        final extendedSchema = baseSchema.extend([
          z.object({
            'type': z.literal('user'), // Duplicate discriminator value
            'email': z.string(),
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
        final schema = z.discriminatedUnion('type', [
          z.object({
            'type': z.literal('user'),
            'name': z.string(),
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
            z.discriminatedUnion('type', <Schema<Map<String, dynamic>>>[]);

        expect(schema.validDiscriminatorValues, isEmpty);
        expect(schema.schemas, isEmpty);
        expect(schema.schemaMapping, isEmpty);
      });

      test('should handle single schema list', () {
        final schema = z.discriminatedUnion('type', [
          z.object({
            'type': z.literal('single'),
            'value': z.string(),
          }),
        ]);

        expect(schema.validDiscriminatorValues, contains('single'));
        expect(schema.schemas, hasLength(1));
        expect(schema.schemaMapping, hasLength(1));
      });
    });

    group('Error Path Testing', () {
      test('should provide correct error paths for missing discriminator', () {
        final schema = z.discriminatedUnion('category', [
          z.object({
            'category': z.literal('A'),
            'value': z.string(),
          }),
        ]);

        final result = schema.validate({'value': 'test'});
        expect(result.isFailure, isTrue);
        expect(result.errors!.errors.first.path, isEmpty);
      });

      test('should provide correct error paths for invalid discriminator', () {
        final schema = z.discriminatedUnion('category', [
          z.object({
            'category': z.literal('A'),
            'value': z.string(),
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
        final schema = z.discriminatedUnion('type', [
          z.object({
            'type': z.literal('user'),
            'profile': z.object({
              'name': z.string(),
              'age': z.number(),
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
        final stringSchema = z.discriminatedUnion('stringType', [
          z.object({
            'stringType': z.literal('string'),
            'value': z.string(),
          }),
        ]);

        final numberSchema = z.discriminatedUnion('numberType', [
          z.object({
            'numberType': z.literal(42),
            'value': z.number(),
          }),
        ]);

        final booleanSchema = z.discriminatedUnion('booleanType', [
          z.object({
            'booleanType': z.literal(true),
            'value': z.boolean(),
          }),
        ]);

        expect(stringSchema.hasDiscriminatorValue('string'), isTrue);
        expect(numberSchema.hasDiscriminatorValue(42), isTrue);
        expect(booleanSchema.hasDiscriminatorValue(true), isTrue);
      });

      test('should handle negative number discriminators', () {
        final schema = z.discriminatedUnion('id', [
          z.object({
            'id': z.literal(-1),
            'errorType': z.string(),
          }),
          z.object({
            'id': z.literal(-2),
            'warningType': z.string(),
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
        final schema = z.discriminatedUnion('level', [
          z.object({
            'level': z.literal(0),
            'message': z.string(),
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
        final schema = z.discriminatedUnion('type', [
          z.object({
            'type': z.literal('A'),
            'value': z.string(),
          }),
          z.object({
            'type': z.literal('B'),
            'value': z.number(),
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
        final schema = z.discriminatedUnion(
          'type',
          [
            z.object({
              'type': z.literal('test'),
              'value': z.string(),
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

    group('Extension Factory Method', () {
      test('should create discriminated union using extension factory method',
          () {
        // This tests the extension factory method (lines 370-381)
        final schema = DiscriminatedUnionExtension.discriminatedUnion<
            Map<String, dynamic>>(
          'type',
          [
            z.object({
              'type': z.literal('user'),
              'name': z.string(),
            }),
            z.object({
              'type': z.literal('admin'),
              'role': z.string(),
            }),
          ],
          description: 'Factory method test',
          metadata: {'source': 'extension'},
        );

        expect(schema.discriminator, equals('type'));
        expect(schema.validDiscriminatorValues, containsAll(['user', 'admin']));
        expect(schema.description, equals('Factory method test'));
        expect(schema.metadata, equals({'source': 'extension'}));

        final result = schema.parse({
          'type': 'user',
          'name': 'John Doe',
        });
        expect(result['type'], equals('user'));
        expect(result['name'], equals('John Doe'));
      });

      test(
          'should create discriminated union using extension factory method with minimal parameters',
          () {
        final schema = DiscriminatedUnionExtension.discriminatedUnion<
            Map<String, dynamic>>(
          'category',
          [
            z.object({
              'category': z.literal('basic'),
              'value': z.string(),
            }),
          ],
        );

        expect(schema.discriminator, equals('category'));
        expect(schema.validDiscriminatorValues, contains('basic'));
        expect(schema.description, isNull);
        expect(schema.metadata, isNull);

        final result = schema.parse({
          'category': 'basic',
          'value': 'test',
        });
        expect(result['category'], equals('basic'));
        expect(result['value'], equals('test'));
      });
    });
  });
}
