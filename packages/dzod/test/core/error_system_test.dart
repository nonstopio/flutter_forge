import 'package:dzod/src/core/error.dart';
import 'package:dzod/src/core/error_codes.dart';
import 'package:dzod/src/core/error_context.dart';
import 'package:dzod/src/core/error_formatter.dart' as zod_formatter;
import 'package:dzod/src/core/error_utils.dart';
import 'package:test/test.dart';

void main() {
  group('ValidationError', () {
    test('should create basic validation error', () {
      const error = ValidationError(
        message: 'Test error',
        path: ['user', 'name'],
        received: null,
        expected: 'string',
        code: 'type_mismatch',
      );

      expect(error.message, equals('Test error'));
      expect(error.path, equals(['user', 'name']));
      expect(error.fullPath, equals('user.name'));
      expect(error.received, isNull);
      expect(error.expected, equals('string'));
      expect(error.code, equals('type_mismatch'));
    });

    test('should create type mismatch error', () {
      final error = ValidationError.typeMismatch(
        path: ['age'],
        received: 'not a number',
        expected: 'number',
      );

      expect(error.message, equals('Expected number, but received string'));
      expect(error.path, equals(['age']));
      expect(error.code, equals('type_mismatch'));
    });

    test('should create constraint violation error', () {
      final error = ValidationError.constraintViolation(
        path: ['password'],
        received: '123',
        constraint: 'Password must be at least 8 characters',
        code: 'string_too_short',
      );

      expect(error.message, equals('Password must be at least 8 characters'));
      expect(error.code, equals('string_too_short'));
    });

    test('should add path segments', () {
      final error = ValidationError.simple(
        message: 'Error',
        path: ['user'],
        received: null,
      );

      final withPath = error.withPath(['profile', 'avatar']);
      expect(withPath.path, equals(['user', 'profile', 'avatar']));
    });

    test('should add context', () {
      final error = ValidationError.simple(
        message: 'Error',
        path: [],
        received: null,
      );

      final withContext =
          error.withContext({'source': 'api', 'timestamp': '2023-01-01'});
      expect(withContext.context, isNotNull);
      expect(withContext.context!['source'], equals('api'));
    });
  });

  group('ValidationErrorCollection', () {
    test('should create empty collection', () {
      final collection = ValidationErrorCollection.empty();
      expect(collection.isEmpty, isTrue);
      expect(collection.length, equals(0));
    });

    test('should create single error collection', () {
      final error = ValidationError.simple(
        message: 'Error',
        path: [],
        received: null,
      );
      final collection = ValidationErrorCollection.single(error);

      expect(collection.length, equals(1));
      expect(collection.first, equals(error));
    });

    test('should add errors', () {
      final error1 =
          ValidationError.simple(message: 'Error 1', path: [], received: null);
      final error2 =
          ValidationError.simple(message: 'Error 2', path: [], received: null);

      final collection =
          ValidationErrorCollection.empty().add(error1).add(error2);

      expect(collection.length, equals(2));
      expect(collection.errors, contains(error1));
      expect(collection.errors, contains(error2));
    });

    test('should merge collections', () {
      final error1 =
          ValidationError.simple(message: 'Error 1', path: [], received: null);
      final error2 =
          ValidationError.simple(message: 'Error 2', path: [], received: null);

      final collection1 = ValidationErrorCollection.single(error1);
      final collection2 = ValidationErrorCollection.single(error2);
      final merged = collection1.merge(collection2);

      expect(merged.length, equals(2));
    });

    test('should filter by path', () {
      final error1 = ValidationError.simple(
          message: 'Error 1', path: ['user', 'name'], received: null);
      final error2 = ValidationError.simple(
          message: 'Error 2', path: ['user', 'age'], received: null);
      final error3 = ValidationError.simple(
          message: 'Error 3', path: ['admin', 'role'], received: null);

      final collection = ValidationErrorCollection([error1, error2, error3]);
      final filtered = collection.filterByPath(['user']);

      expect(filtered.length, equals(2));
      expect(filtered.errors, contains(error1));
      expect(filtered.errors, contains(error2));
    });

    test('should filter by code', () {
      final error1 = ValidationError.simple(
          message: 'Error 1', path: [], received: null, code: 'type_mismatch');
      final error2 = ValidationError.simple(
          message: 'Error 2', path: [], received: null, code: 'required');
      final error3 = ValidationError.simple(
          message: 'Error 3', path: [], received: null, code: 'type_mismatch');

      final collection = ValidationErrorCollection([error1, error2, error3]);
      final filtered = collection.filterByCode('type_mismatch');

      expect(filtered.length, equals(2));
    });

    test('should convert to JSON', () {
      final error = ValidationError.simple(
        message: 'Test error',
        path: ['user', 'name'],
        received: null,
        code: 'required',
      );
      final collection = ValidationErrorCollection.single(error);
      final json = collection.toJson();

      expect(json, isList);
      expect(json.length, equals(1));
      expect(json[0]['message'], equals('Test error'));
      expect(json[0]['path'], equals(['user', 'name']));
      expect(json[0]['code'], equals('required'));
    });
  });

  group('ValidationErrorCode', () {
    test('should have predefined error codes', () {
      expect(ValidationErrorCode.typeMismatch.code, equals('type_mismatch'));
      expect(
          ValidationErrorCode.stringTooShort.code, equals('string_too_short'));
      expect(
          ValidationErrorCode.numberTooLarge.code, equals('number_too_large'));
    });

    test('should create error from code', () {
      final error = ValidationErrorCode.stringTooShort.createError(
        path: ['password'],
        received: '123',
        expected: 'string with at least 8 characters',
      );

      expect(error.code, equals('string_too_short'));
      expect(error.message, equals('String is too short'));
    });

    test('should find error code by string', () {
      final code = ValidationErrorCode.fromCode('type_mismatch');
      expect(code, equals(ValidationErrorCode.typeMismatch));

      final unknownCode = ValidationErrorCode.fromCode('unknown_code');
      expect(unknownCode, isNull);
    });

    test('should get error codes by category', () {
      final stringCodes = ValidationErrorCode.stringErrorCodes;
      expect(stringCodes, contains(ValidationErrorCode.stringTooShort));
      expect(stringCodes, contains(ValidationErrorCode.stringTooLong));
      expect(stringCodes, contains(ValidationErrorCode.stringEmail));
    });
  });

  group('ErrorFormatter', () {
    setUp(() {
      zod_formatter.ErrorFormatter.resetGlobalConfig();
    });

    test('should format single error with default config', () {
      final error = ValidationError.simple(
        message: 'Test error',
        path: ['user', 'name'],
        received: 'invalid',
      );

      final formatted = zod_formatter.ErrorFormatter.formatError(error);
      expect(formatted, contains('Test error'));
      expect(formatted, contains('[user.name]'));
      expect(formatted, contains('received: "invalid"'));
    });

    test('should format errors collection', () {
      final error1 = ValidationError.simple(
          message: 'Error 1', path: ['user'], received: null);
      final error2 = ValidationError.simple(
          message: 'Error 2', path: ['admin'], received: null);
      final collection = ValidationErrorCollection([error1, error2]);

      final formatted = zod_formatter.ErrorFormatter.formatErrors(collection);
      expect(formatted, contains('Error 1'));
      expect(formatted, contains('Error 2'));
    });

    test('should format errors as JSON', () {
      final error = ValidationError.simple(
        message: 'Test error',
        path: ['user'],
        received: null,
        code: 'required',
      );
      final collection = ValidationErrorCollection.single(error);

      final json = zod_formatter.ErrorFormatter.formatErrorsAsJson(collection);
      expect(json['errors'], isList);
      expect(json['count'], equals(1));
      expect(json['formatted'], isA<String>());
    });

    test('should use custom error messages', () {
      zod_formatter.ErrorFormatter.setGlobalConfig(
        const zod_formatter.ErrorFormatConfig(
          customMessages: {'required': 'This field is mandatory'},
        ),
      );

      final error = ValidationError.simple(
        message: 'Field is required',
        path: ['name'],
        received: null,
        code: 'required',
      );

      final formatted = zod_formatter.ErrorFormatter.formatError(error);
      expect(formatted, contains('This field is mandatory'));
    });

    test('should format for humans', () {
      final error = ValidationError.simple(
        message: 'Test error',
        path: ['user', 'profile', 'name'],
        received: null,
        code: 'required',
      );
      final collection = ValidationErrorCollection.single(error);

      final formatted =
          zod_formatter.ErrorFormatter.formatErrorsForHumans(collection);
      expect(formatted, contains('Test error'));
      expect(formatted, isNot(contains('received:')));
      expect(formatted, isNot(contains('[required]')));
    });

    test('should format compact', () {
      final error1 =
          ValidationError.simple(message: 'Error 1', path: [], received: null);
      final error2 =
          ValidationError.simple(message: 'Error 2', path: [], received: null);
      final collection = ValidationErrorCollection([error1, error2]);

      final formatted =
          zod_formatter.ErrorFormatter.formatErrorsCompact(collection);
      expect(formatted, equals('Error 1; Error 2'));
    });

    test('should group errors by path', () {
      final error1 = ValidationError.simple(
          message: 'Error 1', path: ['user'], received: null);
      final error2 = ValidationError.simple(
          message: 'Error 2', path: ['user'], received: null);
      final error3 = ValidationError.simple(
          message: 'Error 3', path: ['admin'], received: null);
      final collection = ValidationErrorCollection([error1, error2, error3]);

      final grouped =
          zod_formatter.ErrorFormatter.formatErrorsGroupedByPath(collection);
      expect(grouped['user'], hasLength(2));
      expect(grouped['admin'], hasLength(1));
    });

    test('should use predefined presets', () {
      final error = ValidationError.simple(
        message: 'Test error',
        path: ['user'],
        received: 'invalid',
        code: 'type_mismatch',
      );

      final minimal = zod_formatter.ErrorFormatter.formatError(
          error, zod_formatter.ErrorFormatPresets.minimal);
      expect(minimal, equals('Test error'));

      final detailed = zod_formatter.ErrorFormatter.formatError(
          error, zod_formatter.ErrorFormatPresets.detailed);
      expect(detailed, contains('[user]'));
      expect(detailed, contains('received:'));
      expect(detailed, contains('[type_mismatch]'));
    });
  });

  group('ErrorContext', () {
    test('should create root context', () {
      final context = ErrorContext.root(source: 'api', operation: 'create');
      expect(context.path, isEmpty);
      expect(context.source, equals('api'));
      expect(context.operation, equals('create'));
      expect(context.depth, equals(0));
      expect(context.isRoot, isTrue);
    });

    test('should create child contexts', () {
      final root = ErrorContext.root();
      final field = root.forField('name', schemaType: 'string');
      final index = field.forIndex(0, schemaType: 'string');

      expect(field.path, equals(['name']));
      expect(field.fieldName, equals('name'));
      expect(field.depth, equals(1));
      expect(field.isObjectField, isTrue);

      expect(index.path, equals(['name', '0']));
      expect(index.index, equals(0));
      expect(index.depth, equals(2));
      expect(index.isArrayElement, isTrue);
    });

    test('should track ancestors and breadcrumbs', () {
      final root = ErrorContext.root();
      final child1 = root.forField('user');
      final child2 = child1.forField('profile');
      final child3 = child2.forIndex(0);

      expect(child3.ancestors, hasLength(3));
      expect(child3.breadcrumbs, equals(['user', 'profile', '0']));
      expect(child3.root, equals(root));
    });

    test('should create errors with context', () {
      final context = ErrorContext.root(source: 'api')
          .forField('user', schemaType: 'object')
          .forField('name', schemaType: 'string');

      final error = context.createError(
        message: 'Name is required',
        received: null,
        code: 'required',
      );

      expect(error.path, equals(['user', 'name']));
      expect(error.context!['source'], equals('api'));
      expect(error.context!['schema_type'], equals('string'));
      expect(error.context!['field_name'], equals('name'));
      expect(error.context!['depth'], equals(2));
    });

    test('should create typed errors', () {
      final context = ErrorContext.root().forField('age');

      final typeMismatch = context.createTypeMismatchError(
        received: 'not a number',
        expected: 'number',
      );

      expect(typeMismatch.code, equals('type_mismatch'));
      expect(
          typeMismatch.message, equals('Expected number, but received string'));

      final constraint = context.createConstraintViolationError(
        received: -5,
        constraint: 'Age must be positive',
        code: 'number_not_positive',
      );

      expect(constraint.code, equals('number_not_positive'));
      expect(constraint.message, equals('Age must be positive'));
    });

    test('should create errors from error codes', () {
      final context = ErrorContext.root().forField('email');

      final error = context.createErrorFromCode(
        errorCode: ValidationErrorCode.stringEmail,
        received: 'invalid-email',
        expected: 'valid email address',
      );

      expect(error.code, equals('string_email'));
      expect(error.message, equals('Invalid email format'));
    });

    test('should convert to JSON', () {
      final context = ErrorContext.root(source: 'api')
          .forField('user')
          .asAsync()
          .withMetadata({'version': '1.0'});

      final json = context.toJson();
      expect(json['path'], equals(['user']));
      expect(json['source'], equals('api'));
      expect(json['is_async'], isTrue);
      expect(json['metadata'], containsPair('version', '1.0'));
    });
  });

  group('ErrorContextBuilder', () {
    test('should build context fluently', () {
      final context = ErrorContextBuilder()
          .source('api')
          .operation('validate')
          .field('user')
          .async()
          .metadata({'trace_id': '12345'}).build();

      expect(context.source, equals('api'));
      expect(context.operation, equals('validate'));
      expect(context.path, equals(['user']));
      expect(context.isAsync, isTrue);
      expect(context.metadata['trace_id'], equals('12345'));
    });
  });

  group('ErrorUtils', () {
    late List<ValidationError> testErrors;

    setUp(() {
      testErrors = [
        ValidationError.simple(
            message: 'Error 1',
            path: ['user', 'name'],
            received: null,
            code: 'required'),
        ValidationError.simple(
            message: 'Error 2',
            path: ['user', 'age'],
            received: 'invalid',
            code: 'type_mismatch'),
        ValidationError.simple(
            message: 'Error 3',
            path: ['admin', 'role'],
            received: '',
            code: 'string_empty'),
        ValidationError.simple(
            message: 'Error 4',
            path: ['user', 'profile', 'avatar'],
            received: null,
            code: 'required'),
        ValidationError.simple(
            message: 'Error 5', path: [], received: {}, code: 'object_invalid'),
      ];
    });

    test('should filter by code', () {
      final filtered = ErrorUtils.filterByCode(testErrors, 'required');
      expect(filtered, hasLength(2));
      expect(filtered.every((e) => e.code == 'required'), isTrue);
    });

    test('should filter by codes', () {
      final filtered =
          ErrorUtils.filterByCodes(testErrors, ['required', 'type_mismatch']);
      expect(filtered, hasLength(3));
    });

    test('should filter by path prefix', () {
      final filtered = ErrorUtils.filterByPathPrefix(testErrors, ['user']);
      expect(filtered, hasLength(3));
      expect(filtered.every((e) => e.path.isNotEmpty && e.path.first == 'user'),
          isTrue);
    });

    test('should filter by exact path', () {
      final filtered =
          ErrorUtils.filterByExactPath(testErrors, ['user', 'name']);
      expect(filtered, hasLength(1));
      expect(filtered.first.path, equals(['user', 'name']));
    });

    test('should filter by depth', () {
      final filtered = ErrorUtils.filterByDepth(testErrors, 2);
      expect(filtered, hasLength(2)); // ['user', 'name'] and ['user', 'age']
    });

    test('should filter by category', () {
      final filtered = ErrorUtils.filterByCategory(testErrors, 'string');
      expect(filtered, hasLength(1));
      expect(filtered.first.code, equals('string_empty'));
    });

    test('should group by code', () {
      final grouped = ErrorUtils.groupByCode(testErrors);
      expect(grouped['required'], hasLength(2));
      expect(grouped['type_mismatch'], hasLength(1));
      expect(grouped['string_empty'], hasLength(1));
    });

    test('should group by path', () {
      final grouped = ErrorUtils.groupByPath(testErrors);
      expect(grouped.keys, contains('user.name'));
      expect(grouped.keys, contains('user.age'));
      expect(grouped.keys, contains('admin.role'));
      expect(grouped.keys, contains('user.profile.avatar'));
      expect(grouped.keys, contains('root'));
    });

    test('should group by depth', () {
      final grouped = ErrorUtils.groupByDepth(testErrors);
      expect(grouped[0], hasLength(1)); // root path
      expect(grouped[2], hasLength(2)); // user.name, user.age
      expect(grouped[3], hasLength(1)); // user.profile.avatar
    });

    test('should sort by path', () {
      final sorted = ErrorUtils.sortByPath(testErrors);
      expect(sorted.first.fullPath, equals('')); // root comes first
      expect(sorted[1].fullPath, equals('admin.role'));
      expect(sorted[2].fullPath, equals('user.age'));
    });

    test('should sort by depth', () {
      final sorted = ErrorUtils.sortByDepth(testErrors);
      expect(sorted.first.path, hasLength(0)); // root
      expect(sorted.last.path, hasLength(3)); // deepest
    });

    test('should get statistics', () {
      final stats = ErrorUtils.getErrorStatistics(testErrors);
      expect(stats['total_errors'], equals(5));
      expect(stats['unique_codes'], equals(4));
      expect(stats['max_depth'], equals(3));
      expect(stats['min_depth'], equals(0));
      expect(stats['most_common_code'], equals('required'));
    });

    test('should get unique values', () {
      final codes = ErrorUtils.getUniqueCodes(testErrors);
      expect(codes, hasLength(4));
      expect(codes, contains('required'));
      expect(codes, contains('type_mismatch'));

      final paths = ErrorUtils.getUniquePaths(testErrors);
      expect(paths, hasLength(5));
    });

    test('should count by category', () {
      final counts = ErrorUtils.countByCategory(testErrors);
      expect(counts['string'], equals(1));
      expect(counts['object'], equals(1));
      expect(counts['type'], equals(1));
      expect(counts['required'], equals(2)); // 'required' is its own category
    });
  });

  group('ErrorProcessor', () {
    late ErrorProcessor processor;

    setUp(() {
      final errors = [
        ValidationError.simple(
            message: 'Error 1',
            path: ['user', 'name'],
            received: null,
            code: 'required'),
        ValidationError.simple(
            message: 'Error 2',
            path: ['user', 'age'],
            received: 'invalid',
            code: 'type_mismatch'),
        ValidationError.simple(
            message: 'Error 3',
            path: ['admin'],
            received: '',
            code: 'string_empty'),
      ];
      processor = ErrorProcessor(errors);
    });

    test('should chain filters', () {
      final result =
          processor.filterByPathPrefix(['user']).filterByCode('required');

      expect(result.count, equals(1));
      expect(result.errors.first.path, equals(['user', 'name']));
    });

    test('should chain filters and sorting', () {
      final result = processor.filterByPathPrefix(['user']).sortByPath();

      expect(result.count, equals(2));
      expect(result.errors.first.path, equals(['user', 'age']));
      expect(result.errors.last.path, equals(['user', 'name']));
    });

    test('should provide statistics', () {
      final stats = processor.getStatistics();
      expect(stats['total_errors'], equals(3));
      expect(stats['unique_codes'], equals(3));
    });

    test('should convert to collection', () {
      final collection = processor.collection;
      expect(collection, isA<ValidationErrorCollection>());
      expect(collection.length, equals(3));
    });
  });

  group('Extension Methods', () {
    test('should format validation error', () {
      final error = ValidationError.simple(
        message: 'Test error',
        path: ['user'],
        received: null,
        code: 'required',
      );

      expect(error.format(), contains('Test error'));
      expect(error.formatForHumans(), equals('[user] Test error'));
      expect(error.formatCompact(), equals('Test error'));
    });

    test('should format validation error collection', () {
      final error1 =
          ValidationError.simple(message: 'Error 1', path: [], received: null);
      final error2 =
          ValidationError.simple(message: 'Error 2', path: [], received: null);
      final collection = ValidationErrorCollection([error1, error2]);

      expect(collection.format(), contains('Error 1'));
      expect(collection.format(), contains('Error 2'));
      expect(collection.formatCompact(), equals('Error 1; Error 2'));
    });

    test('should get error context extensions', () {
      final error = ValidationError.simple(
        message: 'Test error',
        path: ['user'],
        received: null,
        code: 'required',
      ).withContext({
        'schema_type': 'string',
        'source': 'api',
        'is_async': true,
        'depth': 2,
      });

      expect(error.schemaType, equals('string'));
      expect(error.validationSource, equals('api'));
      expect(error.isAsyncValidation, isTrue);
      expect(error.validationDepth, equals(2));
      expect(error.hasContext, isTrue);
    });
  });
}
