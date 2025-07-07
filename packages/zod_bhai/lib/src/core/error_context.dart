import 'error.dart';
import 'error_codes.dart';

/// Enhanced error context tracking and path management
class ErrorContext {
  /// The current path in the validation hierarchy
  final List<String> path;

  /// The schema type being validated
  final String? schemaType;

  /// The field name being validated (if applicable)
  final String? fieldName;

  /// The index in an array/list (if applicable)
  final int? index;

  /// The key in a map/object (if applicable)
  final String? key;

  /// The parent context (for nested validations)
  final ErrorContext? parent;

  /// Additional metadata about the validation context
  final Map<String, dynamic> metadata;

  /// The depth of nesting in the validation hierarchy
  final int depth;

  /// Whether this context represents an async validation
  final bool isAsync;

  /// The timestamp when this context was created
  final DateTime timestamp;

  /// The source of the validation (e.g., 'user_input', 'api_request', 'database')
  final String? source;

  /// The operation being performed (e.g., 'create', 'update', 'validate')
  final String? operation;

  ErrorContext({
    required this.path,
    this.schemaType,
    this.fieldName,
    this.index,
    this.key,
    this.parent,
    this.metadata = const {},
    this.depth = 0,
    this.isAsync = false,
    DateTime? timestamp,
    this.source,
    this.operation,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Creates a root error context
  factory ErrorContext.root({
    String? source,
    String? operation,
    Map<String, dynamic>? metadata,
  }) {
    return ErrorContext(
      path: const [],
      metadata: metadata ?? const {},
      source: source,
      operation: operation,
    );
  }

  /// Creates a child context for a field
  ErrorContext forField(
    String fieldName, {
    String? schemaType,
    Map<String, dynamic>? metadata,
  }) {
    return ErrorContext(
      path: [...path, fieldName],
      schemaType: schemaType,
      fieldName: fieldName,
      parent: this,
      metadata: {...this.metadata, ...?metadata},
      depth: depth + 1,
      isAsync: isAsync,
      source: source,
      operation: operation,
    );
  }

  /// Creates a child context for an array index
  ErrorContext forIndex(
    int index, {
    String? schemaType,
    Map<String, dynamic>? metadata,
  }) {
    return ErrorContext(
      path: [...path, index.toString()],
      schemaType: schemaType,
      index: index,
      parent: this,
      metadata: {...this.metadata, ...?metadata},
      depth: depth + 1,
      isAsync: isAsync,
      source: source,
      operation: operation,
    );
  }

  /// Creates a child context for a map key
  ErrorContext forKey(
    String key, {
    String? schemaType,
    Map<String, dynamic>? metadata,
  }) {
    return ErrorContext(
      path: [...path, key],
      schemaType: schemaType,
      key: key,
      parent: this,
      metadata: {...this.metadata, ...?metadata},
      depth: depth + 1,
      isAsync: isAsync,
      source: source,
      operation: operation,
    );
  }

  /// Creates a child context for nested validation
  ErrorContext forNested({
    String? schemaType,
    Map<String, dynamic>? metadata,
  }) {
    return ErrorContext(
      path: path,
      schemaType: schemaType,
      parent: this,
      metadata: {...this.metadata, ...?metadata},
      depth: depth + 1,
      isAsync: isAsync,
      source: source,
      operation: operation,
    );
  }

  /// Creates a context marked as async
  ErrorContext asAsync() {
    return ErrorContext(
      path: path,
      schemaType: schemaType,
      fieldName: fieldName,
      index: index,
      key: key,
      parent: parent,
      metadata: metadata,
      depth: depth,
      isAsync: true,
      source: source,
      operation: operation,
    );
  }

  /// Creates a context with additional metadata
  ErrorContext withMetadata(Map<String, dynamic> additionalMetadata) {
    return ErrorContext(
      path: path,
      schemaType: schemaType,
      fieldName: fieldName,
      index: index,
      key: key,
      parent: parent,
      metadata: {...metadata, ...additionalMetadata},
      depth: depth,
      isAsync: isAsync,
      source: source,
      operation: operation,
    );
  }

  /// Gets the full path as a string
  String get fullPath => path.join('.');

  /// Gets the path segments as a breadcrumb trail
  List<String> get breadcrumbs {
    if (parent == null) return path;
    return [...parent!.breadcrumbs, ...path];
  }

  /// Gets all ancestors in the context hierarchy
  List<ErrorContext> get ancestors {
    if (parent == null) return [];
    return [...parent!.ancestors, parent!];
  }

  /// Gets the root context
  ErrorContext get root {
    if (parent == null) return this;
    return parent!.root;
  }

  /// Checks if this context is at the root level
  bool get isRoot => parent == null;

  /// Checks if this context represents an array element
  bool get isArrayElement => index != null;

  /// Checks if this context represents an object field
  bool get isObjectField => fieldName != null;

  /// Checks if this context represents a map key
  bool get isMapKey => key != null;

  /// Gets the current validation target type
  String get targetType {
    if (isArrayElement) return 'array element';
    if (isObjectField) return 'object field';
    if (isMapKey) return 'map key';
    return 'value';
  }

  /// Creates a validation error with this context
  ValidationError createError({
    required String message,
    required dynamic received,
    String? expected,
    String? code,
    Map<String, dynamic>? additionalContext,
  }) {
    return ValidationError(
      message: message,
      path: path,
      received: received,
      expected: expected ?? 'valid value',
      code: code,
      context: {
        ...metadata,
        ...?additionalContext,
        'schema_type': schemaType,
        'field_name': fieldName,
        'index': index,
        'key': key,
        'depth': depth,
        'is_async': isAsync,
        'timestamp': timestamp.toIso8601String(),
        'source': source,
        'operation': operation,
        'target_type': targetType,
      },
    );
  }

  /// Creates a type mismatch error with this context
  ValidationError createTypeMismatchError({
    required dynamic received,
    required String expected,
    String? code,
    Map<String, dynamic>? additionalContext,
  }) {
    return ValidationError.typeMismatch(
      path: path,
      received: received,
      expected: expected,
      code: code,
    ).withContext({
      ...metadata,
      ...?additionalContext,
      'schema_type': schemaType,
      'field_name': fieldName,
      'index': index,
      'key': key,
      'depth': depth,
      'is_async': isAsync,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
      'operation': operation,
      'target_type': targetType,
    });
  }

  /// Creates a constraint violation error with this context
  ValidationError createConstraintViolationError({
    required dynamic received,
    required String constraint,
    String? code,
    Map<String, dynamic>? additionalContext,
  }) {
    return ValidationError.constraintViolation(
      path: path,
      received: received,
      constraint: constraint,
      code: code,
    ).withContext({
      ...metadata,
      ...?additionalContext,
      'schema_type': schemaType,
      'field_name': fieldName,
      'index': index,
      'key': key,
      'depth': depth,
      'is_async': isAsync,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
      'operation': operation,
      'target_type': targetType,
    });
  }

  /// Creates an error using a ValidationErrorCode
  ValidationError createErrorFromCode({
    required ValidationErrorCode errorCode,
    required dynamic received,
    String? expected,
    String? message,
    Map<String, dynamic>? additionalContext,
  }) {
    return errorCode
        .createError(
      path: path,
      received: received,
      expected: expected,
      message: message,
    )
        .withContext({
      ...metadata,
      ...?additionalContext,
      'schema_type': schemaType,
      'field_name': fieldName,
      'index': index,
      'key': key,
      'depth': depth,
      'is_async': isAsync,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
      'operation': operation,
      'target_type': targetType,
    });
  }

  /// Gets a human-readable description of this context
  String get description {
    final parts = <String>[];

    if (source != null) {
      parts.add('Source: $source');
    }

    if (operation != null) {
      parts.add('Operation: $operation');
    }

    if (path.isNotEmpty) {
      parts.add('Path: $fullPath');
    }

    if (schemaType != null) {
      parts.add('Schema: $schemaType');
    }

    if (depth > 0) {
      parts.add('Depth: $depth');
    }

    if (isAsync) {
      parts.add('Async validation');
    }

    return parts.join(', ');
  }

  /// Converts this context to a JSON-serializable map
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'schema_type': schemaType,
      'field_name': fieldName,
      'index': index,
      'key': key,
      'metadata': metadata,
      'depth': depth,
      'is_async': isAsync,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
      'operation': operation,
      'target_type': targetType,
      'full_path': fullPath,
      'breadcrumbs': breadcrumbs,
      'description': description,
    };
  }

