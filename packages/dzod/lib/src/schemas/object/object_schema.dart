import '../../core/error.dart';
import '../../core/schema.dart';
import '../../core/validation_result.dart';

/// Mode for handling unknown properties in object validation
enum ObjectMode {
  /// Allow unknown properties (default)
  passthrough,

  /// Reject unknown properties with errors
  strict,

  /// Remove unknown properties from output
  strip,
}

/// Schema for validating object structures with comprehensive manipulation methods
class ObjectSchema extends Schema<Map<String, dynamic>> {
  /// Shape definition with property schemas
  final Map<String, Schema<dynamic>> _shape;

  /// Optional properties that may be missing
  final Set<String> _optionalKeys;

  /// Mode for handling unknown properties
  final ObjectMode _mode;

  /// Catchall schema for unknown properties (when not in strict mode)
  final Schema<dynamic>? _catchall;

  /// Whether all properties should be optional (partial mode)
  final bool _isPartial;

  /// Whether nested objects should also be partial (deep partial mode)
  final bool _isDeepPartial;

  const ObjectSchema(
    this._shape, {
    super.description,
    super.metadata,
    Set<String>? optionalKeys,
    ObjectMode mode = ObjectMode.passthrough,
    Schema<dynamic>? catchall,
    bool isPartial = false,
    bool isDeepPartial = false,
  })  : _optionalKeys = optionalKeys ?? const {},
        _mode = mode,
        _catchall = catchall,
        _isPartial = isPartial,
        _isDeepPartial = isDeepPartial;

