/// JSON Schema generation for OpenAPI documentation support
///
/// This module provides functionality to convert dzod schemas into standard JSON Schema format,
/// enabling integration with OpenAPI documentation tools, code generators, and validation systems.
library;

import '../schemas/collections/array_schema.dart';
import '../schemas/collections/record_schema.dart';
import '../schemas/collections/tuple_schema.dart';
import '../schemas/object/object_schema.dart';
import '../schemas/primitive/boolean_schema.dart';
import '../schemas/primitive/null_schema.dart';
import '../schemas/primitive/number_schema.dart';
import '../schemas/primitive/string_schema.dart';
import '../schemas/specialized/enum_schema.dart';
import 'schema.dart';

/// JSON Schema specification version
enum JsonSchemaVersion {
  draft07('http://json-schema.org/draft-07/schema#'),
  draft201909('https://json-schema.org/draft/2019-09/schema'),
  draft202012('https://json-schema.org/draft/2020-12/schema');

  const JsonSchemaVersion(this.uri);
  final String uri;
}

/// Configuration for JSON Schema generation
class JsonSchemaConfig {
  /// JSON Schema version to target
  final JsonSchemaVersion version;

  /// Include schema titles from descriptions
  final bool includeDescriptions;

  /// Include examples in the schema
  final bool includeExamples;

  /// Include metadata as custom properties
  final bool includeMetadata;

  /// Custom property prefix for metadata
  final String metadataPrefix;

  /// Include validation constraints
  final bool includeConstraints;

  /// Generate definitions for reusable schemas
  final bool generateDefinitions;

  /// Root schema identifier
  final String? schemaId;

  const JsonSchemaConfig({
    this.version = JsonSchemaVersion.draft07,
    this.includeDescriptions = true,
    this.includeExamples = false,
    this.includeMetadata = false,
    this.metadataPrefix = 'x-',
    this.includeConstraints = true,
    this.generateDefinitions = false,
    this.schemaId,
  });

  /// Preset for OpenAPI 3.0 documentation
  static const openApi30 = JsonSchemaConfig(
    version: JsonSchemaVersion.draft07,
    includeDescriptions: true,
    includeExamples: true,
    includeConstraints: true,
    includeMetadata: true,
    generateDefinitions: true,
  );

  /// Preset for minimal schemas
  static const minimal = JsonSchemaConfig(
    includeDescriptions: false,
    includeExamples: false,
    includeMetadata: false,
    includeConstraints: false,
    generateDefinitions: false,
  );

  /// Preset for comprehensive documentation
  static const comprehensive = JsonSchemaConfig(
    includeDescriptions: true,
    includeExamples: true,
    includeMetadata: true,
    includeConstraints: true,
    generateDefinitions: true,
  );
}

/// Context for JSON Schema generation
class JsonSchemaContext {
  final JsonSchemaConfig config;
  final Map<String, Map<String, dynamic>> _definitions = {};
  final Map<Schema, String> _schemaRefs = {};
  int _definitionCounter = 0;

  JsonSchemaContext(this.config);

  /// Get or create a definition reference for a schema
  String getDefinitionRef(Schema schema, String? name) {
    if (!config.generateDefinitions) return '';

    final existingRef = _schemaRefs[schema];
    if (existingRef != null) return existingRef;

    final defName = name ?? 'Schema${_definitionCounter++}';
    _schemaRefs[schema] = defName;
    return defName;
  }

  /// Add a schema definition
  void addDefinition(String name, Map<String, dynamic> definition) {
    _definitions[name] = definition;
  }

  /// Get all collected definitions
  Map<String, Map<String, dynamic>> get definitions =>
      Map.unmodifiable(_definitions);
}

/// JSON Schema generator for dzod schemas
class JsonSchemaGenerator {
  const JsonSchemaGenerator();

  /// Generate JSON Schema from a dzod schema
  Map<String, dynamic> generate(
    Schema schema, {
    JsonSchemaConfig config = const JsonSchemaConfig(),
    String? title,
  }) {
    final context = JsonSchemaContext(config);
    final schemaMap = _generateSchema(schema, context);

    // Build the root schema
    final result = <String, dynamic>{
      if (config.schemaId != null) '\$id': config.schemaId,
      '\$schema': config.version.uri,
      if (title != null) 'title': title,
      ...schemaMap,
    };

    // Add definitions if any were collected
    if (context.definitions.isNotEmpty) {
      result['definitions'] = context.definitions;
    }

    return result;
  }

