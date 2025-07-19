import 'error.dart';

/// Type definition for custom error message formatters
typedef ErrorMessageFormatter = String Function(ValidationError error);

/// Type definition for custom error context formatters
typedef ErrorContextFormatter = Map<String, dynamic> Function(
    ValidationError error);

/// Configuration for error formatting and customization
class ErrorFormatConfig {
  /// Custom error messages mapped by error code
  final Map<String, String> customMessages;

  /// Custom error message formatters mapped by error code
  final Map<String, ErrorMessageFormatter> customFormatters;

  /// Custom context formatters mapped by error code
  final Map<String, ErrorContextFormatter> contextFormatters;

  /// Default message formatter for unknown error codes
  final ErrorMessageFormatter? defaultFormatter;

  /// Whether to include error codes in formatted messages
  final bool includeErrorCodes;

  /// Whether to include error paths in formatted messages
  final bool includeErrorPaths;

  /// Whether to include received values in formatted messages
  final bool includeReceivedValues;

  /// Whether to include expected values in formatted messages
  final bool includeExpectedValues;

  /// Whether to include context information in formatted messages
  final bool includeContext;

  /// Custom path separator for nested errors
  final String pathSeparator;

  /// Maximum depth for nested error display
  final int maxDepth;

  /// Whether to group errors by path
  final bool groupByPath;

  /// Whether to sort errors by path
  final bool sortByPath;

  /// Custom error grouping function
  final String Function(ValidationError error)? groupingFunction;

  const ErrorFormatConfig({
    this.customMessages = const {},
    this.customFormatters = const {},
    this.contextFormatters = const {},
    this.defaultFormatter,
    this.includeErrorCodes = true,
    this.includeErrorPaths = true,
    this.includeReceivedValues = true,
    this.includeExpectedValues = true,
    this.includeContext = false,
    this.pathSeparator = '.',
    this.maxDepth = 10,
    this.groupByPath = false,
    this.sortByPath = false,
    this.groupingFunction,
  });

  /// Creates a copy of this config with updated values
  ErrorFormatConfig copyWith({
    Map<String, String>? customMessages,
    Map<String, ErrorMessageFormatter>? customFormatters,
    Map<String, ErrorContextFormatter>? contextFormatters,
    ErrorMessageFormatter? defaultFormatter,
    bool? includeErrorCodes,
    bool? includeErrorPaths,
    bool? includeReceivedValues,
    bool? includeExpectedValues,
    bool? includeContext,
    String? pathSeparator,
    int? maxDepth,
    bool? groupByPath,
    bool? sortByPath,
    String Function(ValidationError error)? groupingFunction,
  }) {
    return ErrorFormatConfig(
      customMessages: customMessages ?? this.customMessages,
      customFormatters: customFormatters ?? this.customFormatters,
      contextFormatters: contextFormatters ?? this.contextFormatters,
      defaultFormatter: defaultFormatter ?? this.defaultFormatter,
      includeErrorCodes: includeErrorCodes ?? this.includeErrorCodes,
      includeErrorPaths: includeErrorPaths ?? this.includeErrorPaths,
      includeReceivedValues:
          includeReceivedValues ?? this.includeReceivedValues,
      includeExpectedValues:
          includeExpectedValues ?? this.includeExpectedValues,
      includeContext: includeContext ?? this.includeContext,
      pathSeparator: pathSeparator ?? this.pathSeparator,
      maxDepth: maxDepth ?? this.maxDepth,
      groupByPath: groupByPath ?? this.groupByPath,
      sortByPath: sortByPath ?? this.sortByPath,
      groupingFunction: groupingFunction ?? this.groupingFunction,
    );
  }

  /// Merges this config with another config
  ErrorFormatConfig merge(ErrorFormatConfig other) {
    return ErrorFormatConfig(
      customMessages: {...customMessages, ...other.customMessages},
      customFormatters: {...customFormatters, ...other.customFormatters},
      contextFormatters: {...contextFormatters, ...other.contextFormatters},
      defaultFormatter: other.defaultFormatter ?? defaultFormatter,
      includeErrorCodes: other.includeErrorCodes,
      includeErrorPaths: other.includeErrorPaths,
      includeReceivedValues: other.includeReceivedValues,
      includeExpectedValues: other.includeExpectedValues,
      includeContext: other.includeContext,
      pathSeparator: other.pathSeparator,
      maxDepth: other.maxDepth,
      groupByPath: other.groupByPath,
      sortByPath: other.sortByPath,
      groupingFunction: other.groupingFunction ?? groupingFunction,
    );
  }
}

/// Global error formatting and customization system
class ErrorFormatter {
  static ErrorFormatConfig _globalConfig = const ErrorFormatConfig();

  /// Gets the current global error format configuration
  static ErrorFormatConfig get globalConfig => _globalConfig;