  @override
  ValidationResult<Map<String, dynamic>> validate(dynamic input,
      [List<String> path = const []]) {
    // Type check
    if (input is! Map) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.typeMismatch(
            path: path,
            received: input,
            expected: 'object',
          ),
        ),
      );
    }

    final inputMap = Map<String, dynamic>.from(input);
    final result = <String, dynamic>{};
    final errors = <ValidationError>[];

    // Validate defined properties
    for (final entry in _shape.entries) {
      final key = entry.key;
      final schema = entry.value;
      final isOptional = _optionalKeys.contains(key) || _isPartial;

      if (!inputMap.containsKey(key)) {
        if (!isOptional) {
          errors.add(
            ValidationError.constraintViolation(
              path: path,
              received: inputMap,
              constraint: 'required property $key',
              code: 'missing_required_property',
              context: {'missingKey': key},
            ),
          );
        }
        continue;
      }

      final value = inputMap[key];
      Schema<dynamic> validationSchema = schema;

      // Apply deep partial to nested objects
      if (_isDeepPartial && schema is ObjectSchema) {
        validationSchema = schema.deepPartial();
      }

      final fieldResult = validationSchema.validate(value, [...path, key]);
      if (fieldResult.isSuccess) {
        result[key] = fieldResult.data;
      } else {
        errors.addAll(fieldResult.errors!.errors);
      }
    }

    // Handle unknown properties
    final unknownKeys = inputMap.keys.where((key) => !_shape.containsKey(key));

    for (final key in unknownKeys) {
      final value = inputMap[key];

      switch (_mode) {
        case ObjectMode.strict:
          errors.add(
            ValidationError.constraintViolation(
              path: [...path, key],
              received: value,
              constraint: 'known property',
              code: 'unknown_property',
              context: {'allowedKeys': _shape.keys.toList()},
            ),
          );
          break;

        case ObjectMode.strip:
          // Do nothing - unknown properties are stripped
          break;

        case ObjectMode.passthrough:
          if (_catchall != null) {
            final catchallResult = _catchall!.validate(value, [...path, key]);
            if (catchallResult.isSuccess) {
              result[key] = catchallResult.data;
            } else {
              errors.addAll(catchallResult.errors!.errors);
            }
          } else {
            result[key] = value;
          }
          break;
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(ValidationErrorCollection(errors));
    }

    return ValidationResult.success(result);
  }

  @override
  Future<ValidationResult<Map<String, dynamic>>> validateAsync(dynamic input,
      [List<String> path = const []]) async {
    // Type check
    if (input is! Map) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.typeMismatch(
            path: path,
            received: input,
            expected: 'object',
          ),
        ),
      );
    }

    final inputMap = Map<String, dynamic>.from(input);
    final result = <String, dynamic>{};
    final errors = <ValidationError>[];

    // Validate defined properties asynchronously
    for (final entry in _shape.entries) {
      final key = entry.key;
      final schema = entry.value;
      final isOptional = _optionalKeys.contains(key) || _isPartial;

      if (!inputMap.containsKey(key)) {
        if (!isOptional) {
          errors.add(
            ValidationError.constraintViolation(
              path: path,
              received: inputMap,
              constraint: 'required property $key',
              code: 'missing_required_property',
              context: {'missingKey': key},
            ),
          );
        }
        continue;
      }

      final value = inputMap[key];
      Schema<dynamic> validationSchema = schema;

      // Apply deep partial to nested objects
      if (_isDeepPartial && schema is ObjectSchema) {
        validationSchema = schema.deepPartial();
      }

      final fieldResult =
          await validationSchema.validateAsync(value, [...path, key]);
      if (fieldResult.isSuccess) {
        result[key] = fieldResult.data;
      } else {
        errors.addAll(fieldResult.errors!.errors);
      }
    }

    // Handle unknown properties
    final unknownKeys = inputMap.keys.where((key) => !_shape.containsKey(key));

    for (final key in unknownKeys) {
      final value = inputMap[key];

      switch (_mode) {
        case ObjectMode.strict:
          errors.add(
            ValidationError.constraintViolation(
              path: [...path, key],
              received: value,
              constraint: 'known property',
              code: 'unknown_property',
              context: {'allowedKeys': _shape.keys.toList()},
            ),
          );
          break;

        case ObjectMode.strip:
          // Do nothing - unknown properties are stripped
          break;

        case ObjectMode.passthrough:
          if (_catchall != null) {
            final catchallResult =
                await _catchall!.validateAsync(value, [...path, key]);
            if (catchallResult.isSuccess) {
              result[key] = catchallResult.data;
            } else {
              errors.addAll(catchallResult.errors!.errors);
            }
          } else {
            result[key] = value;
          }
          break;
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(ValidationErrorCollection(errors));
    }

    return ValidationResult.success(result);
  }

  /// Creates a new schema with only the specified properties
  ObjectSchema pick(List<String> keys) {
    final newShape = <String, Schema<dynamic>>{};
    final newOptionalKeys = <String>{};

    for (final key in keys) {
      if (_shape.containsKey(key)) {
        newShape[key] = _shape[key]!;
        if (_optionalKeys.contains(key)) {
          newOptionalKeys.add(key);
        }
      }
    }

    return ObjectSchema(
      newShape,
      description: description,
      metadata: metadata,
      optionalKeys: newOptionalKeys,
      mode: _mode,
      catchall: _catchall,
      isPartial: _isPartial,
      isDeepPartial: _isDeepPartial,
    );
  }

  /// Creates a new schema excluding the specified properties
  ObjectSchema omit(List<String> keys) {
    final newShape = Map<String, Schema<dynamic>>.from(_shape);
    final newOptionalKeys = Set<String>.from(_optionalKeys);

    for (final key in keys) {
      newShape.remove(key);
      newOptionalKeys.remove(key);
    }

    return ObjectSchema(
      newShape,
      description: description,
      metadata: metadata,
      optionalKeys: newOptionalKeys,
      mode: _mode,
      catchall: _catchall,
      isPartial: _isPartial,
      isDeepPartial: _isDeepPartial,
    );
  }

  /// Makes all properties optional
  ObjectSchema partial() {
    return ObjectSchema(
      _shape,
      description: description,
      metadata: metadata,
      optionalKeys: _shape.keys.toSet(),
      mode: _mode,
      catchall: _catchall,
      isPartial: true,
      isDeepPartial: _isDeepPartial,
    );
  }

  /// Makes all properties optional, including nested objects
  ObjectSchema deepPartial() {
    return ObjectSchema(
      _shape,
      description: description,
      metadata: metadata,
      optionalKeys: _shape.keys.toSet(),
      mode: _mode,
      catchall: _catchall,
      isPartial: true,
      isDeepPartial: true,
    );
  }

  /// Makes all optional properties required
  ObjectSchema required([List<String>? keys]) {
    Set<String> newOptionalKeys;

    if (keys != null) {
      newOptionalKeys = Set<String>.from(_optionalKeys);
      for (final key in keys) {
        newOptionalKeys.remove(key);
      }
    } else {
      newOptionalKeys = const <String>{};
    }

    return ObjectSchema(
      _shape,
      description: description,
      metadata: metadata,
      optionalKeys: newOptionalKeys,
      mode: _mode,
      catchall: _catchall,
      isPartial: false,
      isDeepPartial: _isDeepPartial,
    );
  }

  /// Extends the schema with additional properties
  ObjectSchema extend(
    Map<String, Schema<dynamic>> additionalShape, {
    Set<String>? additionalOptionalKeys,
  }) {
    final newShape = <String, Schema<dynamic>>{
      ..._shape,
      ...additionalShape,
    };

    final newOptionalKeys = <String>{
      ..._optionalKeys,
      ...?additionalOptionalKeys,
    };

    return ObjectSchema(
      newShape,
      description: description,
      metadata: metadata,
      optionalKeys: newOptionalKeys,
      mode: _mode,
      catchall: _catchall,
      isPartial: _isPartial,
      isDeepPartial: _isDeepPartial,
    );
  }

  /// Merges with another object schema
  ObjectSchema merge(ObjectSchema other) {
    final newShape = <String, Schema<dynamic>>{
      ..._shape,
      ...other._shape,
    };

    final newOptionalKeys = <String>{
      ..._optionalKeys,
      ...other._optionalKeys,
    };

    return ObjectSchema(
      newShape,
      description: description,
      metadata: metadata,
      optionalKeys: newOptionalKeys,
      mode: _mode,
      catchall: _catchall,
      isPartial: _isPartial || other._isPartial,
      isDeepPartial: _isDeepPartial || other._isDeepPartial,
    );
  }

  /// Sets mode to passthrough (allow unknown properties)
  ObjectSchema passthrough([Schema<dynamic>? catchall]) {
    return ObjectSchema(
      _shape,
      description: description,
      metadata: metadata,
      optionalKeys: _optionalKeys,
      mode: ObjectMode.passthrough,
      catchall: catchall,
      isPartial: _isPartial,
      isDeepPartial: _isDeepPartial,
    );
  }

  /// Sets mode to strict (reject unknown properties)
  ObjectSchema strict() {
    return ObjectSchema(
      _shape,
      description: description,
      metadata: metadata,
      optionalKeys: _optionalKeys,
      mode: ObjectMode.strict,
      catchall: null,
      isPartial: _isPartial,
      isDeepPartial: _isDeepPartial,
    );
  }

  /// Sets mode to strip (remove unknown properties)
  ObjectSchema strip() {
    return ObjectSchema(
      _shape,
      description: description,
      metadata: metadata,
      optionalKeys: _optionalKeys,
      mode: ObjectMode.strip,
      catchall: null,
      isPartial: _isPartial,
      isDeepPartial: _isDeepPartial,
    );
  }

  /// Sets a catchall schema for unknown properties
  ObjectSchema catchall(Schema<dynamic> schema) {
    return ObjectSchema(
      _shape,
      description: description,
      metadata: metadata,
      optionalKeys: _optionalKeys,
      mode: ObjectMode.passthrough,
      catchall: schema,
      isPartial: _isPartial,
      isDeepPartial: _isDeepPartial,
    );
  }

  /// Validates that object contains all specified keys
  Schema<Map<String, dynamic>> containsKeys(List<String> keys) {
    return refine(
      (obj) => keys.every((key) => obj.containsKey(key)),
      message: 'object must contain keys: ${keys.join(', ')}',
      code: 'missing_keys',
    );
  }

  /// Validates that object has at least the minimum number of properties
  Schema<Map<String, dynamic>> minProperties(int min) {
    return refine(
      (obj) => obj.length >= min,
      message: 'object must have at least $min properties',
      code: 'too_few_properties',
    );
  }

  /// Validates that object has at most the maximum number of properties
  Schema<Map<String, dynamic>> maxProperties(int max) {
    return refine(
      (obj) => obj.length <= max,
      message: 'object must have at most $max properties',
      code: 'too_many_properties',
    );
  }

  /// Validates that object is not empty
  Schema<Map<String, dynamic>> nonempty() {
    return minProperties(1);
  }

  /// Transforms object after validation
  Schema<Map<String, R>> mapValues<R>(R Function(dynamic value) mapper) {
    return transform<Map<String, R>>(
      (obj) => obj.map((key, value) => MapEntry(key, mapper(value))),
    );
  }

  /// Filters object properties after validation
  Schema<Map<String, dynamic>> filterKeys(
      bool Function(String key, dynamic value) predicate) {
    return transform(
      (obj) => Map.fromEntries(
        obj.entries.where((entry) => predicate(entry.key, entry.value)),
      ),
    );
  }

  /// Gets the object shape
  Map<String, Schema<dynamic>> get shape => Map.unmodifiable(_shape);

  /// Gets optional keys
  Set<String> get optionalKeys => Set.unmodifiable(_optionalKeys);

  /// Gets required keys
  Set<String> get requiredKeys => _shape.keys
      .where((key) => !_optionalKeys.contains(key) && !_isPartial)
      .toSet();

  /// Gets the current mode
  ObjectMode get mode => _mode;

  /// Gets the catchall schema
  Schema<dynamic>? get catchallSchema => _catchall;

  /// Checks if schema is in partial mode
  bool get isPartial => _isPartial;

  /// Checks if schema is in deep partial mode
  bool get isDeepPartial => _isDeepPartial;

  @override
  String toString() {
    final modeStr = _mode != ObjectMode.passthrough ? ' (${_mode.name})' : '';
    final partialStr = _isPartial ? ' partial' : '';
    final deepPartialStr = _isDeepPartial ? ' deep-partial' : '';
    final requiredCount = requiredKeys.length;
    final optionalCount = _optionalKeys.length;

    return 'ObjectSchema{required: $requiredCount, optional: $optionalCount$partialStr$deepPartialStr$modeStr}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ObjectSchema &&
        _mapEquals(_shape, other._shape) &&
        _setEquals(_optionalKeys, other._optionalKeys) &&
        _mode == other._mode &&
        _catchall == other._catchall &&
        _isPartial == other._isPartial &&
        _isDeepPartial == other._isDeepPartial;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(_shape.entries.map((e) => Object.hash(e.key, e.value))),
        Object.hashAll(_optionalKeys),
        _mode,
        _catchall,
        _isPartial,
        _isDeepPartial,
      );

  /// Helper method to compare maps for equality
  static bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  /// Helper method to compare sets for equality
  static bool _setEquals<T>(Set<T>? a, Set<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    return a.containsAll(b);
  }
}

/// Factory methods for creating common object schemas
extension ObjectFactories on Never {
  /// Creates a simple object schema with string keys
  static ObjectSchema simple(Map<String, Schema<dynamic>> shape) {
    return ObjectSchema(shape);
  }

  /// Creates an object schema with optional properties
  static ObjectSchema withOptional(
    Map<String, Schema<dynamic>> shape,
    Set<String> optionalKeys,
  ) {
    return ObjectSchema(shape, optionalKeys: optionalKeys);
  }

  /// Creates a strict object schema (no unknown properties)
  static ObjectSchema strictObject(Map<String, Schema<dynamic>> shape) {
    return ObjectSchema(shape, mode: ObjectMode.strict);
  }

  /// Creates a partial object schema (all properties optional)
  static ObjectSchema partialObject(Map<String, Schema<dynamic>> shape) {
    return ObjectSchema(shape).partial();
  }

  /// Creates an empty object schema
  static ObjectSchema empty() {
    return const ObjectSchema({});
  }
}