  /// Generate JSON Schema map for a specific schema
  Map<String, dynamic> _generateSchema(
      Schema schema, JsonSchemaContext context) {
    // Handle wrapper schemas by delegating to their inner schema
    if (schema is DescribeSchema) {
      final result = _generateSchema(schema.innerSchema, context);
      if (context.config.includeDescriptions && schema.description != null) {
        result['title'] = schema.description;
        result['description'] = schema.description;
      }
      if (context.config.includeMetadata && schema.metadata != null) {
        for (final entry in schema.metadata!.entries) {
          result['${context.config.metadataPrefix}${entry.key}'] = entry.value;
        }
      }
      return result;
    }

    if (schema is BrandedSchema) {
      return _generateSchema(schema.innerSchema, context);
    }

    if (schema is ReadonlySchema) {
      final result = _generateSchema(schema.innerSchema, context);
      result['readOnly'] = true;
      return result;
    }

    if (schema is OptionalSchema) {
      final result = _generateSchema(schema.innerSchema, context);
      // Optional is typically handled at the object level in JSON Schema
      return result;
    }

    // Generate schema based on type
    final result = _generateSchemaByType(schema, context);

    // Add common properties
    if (context.config.includeDescriptions && schema.description != null) {
      result['title'] = schema.description;
      result['description'] = schema.description;
    }

    if (context.config.includeMetadata && schema.metadata != null) {
      for (final entry in schema.metadata!.entries) {
        result['${context.config.metadataPrefix}${entry.key}'] = entry.value;
      }
    }

    return result;
  }

  /// Generate schema based on the specific schema type
  Map<String, dynamic> _generateSchemaByType(
      Schema schema, JsonSchemaContext context) {
    if (schema is StringSchema) {
      return _generateStringSchema(schema, context);
    }

    if (schema is NumberSchema) {
      return _generateNumberSchema(schema, context);
    }

    if (schema is BooleanSchema) {
      return {'type': 'boolean'};
    }

    if (schema is NullSchema) {
      return {'type': 'null'};
    }

    if (schema is ArraySchema) {
      return _generateArraySchema(schema, context);
    }

    if (schema is TupleSchema) {
      return _generateTupleSchema(schema, context);
    }

    if (schema is ObjectSchema) {
      return _generateObjectSchema(schema, context);
    }

    if (schema is EnumSchema) {
      return _generateEnumSchema(schema, context);
    }

    if (schema is RecordSchema) {
      return _generateRecordSchema(schema, context);
    }

    if (schema is UnionSchema) {
      return _generateUnionSchema(schema, context);
    }

    if (schema is IntersectionSchema) {
      return _generateIntersectionSchema(schema, context);
    }

    // Fallback for unknown schema types
    return {
      'type': 'object',
      'description': 'Unknown schema type: ${schema.runtimeType}'
    };
  }

  /// Generate JSON Schema for StringSchema
  Map<String, dynamic> _generateStringSchema(
      StringSchema schema, JsonSchemaContext context) {
    final result = <String, dynamic>{'type': 'string'};

    if (!context.config.includeConstraints) return result;

    // Add string constraints using reflection-like approach
    try {
      // Note: This is a simplified approach. In a real implementation,
      // you might want to add getters to StringSchema to access constraints
      final constraints = _extractStringConstraints(schema);

      if (constraints['minLength'] != null) {
        result['minLength'] = constraints['minLength'];
      }
      if (constraints['maxLength'] != null) {
        result['maxLength'] = constraints['maxLength'];
      }
      if (constraints['pattern'] != null) {
        result['pattern'] = constraints['pattern'];
      }
      if (constraints['format'] != null) {
        result['format'] = constraints['format'];
      }
    } catch (e) {
      // Ignore constraint extraction errors
    }

    return result;
  }

  /// Extract string constraints (simplified implementation)
  Map<String, dynamic> _extractStringConstraints(StringSchema schema) {
    final constraints = <String, dynamic>{};
    
    if (schema.minLength != null) {
      constraints['minLength'] = schema.minLength;
    }
    if (schema.maxLength != null) {
      constraints['maxLength'] = schema.maxLength;
    }
    if (schema.pattern != null) {
      constraints['pattern'] = schema.pattern;
    }
    if (schema.format != null) {
      constraints['format'] = schema.format;
    }
    
    return constraints;
  }