  @override
  String toString() => description;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ErrorContext &&
        other.path.length == path.length &&
        other.schemaType == schemaType &&
        other.fieldName == fieldName &&
        other.index == index &&
        other.key == key &&
        other.depth == depth &&
        other.isAsync == isAsync &&
        other.source == source &&
        other.operation == operation;
  }

  @override
  int get hashCode => Object.hash(
        path.length,
        schemaType,
        fieldName,
        index,
        key,
        depth,
        isAsync,
        source,
        operation,
      );
}

/// Utility class for building error contexts
class ErrorContextBuilder {
  ErrorContext _context;

  ErrorContextBuilder([ErrorContext? initialContext])
      : _context = initialContext ?? ErrorContext.root();

  /// Sets the source of the validation
  ErrorContextBuilder source(String source) {
    _context = ErrorContext(
      path: _context.path,
      schemaType: _context.schemaType,
      fieldName: _context.fieldName,
      index: _context.index,
      key: _context.key,
      parent: _context.parent,
      metadata: _context.metadata,
      depth: _context.depth,
      isAsync: _context.isAsync,
      source: source,
      operation: _context.operation,
    );
    return this;
  }

  /// Sets the operation being performed
  ErrorContextBuilder operation(String operation) {
    _context = ErrorContext(
      path: _context.path,
      schemaType: _context.schemaType,
      fieldName: _context.fieldName,
      index: _context.index,
      key: _context.key,
      parent: _context.parent,
      metadata: _context.metadata,
      depth: _context.depth,
      isAsync: _context.isAsync,
      source: _context.source,
      operation: operation,
    );
    return this;
  }