  /// Sets the global error format configuration
  static void setGlobalConfig(ErrorFormatConfig config) {
    _globalConfig = config;
  }

  /// Resets the global configuration to default
  static void resetGlobalConfig() {
    _globalConfig = const ErrorFormatConfig();
  }

  /// Formats a single validation error using the global configuration
  static String formatError(ValidationError error,
      [ErrorFormatConfig? config]) {
    final effectiveConfig = config ?? _globalConfig;
    return _formatSingleError(error, effectiveConfig);
  }

  /// Formats a collection of validation errors using the global configuration
  static String formatErrors(ValidationErrorCollection errors,
      [ErrorFormatConfig? config]) {
    final effectiveConfig = config ?? _globalConfig;
    return _formatErrorCollection(errors, effectiveConfig);
  }

  /// Formats errors as JSON using the global configuration
  static Map<String, dynamic> formatErrorsAsJson(
      ValidationErrorCollection errors,
      [ErrorFormatConfig? config]) {
    final effectiveConfig = config ?? _globalConfig;
    return _formatErrorsAsJson(errors, effectiveConfig);
  }

  /// Formats errors as a structured object for programmatic use
  static Map<String, List<Map<String, dynamic>>> formatErrorsAsStructured(
      ValidationErrorCollection errors,
      [ErrorFormatConfig? config]) {
    final effectiveConfig = config ?? _globalConfig;
    return _formatErrorsAsStructured(errors, effectiveConfig);
  }

  /// Formats errors for human-readable display
  static String formatErrorsForHumans(ValidationErrorCollection errors,
      [ErrorFormatConfig? config]) {
    final effectiveConfig = config ?? _globalConfig;
    return _formatErrorsForHumans(errors, effectiveConfig);
  }

  /// Formats errors in a compact format
  static String formatErrorsCompact(ValidationErrorCollection errors,
      [ErrorFormatConfig? config]) {
    final effectiveConfig = config ?? _globalConfig;
    return _formatErrorsCompact(errors, effectiveConfig);
  }

  /// Formats errors grouped by path
  static Map<String, List<String>> formatErrorsGroupedByPath(
      ValidationErrorCollection errors,
      [ErrorFormatConfig? config]) {
    final effectiveConfig = config ?? _globalConfig;
    return _formatErrorsGroupedByPath(errors, effectiveConfig);
  }

  /// Formats errors grouped by error code
  static Map<String, List<String>> formatErrorsGroupedByCode(
      ValidationErrorCollection errors,
      [ErrorFormatConfig? config]) {
    final effectiveConfig = config ?? _globalConfig;
    return _formatErrorsGroupedByCode(errors, effectiveConfig);
  }

  /// Internal method to format a single error
  static String _formatSingleError(
      ValidationError error, ErrorFormatConfig config) {
    // Check for custom formatter first
    if (error.code != null && config.customFormatters.containsKey(error.code)) {
      return config.customFormatters[error.code]!(error);
    }

    // Check for custom message
    String message = error.message;
    if (error.code != null && config.customMessages.containsKey(error.code)) {
      message = config.customMessages[error.code]!;
    }

    // Use default formatter if available
    if (config.defaultFormatter != null) {
      return config.defaultFormatter!(error);
    }

    // Build formatted message
    final parts = <String>[];

    // Add path if enabled
    if (config.includeErrorPaths && error.path.isNotEmpty) {
      final pathStr = error.path.join(config.pathSeparator);
      parts.add('[$pathStr]');
    }

    // Add main message
    parts.add(message);

    // Add received value if enabled
    if (config.includeReceivedValues) {
      parts.add('(received: ${_formatValue(error.received)})');
    }

    // Add expected value if enabled
    if (config.includeExpectedValues && error.expected.isNotEmpty) {
      parts.add('(expected: ${error.expected})');
    }

    // Add error code if enabled
    if (config.includeErrorCodes && error.code != null) {
      parts.add('[${error.code}]');
    }

    // Add context if enabled
    if (config.includeContext &&
        error.context != null &&
        error.context!.isNotEmpty) {
      final contextStr = error.context!.entries
          .map((e) => '${e.key}: ${_formatValue(e.value)}')
          .join(', ');
      parts.add('(context: {$contextStr})');
    }

    return parts.join(' ');
  }

  /// Internal method to format error collection
  static String _formatErrorCollection(
      ValidationErrorCollection errors, ErrorFormatConfig config) {
    if (errors.isEmpty) return 'No validation errors';

    var errorList = errors.errors;

    // Sort by path if enabled
    if (config.sortByPath) {
      errorList = List.from(errorList)
        ..sort((a, b) => a.fullPath.compareTo(b.fullPath));
    }

    // Group by path if enabled
    if (config.groupByPath) {
      return _formatErrorsGroupedByPath(errors, config)
          .entries
          .map((entry) => '${entry.key}: ${entry.value.join(', ')}')
          .join('\n');
    }

    // Format each error
    return errorList
        .map((error) => _formatSingleError(error, config))
        .join('\n');
  }

