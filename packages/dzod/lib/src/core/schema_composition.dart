/// Schema composition utilities and metadata extraction
///
/// This module provides utilities for composing, analyzing, and extracting
/// metadata from dzod schemas, enabling advanced schema manipulation and introspection.
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
import 'validation_result.dart';

/// Schema information extracted from introspection
class SchemaInfo {
  /// The schema type name
  final String typeName;

  /// Whether the schema is optional/nullable
  final bool isOptional;

  /// Whether the schema is readonly
  final bool isReadonly;

  /// Whether the schema is branded
  final bool isBranded;

  /// Schema description if available
  final String? description;

  /// Schema metadata if available
  final Map<String, dynamic>? metadata;

  /// Nested schema information for composite types
  final List<SchemaInfo> children;

  /// Additional properties specific to the schema type
  final Map<String, dynamic> properties;

  const SchemaInfo({
    required this.typeName,
    this.isOptional = false,
    this.isReadonly = false,
    this.isBranded = false,
    this.description,
    this.metadata,
    this.children = const [],
    this.properties = const {},
  });

  /// Create a copy with modified properties
  SchemaInfo copyWith({
    String? typeName,
    bool? isOptional,
    bool? isReadonly,
    bool? isBranded,
    String? description,
    Map<String, dynamic>? metadata,
    List<SchemaInfo>? children,
    Map<String, dynamic>? properties,
  }) {
    return SchemaInfo(
      typeName: typeName ?? this.typeName,
      isOptional: isOptional ?? this.isOptional,
      isReadonly: isReadonly ?? this.isReadonly,
      isBranded: isBranded ?? this.isBranded,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      children: children ?? this.children,
      properties: properties ?? this.properties,
    );
  }

  @override
  String toString() {
    final flags = <String>[];
    if (isOptional) flags.add('optional');
    if (isReadonly) flags.add('readonly');
    if (isBranded) flags.add('branded');

    final flagStr = flags.isNotEmpty ? ' (${flags.join(', ')})' : '';
    final descStr = description != null ? ' - $description' : '';

    return '$typeName$flagStr$descStr';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SchemaInfo &&
        other.typeName == typeName &&
        other.isOptional == isOptional &&
        other.isReadonly == isReadonly &&
        other.isBranded == isBranded &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(
        typeName,
        isOptional,
        isReadonly,
        isBranded,
        description,
      );
}

/// Schema composition and analysis utilities
class SchemaComposer {
  const SchemaComposer();

  /// Extract comprehensive information from a schema
  SchemaInfo analyze(Schema schema) {
    return _analyzeSchema(schema);
  }

  /// Get the base type name of a schema (unwrapping wrappers)
  String getBaseTypeName(Schema schema) {
    final info = analyze(schema);
    return info.typeName;
  }

  /// Check if a schema is optional/nullable
  bool isOptional(Schema schema) {
    return _isOptionalSchema(schema);
  }

  /// Check if a schema is readonly
  bool isReadonly(Schema schema) {
    return _isReadonlySchema(schema);
  }

  /// Check if a schema is branded
  bool isBranded(Schema schema) {
    return _isBrandedSchema(schema);
  }

  /// Extract all descriptions from a schema tree
  List<String> extractDescriptions(Schema schema) {
    final descriptions = <String>[];
    _collectDescriptions(schema, descriptions);
    return descriptions;
  }

  /// Extract all metadata from a schema tree
  Map<String, dynamic> extractMetadata(Schema schema) {
    final metadata = <String, dynamic>{};
    _collectMetadata(schema, metadata);
    return metadata;
  }

  /// Get schema complexity score (0-100)
  int getComplexityScore(Schema schema) {
    return _calculateComplexity(schema);
  }

  /// Check if two schemas are structurally equivalent
  bool areEquivalent(Schema schema1, Schema schema2) {
    final info1 = analyze(schema1);
    final info2 = analyze(schema2);
    return _compareSchemaInfo(info1, info2);
  }

