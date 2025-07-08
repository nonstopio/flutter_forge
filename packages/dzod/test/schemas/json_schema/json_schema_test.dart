import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('JSON Schema Generation', () {
    group('Basic Types', () {
      test('should generate string schema', () {
        final schema = Z.string();
        final jsonSchema = schema.toJsonSchema();

        expect(jsonSchema['type'], equals('string'));
        expect(jsonSchema['\$schema'], isNotNull);
      });

      test('should generate number schema', () {
        final schema = Z.number();
        final jsonSchema = schema.toJsonSchema();

        expect(jsonSchema['type'], equals('number'));
      });

      test('should generate boolean schema', () {
        final schema = Z.boolean();
        final jsonSchema = schema.toJsonSchema();

        expect(jsonSchema['type'], equals('boolean'));
      });

      test('should generate null schema', () {
        final schema = Z.null_();
        final jsonSchema = schema.toJsonSchema();

        expect(jsonSchema['type'], equals('null'));
      });
    });

    group('Array and Collection Types', () {
      test('should generate array schema', () {
        final schema = Z.array(Z.string());
        final jsonSchema = schema.toJsonSchema();

        expect(jsonSchema['type'], equals('array'));
        expect(jsonSchema['items'], isNotNull);
      });

      test('should generate object schema', () {
        final schema = Z.object({
          'name': Z.string(),
          'age': Z.number(),
        });
        final jsonSchema = schema.toJsonSchema();

        expect(jsonSchema['type'], equals('object'));
        expect(jsonSchema['properties'], isNotNull);
      });
    });

    group('Schema Configuration', () {
      test('should include descriptions when configured', () {
        final schema = Z.string().describe('User name');
        final jsonSchema = schema.toJsonSchema(
          config: const JsonSchemaConfig(includeDescriptions: true),
        );

        expect(jsonSchema['title'], equals('User name'));
        expect(jsonSchema['description'], equals('User name'));
      });

      test('should exclude descriptions when configured', () {
        final schema = Z.string().describe('User name');
        final jsonSchema = schema.toJsonSchema(
          config: const JsonSchemaConfig(includeDescriptions: false),
        );

        expect(jsonSchema.containsKey('title'), isFalse);
        expect(jsonSchema.containsKey('description'), isFalse);
      });

      test('should include metadata when configured', () {
        final metadata = {'validation': 'required', 'ui': 'text-input'};
        final schema = Z.string().describe('User name', metadata: metadata);
        final jsonSchema = schema.toJsonSchema(
          config: const JsonSchemaConfig(
            includeMetadata: true,
            metadataPrefix: 'x-',
          ),
        );

        expect(jsonSchema['x-validation'], equals('required'));
        expect(jsonSchema['x-ui'], equals('text-input'));
      });

      test('should set schema version', () {
        final schema = Z.string();
        final jsonSchema = schema.toJsonSchema(
          config:
              const JsonSchemaConfig(version: JsonSchemaVersion.draft202012),
        );

        expect(jsonSchema['\$schema'],
            equals('https://json-schema.org/draft/2020-12/schema'));
      });

      test('should set schema ID when provided', () {
        final schema = Z.string();
        final jsonSchema = schema.toJsonSchema(
          config: const JsonSchemaConfig(
              schemaId: 'https://example.com/user-schema'),
        );

        expect(jsonSchema['\$id'], equals('https://example.com/user-schema'));
      });
    });

    group('Branded and Readonly Schemas', () {
      test('should generate schema for branded types', () {
        final schema = Z.string().brand<String>();
        final jsonSchema = schema.toJsonSchema();

        expect(jsonSchema['type'], equals('string'));
        // Branded wrapper should not affect JSON Schema structure
      });

      test('should generate schema for readonly types', () {
        final schema = Z.string().readonly();
        final jsonSchema = schema.toJsonSchema();

        expect(jsonSchema['type'], equals('string'));
        expect(jsonSchema['readOnly'], equals(true));
      });

      test('should handle complex wrapper combinations', () {
        final schema =
            Z.string().describe('User ID').brand<String>().readonly();
        final jsonSchema = schema.toJsonSchema();

        expect(jsonSchema['type'], equals('string'));
        expect(jsonSchema['title'], equals('User ID'));
        expect(jsonSchema['readOnly'], equals(true));
      });
    });

    group('Preset Configurations', () {
      test('should use OpenAPI 3.0 preset', () {
        final schema = Z.string().describe('API Key');
        final jsonSchema = schema.toOpenApiSchema();

        expect(jsonSchema['\$schema'],
            equals('http://json-schema.org/draft-07/schema#'));
        expect(jsonSchema['title'], equals('API Key'));
      });

      test('should use minimal preset', () {
        final schema = Z.string().describe('Test');
        final jsonSchema = schema.toMinimalJsonSchema();

        expect(jsonSchema['type'], equals('string'));
        expect(jsonSchema.containsKey('title'), isFalse);
        expect(jsonSchema.containsKey('description'), isFalse);
      });
    });

    group('Complex Schema Types', () {
      test('should handle enum schemas', () {
        final schema = Z.enum_(['red', 'green', 'blue']);
        final jsonSchema = schema.toJsonSchema();

        expect(jsonSchema['type'], equals('string'));
        expect(jsonSchema.containsKey('description'), isTrue);
      });

      test('should handle tuple schemas', () {
        final schema = Z.tuple([Z.string(), Z.number()]);
        final jsonSchema = schema.toJsonSchema();

        expect(jsonSchema['type'], equals('array'));
      });

      test('should handle record schemas', () {
        final schema = Z.record(Z.number());
        final jsonSchema = schema.toJsonSchema();

        expect(jsonSchema['type'], equals('object'));
      });
    });

    group('Error Handling', () {
      test('should handle unknown schema types gracefully', () {
        // Create a custom schema type for testing
        const customSchema = _CustomTestSchema();
        final jsonSchema = customSchema.toJsonSchema();

        expect(jsonSchema['type'], equals('object'));
        expect(jsonSchema['description'], contains('Unknown schema type'));
      });
    });

    group('Schema Context and Definitions', () {
      test('should generate definitions when configured', () {
        final schema = Z.string().describe('Test Schema');
        final jsonSchema = schema.toJsonSchema(
          config: const JsonSchemaConfig(generateDefinitions: true),
        );

        // Basic structure should be maintained
        expect(jsonSchema['type'], equals('string'));
      });

      test('should handle schema titles', () {
        final schema = Z.string();
        final jsonSchema = schema.toJsonSchema(title: 'Custom Title');

        expect(jsonSchema['title'], equals('Custom Title'));
      });
    });

    group('Configuration Presets', () {
      test('should validate OpenAPI 3.0 preset configuration', () {
        const config = JsonSchemaConfig.openApi30;

        expect(config.version, equals(JsonSchemaVersion.draft07));
        expect(config.includeDescriptions, isTrue);
        expect(config.includeExamples, isTrue);
        expect(config.includeConstraints, isTrue);
        expect(config.includeMetadata, isTrue);
        expect(config.generateDefinitions, isTrue);
      });

      test('should validate minimal preset configuration', () {
        const config = JsonSchemaConfig.minimal;

        expect(config.includeDescriptions, isFalse);
        expect(config.includeExamples, isFalse);
        expect(config.includeMetadata, isFalse);
        expect(config.includeConstraints, isFalse);
        expect(config.generateDefinitions, isFalse);
      });

      test('should validate comprehensive preset configuration', () {
        const config = JsonSchemaConfig.comprehensive;

        expect(config.includeDescriptions, isTrue);
        expect(config.includeExamples, isTrue);
        expect(config.includeMetadata, isTrue);
        expect(config.includeConstraints, isTrue);
        expect(config.generateDefinitions, isTrue);
      });
    });

    group('Schema Version Support', () {
      test('should support draft-07 version', () {
        const version = JsonSchemaVersion.draft07;
        expect(version.uri, equals('http://json-schema.org/draft-07/schema#'));
      });

      test('should support draft 2019-09 version', () {
        const version = JsonSchemaVersion.draft201909;
        expect(version.uri,
            equals('https://json-schema.org/draft/2019-09/schema'));
      });

      test('should support draft 2020-12 version', () {
        const version = JsonSchemaVersion.draft202012;
        expect(version.uri,
            equals('https://json-schema.org/draft/2020-12/schema'));
      });
    });
  });
}

/// Custom test schema for error handling tests
class _CustomTestSchema extends Schema<String> {
  const _CustomTestSchema();

  @override
  ValidationResult<String> validate(dynamic input,
      [List<String> path = const []]) {
    return const ValidationResult.success('test');
  }
}