  /// Internal method to format errors as JSON
  static Map<String, dynamic> _formatErrorsAsJson(
      ValidationErrorCollection errors, ErrorFormatConfig config) {
    final formattedErrors = errors.errors.map((error) {
      final formatted = <String, dynamic>{
        'message': error.message,
        'path': error.path,
        'received': _serializeValue(error.received),
        'expected': error.expected,
      };

      if (error.code != null) {
        formatted['code'] = error.code;
      }

      if (error.context != null && error.context!.isNotEmpty) {
        formatted['context'] =
            error.context!.map((k, v) => MapEntry(k, _serializeValue(v)));
      }

      return formatted;
    }).toList();

    return {
      'errors': formattedErrors,
      'count': errors.length,
      'formatted': _formatErrorCollection(errors, config),
    };
  }

  /// Internal method to format errors as structured object
  static Map<String, List<Map<String, dynamic>>> _formatErrorsAsStructured(
      ValidationErrorCollection errors, ErrorFormatConfig config) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final error in errors.errors) {
      final key = config.groupingFunction?.call(error) ?? error.fullPath;
      grouped.putIfAbsent(key, () => []).add({
        'message': error.message,
        'path': error.path,
        'received': _serializeValue(error.received),
        'expected': error.expected,
        'code': error.code,
        'context': error.context,
      });
    }

    return grouped;
  }

  /// Internal method to format errors for human-readable display
  static String _formatErrorsForHumans(
      ValidationErrorCollection errors, ErrorFormatConfig config) {
    if (errors.isEmpty) return 'All validations passed successfully!';

    final humanConfig = config.copyWith(
      includeErrorCodes: false,
      includeReceivedValues: false,
      includeExpectedValues: false,
      includeContext: false,
      pathSeparator: ' → ',
    );

    return _formatErrorCollection(errors, humanConfig);
  }

  /// Internal method to format errors in compact format
  static String _formatErrorsCompact(
      ValidationErrorCollection errors, ErrorFormatConfig config) {
    if (errors.isEmpty) return 'Valid';

    final compactConfig = config.copyWith(
      includeErrorPaths: false,
      includeReceivedValues: false,
      includeExpectedValues: false,
      includeContext: false,
      includeErrorCodes: false,
    );

    final messages =
        errors.errors.map((e) => _formatSingleError(e, compactConfig)).toList();
    return messages.join('; ');
  }

  /// Internal method to format errors grouped by path
  static Map<String, List<String>> _formatErrorsGroupedByPath(
      ValidationErrorCollection errors, ErrorFormatConfig config) {
    final grouped = <String, List<String>>{};

    for (final error in errors.errors) {
      final path =
          error.path.isEmpty ? 'root' : error.path.join(config.pathSeparator);
      grouped.putIfAbsent(path, () => []).add(error.message);
    }

    return grouped;
  }

  /// Internal method to format errors grouped by error code
  static Map<String, List<String>> _formatErrorsGroupedByCode(
      ValidationErrorCollection errors, ErrorFormatConfig config) {
    final grouped = <String, List<String>>{};

    for (final error in errors.errors) {
      final code = error.code ?? 'unknown';
      grouped
          .putIfAbsent(code, () => [])
          .add(_formatSingleError(error, config));
    }

    return grouped;
  }

  /// Internal method to format a value for display
  static String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    if (value is num) return value.toString();
    if (value is bool) return value.toString();
    if (value is List) return '[${value.length} items]';
    if (value is Map) return '{${value.length} entries}';
    return value.toString();
  }

  /// Internal method to serialize a value for JSON output
  static dynamic _serializeValue(dynamic value) {
    if (value == null) return null;
    if (value is String || value is num || value is bool) return value;
    if (value is List) return value.map(_serializeValue).toList();
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _serializeValue(v)));
    }
    return value.toString();
  }
}

/// Predefined error format configurations
class ErrorFormatPresets {
  /// Minimal configuration - only shows error messages
  static const ErrorFormatConfig minimal = ErrorFormatConfig(
    includeErrorCodes: false,
    includeErrorPaths: false,
    includeReceivedValues: false,
    includeExpectedValues: false,
    includeContext: false,
  );

  /// Detailed configuration - shows all available information
  static const ErrorFormatConfig detailed = ErrorFormatConfig(
    includeErrorCodes: true,
    includeErrorPaths: true,
    includeReceivedValues: true,
    includeExpectedValues: true,
    includeContext: true,
  );

  /// Human-friendly configuration - optimized for end users
  static const ErrorFormatConfig humanFriendly = ErrorFormatConfig(
    includeErrorCodes: false,
    includeErrorPaths: true,
    includeReceivedValues: false,
    includeExpectedValues: false,
    includeContext: false,
    pathSeparator: ' → ',
  );