  /// Merge multiple schemas into a union
  Schema<T> union<T>(List<Schema<T>> schemas) {
    if (schemas.isEmpty) {
      throw ArgumentError('Cannot create union from empty schema list');
    }
    if (schemas.length == 1) {
      return schemas.first;
    }
    return UnionSchema<T>(schemas);
  }

  /// Create intersection of multiple schemas
  Schema<T> intersection<T>(List<Schema<T>> schemas) {
    if (schemas.isEmpty) {
      throw ArgumentError('Cannot create intersection from empty schema list');
    }
    if (schemas.length == 1) {
      return schemas.first;
    }
    return IntersectionSchema<T>(schemas);
  }

  /// Create a conditional schema based on a predicate
  Schema<T> conditional<T>(
    bool Function() condition,
    Schema<T> trueSchema,
    Schema<T> falseSchema,
  ) {
    return Schema.lazy<T>(() => condition() ? trueSchema : falseSchema);
  }

  /// Internal methods for schema analysis

  SchemaInfo _analyzeSchema(Schema schema) {
    // Handle wrapper schemas
    if (schema is DescribeSchema) {
      final inner = _analyzeSchema(schema.innerSchema);
      return inner.copyWith(
        description: schema.description,
        metadata: schema.metadata,
      );
    }

    if (schema is BrandedSchema) {
      final inner = _analyzeSchema(schema.innerSchema);
      return inner.copyWith(isBranded: true);
    }

    if (schema is ReadonlySchema) {
      final inner = _analyzeSchema(schema.innerSchema);
      return inner.copyWith(isReadonly: true);
    }

    if (schema is OptionalSchema) {
      final inner = _analyzeSchema(schema.innerSchema);
      return inner.copyWith(isOptional: true);
    }

    // Analyze base schema types
    return _analyzeBaseSchema(schema);
  }

  SchemaInfo _analyzeBaseSchema(Schema schema) {
    if (schema is StringSchema) {
      return SchemaInfo(
        typeName: 'string',
        description: schema.description,
        metadata: schema.metadata,
        properties: _extractStringProperties(schema),
      );
    }

    if (schema is NumberSchema) {
      return SchemaInfo(
        typeName: 'number',
        description: schema.description,
        metadata: schema.metadata,
        properties: _extractNumberProperties(schema),
      );
    }

    if (schema is BooleanSchema) {
      return SchemaInfo(
        typeName: 'boolean',
        description: schema.description,
        metadata: schema.metadata,
      );
    }

    if (schema is NullSchema) {
      return SchemaInfo(
        typeName: 'null',
        description: schema.description,
        metadata: schema.metadata,
      );
    }

    if (schema is ArraySchema) {
      return SchemaInfo(
        typeName: 'array',
        description: schema.description,
        metadata: schema.metadata,
        properties: _extractArrayProperties(schema),
      );
    }

    if (schema is TupleSchema) {
      return SchemaInfo(
        typeName: 'tuple',
        description: schema.description,
        metadata: schema.metadata,
        properties: _extractTupleProperties(schema),
      );
    }

    if (schema is ObjectSchema) {
      return SchemaInfo(
        typeName: 'object',
        description: schema.description,
        metadata: schema.metadata,
        properties: _extractObjectProperties(schema),
      );
    }

    if (schema is EnumSchema) {
      return SchemaInfo(
        typeName: 'enum',
        description: schema.description,
        metadata: schema.metadata,
        properties: _extractEnumProperties(schema),
      );
    }

    if (schema is RecordSchema) {
      return SchemaInfo(
        typeName: 'record',
        description: schema.description,
        metadata: schema.metadata,
        properties: _extractRecordProperties(schema),
      );
    }

    if (schema is UnionSchema) {
      return SchemaInfo(
        typeName: 'union',
        description: schema.description,
        metadata: schema.metadata,
        properties: {'schemaCount': _getUnionSchemaCount(schema)},
      );
    }

    if (schema is IntersectionSchema) {
      return SchemaInfo(
        typeName: 'intersection',
        description: schema.description,
        metadata: schema.metadata,
        properties: {'schemaCount': _getIntersectionSchemaCount(schema)},
      );
    }

    // Unknown schema type
    return SchemaInfo(
      typeName: schema.runtimeType.toString(),
      description: schema.description,
      metadata: schema.metadata,
      properties: {'isUnknown': true},
    );
  }

