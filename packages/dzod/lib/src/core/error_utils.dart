import 'error.dart';
import 'error_codes.dart';
import 'error_context.dart';

/// Type definition for error filter functions
typedef ErrorFilter = bool Function(ValidationError error);

/// Type definition for error grouping functions
typedef ErrorGroupingFunction<T> = T Function(ValidationError error);

/// Type definition for error sorting functions
typedef ErrorComparator = int Function(ValidationError a, ValidationError b);

/// Comprehensive error filtering and grouping utilities
class ErrorUtils {
  const ErrorUtils._();

  // ==================== FILTERING UTILITIES ====================

  /// Filters errors by error code
  static List<ValidationError> filterByCode(
    List<ValidationError> errors,
    String code,
  ) {
    return errors.where((error) => error.code == code).toList();
  }

  /// Filters errors by multiple error codes
  static List<ValidationError> filterByCodes(
    List<ValidationError> errors,
    List<String> codes,
  ) {
    final codeSet = codes.toSet();
    return errors
        .where((error) => error.code != null && codeSet.contains(error.code))
        .toList();
  }

  /// Filters errors by path prefix
  static List<ValidationError> filterByPathPrefix(
    List<ValidationError> errors,
    List<String> pathPrefix,
  ) {
    return errors.where((error) {
      if (error.path.length < pathPrefix.length) return false;
      for (int i = 0; i < pathPrefix.length; i++) {
        if (error.path[i] != pathPrefix[i]) return false;
      }
      return true;
    }).toList();
  }

  /// Filters errors by exact path
  static List<ValidationError> filterByExactPath(
    List<ValidationError> errors,
    List<String> path,
  ) {
    return errors.where((error) {
      if (error.path.length != path.length) return false;
      for (int i = 0; i < path.length; i++) {
        if (error.path[i] != path[i]) return false;
      }
      return true;
    }).toList();
  }

  /// Filters errors by path depth
  static List<ValidationError> filterByDepth(
    List<ValidationError> errors,
    int depth,
  ) {
    return errors.where((error) => error.path.length == depth).toList();
  }

  /// Filters errors by minimum depth
  static List<ValidationError> filterByMinDepth(
    List<ValidationError> errors,
    int minDepth,
  ) {
    return errors.where((error) => error.path.length >= minDepth).toList();
  }

  /// Filters errors by maximum depth
  static List<ValidationError> filterByMaxDepth(
    List<ValidationError> errors,
    int maxDepth,
  ) {
    return errors.where((error) => error.path.length <= maxDepth).toList();
  }

  /// Filters errors by schema type
  static List<ValidationError> filterBySchemaType(
    List<ValidationError> errors,
    String schemaType,
  ) {
    return errors.where((error) => error.schemaType == schemaType).toList();
  }

  /// Filters errors by validation source
  static List<ValidationError> filterBySource(
    List<ValidationError> errors,
    String source,
  ) {
    return errors.where((error) => error.validationSource == source).toList();
  }

  /// Filters errors by validation operation
  static List<ValidationError> filterByOperation(
    List<ValidationError> errors,
    String operation,
  ) {
    return errors
        .where((error) => error.validationOperation == operation)
        .toList();
  }

  /// Filters async validation errors
  static List<ValidationError> filterAsyncErrors(List<ValidationError> errors) {
    return errors.where((error) => error.isAsyncValidation).toList();
  }

  /// Filters sync validation errors
  static List<ValidationError> filterSyncErrors(List<ValidationError> errors) {
    return errors.where((error) => !error.isAsyncValidation).toList();
  }

  /// Filters errors by error category
  static List<ValidationError> filterByCategory(
    List<ValidationError> errors,
    String category,
  ) {
    return errors.where((error) {
      if (error.code == null) return false;
      return error.code!.startsWith('${category}_');
    }).toList();
  }

  /// Filters type-related errors
  static List<ValidationError> filterTypeErrors(List<ValidationError> errors) {
    return errors.where((error) {
      if (error.code == null) return false;
      return ValidationErrorCodeUtils.isTypeError(error.code!);
    }).toList();
  }

