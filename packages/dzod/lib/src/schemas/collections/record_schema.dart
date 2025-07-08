import '../../core/error.dart';
import '../../core/schema.dart';
import '../../core/validation_result.dart';

/// Schema for validating record (key-value) structures with typed keys and values
class RecordSchema<K, V> extends Schema<Map<K, V>> {
  /// Schema for validating keys
  final Schema<K>? _keySchema;

  /// Schema for validating values
  final Schema<V>? _valueSchema;

  /// Required keys that must be present
  final Set<K>? _requiredKeys;

  /// Optional keys that may be present
  final Set<K>? _optionalKeys;

  /// Minimum number of entries
  final int? _minEntries;

  /// Maximum number of entries
  final int? _maxEntries;

  /// Whether to allow additional keys beyond required/optional
  final bool _strict;

  const RecordSchema({
    super.description,
    super.metadata,
    Schema<K>? keySchema,
    Schema<V>? valueSchema,
    Set<K>? requiredKeys,
    Set<K>? optionalKeys,
    int? minEntries,
    int? maxEntries,
    bool strict = false,
  })  : _keySchema = keySchema,
        _valueSchema = valueSchema,
        _requiredKeys = requiredKeys,
        _optionalKeys = optionalKeys,
        _minEntries = minEntries,
        _maxEntries = maxEntries,
        _strict = strict;