  Map<String, dynamic> _extractStringProperties(StringSchema schema) {
    // In a full implementation, you would extract constraints like min/max length
    // For now, return basic properties
    return {'hasConstraints': false};
  }

  Map<String, dynamic> _extractNumberProperties(NumberSchema schema) {
    // In a full implementation, you would extract constraints like min/max values
    return {'hasConstraints': false};
  }

  Map<String, dynamic> _extractArrayProperties(ArraySchema schema) {
    return {'hasConstraints': false};
  }

  Map<String, dynamic> _extractTupleProperties(TupleSchema schema) {
    return {'hasRestSchema': false};
  }

  Map<String, dynamic> _extractObjectProperties(ObjectSchema schema) {
    return {'hasShape': false};
  }

  Map<String, dynamic> _extractEnumProperties(EnumSchema schema) {
    return {'hasValues': false};
  }

  Map<String, dynamic> _extractRecordProperties(RecordSchema schema) {
    return {'hasKeySchema': false};
  }

  int _getUnionSchemaCount(UnionSchema schema) {
    // Would need access to schemas list
    return 0;
  }

  int _getIntersectionSchemaCount(IntersectionSchema schema) {
    // Would need access to schemas list
    return 0;
  }

  bool _isOptionalSchema(Schema schema) {
    if (schema is OptionalSchema) return true;
    if (schema is DescribeSchema) return _isOptionalSchema(schema.innerSchema);
    if (schema is BrandedSchema) return _isOptionalSchema(schema.innerSchema);
    if (schema is ReadonlySchema) return _isOptionalSchema(schema.innerSchema);
    return false;
  }

  bool _isReadonlySchema(Schema schema) {
    if (schema is ReadonlySchema) return true;
    if (schema is DescribeSchema) return _isReadonlySchema(schema.innerSchema);
    if (schema is BrandedSchema) return _isReadonlySchema(schema.innerSchema);
    if (schema is OptionalSchema) return _isReadonlySchema(schema.innerSchema);
    return false;
  }

  bool _isBrandedSchema(Schema schema) {
    if (schema is BrandedSchema) return true;
    if (schema is DescribeSchema) return _isBrandedSchema(schema.innerSchema);
    if (schema is ReadonlySchema) return _isBrandedSchema(schema.innerSchema);
    if (schema is OptionalSchema) return _isBrandedSchema(schema.innerSchema);
    return false;
  }

  void _collectDescriptions(Schema schema, List<String> descriptions) {
    if (schema.description != null) {
      descriptions.add(schema.description!);
    }

    // Recurse into wrapper schemas
    if (schema is DescribeSchema) {
      _collectDescriptions(schema.innerSchema, descriptions);
    } else if (schema is BrandedSchema) {
      _collectDescriptions(schema.innerSchema, descriptions);
    } else if (schema is ReadonlySchema) {
      _collectDescriptions(schema.innerSchema, descriptions);
    } else if (schema is OptionalSchema) {
      _collectDescriptions(schema.innerSchema, descriptions);
    }
  }

  void _collectMetadata(Schema schema, Map<String, dynamic> metadata) {
    if (schema.metadata != null) {
      metadata.addAll(schema.metadata!);
    }

    // Recurse into wrapper schemas
    if (schema is DescribeSchema) {
      _collectMetadata(schema.innerSchema, metadata);
    } else if (schema is BrandedSchema) {
      _collectMetadata(schema.innerSchema, metadata);
    } else if (schema is ReadonlySchema) {
      _collectMetadata(schema.innerSchema, metadata);
    } else if (schema is OptionalSchema) {
      _collectMetadata(schema.innerSchema, metadata);
    }
  }