  /// Filters constraint-related errors
  static List<ValidationError> filterConstraintErrors(
      List<ValidationError> errors) {
    return errors.where((error) {
      if (error.code == null) return false;
      return ValidationErrorCodeUtils.isConstraintError(error.code!);
    }).toList();
  }

  /// Filters transformation-related errors
  static List<ValidationError> filterTransformationErrors(
      List<ValidationError> errors) {
    return errors.where((error) {
      if (error.code == null) return false;
      return ValidationErrorCodeUtils.isTransformationError(error.code!);
    }).toList();
  }

  /// Filters errors by received value type
  static List<ValidationError> filterByReceivedType<T>(
      List<ValidationError> errors) {
    return errors.where((error) => error.received is T).toList();
  }

  /// Filters errors by message pattern
  static List<ValidationError> filterByMessagePattern(
    List<ValidationError> errors,
    RegExp pattern,
  ) {
    return errors.where((error) => pattern.hasMatch(error.message)).toList();
  }

  /// Filters errors with context information
  static List<ValidationError> filterWithContext(List<ValidationError> errors) {
    return errors.where((error) => error.hasContext).toList();
  }

  /// Filters errors without context information
  static List<ValidationError> filterWithoutContext(
      List<ValidationError> errors) {
    return errors.where((error) => !error.hasContext).toList();
  }

  /// Filters errors using a custom filter function
  static List<ValidationError> filterCustom(
    List<ValidationError> errors,
    ErrorFilter filter,
  ) {
    return errors.where(filter).toList();
  }

  // ==================== GROUPING UTILITIES ====================

  /// Groups errors by error code
  static Map<String, List<ValidationError>> groupByCode(
      List<ValidationError> errors) {
    final grouped = <String, List<ValidationError>>{};
    for (final error in errors) {
      final code = error.code ?? 'unknown';
      grouped.putIfAbsent(code, () => []).add(error);
    }
    return grouped;
  }

  /// Groups errors by path
  static Map<String, List<ValidationError>> groupByPath(
      List<ValidationError> errors) {
    final grouped = <String, List<ValidationError>>{};
    for (final error in errors) {
      final path = error.path.isEmpty ? 'root' : error.path.join('.');
      grouped.putIfAbsent(path, () => []).add(error);
    }
    return grouped;
  }

  /// Groups errors by path depth
  static Map<int, List<ValidationError>> groupByDepth(
      List<ValidationError> errors) {
    final grouped = <int, List<ValidationError>>{};
    for (final error in errors) {
      final depth = error.path.length;
      grouped.putIfAbsent(depth, () => []).add(error);
    }
    return grouped;
  }

  /// Groups errors by schema type
  static Map<String, List<ValidationError>> groupBySchemaType(
      List<ValidationError> errors) {
    final grouped = <String, List<ValidationError>>{};
    for (final error in errors) {
      final schemaType = error.schemaType ?? 'unknown';
      grouped.putIfAbsent(schemaType, () => []).add(error);
    }
    return grouped;
  }

  /// Groups errors by error category
  static Map<String, List<ValidationError>> groupByCategory(
      List<ValidationError> errors) {
    final grouped = <String, List<ValidationError>>{};
    for (final error in errors) {
      if (error.code == null) {
        grouped.putIfAbsent('unknown', () => []).add(error);
        continue;
      }
      final category = error.code!.split('_').first;
      grouped.putIfAbsent(category, () => []).add(error);
    }
    return grouped;
  }

  /// Groups errors by validation source
  static Map<String, List<ValidationError>> groupBySource(
      List<ValidationError> errors) {
    final grouped = <String, List<ValidationError>>{};
    for (final error in errors) {
      final source = error.validationSource ?? 'unknown';
      grouped.putIfAbsent(source, () => []).add(error);
    }
    return grouped;
  }