  @override
  ValidationResult<Map<K, V>> validate(dynamic input,
      [List<String> path = const []]) {
    // Type check
    if (input is! Map) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.typeMismatch(
            path: path,
            received: input,
            expected: 'record',
          ),
        ),
      );
    }

    Map<dynamic, dynamic> inputMap = input;

    // Length validations
    if (_minEntries != null && inputMap.length < _minEntries!) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: inputMap,
            constraint: 'minimum $_minEntries entries',
            code: 'record_too_small',
            context: {'expected': _minEntries, 'actual': inputMap.length},
          ),
        ),
      );
    }

    if (_maxEntries != null && inputMap.length > _maxEntries!) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: inputMap,
            constraint: 'maximum $_maxEntries entries',
            code: 'record_too_large',
            context: {'expected': _maxEntries, 'actual': inputMap.length},
          ),
        ),
      );
    }

    final validatedMap = <K, V>{};
    final errors = <ValidationError>[];

    // Check required keys
    if (_requiredKeys != null) {
      for (final requiredKey in _requiredKeys!) {
        if (!inputMap.containsKey(requiredKey)) {
          errors.add(
            ValidationError.constraintViolation(
              path: path,
              received: inputMap,
              constraint: 'required key $requiredKey',
              code: 'missing_required_key',
              context: {'missingKey': requiredKey},
            ),
          );
          continue;
        }
      }
    }

    // Validate each entry
    final allowedKeys = <K>{
      ...?_requiredKeys,
      ...?_optionalKeys,
    };

    for (final entry in inputMap.entries) {
      final key = entry.key;
      final value = entry.value;

      // Validate key
      K validatedKey;
      if (_keySchema != null) {
        final keyResult = _keySchema!.validate(key, [...path, 'key']);
        if (keyResult.isSuccess) {
          validatedKey = keyResult.data as K;
        } else {
          errors.addAll(keyResult.errors!.errors);
          continue;
        }
      } else {
        if (key is! K) {
          errors.add(
            ValidationError.typeMismatch(
              path: [...path, 'key'],
              received: key,
              expected: K.toString(),
            ),
          );
          continue;
        }
        validatedKey = key;
      }

      // Check if key is allowed in strict mode
      if (_strict &&
          allowedKeys.isNotEmpty &&
          !allowedKeys.contains(validatedKey)) {
        errors.add(
          ValidationError.constraintViolation(
            path: [...path, validatedKey.toString()],
            received: validatedKey,
            constraint: 'allowed key',
            code: 'unexpected_key',
            context: {'allowedKeys': allowedKeys.toList()},
          ),
        );
        continue;
      }

      // Validate value
      V validatedValue;
      if (_valueSchema != null) {
        final valueResult = _valueSchema!.validate(
          value,
          [...path, validatedKey.toString()],
        );
        if (valueResult.isSuccess) {
          validatedValue = valueResult.data as V;
        } else {
          errors.addAll(valueResult.errors!.errors);
          continue;
        }
      } else {
        if (value is! V) {
          errors.add(
            ValidationError.typeMismatch(
              path: [...path, validatedKey.toString()],
              received: value,
              expected: V.toString(),
            ),
          );
          continue;
        }
        validatedValue = value;
      }

      validatedMap[validatedKey] = validatedValue;
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(ValidationErrorCollection(errors));
    }

    return ValidationResult.success(validatedMap);
  }

  /// Sets key validation schema
  RecordSchema<K, V> keySchema(Schema<K> schema) {
    return RecordSchema<K, V>(
      description: description,
      metadata: metadata,
      keySchema: schema,
      valueSchema: _valueSchema,
      requiredKeys: _requiredKeys,
      optionalKeys: _optionalKeys,
      minEntries: _minEntries,
      maxEntries: _maxEntries,
      strict: _strict,
    );
  }

  /// Sets value validation schema
  RecordSchema<K, V> valueSchema(Schema<V> schema) {
    return RecordSchema<K, V>(
      description: description,
      metadata: metadata,
      keySchema: _keySchema,
      valueSchema: schema,
      requiredKeys: _requiredKeys,
      optionalKeys: _optionalKeys,
      minEntries: _minEntries,
      maxEntries: _maxEntries,
      strict: _strict,
    );
  }

  /// Sets required keys
  RecordSchema<K, V> requiredKeys(Set<K> keys) {
    return RecordSchema<K, V>(
      description: description,
      metadata: metadata,
      keySchema: _keySchema,
      valueSchema: _valueSchema,
      requiredKeys: keys,
      optionalKeys: _optionalKeys,
      minEntries: _minEntries,
      maxEntries: _maxEntries,
      strict: _strict,
    );
  }

  /// Sets optional keys
  RecordSchema<K, V> optionalKeys(Set<K> keys) {
    return RecordSchema<K, V>(
      description: description,
      metadata: metadata,
      keySchema: _keySchema,
      valueSchema: _valueSchema,
      requiredKeys: _requiredKeys,
      optionalKeys: keys,
      minEntries: _minEntries,
      maxEntries: _maxEntries,
      strict: _strict,
    );
  }

  /// Sets minimum number of entries
  RecordSchema<K, V> min(int minEntries) {
    return RecordSchema<K, V>(
      description: description,
      metadata: metadata,
      keySchema: _keySchema,
      valueSchema: _valueSchema,
      requiredKeys: _requiredKeys,
      optionalKeys: _optionalKeys,
      minEntries: minEntries,
      maxEntries: _maxEntries,
      strict: _strict,
    );
  }

  /// Sets maximum number of entries
  RecordSchema<K, V> max(int maxEntries) {
    return RecordSchema<K, V>(
      description: description,
      metadata: metadata,
      keySchema: _keySchema,
      valueSchema: _valueSchema,
      requiredKeys: _requiredKeys,
      optionalKeys: _optionalKeys,
      minEntries: _minEntries,
      maxEntries: maxEntries,
      strict: _strict,
    );
  }

  /// Enables strict mode (no additional keys allowed)
  RecordSchema<K, V> strict() {
    return RecordSchema<K, V>(
      description: description,
      metadata: metadata,
      keySchema: _keySchema,
      valueSchema: _valueSchema,
      requiredKeys: _requiredKeys,
      optionalKeys: _optionalKeys,
      minEntries: _minEntries,
      maxEntries: _maxEntries,
      strict: true,
    );
  }

  /// Sets exact number of entries
  RecordSchema<K, V> length(int exactLength) {
    return RecordSchema<K, V>(
      description: description,
      metadata: metadata,
      keySchema: _keySchema,
      valueSchema: _valueSchema,
      requiredKeys: _requiredKeys,
      optionalKeys: _optionalKeys,
      minEntries: exactLength,
      maxEntries: exactLength,
      strict: _strict,
    );
  }

  /// Ensures record is non-empty
  RecordSchema<K, V> nonempty() {
    return min(1);
  }

  /// Validates that record contains specific keys
  Schema<Map<K, V>> containsKeys(Set<K> keys) {
    return refine(
      (record) => keys.every((key) => record.containsKey(key)),
      message: 'record must contain keys: ${keys.join(', ')}',
      code: 'missing_keys',
    );
  }

  /// Validates that record contains specific values
  Schema<Map<K, V>> containsValues(Set<V> values) {
    return refine(
      (record) => values.every((value) => record.containsValue(value)),
      message: 'record must contain values: ${values.join(', ')}',
      code: 'missing_values',
    );
  }

  /// Transforms record after validation
  Schema<Map<K2, V2>> mapEntries<K2, V2>(
    MapEntry<K2, V2> Function(K key, V value) mapper,
  ) {
    return transform<Map<K2, V2>>(
      (record) => Map.fromEntries(
        record.entries.map((e) => mapper(e.key, e.value)),
      ),
    );
  }

  /// Transforms record keys after validation
  Schema<Map<K2, V>> mapKeys<K2>(K2 Function(K key) mapper) {
    return transform<Map<K2, V>>(
      (record) => Map.fromEntries(
        record.entries.map((e) => MapEntry(mapper(e.key), e.value)),
      ),
    );
  }

  /// Transforms record values after validation
  Schema<Map<K, V2>> mapValues<V2>(V2 Function(V value) mapper) {
    return transform<Map<K, V2>>(
      (record) => Map.fromEntries(
        record.entries.map((e) => MapEntry(e.key, mapper(e.value))),
      ),
    );
  }

  /// Filters record entries after validation
  Schema<Map<K, V>> filterEntries(bool Function(K key, V value) predicate) {
    return transform(
      (record) => Map.fromEntries(
        record.entries.where((e) => predicate(e.key, e.value)),
      ),
    );
  }

  /// Gets record size constraints
  int? get minEntries => _minEntries;
  int? get maxEntries => _maxEntries;
  bool get isStrict => _strict;
  Set<K>? get requiredKeySet => _requiredKeys;
  Set<K>? get optionalKeySet => _optionalKeys;

  @override
  String toString() {
    final constraints = <String>[];

    if (_minEntries != null) constraints.add('min: $_minEntries');
    if (_maxEntries != null) constraints.add('max: $_maxEntries');
    if (_strict) constraints.add('strict');
    if (_requiredKeys?.isNotEmpty == true) {
      constraints.add('required: ${_requiredKeys!.take(2).join(', ')}');
    }

    final constraintStr =
        constraints.isNotEmpty ? ' (${constraints.join(', ')})' : '';
    return 'RecordSchema<$K, $V>$constraintStr';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecordSchema<K, V> &&
        other._keySchema == _keySchema &&
        other._valueSchema == _valueSchema &&
        _setEquals(other._requiredKeys, _requiredKeys) &&
        _setEquals(other._optionalKeys, _optionalKeys) &&
        other._minEntries == _minEntries &&
        other._maxEntries == _maxEntries &&
        other._strict == _strict;
  }

  @override
  int get hashCode => Object.hash(
        _keySchema,
        _valueSchema,
        _requiredKeys,
        _optionalKeys,
        _minEntries,
        _maxEntries,
        _strict,
      );

  /// Helper method to compare sets for equality
  static bool _setEquals<T>(Set<T>? a, Set<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    return a.containsAll(b);
  }
}

/// Factory methods for creating common record schemas
extension RecordFactories on Never {
  /// Creates a string-keyed record schema
  static RecordSchema<String, V> stringRecord<V>([Schema<V>? valueSchema]) {
    return RecordSchema<String, V>(valueSchema: valueSchema);
  }

  /// Creates a string-to-string record schema
  static RecordSchema<String, String> stringMap() {
    return const RecordSchema<String, String>();
  }

  /// Creates a string-to-dynamic record schema
  static RecordSchema<String, dynamic> dynamicRecord() {
    return const RecordSchema<String, dynamic>();
  }

  /// Creates a typed key-value record schema
  static RecordSchema<K, V> typedRecord<K, V>({
    Schema<K>? keySchema,
    Schema<V>? valueSchema,
  }) {
    return RecordSchema<K, V>(
      keySchema: keySchema,
      valueSchema: valueSchema,
    );
  }
}