  int _calculateComplexity(Schema schema) {
    // Simple complexity scoring
    int score = 10; // Base score

    if (schema is UnionSchema) score += 20;
    if (schema is IntersectionSchema) score += 25;
    if (schema is ObjectSchema) score += 15;
    if (schema is ArraySchema) score += 10;
    if (schema is TupleSchema) score += 12;
    if (schema is RecordSchema) score += 15;
    if (schema is EnumSchema) score += 5;

    // Wrapper complexity
    if (schema is DescribeSchema) {
      score += 2;
      score += _calculateComplexity(schema.innerSchema);
    } else if (schema is BrandedSchema) {
      score += 3;
      score += _calculateComplexity(schema.innerSchema);
    } else if (schema is ReadonlySchema) {
      score += 2;
      score += _calculateComplexity(schema.innerSchema);
    } else if (schema is OptionalSchema) {
      score += 1;
      score += _calculateComplexity(schema.innerSchema);
    }

    return score.clamp(0, 100);
  }

  bool _compareSchemaInfo(SchemaInfo info1, SchemaInfo info2) {
    return info1.typeName == info2.typeName &&
        info1.isOptional == info2.isOptional &&
        info1.isReadonly == info2.isReadonly &&
        info1.isBranded == info2.isBranded;
  }
}

/// Extension to add composition utilities to Schema class
extension SchemaCompositionExtension on Schema {
  /// Analyze this schema and extract information
  SchemaInfo analyze() {
    return const SchemaComposer().analyze(this);
  }

  /// Get the base type name (unwrapping wrappers)
  String get baseTypeName {
    return const SchemaComposer().getBaseTypeName(this);
  }

  /// Check if this schema is optional/nullable
  bool get isOptionalSchema {
    return const SchemaComposer().isOptional(this);
  }

  /// Check if this schema is readonly
  bool get isReadonlySchema {
    return const SchemaComposer().isReadonly(this);
  }

  /// Check if this schema is branded
  bool get isBrandedSchema {
    return const SchemaComposer().isBranded(this);
  }

  /// Extract all descriptions from this schema tree
  List<String> get allDescriptions {
    return const SchemaComposer().extractDescriptions(this);
  }

  /// Extract all metadata from this schema tree
  Map<String, dynamic> get allMetadata {
    return const SchemaComposer().extractMetadata(this);
  }

  /// Get complexity score (0-100)
  int get complexityScore {
    return const SchemaComposer().getComplexityScore(this);
  }

  /// Check if this schema is structurally equivalent to another
  bool isEquivalentTo(Schema other) {
    return const SchemaComposer().areEquivalent(this, other);
  }
}

/// A simple schema that accepts any value
class _AnySchema extends Schema<dynamic> {
  const _AnySchema();

  @override
  ValidationResult<dynamic> validate(dynamic input,
      [List<String> path = const []]) {
    return ValidationResult.success(input);
  }
}

/// Utility functions for schema composition
class SchemaUtils {
  const SchemaUtils._();

  /// Create a union of multiple schemas
  static Schema<T> union<T>(List<Schema<T>> schemas) {
    return const SchemaComposer().union(schemas);
  }

  /// Create an intersection of multiple schemas
  static Schema<T> intersection<T>(List<Schema<T>> schemas) {
    return const SchemaComposer().intersection(schemas);
  }

  /// Create a conditional schema
  static Schema<T> conditional<T>(
    bool Function() condition,
    Schema<T> trueSchema,
    Schema<T> falseSchema,
  ) {
    return const SchemaComposer()
        .conditional(condition, trueSchema, falseSchema);
  }

  /// Create a schema that validates any of the provided values
  static Schema<T> oneOf<T>(List<T> values) {
    if (values.isEmpty) {
      throw ArgumentError('oneOf requires at least one value');
    }

    return Schema.lazy<T>(() {
      // Use a simple implementation that accepts anything and refines it
      return RefineSchema<dynamic>(
        const _AnySchema(),
        (dynamic value) => values.contains(value as T),
        message: 'Must be one of: ${values.join(', ')}',
        code: 'one_of',
      ) as Schema<T>;
    });
  }

  /// Create a schema that validates none of the provided values
  static Schema<T> noneOf<T>(List<T> values, Schema<T> baseSchema) {
    return baseSchema.refine(
      (value) => !values.contains(value),
      message: 'Must not be one of: ${values.join(', ')}',
      code: 'none_of',
    );
  }
}