  /// Groups errors by validation operation
  static Map<String, List<ValidationError>> groupByOperation(
      List<ValidationError> errors) {
    final grouped = <String, List<ValidationError>>{};
    for (final error in errors) {
      final operation = error.validationOperation ?? 'unknown';
      grouped.putIfAbsent(operation, () => []).add(error);
    }
    return grouped;
  }

  /// Groups errors by received value type
  static Map<String, List<ValidationError>> groupByReceivedType(
      List<ValidationError> errors) {
    final grouped = <String, List<ValidationError>>{};
    for (final error in errors) {
      final type = error.received.runtimeType.toString();
      grouped.putIfAbsent(type, () => []).add(error);
    }
    return grouped;
  }

  /// Groups errors by parent path (one level up)
  static Map<String, List<ValidationError>> groupByParentPath(
      List<ValidationError> errors) {
    final grouped = <String, List<ValidationError>>{};
    for (final error in errors) {
      final parentPath = error.path.length <= 1
          ? 'root'
          : error.path.take(error.path.length - 1).join('.');
      grouped.putIfAbsent(parentPath, () => []).add(error);
    }
    return grouped;
  }

  /// Groups errors by async/sync validation type
  static Map<String, List<ValidationError>> groupByValidationType(
      List<ValidationError> errors) {
    final grouped = <String, List<ValidationError>>{};
    for (final error in errors) {
      final type = error.isAsyncValidation ? 'async' : 'sync';
      grouped.putIfAbsent(type, () => []).add(error);
    }
    return grouped;
  }

  /// Groups errors using a custom grouping function
  static Map<T, List<ValidationError>> groupByCustom<T>(
    List<ValidationError> errors,
    ErrorGroupingFunction<T> groupingFunction,
  ) {
    final grouped = <T, List<ValidationError>>{};
    for (final error in errors) {
      final key = groupingFunction(error);
      grouped.putIfAbsent(key, () => []).add(error);
    }
    return grouped;
  }

  // ==================== SORTING UTILITIES ====================

  /// Sorts errors by path (lexicographically)
  static List<ValidationError> sortByPath(List<ValidationError> errors) {
    final sorted = List<ValidationError>.from(errors);
    sorted.sort((a, b) => a.fullPath.compareTo(b.fullPath));
    return sorted;
  }

  /// Sorts errors by error code
  static List<ValidationError> sortByCode(List<ValidationError> errors) {
    final sorted = List<ValidationError>.from(errors);
    sorted.sort((a, b) {
      final codeA = a.code ?? '';
      final codeB = b.code ?? '';
      return codeA.compareTo(codeB);
    });
    return sorted;
  }

  /// Sorts errors by path depth (shallowest first)
  static List<ValidationError> sortByDepth(List<ValidationError> errors) {
    final sorted = List<ValidationError>.from(errors);
    sorted.sort((a, b) => a.path.length.compareTo(b.path.length));
    return sorted;
  }

  /// Sorts errors by validation depth (from context)
  static List<ValidationError> sortByValidationDepth(
      List<ValidationError> errors) {
    final sorted = List<ValidationError>.from(errors);
    sorted.sort((a, b) => a.validationDepth.compareTo(b.validationDepth));
    return sorted;
  }

  /// Sorts errors by schema type
  static List<ValidationError> sortBySchemaType(List<ValidationError> errors) {
    final sorted = List<ValidationError>.from(errors);
    sorted.sort((a, b) {
      final typeA = a.schemaType ?? '';
      final typeB = b.schemaType ?? '';
      return typeA.compareTo(typeB);
    });
    return sorted;
  }

  /// Sorts errors by message
  static List<ValidationError> sortByMessage(List<ValidationError> errors) {
    final sorted = List<ValidationError>.from(errors);
    sorted.sort((a, b) => a.message.compareTo(b.message));
    return sorted;
  }

  /// Sorts errors with custom comparator
  static List<ValidationError> sortCustom(
    List<ValidationError> errors,
    ErrorComparator comparator,
  ) {
    final sorted = List<ValidationError>.from(errors);
    sorted.sort(comparator);
    return sorted;
  }

