import '../../core/error.dart';
import '../../core/error_codes.dart';
import '../../core/schema.dart';
import '../../core/validation_result.dart';

/// Enhanced recursive schema with circular reference detection and handling
///
/// This schema provides better support for recursive data structures with
/// built-in circular reference detection, depth limits, and memory management.
///
/// Example:
/// ```dart
/// // Define a tree structure
/// late final Schema<Map<String, dynamic>> treeSchema;
/// treeSchema = z.recursive(() => z.object({
///   'value': z.string(),
///   'children': z.array(treeSchema).optional(),
/// }));
/// ```
class RecursiveSchema<T> extends Schema<T> {
  final Schema<T> Function() _schemaFactory;
  final int _maxDepth;
  final bool _enableCircularDetection;
  final bool _enableMemoization;
  final Map<String, Schema<T>> _memoCache = {};
  Schema<T>? _cachedSchema;

  /// Creates a recursive schema with enhanced circular reference handling
  ///
  /// [schemaFactory] - Function that returns the schema definition
  /// [maxDepth] - Maximum recursion depth (default: 1000)
  /// [enableCircularDetection] - Whether to detect circular references (default: true)
  /// [enableMemoization] - Whether to cache schema instances (default: true)
  RecursiveSchema(
    this._schemaFactory, {
    int maxDepth = 1000,
    bool enableCircularDetection = true,
    bool enableMemoization = true,
    super.description,
    super.metadata,
  })  : _maxDepth = maxDepth,
        _enableCircularDetection = enableCircularDetection,
        _enableMemoization = enableMemoization;

  Schema<T> get _schema {
    if (_enableMemoization) {
      final cacheKey = _getCacheKey();
      if (_memoCache.containsKey(cacheKey)) {
        return _memoCache[cacheKey]!;
      }

      _cachedSchema ??= _schemaFactory();
      _memoCache[cacheKey] = _cachedSchema!;
      return _cachedSchema!;
    } else {
      _cachedSchema ??= _schemaFactory();
      return _cachedSchema!;
    }
  }

  String _getCacheKey() {
    return '${runtimeType}_${hashCode}_${description ?? 'no_desc'}';
  }

  @override
  ValidationResult<T> validate(dynamic input, [List<String> path = const []]) {
    // Check if this is the root of the validation tree
    final isRoot = _globalContext == null;

    try {
      final context = _getOrCreateValidationContext();
      return _validateWithContext(input, path, context);
    } finally {
      // Clear global context only if this was the root validator
      if (isRoot) {
        _clearGlobalContext();
      }
    }
  }

  static ValidationContext? _globalContext;

  ValidationContext _getOrCreateValidationContext() {
    // Use global context for the validation tree
    return _globalContext ??= ValidationContext();
  }

  static void _clearGlobalContext() {
    _globalContext = null;
  }

  @override
  Future<ValidationResult<T>> validateAsync(dynamic input,
      [List<String> path = const []]) async {
    return await _validateAsyncWithContext(input, path, ValidationContext());
  }

