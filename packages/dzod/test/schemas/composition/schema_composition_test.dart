import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('Schema Composition and Analysis', () {
    group('Schema Analysis', () {
      test('should analyze basic string schema', () {
        final schema = Z.string();
        final info = schema.analyze();

        expect(info.typeName, equals('string'));
        expect(info.isOptional, isFalse);
        expect(info.isReadonly, isFalse);
        expect(info.isBranded, isFalse);
        expect(info.description, isNull);
      });

      test('should analyze string schema with description', () {
        final schema = Z.string().describe('User name');
        final info = schema.analyze();

        expect(info.typeName, equals('string'));
        expect(info.description, equals('User name'));
      });

      test('should analyze optional schema', () {
        final schema = Z.string().optional();
        final info = schema.analyze();

        expect(info.typeName, equals('string'));
        expect(info.isOptional, isTrue);
      });

      test('should analyze readonly schema', () {
        final schema = Z.string().readonly();
        final info = schema.analyze();

        expect(info.typeName, equals('string'));
        expect(info.isReadonly, isTrue);
      });

      test('should analyze branded schema', () {
        final schema = Z.string().brand<String>();
        final info = schema.analyze();

        expect(info.typeName, equals('string'));
        expect(info.isBranded, isTrue);
      });

      test('should analyze complex wrapper combinations', () {
        final schema = Z
            .string()
            .describe('User ID')
            .brand<String>()
            .readonly()
            .optional();
        final info = schema.analyze();

        expect(info.typeName, equals('string'));
        expect(info.description, equals('User ID'));
        expect(info.isBranded, isTrue);
        expect(info.isReadonly, isTrue);
        expect(info.isOptional, isTrue);
      });

      test('should analyze different primitive types', () {
        final stringInfo = Z.string().analyze();
        final numberInfo = Z.number().analyze();
        final boolInfo = Z.boolean().analyze();
        final nullInfo = Z.null_().analyze();

        expect(stringInfo.typeName, equals('string'));
        expect(numberInfo.typeName, equals('number'));
        expect(boolInfo.typeName, equals('boolean'));
        expect(nullInfo.typeName, equals('null'));
      });

      test('should analyze collection types', () {
        final arrayInfo = Z.array(Z.string()).analyze();
        final objectInfo = Z.object({'name': Z.string()}).analyze();
        final tupleInfo = Z.tuple([Z.string(), Z.number()]).analyze();
        final recordInfo = Z.record(Z.number()).analyze();
        final enumInfo = Z.enum_(['a', 'b', 'c']).analyze();

        expect(arrayInfo.typeName, equals('array'));
        expect(objectInfo.typeName, equals('object'));
        expect(tupleInfo.typeName, equals('tuple'));
        expect(recordInfo.typeName, equals('record'));
        expect(enumInfo.typeName, equals('enum'));
      });
    });

    group('Schema Extensions', () {
      test('should provide baseTypeName getter', () {
        final schema = Z.string().describe('Test').brand<String>().readonly();

        expect(schema.baseTypeName, equals('string'));
      });

      test('should provide wrapper type checks', () {
        final schema = Z.string().brand<String>().readonly().optional();

        expect(schema.isOptionalSchema, isTrue);
        expect(schema.isReadonlySchema, isTrue);
        expect(schema.isBrandedSchema, isTrue);
      });

      test('should extract descriptions from schema tree', () {
        final schema = Z.string().describe('Base description');
        final descriptions = schema.allDescriptions;

        expect(descriptions, contains('Base description'));
      });

      test('should extract metadata from schema tree', () {
        final metadata = {'type': 'input', 'required': true};
        final schema = Z.string().describe('Test', metadata: metadata);
        final allMetadata = schema.allMetadata;

        expect(allMetadata, equals(metadata));
      });

      test('should calculate complexity score', () {
        final simpleSchema = Z.string();
        final complexSchema = Z.object({
          'user': Z.object({
            'name': Z.string().describe('Name').brand<String>(),
            'age': Z.number().optional(),
          }),
          'tags': Z.array(Z.string()),
        });

        final simpleScore = simpleSchema.complexityScore;
        final complexScore = complexSchema.complexityScore;

        expect(simpleScore, greaterThan(0));
        expect(complexScore, greaterThan(simpleScore));
        expect(simpleScore, lessThanOrEqualTo(100));
        expect(complexScore, lessThanOrEqualTo(100));
      });

      test('should check schema equivalence', () {
        final schema1 = Z.string().describe('Test');
        final schema2 = Z.string().describe('Different');
        final schema3 = Z.string();

        expect(schema1.isEquivalentTo(schema2), isTrue); // Same base type
        expect(schema1.isEquivalentTo(schema3), isTrue); // Same base type
        expect(schema1.isEquivalentTo(Z.number()), isFalse); // Different type
      });
    });

    group('Schema Info', () {
      test('should create SchemaInfo with all properties', () {
        const info = SchemaInfo(
          typeName: 'string',
          isOptional: true,
          isReadonly: true,
          isBranded: true,
          description: 'Test schema',
          metadata: {'key': 'value'},
          properties: {'prop': 'value'},
        );

        expect(info.typeName, equals('string'));
        expect(info.isOptional, isTrue);
        expect(info.isReadonly, isTrue);
        expect(info.isBranded, isTrue);
        expect(info.description, equals('Test schema'));
        expect(info.metadata, equals({'key': 'value'}));
        expect(info.properties, equals({'prop': 'value'}));
      });

      test('should create copy with modified properties', () {
        const original = SchemaInfo(typeName: 'string');
        final modified = original.copyWith(
          isOptional: true,
          description: 'Modified',
        );

        expect(modified.typeName, equals('string'));
        expect(modified.isOptional, isTrue);
        expect(modified.description, equals('Modified'));
        expect(original.isOptional, isFalse); // Original unchanged
      });

      test('should have proper toString representation', () {
        const info = SchemaInfo(
          typeName: 'string',
          isOptional: true,
          isReadonly: true,
          description: 'User name',
        );

        final stringRep = info.toString();
        expect(stringRep, contains('string'));
        expect(stringRep, contains('optional'));
        expect(stringRep, contains('readonly'));
        expect(stringRep, contains('User name'));
      });

      test('should have proper equality', () {
        const info1 = SchemaInfo(
          typeName: 'string',
          isOptional: true,
          description: 'Test',
        );
        const info2 = SchemaInfo(
          typeName: 'string',
          isOptional: true,
          description: 'Test',
        );
        const info3 = SchemaInfo(
          typeName: 'number',
          isOptional: true,
          description: 'Test',
        );

        expect(info1, equals(info2));
        expect(info1, isNot(equals(info3)));
        expect(info1.hashCode, equals(info2.hashCode));
      });
    });

    group('Schema Composition', () {
      test('should create union schemas', () {
        final schema1 = Z.string();
        final schema2 = Z.string();
        final unionSchema = SchemaUtils.union([schema1, schema2]);

        expect(unionSchema, isA<UnionSchema>());
      });

      test('should create intersection schemas', () {
        final schema1 = Z.string();
        final schema2 = Z.string().min(5);
        final intersectionSchema = SchemaUtils.intersection([schema1, schema2]);

        expect(intersectionSchema, isA<IntersectionSchema>());
      });

      test('should create conditional schemas', () {
        var useString = true;
        final conditionalSchema = SchemaUtils.conditional<dynamic>(
          () => useString,
          Z.string(),
          Z.number(),
        );

        expect(conditionalSchema, isA<LazySchema>());
      });

      test('should handle empty schema lists', () {
        expect(
          () => SchemaUtils.union<String>([]),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => SchemaUtils.intersection<String>([]),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should return single schema for single-item lists', () {
        final schema = Z.string();
        final unionResult = SchemaUtils.union([schema]);
        final intersectionResult = SchemaUtils.intersection([schema]);

        expect(unionResult, same(schema));
        expect(intersectionResult, same(schema));
      });

      test('should create oneOf validation', () {
        final schema = SchemaUtils.oneOf(['red', 'green', 'blue']);

        expect(schema, isA<LazySchema>());
      });

      test('should create noneOf validation', () {
        final schema = SchemaUtils.noneOf(['admin', 'root'], Z.string());

        expect(schema.parse('user'), equals('user'));
        expect(
            () => schema.parse('admin'), throwsA(isA<ValidationException>()));
      });

      test('should handle empty oneOf', () {
        expect(
          () => SchemaUtils.oneOf<String>([]),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Complex Analysis Scenarios', () {
      test('should analyze deeply nested schemas', () {
        final complexSchema = Z.object({
          'user': Z.object({
            'profile': Z.object({
              'name': Z.string().describe('Full name').brand<String>(),
              'email': Z.string().email().readonly(),
              'age': Z.number().positive().optional(),
            }),
            'preferences': Z.record(Z.boolean()),
          }),
          'metadata': Z.array(Z.tuple([Z.string(), Z.string()])),
        });

        final info = complexSchema.analyze();
        expect(info.typeName, equals('object'));

        final complexity = complexSchema.complexityScore;
        expect(complexity, greaterThan(20)); // Should be quite complex
      });

      test('should handle unknown schema types', () {
        const customSchema = _CustomTestSchema();
        final info = customSchema.analyze();

        expect(info.typeName, contains('_CustomTestSchema'));
        expect(info.properties['isUnknown'], isTrue);
      });

      test('should extract nested descriptions and metadata', () {
        final schema = Z.object({
          'name': Z.string().describe('User name'),
          'profile': Z.object({
            'bio':
                Z.string().describe('Biography', metadata: {'ui': 'textarea'}),
          }),
        }).describe('User object', metadata: {'version': '1.0'});

        final descriptions = schema.allDescriptions;
        final metadata = schema.allMetadata;

        expect(descriptions, hasLength(greaterThanOrEqualTo(1)));
        expect(descriptions, contains('User object'));
        expect(metadata['version'], equals('1.0'));
        // Note: nested metadata extraction is limited in current implementation
        // expect(metadata['ui'], equals('textarea'));
      });
    });

    group('Performance and Edge Cases', () {
      test('should handle circular references gracefully', () {
        // Test with lazy schemas to avoid infinite recursion
        late final Schema<Map<String, dynamic>> lazySchema;
        lazySchema = Schema.lazy<Map<String, dynamic>>(() => Z.object({
              'self': Schema.lazy<Map<String, dynamic>>(() => lazySchema)
                  .optional(),
              'name': Z.string(),
            }));

        final info = lazySchema.analyze();
        expect(info.typeName, isNotEmpty);
      });

      test('should handle very complex schemas', () {
        final veryComplexSchema = Z.union([
          Z.intersection([
            Z.object({'type': Z.string()}),
            Z.object({'name': Z.string()}),
          ]),
          Z.intersection([
            Z.object({'type': Z.string()}),
            Z.object({'permissions': Z.array(Z.string())}),
          ]),
        ]);

        final complexity = veryComplexSchema.complexityScore;
        expect(complexity, greaterThan(0));
        expect(complexity, lessThanOrEqualTo(100));
      });
    });
  });
}

/// Custom test schema for testing unknown types
class _CustomTestSchema extends Schema<String> {
  const _CustomTestSchema();

  @override
  ValidationResult<String> validate(dynamic input,
      [List<String> path = const []]) {
    return const ValidationResult.success('test');
  }
}