  // ==================== UTILITY METHODS ====================

  /// Gets unique error codes from a list of errors
  static Set<String> getUniqueCodes(List<ValidationError> errors) {
    return errors
        .where((error) => error.code != null)
        .map((error) => error.code!)
        .toSet();
  }

  /// Gets unique paths from a list of errors
  static Set<String> getUniquePaths(List<ValidationError> errors) {
    return errors.map((error) => error.fullPath).toSet();
  }

  /// Gets unique schema types from a list of errors
  static Set<String> getUniqueSchemaTypes(List<ValidationError> errors) {
    return errors
        .where((error) => error.schemaType != null)
        .map((error) => error.schemaType!)
        .toSet();
  }

  /// Gets the maximum depth of errors
  static int getMaxDepth(List<ValidationError> errors) {
    if (errors.isEmpty) return 0;
    return errors
        .map((error) => error.path.length)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Gets the minimum depth of errors
  static int getMinDepth(List<ValidationError> errors) {
    if (errors.isEmpty) return 0;
    return errors
        .map((error) => error.path.length)
        .reduce((a, b) => a < b ? a : b);
  }

  /// Counts errors by error code
  static Map<String, int> countByCode(List<ValidationError> errors) {
    final counts = <String, int>{};
    for (final error in errors) {
      final code = error.code ?? 'unknown';
      counts[code] = (counts[code] ?? 0) + 1;
    }
    return counts;
  }

  /// Counts errors by path
  static Map<String, int> countByPath(List<ValidationError> errors) {
    final counts = <String, int>{};
    for (final error in errors) {
      final path = error.fullPath.isEmpty ? 'root' : error.fullPath;
      counts[path] = (counts[path] ?? 0) + 1;
    }
    return counts;
  }

  /// Counts errors by category
  static Map<String, int> countByCategory(List<ValidationError> errors) {
    final counts = <String, int>{};
    for (final error in errors) {
      if (error.code == null) {
        counts['unknown'] = (counts['unknown'] ?? 0) + 1;
        continue;
      }
      final category = error.code!.split('_').first;
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts;
  }

  /// Finds the most common error code
  static String? getMostCommonCode(List<ValidationError> errors) {
    final counts = countByCode(errors);
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Finds the most problematic path (with most errors)
  static String? getMostProblematicPath(List<ValidationError> errors) {
    final counts = countByPath(errors);
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Gets error statistics
  static Map<String, dynamic> getErrorStatistics(List<ValidationError> errors) {
    return {
      'total_errors': errors.length,
      'unique_codes': getUniqueCodes(errors).length,
      'unique_paths': getUniquePaths(errors).length,
      'unique_schema_types': getUniqueSchemaTypes(errors).length,
      'max_depth': getMaxDepth(errors),
      'min_depth': getMinDepth(errors),
      'most_common_code': getMostCommonCode(errors),
      'most_problematic_path': getMostProblematicPath(errors),
      'async_errors': filterAsyncErrors(errors).length,
      'sync_errors': filterSyncErrors(errors).length,
      'type_errors': filterTypeErrors(errors).length,
      'constraint_errors': filterConstraintErrors(errors).length,
      'transformation_errors': filterTransformationErrors(errors).length,
      'errors_with_context': filterWithContext(errors).length,
      'errors_without_context': filterWithoutContext(errors).length,
      'code_distribution': countByCode(errors),
      'path_distribution': countByPath(errors),
      'category_distribution': countByCategory(errors),
    };
  }
}

/// Advanced error filtering and grouping with chaining support
class ErrorProcessor {
  final List<ValidationError> _errors;

  ErrorProcessor(this._errors);

  /// Creates an error processor from a ValidationErrorCollection
  factory ErrorProcessor.fromCollection(ValidationErrorCollection collection) {
    return ErrorProcessor(collection.errors);
  }

  /// Filters errors by code
  ErrorProcessor filterByCode(String code) {
    return ErrorProcessor(ErrorUtils.filterByCode(_errors, code));
  }

  /// Filters errors by multiple codes
  ErrorProcessor filterByCodes(List<String> codes) {
    return ErrorProcessor(ErrorUtils.filterByCodes(_errors, codes));
  }

  /// Filters errors by path prefix
  ErrorProcessor filterByPathPrefix(List<String> pathPrefix) {
    return ErrorProcessor(ErrorUtils.filterByPathPrefix(_errors, pathPrefix));
  }

  /// Filters errors by exact path
  ErrorProcessor filterByExactPath(List<String> path) {
    return ErrorProcessor(ErrorUtils.filterByExactPath(_errors, path));
  }

  /// Filters errors by depth
  ErrorProcessor filterByDepth(int depth) {
    return ErrorProcessor(ErrorUtils.filterByDepth(_errors, depth));
  }

  /// Filters errors by minimum depth
  ErrorProcessor filterByMinDepth(int minDepth) {
    return ErrorProcessor(ErrorUtils.filterByMinDepth(_errors, minDepth));
  }

  /// Filters errors by maximum depth
  ErrorProcessor filterByMaxDepth(int maxDepth) {
    return ErrorProcessor(ErrorUtils.filterByMaxDepth(_errors, maxDepth));
  }

  /// Filters async errors
  ErrorProcessor filterAsync() {
    return ErrorProcessor(ErrorUtils.filterAsyncErrors(_errors));
  }

  /// Filters sync errors
  ErrorProcessor filterSync() {
    return ErrorProcessor(ErrorUtils.filterSyncErrors(_errors));
  }

  /// Filters type errors
  ErrorProcessor filterTypeErrors() {
    return ErrorProcessor(ErrorUtils.filterTypeErrors(_errors));
  }

  /// Filters constraint errors
  ErrorProcessor filterConstraintErrors() {
    return ErrorProcessor(ErrorUtils.filterConstraintErrors(_errors));
  }

  /// Filters with custom filter
  ErrorProcessor filterCustom(ErrorFilter filter) {
    return ErrorProcessor(ErrorUtils.filterCustom(_errors, filter));
  }

  /// Sorts errors by path
  ErrorProcessor sortByPath() {
    return ErrorProcessor(ErrorUtils.sortByPath(_errors));
  }

  /// Sorts errors by code
  ErrorProcessor sortByCode() {
    return ErrorProcessor(ErrorUtils.sortByCode(_errors));
  }

  /// Sorts errors by depth
  ErrorProcessor sortByDepth() {
    return ErrorProcessor(ErrorUtils.sortByDepth(_errors));
  }

  /// Sorts with custom comparator
  ErrorProcessor sortCustom(ErrorComparator comparator) {
    return ErrorProcessor(ErrorUtils.sortCustom(_errors, comparator));
  }

  /// Gets the processed errors
  List<ValidationError> get errors => List.unmodifiable(_errors);

  /// Gets the errors as a ValidationErrorCollection
  ValidationErrorCollection get collection =>
      ValidationErrorCollection(_errors);

  /// Groups by code
  Map<String, List<ValidationError>> groupByCode() {
    return ErrorUtils.groupByCode(_errors);
  }

  /// Groups by path
  Map<String, List<ValidationError>> groupByPath() {
    return ErrorUtils.groupByPath(_errors);
  }

  /// Groups by custom function
  Map<T, List<ValidationError>> groupByCustom<T>(
      ErrorGroupingFunction<T> groupingFunction) {
    return ErrorUtils.groupByCustom(_errors, groupingFunction);
  }

  /// Gets error statistics
  Map<String, dynamic> getStatistics() {
    return ErrorUtils.getErrorStatistics(_errors);
  }

  /// Gets the count of errors
  int get count => _errors.length;

  /// Checks if empty
  bool get isEmpty => _errors.isEmpty;

  /// Checks if not empty
  bool get isNotEmpty => _errors.isNotEmpty;
}