  /// Generate JSON Schema for NumberSchema
  Map<String, dynamic> _generateNumberSchema(
      NumberSchema schema, JsonSchemaContext context) {
    final result = <String, dynamic>{'type': 'number'};

    if (!context.config.includeConstraints) return result;

    try {
      final constraints = _extractNumberConstraints(schema);

      if (constraints['minimum'] != null) {
        result['minimum'] = constraints['minimum'];
      }
      if (constraints['maximum'] != null) {
        result['maximum'] = constraints['maximum'];
      }
      if (constraints['exclusiveMinimum'] != null) {
        result['exclusiveMinimum'] = constraints['exclusiveMinimum'];
      }
      if (constraints['exclusiveMaximum'] != null) {
        result['exclusiveMaximum'] = constraints['exclusiveMaximum'];
      }
      if (constraints['multipleOf'] != null) {
        result['multipleOf'] = constraints['multipleOf'];
      }
    } catch (e) {
      // Ignore constraint extraction errors
    }

    return result;
  }

  /// Extract number constraints (simplified implementation)
  Map<String, dynamic> _extractNumberConstraints(NumberSchema schema) {
    final constraints = <String, dynamic>{};
    
    if (schema.minimum != null) {
      constraints['minimum'] = schema.minimum;
    }
    if (schema.maximum != null) {
      constraints['maximum'] = schema.maximum;
    }
    if (schema.exclusiveMinimum != null) {
      constraints['exclusiveMinimum'] = schema.exclusiveMinimum;
    }
    if (schema.exclusiveMaximum != null) {
      constraints['exclusiveMaximum'] = schema.exclusiveMaximum;
    }
    // multipleOf is not available as a getter due to naming conflict with method
    
    return constraints;
  }

  /// Generate JSON Schema for ArraySchema
  Map<String, dynamic> _generateArraySchema(
      ArraySchema schema, JsonSchemaContext context) {
    final result = <String, dynamic>{
      'type': 'array',
    };

    // Add item schema
    try {
      result['items'] = _generateSchema(schema.elementSchema, context);
    } catch (e) {
      result['items'] = {'type': 'object'};
    }

    if (!context.config.includeConstraints) return result;

    try {
      final constraints = _extractArrayConstraints(schema);

      if (constraints['minItems'] != null) {
        result['minItems'] = constraints['minItems'];
      }
      if (constraints['maxItems'] != null) {
        result['maxItems'] = constraints['maxItems'];
      }
      if (constraints['uniqueItems'] == true) {
        result['uniqueItems'] = true;
      }
    } catch (e) {
      // Ignore constraint extraction errors
    }

    return result;
  }

  /// Extract array constraints (simplified implementation)
  Map<String, dynamic> _extractArrayConstraints(ArraySchema schema) {
    final constraints = <String, dynamic>{};

    // Generate schema for array items
    final context = JsonSchemaContext(const JsonSchemaConfig());
    constraints['items'] = _generateSchema(schema.elementSchema, context);

    // Add length constraints
    if (schema.minItems != null) {
      constraints['minItems'] = schema.minItems;
    }
    if (schema.maxItems != null) {
      constraints['maxItems'] = schema.maxItems;
    }
    if (schema.uniqueItems != null) {
      constraints['uniqueItems'] = schema.uniqueItems;
    }

    return constraints;
  }

  /// Generate JSON Schema for TupleSchema
  Map<String, dynamic> _generateTupleSchema(
      TupleSchema schema, JsonSchemaContext context) {
    final result = <String, dynamic>{
      'type': 'array',
    };

    try {
      // Generate schema for each element in the tuple
      final items = schema.elementSchemas
          .map((s) => _generateSchema(s, context))
          .toList();
      result['items'] = items;

      // Set minimum items to the number of required elements
      result['minItems'] = schema.length;

      // Handle rest schema (additional items)
      if (schema.hasRest) {
        result['additionalItems'] =
            _generateSchema(schema.restSchema!, context);
      } else {
        // If no rest schema, don't allow additional items
        result['additionalItems'] = false;
        // Set maximum items to exact length if no rest schema
        result['maxItems'] = schema.length;
      }
    } catch (e) {
      // Fallback in case of any errors
      result['items'] = {};
    }

    return result;
  }