  ValidationResult<T> _validateWithContext(
      dynamic input, List<String> path, ValidationContext context) {
    // Update context stats
    context.totalValidations++;

    // Check depth limit
    if (context.depth >= _maxDepth) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            constraint: 'Maximum recursion depth exceeded: $_maxDepth',
            received: input,
            path: path,
            code: ValidationErrorCode.schemaCircular.code,
          ),
        ),
      );
    }

    // Check for circular references before processing
    String? objectId;
    if (_enableCircularDetection) {
      objectId = _getObjectId(input);
      if (objectId != null) {
        if (context.visitedObjects.contains(objectId)) {
          context.circularReferencesDetected++;
          return ValidationResult.failure(
            ValidationErrorCollection.single(
              ValidationError.constraintViolation(
                constraint: 'Circular reference detected',
                received: input,
                path: path,
                code: ValidationErrorCode.schemaCircular.code,
              ),
            ),
          );
        }
        // Add to visited set before processing
        context.visitedObjects.add(objectId);
      }
    }

    // Increment depth and update max depth reached
    context.depth++;
    if (context.depth > context.maxDepthReached) {
      context.maxDepthReached = context.depth;
    }

    ValidationResult<T> result;

    try {
      // If the schema is also a RecursiveSchema, pass the context
      if (_schema is RecursiveSchema<T>) {
        final recursiveSchema = _schema as RecursiveSchema<T>;
        result = recursiveSchema._validateWithContext(input, path, context);
      } else {
        // For non-recursive schemas, we need to handle nested RecursiveSchema instances
        result = _validateNestedWithContext(input, path, context);
      }
    } finally {
      // Always decrement depth and clean up
      context.depth--;

      // Remove from visited set when done processing this object
      if (_enableCircularDetection && objectId != null) {
        context.visitedObjects.remove(objectId);
      }
    }

    return result;
  }

  /// Helper method to handle nested validation with context propagation
  ValidationResult<T> _validateNestedWithContext(
      dynamic input, List<String> path, ValidationContext context) {
    // For now, just use regular validation - the context will be passed through RecursiveSchema instances
    return _schema.validate(input, path);
  }

  Future<ValidationResult<T>> _validateAsyncWithContext(
      dynamic input, List<String> path, ValidationContext context) async {
    // Update context stats
    context.totalValidations++;

    // Check depth limit
    if (context.depth >= _maxDepth) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            constraint: 'Maximum recursion depth exceeded: $_maxDepth',
            received: input,
            path: path,
            code: ValidationErrorCode.schemaCircular.code,
          ),
        ),
      );
    }

    // Check for circular references
    if (_enableCircularDetection) {
      final objectId = _getObjectId(input);
      if (objectId != null && context.visitedObjects.contains(objectId)) {
        context.circularReferencesDetected++;
        return ValidationResult.failure(
          ValidationErrorCollection.single(
            ValidationError.constraintViolation(
              constraint: 'Circular reference detected',
              received: input,
              path: path,
              code: ValidationErrorCode.schemaCircular.code,
            ),
          ),
        );
      }

      if (objectId != null) {
        context.visitedObjects.add(objectId);
      }
    }

    // Increment depth and update max depth reached
    context.depth++;
    if (context.depth > context.maxDepthReached) {
      context.maxDepthReached = context.depth;
    }

    ValidationResult<T> result;

    // If the schema is also a RecursiveSchema, pass the context
    if (_schema is RecursiveSchema<T>) {
      final recursiveSchema = _schema as RecursiveSchema<T>;
      result =
          await recursiveSchema._validateAsyncWithContext(input, path, context);
    } else {
      // For non-recursive schemas, use regular validation
      result = await _schema.validateAsync(input, path);
    }

    // Decrement depth when returning
    context.depth--;

    return result;
  }

  String? _getObjectId(dynamic input) {
    if (input == null) return null;

    // For objects and arrays, use identity hash combined with type and length
    if (input is Map) {
      return 'Map_${identityHashCode(input)}_${input.length}';
    }
    if (input is List) {
      return 'List_${identityHashCode(input)}_${input.length}';
    }

    return null;
  }

  /// Gets the maximum recursion depth
  int get maxDepth => _maxDepth;

  /// Checks if circular detection is enabled
  bool get isCircularDetectionEnabled => _enableCircularDetection;

  /// Checks if memoization is enabled
  bool get isMemoizationEnabled => _enableMemoization;

  /// Gets the number of cached schema instances
  int get cacheSize => _memoCache.length;

  /// Clears the memoization cache
  void clearCache() {
    _memoCache.clear();
    _cachedSchema = null;
  }

  /// Creates a new recursive schema with different settings
  RecursiveSchema<T> withSettings({
    int? maxDepth,
    bool? enableCircularDetection,
    bool? enableMemoization,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return RecursiveSchema<T>(
      _schemaFactory,
      maxDepth: maxDepth ?? _maxDepth,
      enableCircularDetection:
          enableCircularDetection ?? _enableCircularDetection,
      enableMemoization: enableMemoization ?? _enableMemoization,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Creates a copy with increased max depth
  RecursiveSchema<T> withMaxDepth(int maxDepth) {
    return withSettings(maxDepth: maxDepth);
  }

  /// Creates a copy with circular detection enabled/disabled
  RecursiveSchema<T> withCircularDetection(bool enabled) {
    return withSettings(enableCircularDetection: enabled);
  }

  /// Creates a copy with memoization enabled/disabled
  RecursiveSchema<T> withMemoization(bool enabled) {
    return withSettings(enableMemoization: enabled);
  }

  /// Creates a safe recursive schema with conservative settings
  RecursiveSchema<T> safe() {
    return withSettings(
      maxDepth: 100,
      enableCircularDetection: true,
      enableMemoization: true,
    );
  }

  /// Creates a performance-optimized recursive schema
  RecursiveSchema<T> optimized() {
    return withSettings(
      maxDepth: 10000,
      enableCircularDetection: false,
      enableMemoization: true,
    );
  }

  /// Validates input and returns detailed recursion statistics
  ValidationResultWithStats<T> validateWithStats(dynamic input,
      [List<String> path = const []]) {
    final context = ValidationContext();
    final result = _validateWithContext(input, path, context);

    return ValidationResultWithStats<T>(
      result: result,
      maxDepthReached: context.maxDepthReached,
      circularReferencesDetected: context.circularReferencesDetected,
      totalValidations: context.totalValidations,
    );
  }

  /// Validates input asynchronously and returns detailed recursion statistics
  Future<ValidationResultWithStats<T>> validateWithStatsAsync(dynamic input,
      [List<String> path = const []]) async {
    final context = ValidationContext();
    final result = await _validateAsyncWithContext(input, path, context);

    return ValidationResultWithStats<T>(
      result: result,
      maxDepthReached: context.maxDepthReached,
      circularReferencesDetected: context.circularReferencesDetected,
      totalValidations: context.totalValidations,
    );
  }

  /// Gets statistics about the recursive schema
  Map<String, dynamic> get statistics => {
        'maxDepth': _maxDepth,
        'circularDetectionEnabled': _enableCircularDetection,
        'memoizationEnabled': _enableMemoization,
        'cacheSize': cacheSize,
        'schemaType': _schema.runtimeType.toString(),
      };

  @override
  String get schemaType => 'RecursiveSchema';

  @override
  String toString() {
    final desc = description != null ? ' ($description)' : '';
    final settings =
        'depth:$_maxDepth,circular:$_enableCircularDetection,memo:$_enableMemoization';
    return 'RecursiveSchema<$T>($settings)$desc';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecursiveSchema<T> &&
        other._maxDepth == _maxDepth &&
        other._enableCircularDetection == _enableCircularDetection &&
        other._enableMemoization == _enableMemoization &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(
        runtimeType,
        _maxDepth,
        _enableCircularDetection,
        _enableMemoization,
        description,
      );
}

/// Context for tracking validation state during recursion
class ValidationContext {
  final Set<String> visitedObjects = <String>{};
  int depth = 0;
  int maxDepthReached = 0;
  int circularReferencesDetected = 0;
  int totalValidations = 0;

  ValidationContext incrementDepth() {
    // Create new context but share the same state
    final newContext = ValidationContext();
    newContext.visitedObjects.addAll(visitedObjects);
    newContext.depth = depth + 1;
    newContext.maxDepthReached = maxDepthReached;
    newContext.circularReferencesDetected = circularReferencesDetected;
    newContext.totalValidations = totalValidations;
    return newContext;
  }
}

/// Validation result with additional recursion statistics
class ValidationResultWithStats<T> {
  final ValidationResult<T> result;
  final int maxDepthReached;
  final int circularReferencesDetected;
  final int totalValidations;

  const ValidationResultWithStats({
    required this.result,
    required this.maxDepthReached,
    required this.circularReferencesDetected,
    required this.totalValidations,
  });

  /// Whether validation was successful
  bool get isSuccess => result.isSuccess;

  /// Whether validation failed
  bool get isFailure => result.isFailure;

  /// The validated data (if successful)
  T? get data => result.data;

  /// The validation errors (if failed)
  ValidationErrorCollection? get errors => result.errors;

  /// Gets detailed statistics
  Map<String, dynamic> get statistics => {
        'maxDepthReached': maxDepthReached,
        'circularReferencesDetected': circularReferencesDetected,
        'totalValidations': totalValidations,
        'success': isSuccess,
      };

  @override
  String toString() {
    return 'ValidationResultWithStats(success: $isSuccess, depth: $maxDepthReached, circular: $circularReferencesDetected, validations: $totalValidations)';
  }
}

/// Factory methods for creating recursive schemas
extension RecursiveExtension on Schema {
  /// Creates a recursive schema with enhanced circular reference handling
  static RecursiveSchema<T> recursive<T>(
    Schema<T> Function() schemaFactory, {
    int maxDepth = 1000,
    bool enableCircularDetection = true,
    bool enableMemoization = true,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return RecursiveSchema<T>(
      schemaFactory,
      maxDepth: maxDepth,
      enableCircularDetection: enableCircularDetection,
      enableMemoization: enableMemoization,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a safe recursive schema with conservative settings
  static RecursiveSchema<T> recursiveSafe<T>(
    Schema<T> Function() schemaFactory, {
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return RecursiveSchema<T>(
      schemaFactory,
      maxDepth: 100,
      enableCircularDetection: true,
      enableMemoization: true,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a performance-optimized recursive schema
  static RecursiveSchema<T> recursiveOptimized<T>(
    Schema<T> Function() schemaFactory, {
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return RecursiveSchema<T>(
      schemaFactory,
      maxDepth: 10000,
      enableCircularDetection: false,
      enableMemoization: true,
      description: description,
      metadata: metadata,
    );
  }
}