  /// Adds metadata to the context
  ErrorContextBuilder metadata(Map<String, dynamic> metadata) {
    _context = _context.withMetadata(metadata);
    return this;
  }

  /// Marks the context as async
  ErrorContextBuilder async() {
    _context = _context.asAsync();
    return this;
  }

  /// Enters a field context
  ErrorContextBuilder field(String fieldName, {String? schemaType}) {
    _context = _context.forField(fieldName, schemaType: schemaType);
    return this;
  }

  /// Enters an index context
  ErrorContextBuilder index(int index, {String? schemaType}) {
    _context = _context.forIndex(index, schemaType: schemaType);
    return this;
  }

  /// Enters a key context
  ErrorContextBuilder key(String key, {String? schemaType}) {
    _context = _context.forKey(key, schemaType: schemaType);
    return this;
  }

  /// Enters a nested context
  ErrorContextBuilder nested({String? schemaType}) {
    _context = _context.forNested(schemaType: schemaType);
    return this;
  }

  /// Builds the final context
  ErrorContext build() => _context;
}

/// Global error context management
class ErrorContextManager {
  static ErrorContext? _currentContext;

  /// Gets the current global error context
  static ErrorContext? get currentContext => _currentContext;

  /// Sets the current global error context
  static void setCurrentContext(ErrorContext? context) {
    _currentContext = context;
  }

  /// Clears the current global error context
  static void clearCurrentContext() {
    _currentContext = null;
  }

  /// Executes a function with a specific error context
  static T withContext<T>(ErrorContext context, T Function() fn) {
    final previousContext = _currentContext;
    _currentContext = context;
    try {
      return fn();
    } finally {
      _currentContext = previousContext;
    }
  }

  /// Executes a function with a new error context built from the current one
  static T withNewContext<T>(
    ErrorContext Function(ErrorContext? current) builder,
    T Function() fn,
  ) {
    final newContext = builder(_currentContext);
    return withContext(newContext, fn);
  }

  /// Creates a new error context builder from the current context
  static ErrorContextBuilder builder([ErrorContext? baseContext]) {
    return ErrorContextBuilder(baseContext ?? _currentContext);
  }
}

/// Extension methods for enhanced error context support
extension ErrorContextExtensions on ValidationError {
  /// Gets the error context from this error
  ErrorContext? get errorContext {
    if (context == null) return null;

    return ErrorContext(
      path: path,
      schemaType: context!['schema_type'] as String?,
      fieldName: context!['field_name'] as String?,
      index: context!['index'] as int?,
      key: context!['key'] as String?,
      metadata: Map<String, dynamic>.from(context!),
      depth: context!['depth'] as int? ?? 0,
      isAsync: context!['is_async'] as bool? ?? false,
      source: context!['source'] as String?,
      operation: context!['operation'] as String?,
    );
  }

  /// Checks if this error has context information
  bool get hasContext => context != null && context!.isNotEmpty;

  /// Gets the validation source from context
  String? get validationSource => context?['source'] as String?;

  /// Gets the validation operation from context
  String? get validationOperation => context?['operation'] as String?;

  /// Gets the schema type from context
  String? get schemaType => context?['schema_type'] as String?;

  /// Gets the validation depth from context
  int get validationDepth => context?['depth'] as int? ?? 0;

  /// Checks if this error is from async validation
  bool get isAsyncValidation => context?['is_async'] as bool? ?? false;

  /// Gets the target type from context
  String? get targetType => context?['target_type'] as String?;
}