  /// Developer configuration - optimized for debugging
  static const ErrorFormatConfig developer = ErrorFormatConfig(
    includeErrorCodes: true,
    includeErrorPaths: true,
    includeReceivedValues: true,
    includeExpectedValues: true,
    includeContext: true,
    groupByPath: true,
    sortByPath: true,
  );

  /// Compact configuration - shows minimal information in one line
  static const ErrorFormatConfig compact = ErrorFormatConfig(
    includeErrorCodes: false,
    includeErrorPaths: false,
    includeReceivedValues: false,
    includeExpectedValues: false,
    includeContext: false,
  );

  /// JSON configuration - optimized for API responses
  static const ErrorFormatConfig json = ErrorFormatConfig(
    includeErrorCodes: true,
    includeErrorPaths: true,
    includeReceivedValues: true,
    includeExpectedValues: true,
    includeContext: true,
    groupByPath: true,
  );
}

/// Global error message customization
class ErrorMessages {
  static final Map<String, String> _globalMessages = <String, String>{};

  /// Sets a global custom message for an error code
  static void setMessage(String errorCode, String message) {
    _globalMessages[errorCode] = message;
  }

  /// Sets multiple global custom messages
  static void setMessages(Map<String, String> messages) {
    _globalMessages.addAll(messages);
  }

  /// Gets a global custom message for an error code
  static String? getMessage(String errorCode) {
    return _globalMessages[errorCode];
  }

  /// Removes a global custom message
  static void removeMessage(String errorCode) {
    _globalMessages.remove(errorCode);
  }

  /// Clears all global custom messages
  static void clearMessages() {
    _globalMessages.clear();
  }

  /// Gets all global custom messages
  static Map<String, String> getAllMessages() {
    return Map.unmodifiable(_globalMessages);
  }

  /// Checks if a custom message exists for an error code
  static bool hasMessage(String errorCode) {
    return _globalMessages.containsKey(errorCode);
  }
}

/// Extension methods for ValidationError to support custom formatting
extension ValidationErrorFormatting on ValidationError {
  /// Formats this error using the global configuration
  String format([ErrorFormatConfig? config]) {
    return ErrorFormatter.formatError(this, config);
  }

  /// Formats this error for human-readable display
  String formatForHumans([ErrorFormatConfig? config]) {
    final humanConfig = (config ?? ErrorFormatter.globalConfig).copyWith(
      includeErrorCodes: false,
      includeReceivedValues: false,
      includeExpectedValues: false,
      includeContext: false,
      pathSeparator: ' → ',
    );
    return ErrorFormatter.formatError(this, humanConfig);
  }

  /// Formats this error in compact format
  String formatCompact([ErrorFormatConfig? config]) {
    final compactConfig = (config ?? ErrorFormatter.globalConfig).copyWith(
      includeErrorPaths: false,
      includeReceivedValues: false,
      includeExpectedValues: false,
      includeContext: false,
      includeErrorCodes: false,
    );
    return ErrorFormatter.formatError(this, compactConfig);
  }

  /// Converts this error to JSON format
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'path': path,
      'received': ErrorFormatter._serializeValue(received),
      'expected': expected,
      'code': code,
      'context': context,
    };
  }
}

/// Extension methods for ValidationErrorCollection to support custom formatting
extension ValidationErrorCollectionFormatting on ValidationErrorCollection {
  /// Formats this error collection using the global configuration
  String format([ErrorFormatConfig? config]) {
    return ErrorFormatter.formatErrors(this, config);
  }

  /// Formats this error collection for human-readable display
  String formatForHumans([ErrorFormatConfig? config]) {
    return ErrorFormatter.formatErrorsForHumans(this, config);
  }

  /// Formats this error collection in compact format
  String formatCompact([ErrorFormatConfig? config]) {
    return ErrorFormatter.formatErrorsCompact(this, config);
  }

  /// Converts this error collection to JSON format
  Map<String, dynamic> toJsonFormat([ErrorFormatConfig? config]) {
    return ErrorFormatter.formatErrorsAsJson(this, config);
  }

  /// Converts this error collection to structured format
  Map<String, List<Map<String, dynamic>>> toStructured(
      [ErrorFormatConfig? config]) {
    return ErrorFormatter.formatErrorsAsStructured(this, config);
  }

  /// Groups errors by path
  Map<String, List<String>> groupByPath([ErrorFormatConfig? config]) {
    return ErrorFormatter.formatErrorsGroupedByPath(this, config);
  }

  /// Groups errors by error code
  Map<String, List<String>> groupByCode([ErrorFormatConfig? config]) {
    return ErrorFormatter.formatErrorsGroupedByCode(this, config);
  }
}