  /// Generate JSON Schema for ObjectSchema
  Map<String, dynamic> _generateObjectSchema(
      ObjectSchema schema, JsonSchemaContext context) {
    final result = <String, dynamic>{
      'type': 'object',
      'properties': <String, dynamic>{},
    };

    try {
      // Generate properties schema
      final properties = <String, dynamic>{};
      final required = <String>[];

      for (final entry in schema.shape.entries) {
        properties[entry.key] = _generateSchema(entry.value, context);
        if (!schema.optionalKeys.contains(entry.key) && !schema.isPartial) {
          required.add(entry.key);
        }
      }

      result['properties'] = properties;
      if (required.isNotEmpty) {
        result['required'] = required;
      }

      // Handle additional properties based on object mode
      if (schema.mode == ObjectMode.strict) {
        result['additionalProperties'] = false;
      } else if (schema.catchallSchema != null) {
        result['additionalProperties'] =
            _generateSchema(schema.catchallSchema!, context);
      }
    } catch (e) {
      // Fallback in case of any errors
    }

    return result;
  }

  /// Generate JSON Schema for EnumSchema
  Map<String, dynamic> _generateEnumSchema(
      EnumSchema schema, JsonSchemaContext context) {
    try {
      final values = schema.values;
      if (values.isEmpty) {
        return {
          'type': 'string',
          'description': 'Empty enum schema',
        };
      }

      // Determine the type based on the first value
      String type = 'string';
      if (values.first is int) {
        type = 'integer';
      } else if (values.first is double) {
        type = 'number';
      } else if (values.first is bool) {
        type = 'boolean';
      }

      return {
        'type': type,
        'enum': values.toList(),
        'description': 'Enum with ${values.length} possible values',
      };
    } catch (e) {
      // Fallback
      return {
        'type': 'string',
        'description': 'Enum schema (values not accessible)',
      };
    }
  }

  /// Generate JSON Schema for RecordSchema
  Map<String, dynamic> _generateRecordSchema(
      RecordSchema schema, JsonSchemaContext context) {
    final result = <String, dynamic>{
      'type': 'object',
    };

    try {
      // For record schemas, we typically use additionalProperties to define the value schema
      // Since we can't access private fields directly, we'll use a fallback approach
      result['additionalProperties'] = true;

      // Add constraints if available
      if (schema.minEntries != null) {
        result['minProperties'] = schema.minEntries;
      }
      if (schema.maxEntries != null) {
        result['maxProperties'] = schema.maxEntries;
      }

      // If strict mode, don't allow additional properties beyond what's defined
      if (schema.isStrict) {
        result['additionalProperties'] = false;
      }
    } catch (e) {
      result['additionalProperties'] = true;
    }

    return result;
  }

  /// Generate JSON Schema for UnionSchema
  Map<String, dynamic> _generateUnionSchema(
      UnionSchema schema, JsonSchemaContext context) {
    try {
      // Union schemas use anyOf in JSON Schema
      // Since we can't access private _schemas field directly, we'll use a fallback
      // In a real implementation, you'd need access to the schemas list
      return {
        'anyOf': [
          // This would need actual access to schema._schemas
          // schema._schemas.map((s) => _generateSchema(s, context)).toList()
        ],
        'description': 'Union schema - requires access to constituent schemas',
      };
    } catch (e) {
      // Fallback
      return {
        'description': 'Union schema (schemas not accessible)',
      };
    }
  }

  /// Generate JSON Schema for IntersectionSchema
  Map<String, dynamic> _generateIntersectionSchema(
      IntersectionSchema schema, JsonSchemaContext context) {
    try {
      // Intersection schemas use allOf in JSON Schema
      // Since we can't access private _schemas field directly, we'll use a fallback
      // In a real implementation, you'd need access to the schemas list
      return {
        'allOf': [
          // This would need actual access to schema._schemas
          // schema._schemas.map((s) => _generateSchema(s, context)).toList()
        ],
        'description':
            'Intersection schema - requires access to constituent schemas',
      };
    } catch (e) {
      // Fallback
      return {
        'description': 'Intersection schema (schemas not accessible)',
      };
    }
  }
}

/// Extension to add JSON Schema generation to Schema class
extension JsonSchemaExtension on Schema {
  /// Generate JSON Schema representation
  Map<String, dynamic> toJsonSchema({
    JsonSchemaConfig config = const JsonSchemaConfig(),
    String? title,
  }) {
    return const JsonSchemaGenerator()
        .generate(this, config: config, title: title);
  }

  /// Generate OpenAPI 3.0 compatible JSON Schema
  Map<String, dynamic> toOpenApiSchema({String? title}) {
    return toJsonSchema(config: JsonSchemaConfig.openApi30, title: title);
  }

  /// Generate minimal JSON Schema
  Map<String, dynamic> toMinimalJsonSchema({String? title}) {
    return toJsonSchema(config: JsonSchemaConfig.minimal, title: title);
  }
}
