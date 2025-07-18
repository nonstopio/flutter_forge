import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('ErrorUtils', () {
    // Create test errors for filtering tests
    final testErrors = [
      ValidationError.typeMismatch(
        expected: 'string',
        received: 123,
        path: ['field1'],
        code: 'type_mismatch',
      ),
      ValidationError.constraintViolation(
        constraint: 'min length 5',
        received: 'abc',
        path: ['field1', 'nested'],
        code: 'min_length',
      ),
      ValidationError.missingProperty(
        property: 'required_field',
        path: ['field2'],
        code: 'missing_property',
      ),
      ValidationError.constraintViolation(
        constraint: 'max value 100',
        received: 150,
        path: ['field3', 'deep', 'value'],
        code: 'max_value',
      ),
      ValidationError.typeMismatch(
        expected: 'number',
        received: 'invalid',
        path: [],
        code: 'type_mismatch',
      ),
    ];

    group('Filtering by Code', () {
      test('should filter errors by single code', () {
        final result = ErrorUtils.filterByCode(testErrors, 'type_mismatch');
        expect(result, hasLength(2));
        expect(result.every((e) => e.code == 'type_mismatch'), isTrue);
      });

      test('should filter errors by multiple codes', () {
        final result = ErrorUtils.filterByCodes(
          testErrors,
          ['type_mismatch', 'min_length'],
        );
        expect(result, hasLength(3));
        expect(
          result.every(
              (e) => e.code == 'type_mismatch' || e.code == 'min_length'),
          isTrue,
        );
      });

      test('should return empty list for non-existent code', () {
        final result = ErrorUtils.filterByCode(testErrors, 'non_existent');
        expect(result, isEmpty);
      });

      test('should handle errors with null codes', () {
        final errorsWithNull = [
          ...testErrors,
          ValidationError.constraintViolation(
            constraint: 'test',
            received: 'test',
            path: [],
          ), // No code specified
        ];
        final result = ErrorUtils.filterByCode(errorsWithNull, 'type_mismatch');
        expect(result, hasLength(2));
      });
    });

    group('Filtering by Path', () {
      test('should filter errors by path prefix', () {
        final result = ErrorUtils.filterByPathPrefix(testErrors, ['field1']);
        expect(result, hasLength(2));
        expect(result.every((e) => e.path.isNotEmpty && e.path[0] == 'field1'),
            isTrue);
      });

      test('should filter errors by exact path', () {
        final result = ErrorUtils.filterByExactPath(testErrors, ['field2']);
        expect(result, hasLength(1));
        expect(result.first.path, equals(['field2']));
      });

      test('should filter errors by path depth', () {
        final depthTwoErrors = ErrorUtils.filterByDepth(testErrors, 2);
        expect(depthTwoErrors, hasLength(1));
        expect(depthTwoErrors.first.path, hasLength(2));

        final depthThreeErrors = ErrorUtils.filterByDepth(testErrors, 3);
        expect(depthThreeErrors, hasLength(1));
        expect(depthThreeErrors.first.path, hasLength(3));
      });

      test('should filter errors by minimum depth', () {
        final result = ErrorUtils.filterByMinDepth(testErrors, 2);
        expect(result, hasLength(2));
        expect(result.every((e) => e.path.length >= 2), isTrue);
      });

      test('should filter errors by maximum depth', () {
        final result = ErrorUtils.filterByMaxDepth(testErrors, 1);
        expect(result, hasLength(3));
        expect(result.every((e) => e.path.length <= 1), isTrue);
      });

      test('should handle empty path prefix', () {
        final result = ErrorUtils.filterByPathPrefix(testErrors, []);
        expect(result, hasLength(testErrors.length));
      });

      test('should handle path prefix longer than error path', () {
        final result = ErrorUtils.filterByPathPrefix(
          testErrors,
          ['field1', 'nested', 'very', 'deep'],
        );
        expect(result, isEmpty);
      });
    });

    group('Filtering by Schema Type', () {
      test('should filter errors by schema type', () {
        final errorsWithSchemaType = testErrors.map((e) {
          return ValidationError.constraintViolation(
            constraint: e.expected,
            received: e.received,
            path: e.path,
            code: e.code,
            context: {'schema_type': 'StringSchema'},
          );
        }).toList();

        final result = ErrorUtils.filterBySchemaType(
          errorsWithSchemaType,
          'StringSchema',
        );
        expect(result, hasLength(errorsWithSchemaType.length));
        expect(result.every((e) => e.schemaType == 'StringSchema'), isTrue);
      });

      test('should return empty list for non-matching schema type', () {
        final result =
            ErrorUtils.filterBySchemaType(testErrors, 'NumberSchema');
        expect(result, isEmpty);
      });
    });

    group('Filtering by Validation Context', () {
      test('should filter errors by validation source', () {
        final errorsWithSource = testErrors.map((e) {
          return ValidationError.constraintViolation(
            constraint: e.expected,
            received: e.received,
            path: e.path,
            code: e.code,
            context: {'source': 'client'},
          );
        }).toList();

        final result = ErrorUtils.filterBySource(errorsWithSource, 'client');
        expect(result, hasLength(errorsWithSource.length));
        expect(result.every((e) => e.validationSource == 'client'), isTrue);
      });

      test('should filter errors by validation operation', () {
        final errorsWithOperation = testErrors.map((e) {
          return ValidationError.constraintViolation(
            constraint: e.expected,
            received: e.received,
            path: e.path,
            code: e.code,
            context: {'operation': 'parse'},
          );
        }).toList();

        final result =
            ErrorUtils.filterByOperation(errorsWithOperation, 'parse');
        expect(result, hasLength(errorsWithOperation.length));
        expect(result.every((e) => e.validationOperation == 'parse'), isTrue);
      });

      test('should filter async validation errors', () {
        final mixedErrors = [
          ValidationError.constraintViolation(
            constraint: 'test',
            received: 'test',
            path: [],
            context: {'is_async': true},
          ),
          ValidationError.constraintViolation(
            constraint: 'test',
            received: 'test',
            path: [],
            context: {'is_async': false},
          ),
          ValidationError.constraintViolation(
            constraint: 'test',
            received: 'test',
            path: [],
          ), // Defaults to false
        ];

        final asyncErrors = ErrorUtils.filterAsyncErrors(mixedErrors);
        expect(asyncErrors, hasLength(1));
        expect(asyncErrors.first.isAsyncValidation, isTrue);

        final syncErrors = ErrorUtils.filterSyncErrors(mixedErrors);
        expect(syncErrors, hasLength(2));
        expect(syncErrors.every((e) => !e.isAsyncValidation), isTrue);
      });
    });

    group('Filtering by Category', () {
      test('should filter errors by category prefix', () {
        final categoryErrors = [
          ValidationError.constraintViolation(
            constraint: 'test',
            received: 'test',
            path: [],
            code: 'string_min_length',
          ),
          ValidationError.constraintViolation(
            constraint: 'test',
            received: 'test',
            path: [],
            code: 'string_max_length',
          ),
          ValidationError.constraintViolation(
            constraint: 'test',
            received: 'test',
            path: [],
            code: 'number_min_value',
          ),
        ];

        final stringErrors =
            ErrorUtils.filterByCategory(categoryErrors, 'string');
        expect(stringErrors, hasLength(2));
        expect(
            stringErrors.every((e) => e.code!.startsWith('string_')), isTrue);
      });

      test('should handle errors without codes in category filtering', () {
        final errorsWithoutCode = [
          ValidationError.constraintViolation(
            constraint: 'test',
            received: 'test',
            path: [],
          ),
        ];

        final result = ErrorUtils.filterByCategory(errorsWithoutCode, 'string');
        expect(result, isEmpty);
      });
    });

    group('Error Type Classification', () {
      test('should filter type errors', () {
        final result = ErrorUtils.filterTypeErrors(testErrors);
        expect(result, hasLength(2)); // Both type_mismatch errors
        expect(result.every((e) => e.code == 'type_mismatch'), isTrue);
      });

      test('should filter constraint errors', () {
        final result = ErrorUtils.filterConstraintErrors(testErrors);
        expect(result, hasLength(2)); // min_length and max_value errors
        expect(result.any((e) => e.code == 'min_length'), isTrue);
        expect(result.any((e) => e.code == 'max_value'), isTrue);
      });
    });

    group('Error Grouping', () {
      test('should group errors by code', () {
        final grouped = ErrorUtils.groupByCode(testErrors);
        expect(grouped.keys, hasLength(4));
        expect(grouped['type_mismatch'], hasLength(2));
        expect(grouped['min_length'], hasLength(1));
        expect(grouped['missing_property'], hasLength(1));
        expect(grouped['max_value'], hasLength(1));
      });

      test('should group errors by path depth', () {
        final grouped = ErrorUtils.groupByDepth(testErrors);
        expect(grouped.keys.contains(0), isTrue); // Root level errors
        expect(grouped.keys.contains(1), isTrue); // First level errors
        expect(grouped.keys.contains(2), isTrue); // Second level errors
        expect(grouped.keys.contains(3), isTrue); // Third level errors
      });

      test('should group errors by path', () {
        final grouped = ErrorUtils.groupByPath(testErrors);
        expect(grouped.keys, contains('field1'));
        expect(grouped.keys, contains('field2'));
        expect(grouped.keys, contains('field3.deep.value'));
      });

      test('should group errors by schema type', () {
        final errorsWithSchemaType = testErrors.map((e) {
          return ValidationError.constraintViolation(
            constraint: e.expected,
            received: e.received,
            path: e.path,
            code: e.code,
            context: {'schema_type': 'StringSchema'},
          );
        }).toList();

        final grouped = ErrorUtils.groupBySchemaType(errorsWithSchemaType);
        expect(grouped['StringSchema'], hasLength(errorsWithSchemaType.length));
      });
    });

    group('Error Sorting', () {
      test('should sort errors by path depth', () {
        final sorted = ErrorUtils.sortByDepth(testErrors);
        expect(sorted.first.path, hasLength(0)); // Root level first
        expect(sorted.last.path, hasLength(3)); // Deepest last
      });

      test('should sort errors by code', () {
        final sorted = ErrorUtils.sortByCode(testErrors);
        // Sorted alphabetically by code
        expect(sorted.first.code, equals('max_value'));
        expect(sorted.last.code, equals('type_mismatch'));
      });

      test('should sort errors by path', () {
        final sorted = ErrorUtils.sortByPath(testErrors);
        expect(sorted, hasLength(testErrors.length));
      });

      test('should sort errors by schema type', () {
        final errorsWithSchemaType = testErrors.map((e) {
          return ValidationError.constraintViolation(
            constraint: e.expected,
            received: e.received,
            path: e.path,
            code: e.code,
            context: {'schema_type': 'StringSchema'},
          );
        }).toList();

        final sorted = ErrorUtils.sortBySchemaType(errorsWithSchemaType);
        expect(sorted, hasLength(errorsWithSchemaType.length));
      });

      test('should sort errors by message', () {
        final sorted = ErrorUtils.sortByMessage(testErrors);
        expect(sorted, hasLength(testErrors.length));
      });

      test('should sort errors with custom comparator', () {
        final sorted = ErrorUtils.sortCustom(testErrors, (a, b) {
          return a.path.length.compareTo(b.path.length);
        });
        expect(sorted.first.path, hasLength(0));
        expect(sorted.last.path, hasLength(3));
      });
    });

    group('Error Statistics', () {
      test('should provide error statistics', () {
        final stats = ErrorUtils.getErrorStatistics(testErrors);
        expect(stats['total_errors'], equals(5));
        expect(stats['unique_codes'], equals(4));
        expect(stats['max_depth'], equals(3));
        expect(stats['code_distribution'], isA<Map>());
      });

      test('should get unique codes', () {
        final codes = ErrorUtils.getUniqueCodes(testErrors);
        expect(codes, hasLength(4));
        expect(
            codes,
            containsAll([
              'type_mismatch',
              'min_length',
              'missing_property',
              'max_value'
            ]));
      });

      test('should get unique paths', () {
        final paths = ErrorUtils.getUniquePaths(testErrors);
        expect(paths, isNotEmpty);
      });

      test('should get unique schema types', () {
        final schemaTypes = ErrorUtils.getUniqueSchemaTypes(testErrors);
        expect(schemaTypes, isA<Set<String>>());
      });

      test('should get max and min depth', () {
        final maxDepth = ErrorUtils.getMaxDepth(testErrors);
        final minDepth = ErrorUtils.getMinDepth(testErrors);
        expect(maxDepth, equals(3));
        expect(minDepth, equals(0));
      });

      test('should count errors by code', () {
        final counts = ErrorUtils.countByCode(testErrors);
        expect(counts['type_mismatch'], equals(2));
        expect(counts['min_length'], equals(1));
        expect(counts['missing_property'], equals(1));
        expect(counts['max_value'], equals(1));
      });

      test('should count errors by path', () {
        final counts = ErrorUtils.countByPath(testErrors);
        expect(counts, isA<Map<String, int>>());
      });

      test('should get most common code', () {
        final mostCommon = ErrorUtils.getMostCommonCode(testErrors);
        expect(mostCommon, equals('type_mismatch'));
      });

      test('should get most problematic path', () {
        final mostProblematic = ErrorUtils.getMostProblematicPath(testErrors);
        expect(mostProblematic, isA<String?>());
      });
    });

    group('Additional Filter and Transform Tests', () {
      test('should filter by received type', () {
        final result = ErrorUtils.filterByReceivedType<String>(testErrors);
        expect(result, isNotEmpty);
        expect(result.every((e) => e.received is String), isTrue);
      });

      test('should filter by message pattern', () {
        final pattern = RegExp(r'type');
        final result = ErrorUtils.filterByMessagePattern(testErrors, pattern);
        expect(result, isNotEmpty);
      });

      test('should filter errors with and without context', () {
        final errorWithContext = ValidationError.constraintViolation(
          constraint: 'test',
          received: 'test',
          path: ['field'],
          context: {'key': 'value'},
        );

        final mixedErrors = [...testErrors, errorWithContext];

        final withContext = ErrorUtils.filterWithContext(mixedErrors);
        final withoutContext = ErrorUtils.filterWithoutContext(mixedErrors);

        expect(withContext, hasLength(1));
        expect(withoutContext, hasLength(testErrors.length));
      });

      test('should filter with custom function', () {
        final result = ErrorUtils.filterCustom(testErrors, (error) {
          return error.path.length > 1;
        });
        expect(result, hasLength(2)); // field1.nested and field3.deep.value
      });

      test('should filter transformation errors', () {
        final transformErrors = [
          ValidationError.constraintViolation(
            constraint: 'test',
            received: 'test',
            path: [],
            code: 'transform_failed',
          ),
        ];

        final result = ErrorUtils.filterTransformationErrors(transformErrors);
        expect(result, isA<List<ValidationError>>());
      });
    });

    group('Additional Grouping Tests', () {
      test('should group by category', () {
        final categoryErrors = [
          ValidationError.constraintViolation(
            constraint: 'test',
            received: 'test',
            path: [],
            code: 'string_min_length',
          ),
          ValidationError.constraintViolation(
            constraint: 'test',
            received: 'test',
            path: [],
            code: 'number_max_value',
          ),
        ];

        final grouped = ErrorUtils.groupByCategory(categoryErrors);
        expect(grouped, isA<Map<String, List<ValidationError>>>());
      });

      test('should group by source', () {
        final errorsWithSource = testErrors.map((e) {
          return ValidationError.constraintViolation(
            constraint: e.expected,
            received: e.received,
            path: e.path,
            code: e.code,
            context: {'source': 'client'},
          );
        }).toList();

        final grouped = ErrorUtils.groupBySource(errorsWithSource);
        expect(grouped['client'], hasLength(errorsWithSource.length));
      });

      test('should group by operation', () {
        final errorsWithOperation = testErrors.map((e) {
          return ValidationError.constraintViolation(
            constraint: e.expected,
            received: e.received,
            path: e.path,
            code: e.code,
            context: {'operation': 'parse'},
          );
        }).toList();

        final grouped = ErrorUtils.groupByOperation(errorsWithOperation);
        expect(grouped['parse'], hasLength(errorsWithOperation.length));
      });

      test('should group by received type', () {
        final grouped = ErrorUtils.groupByReceivedType(testErrors);
        expect(grouped, isA<Map<String, List<ValidationError>>>());
      });

      test('should group by parent path', () {
        final grouped = ErrorUtils.groupByParentPath(testErrors);
        expect(grouped, isA<Map<String, List<ValidationError>>>());
      });
    });
  });
}
