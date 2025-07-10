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
  });
}
