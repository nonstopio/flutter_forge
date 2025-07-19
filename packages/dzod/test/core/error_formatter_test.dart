import 'package:dzod/src/core/error.dart';
import 'package:dzod/src/core/error_formatter.dart' as ef;
import 'package:test/test.dart';

void main() {
  group('ErrorFormatConfig', () {
    test('should create with default values', () {
      const config = ef.ErrorFormatConfig();

      expect(config.customMessages, isEmpty);
      expect(config.customFormatters, isEmpty);
      expect(config.contextFormatters, isEmpty);
      expect(config.defaultFormatter, isNull);
      expect(config.includeErrorCodes, true);
      expect(config.includeErrorPaths, true);
      expect(config.includeReceivedValues, true);
      expect(config.includeExpectedValues, true);
      expect(config.includeContext, false);
      expect(config.pathSeparator, '.');
      expect(config.maxDepth, 10);
      expect(config.groupByPath, false);
      expect(config.sortByPath, false);
      expect(config.groupingFunction, isNull);
    });

    test('should create with custom values', () {
      String customFormatter(ValidationError error) =>
          'Custom: ${error.message}';
      Map<String, dynamic> contextFormatter(ValidationError error) =>
          {'custom': true};
      String groupingFunction(ValidationError error) => 'group-${error.code}';

      final config = ef.ErrorFormatConfig(
        customMessages: {'test': 'Test message'},
        customFormatters: {'test': customFormatter},
        contextFormatters: {'test': contextFormatter},
        defaultFormatter: customFormatter,
        includeErrorCodes: false,
        includeErrorPaths: false,
        includeReceivedValues: false,
        includeExpectedValues: false,
        includeContext: true,
        pathSeparator: '->',
        maxDepth: 5,
        groupByPath: true,
        sortByPath: true,
        groupingFunction: groupingFunction,
      );

      expect(config.customMessages, {'test': 'Test message'});
      expect(config.customFormatters, containsPair('test', customFormatter));
      expect(config.contextFormatters, containsPair('test', contextFormatter));
      expect(config.defaultFormatter, equals(customFormatter));
      expect(config.includeErrorCodes, false);
      expect(config.includeErrorPaths, false);
      expect(config.includeReceivedValues, false);
      expect(config.includeExpectedValues, false);
      expect(config.includeContext, true);
      expect(config.pathSeparator, '->');
      expect(config.maxDepth, 5);
      expect(config.groupByPath, true);
      expect(config.sortByPath, true);
      expect(config.groupingFunction, equals(groupingFunction));
    });

    test('copyWith should create new config with updated values', () {
      const original = ef.ErrorFormatConfig(
        includeErrorCodes: true,
        includeErrorPaths: true,
        pathSeparator: '.',
      );

      final updated = original.copyWith(
        includeErrorCodes: false,
        pathSeparator: '->',
      );

      expect(updated.includeErrorCodes, false);
      expect(updated.includeErrorPaths, true); // unchanged
      expect(updated.pathSeparator, '->');
    });

    test('copyWith should handle null values correctly', () {
      String formatter(ValidationError error) => error.message;
      const original = ef.ErrorFormatConfig(defaultFormatter: null);

      final updated = original.copyWith(defaultFormatter: formatter);
      expect(updated.defaultFormatter, isNotNull);

      final updatedAgain = updated.copyWith();
      expect(updatedAgain.defaultFormatter, isNotNull);
    });

    test('merge should combine two configs correctly', () {
      const config1 = ef.ErrorFormatConfig(
        customMessages: {'error1': 'Message 1'},
        includeErrorCodes: true,
        pathSeparator: '.',
      );

      const config2 = ef.ErrorFormatConfig(
        customMessages: {'error2': 'Message 2'},
        includeErrorCodes: false,
        pathSeparator: '->',
      );

      final merged = config1.merge(config2);

      expect(merged.customMessages, {
        'error1': 'Message 1',
        'error2': 'Message 2',
      });
      expect(merged.includeErrorCodes, false); // from config2
      expect(merged.pathSeparator, '->'); // from config2
    });

    test('merge should handle formatters correctly', () {
      String formatter1(ValidationError error) => 'Format 1';
      String formatter2(ValidationError error) => 'Format 2';
      Map<String, dynamic> contextFormatter1(ValidationError error) =>
          {'ctx': 1};
      Map<String, dynamic> contextFormatter2(ValidationError error) =>
          {'ctx': 2};

      final config1 = ef.ErrorFormatConfig(
        customFormatters: {'type1': formatter1},
        contextFormatters: {'type1': contextFormatter1},
        defaultFormatter: formatter1,
      );

      final config2 = ef.ErrorFormatConfig(
        customFormatters: {'type2': formatter2},
        contextFormatters: {'type2': contextFormatter2},
        defaultFormatter: formatter2,
      );

      final merged = config1.merge(config2);

      expect(merged.customFormatters.keys, containsAll(['type1', 'type2']));
      expect(merged.contextFormatters.keys, containsAll(['type1', 'type2']));
      expect(merged.defaultFormatter, equals(formatter2));
    });

    test('merge should handle null default formatter correctly', () {
      String formatter(ValidationError error) => error.message;
      const config1 = ef.ErrorFormatConfig(defaultFormatter: null);
      final config2 = ef.ErrorFormatConfig(defaultFormatter: formatter);

      final merged1 = config1.merge(config2);
      expect(merged1.defaultFormatter, equals(formatter));

      final merged2 = config2.merge(config1);
      expect(merged2.defaultFormatter, equals(formatter)); // keeps existing
    });

    test('merge should handle grouping function correctly', () {
      String grouping1(ValidationError error) => 'group1';
      String grouping2(ValidationError error) => 'group2';

      final config1 = ef.ErrorFormatConfig(groupingFunction: grouping1);
      final config2 = ef.ErrorFormatConfig(groupingFunction: grouping2);

      final merged1 = config1.merge(config2);
      expect(merged1.groupingFunction, equals(grouping2));

      const config3 = ef.ErrorFormatConfig(groupingFunction: null);
      final merged2 = config1.merge(config3);
      expect(merged2.groupingFunction, equals(grouping1)); // keeps existing
    });
  });

  group('ErrorFormatter', () {
    setUp(() {
      ef.ErrorFormatter.resetGlobalConfig();
    });

    tearDown(() {
      ef.ErrorFormatter.resetGlobalConfig();
    });

    test('should get and set global config', () {
      const newConfig = ef.ErrorFormatConfig(includeErrorCodes: false);

      expect(ef.ErrorFormatter.globalConfig.includeErrorCodes, true);

      ef.ErrorFormatter.setGlobalConfig(newConfig);
      expect(ef.ErrorFormatter.globalConfig.includeErrorCodes, false);
    });

    test('should reset global config to default', () {
      const newConfig = ef.ErrorFormatConfig(includeErrorCodes: false);
      ef.ErrorFormatter.setGlobalConfig(newConfig);

      expect(ef.ErrorFormatter.globalConfig.includeErrorCodes, false);

      ef.ErrorFormatter.resetGlobalConfig();
      expect(ef.ErrorFormatter.globalConfig.includeErrorCodes, true);
    });

    test('formatError should use custom formatter when available', () {
      const error = ValidationError(
        code: 'test_error',
        message: 'Test message',
        path: ['field'],
        received: 'value',
        expected: 'string',
      );

      final config = ef.ErrorFormatConfig(
        customFormatters: {
          'test_error': (error) => 'Custom: ${error.message}',
        },
      );

      final result = ef.ErrorFormatter.formatError(error, config);
      expect(result, 'Custom: Test message');
    });

    test('formatError should use custom message when available', () {
      const error = ValidationError(
        code: 'test_error',
        message: 'Original message',
        path: ['field'],
        received: 'value',
        expected: 'string',
      );

      const config = ef.ErrorFormatConfig(
        customMessages: {'test_error': 'Custom message'},
        includeErrorCodes: false,
        includeErrorPaths: false,
        includeReceivedValues: false,
        includeExpectedValues: false,
      );

      final result = ef.ErrorFormatter.formatError(error, config);
      expect(result, 'Custom message');
    });

    test('formatError should use default formatter when available', () {
      const error = ValidationError(
        code: 'unknown_error',
        message: 'Test message',
        path: ['field'],
        received: 'value',
        expected: 'string',
      );

      final config = ef.ErrorFormatConfig(
        defaultFormatter: (error) => 'Default: ${error.message}',
      );

      final result = ef.ErrorFormatter.formatError(error, config);
      expect(result, 'Default: Test message');
    });

    test('formatError should build formatted message with all components', () {
      const error = ValidationError(
        code: 'test_error',
        message: 'Test message',
        path: ['user', 'name'],
        received: 'invalid',
        expected: 'string',
        context: {'min': 5, 'max': 10},
      );

      const config = ef.ErrorFormatConfig(
        includeErrorCodes: true,
        includeErrorPaths: true,
        includeReceivedValues: true,
        includeExpectedValues: true,
        includeContext: true,
        pathSeparator: '.',
      );

      final result = ef.ErrorFormatter.formatError(error, config);
      expect(result, contains('[user.name]'));
      expect(result, contains('Test message'));
      expect(result, contains('(received: "invalid")'));
      expect(result, contains('(expected: string)'));
      expect(result, contains('[test_error]'));
      expect(result, contains('(context: {min: 5, max: 10})'));
    });

    test('formatError should handle empty path', () {
      const error = ValidationError(
        code: 'test_error',
        message: 'Test message',
        path: [],
        received: 'value',
        expected: 'string',
      );

      const config = ef.ErrorFormatConfig(includeErrorPaths: true);

      final result = ef.ErrorFormatter.formatError(error, config);
      expect(result, isNot(contains('[]')));
    });

    test('formatError should handle empty expected', () {
      const error = ValidationError(
        code: 'test_error',
        message: 'Test message',
        path: ['field'],
        received: 'value',
        expected: '',
      );

      const config = ef.ErrorFormatConfig(includeExpectedValues: true);

      final result = ef.ErrorFormatter.formatError(error, config);
      expect(result, isNot(contains('(expected:')));
    });

    test('formatError should handle null context', () {
      const error = ValidationError(
        code: 'test_error',
        message: 'Test message',
        path: ['field'],
        received: 'value',
        expected: 'string',
        context: null,
      );

      const config = ef.ErrorFormatConfig(includeContext: true);

      final result = ef.ErrorFormatter.formatError(error, config);
      expect(result, isNot(contains('(context:')));
    });

    test('formatError should handle empty context', () {
      const error = ValidationError(
        code: 'test_error',
        message: 'Test message',
        path: ['field'],
        received: 'value',
        expected: 'string',
        context: {},
      );

      const config = ef.ErrorFormatConfig(includeContext: true);

      final result = ef.ErrorFormatter.formatError(error, config);
      expect(result, isNot(contains('(context:')));
    });

    test('formatErrors should handle empty error collection', () {
      const errors = ValidationErrorCollection([]);

      final result = ef.ErrorFormatter.formatErrors(errors);
      expect(result, 'No validation errors');
    });

    test('formatErrors should sort by path when enabled', () {
      const errors = ValidationErrorCollection([
        ValidationError(
            message: 'Error 1', path: ['z'], received: 1, expected: 'valid'),
        ValidationError(
            message: 'Error 2', path: ['a'], received: 2, expected: 'valid'),
        ValidationError(
            message: 'Error 3', path: ['m'], received: 3, expected: 'valid'),
      ]);

      const config = ef.ErrorFormatConfig(
        sortByPath: true,
        includeErrorCodes: false,
        includeErrorPaths: false,
        includeReceivedValues: false,
        includeExpectedValues: false,
      );

      final result = ef.ErrorFormatter.formatErrors(errors, config);
      final lines = result.split('\n');
      expect(lines[0], 'Error 2'); // path ['a']
      expect(lines[1], 'Error 3'); // path ['m']
      expect(lines[2], 'Error 1'); // path ['z']
    });

    test('formatErrors should group by path when enabled', () {
      const errors = ValidationErrorCollection([
        ValidationError(
            message: 'Error 1',
            path: ['user', 'name'],
            received: 1,
            expected: 'valid'),
        ValidationError(
            message: 'Error 2',
            path: ['user', 'email'],
            received: 2,
            expected: 'valid'),
        ValidationError(
            message: 'Error 3',
            path: ['user', 'name'],
            received: 3,
            expected: 'valid'),
      ]);

      const config = ef.ErrorFormatConfig(groupByPath: true);

      final result = ef.ErrorFormatter.formatErrors(errors, config);
      expect(result, contains('user.name:'));
      expect(result, contains('user.email:'));
    });

    test('formatErrorsAsJson should return proper JSON structure', () {
      const errors = ValidationErrorCollection([
        ValidationError(
          code: 'test_error',
          message: 'Test message',
          path: ['field'],
          received: 'value',
          expected: 'string',
          context: {'info': 'test'},
        ),
      ]);

      final result = ef.ErrorFormatter.formatErrorsAsJson(errors);

      expect(result, isA<Map<String, dynamic>>());
      expect(result['errors'], isA<List>());
      expect(result['count'], 1);
      expect(result['formatted'], isA<String>());

      final errorData =
          (result['errors'] as List).first as Map<String, dynamic>;
      expect(errorData['message'], 'Test message');
      expect(errorData['path'], ['field']);
      expect(errorData['received'], 'value');
      expect(errorData['expected'], 'string');
      expect(errorData['code'], 'test_error');
      expect(errorData['context'], {'info': 'test'});
    });

    test('formatErrorsAsJson should handle null code', () {
      const errors = ValidationErrorCollection([
        ValidationError(
          message: 'Test message',
          path: ['field'],
          received: 'value',
          expected: 'string',
        ),
      ]);

      final result = ef.ErrorFormatter.formatErrorsAsJson(errors);
      final errorData =
          (result['errors'] as List).first as Map<String, dynamic>;
      expect(errorData['code'], isNull);
    });

    test('formatErrorsAsJson should handle null/empty context', () {
      const errors1 = ValidationErrorCollection([
        ValidationError(
          message: 'Test message',
          path: ['field'],
          received: 'value',
          expected: 'string',
          context: null,
        ),
      ]);

      final result1 = ef.ErrorFormatter.formatErrorsAsJson(errors1);
      final errorData1 =
          (result1['errors'] as List).first as Map<String, dynamic>;
      expect(errorData1.containsKey('context'), false);

      const errors2 = ValidationErrorCollection([
        ValidationError(
          message: 'Test message',
          path: ['field'],
          received: 'value',
          expected: 'string',
          context: {},
        ),
      ]);

      final result2 = ef.ErrorFormatter.formatErrorsAsJson(errors2);
      final errorData2 =
          (result2['errors'] as List).first as Map<String, dynamic>;
      expect(errorData2.containsKey('context'), false);
    });

    test('formatErrorsAsStructured should group by path by default', () {
      const errors = ValidationErrorCollection([
        ValidationError(
            message: 'Error 1',
            path: ['user', 'name'],
            received: 1,
            expected: 'valid'),
        ValidationError(
            message: 'Error 2',
            path: ['user', 'email'],
            received: 2,
            expected: 'valid'),
        ValidationError(
            message: 'Error 3',
            path: ['user', 'name'],
            received: 3,
            expected: 'valid'),
      ]);

      final result = ef.ErrorFormatter.formatErrorsAsStructured(errors);

      expect(result.keys, containsAll(['user.name', 'user.email']));
      expect(result['user.name']!.length, 2);
      expect(result['user.email']!.length, 1);
    });

    test('formatErrorsAsStructured should use custom grouping function', () {
      const errors = ValidationErrorCollection([
        ValidationError(
            code: 'type_error',
            message: 'Error 1',
            path: ['field1'],
            received: 1,
            expected: 'valid'),
        ValidationError(
            code: 'type_error',
            message: 'Error 2',
            path: ['field2'],
            received: 2,
            expected: 'valid'),
        ValidationError(
            code: 'range_error',
            message: 'Error 3',
            path: ['field3'],
            received: 3,
            expected: 'valid'),
      ]);

      final config = ef.ErrorFormatConfig(
        groupingFunction: (error) => error.code ?? 'unknown',
      );

      final result = ef.ErrorFormatter.formatErrorsAsStructured(errors, config);

      expect(result.keys, containsAll(['type_error', 'range_error']));
      expect(result['type_error']!.length, 2);
      expect(result['range_error']!.length, 1);
    });

    test('formatErrorsForHumans should handle empty errors', () {
      const errors = ValidationErrorCollection([]);

      final result = ef.ErrorFormatter.formatErrorsForHumans(errors);
      expect(result, 'All validations passed successfully!');
    });

    test('formatErrorsForHumans should use human-friendly config', () {
      const errors = ValidationErrorCollection([
        ValidationError(
          code: 'test_error',
          message: 'Test message',
          path: ['user', 'name'],
          received: 'value',
          expected: 'string',
          context: {'info': 'test'},
        ),
      ]);

      final result = ef.ErrorFormatter.formatErrorsForHumans(errors);

      expect(result, contains('[user → name]'));
      expect(result, contains('Test message'));
      expect(result, isNot(contains('[test_error]')));
      expect(result, isNot(contains('(received:')));
      expect(result, isNot(contains('(expected:')));
      expect(result, isNot(contains('(context:')));
    });

    test('formatErrorsCompact should handle empty errors', () {
      const errors = ValidationErrorCollection([]);

      final result = ef.ErrorFormatter.formatErrorsCompact(errors);
      expect(result, 'Valid');
    });

    test('formatErrorsCompact should use compact config', () {
      const errors = ValidationErrorCollection([
        ValidationError(
          code: 'test_error',
          message: 'Error 1',
          path: ['field1'],
          received: 'value1',
          expected: 'valid',
        ),
        ValidationError(
          code: 'test_error',
          message: 'Error 2',
          path: ['field2'],
          received: 'value2',
          expected: 'valid',
        ),
      ]);

      final result = ef.ErrorFormatter.formatErrorsCompact(errors);

      expect(result, 'Error 1; Error 2');
      expect(result, isNot(contains('[')));
      expect(result, isNot(contains('(received:')));
      expect(result, isNot(contains('(expected:')));
    });

    test('formatErrorsGroupedByPath should group errors by path', () {
      const errors = ValidationErrorCollection([
        ValidationError(
            message: 'Error 1',
            path: ['user', 'name'],
            received: 1,
            expected: 'valid'),
        ValidationError(
            message: 'Error 2',
            path: ['user', 'email'],
            received: 2,
            expected: 'valid'),
        ValidationError(
            message: 'Error 3',
            path: ['user', 'name'],
            received: 3,
            expected: 'valid'),
        ValidationError(
            message: 'Error 4', path: [], received: 4, expected: 'valid'),
      ]);

      final result = ef.ErrorFormatter.formatErrorsGroupedByPath(errors);

      expect(result.keys, containsAll(['user.name', 'user.email', 'root']));
      expect(result['user.name'], ['Error 1', 'Error 3']);
      expect(result['user.email'], ['Error 2']);
      expect(result['root'], ['Error 4']);
    });

    test('formatErrorsGroupedByPath should use custom path separator', () {
      const errors = ValidationErrorCollection([
        ValidationError(
            message: 'Error 1',
            path: ['user', 'name'],
            received: 1,
            expected: 'valid'),
      ]);

      const config = ef.ErrorFormatConfig(pathSeparator: '->');
      final result =
          ef.ErrorFormatter.formatErrorsGroupedByPath(errors, config);

      expect(result.keys, contains('user->name'));
    });

    test('formatErrorsGroupedByCode should group errors by code', () {
      const errors = ValidationErrorCollection([
        ValidationError(
            code: 'type_error',
            message: 'Error 1',
            path: ['field1'],
            received: 1,
            expected: 'valid'),
        ValidationError(
            code: 'type_error',
            message: 'Error 2',
            path: ['field2'],
            received: 2,
            expected: 'valid'),
        ValidationError(
            code: 'range_error',
            message: 'Error 3',
            path: ['field3'],
            received: 3,
            expected: 'valid'),
        ValidationError(
            message: 'Error 4',
            path: ['field4'],
            received: 4,
            expected: 'valid'),
      ]);

      final result = ef.ErrorFormatter.formatErrorsGroupedByCode(errors);

      expect(
          result.keys, containsAll(['type_error', 'range_error', 'unknown']));
      expect(result['type_error']!.length, 2);
      expect(result['range_error']!.length, 1);
      expect(result['unknown']!.length, 1);
    });

    test('should format different value types correctly in error messages', () {
      // Test null value formatting
      const errorNull = ValidationError(
        message: 'Test message',
        path: ['field'],
        received: null,
        expected: 'string',
      );
      final resultNull = ef.ErrorFormatter.formatError(errorNull);
      expect(resultNull, contains('(received: null)'));

      // Test string value formatting
      const errorString = ValidationError(
        message: 'Test message',
        path: ['field'],
        received: 'hello',
        expected: 'string',
      );
      final resultString = ef.ErrorFormatter.formatError(errorString);
      expect(resultString, contains('(received: "hello")'));

      // Test number value formatting
      const errorNumber = ValidationError(
        message: 'Test message',
        path: ['field'],
        received: 42,
        expected: 'string',
      );
      final resultNumber = ef.ErrorFormatter.formatError(errorNumber);
      expect(resultNumber, contains('(received: 42)'));

      // Test boolean value formatting
      const errorBool = ValidationError(
        message: 'Test message',
        path: ['field'],
        received: true,
        expected: 'string',
      );
      final resultBool = ef.ErrorFormatter.formatError(errorBool);
      expect(resultBool, contains('(received: true)'));

      // Test list value formatting
      const errorList = ValidationError(
        message: 'Test message',
        path: ['field'],
        received: [1, 2, 3],
        expected: 'string',
      );
      final resultList = ef.ErrorFormatter.formatError(errorList);
      expect(resultList, contains('[3 items]'));

      // Test map value formatting
      const errorMap = ValidationError(
        message: 'Test message',
        path: ['field'],
        received: {'a': 1, 'b': 2},
        expected: 'string',
      );
      final resultMap = ef.ErrorFormatter.formatError(errorMap);
      expect(resultMap, contains('{2 entries}'));
    });

    test('should serialize different value types correctly in JSON output', () {
      // Test JSON serialization through formatErrorsAsJson
      const errors = ValidationErrorCollection([
        ValidationError(
          message: 'Test message',
          path: ['field'],
          received: {
            'nested': [1, 'hello', null],
            'simple': true
          },
          expected: 'string',
        ),
      ]);

      final result = ef.ErrorFormatter.formatErrorsAsJson(errors);
      final errorData =
          (result['errors'] as List).first as Map<String, dynamic>;
      final receivedData = errorData['received'] as Map<String, dynamic>;

      expect(receivedData['nested'], [1, 'hello', null]);
      expect(receivedData['simple'], true);
    });

    test('should use global config when no config provided', () {
      const error = ValidationError(
        message: 'Test message',
        path: ['field'],
        received: 'value',
        expected: 'string',
      );

      ef.ErrorFormatter.setGlobalConfig(const ef.ErrorFormatConfig(
        includeErrorPaths: false,
        includeReceivedValues: false,
        includeExpectedValues: false,
      ));

      final result = ef.ErrorFormatter.formatError(error);
      expect(result, 'Test message');
      expect(result, isNot(contains('[')));
      expect(result, isNot(contains('(received:')));
      expect(result, isNot(contains('(expected:')));
    });
  });

  group('ErrorFormatPresets', () {
    test('minimal should have minimal configuration', () {
      expect(ef.ErrorFormatPresets.minimal.includeErrorCodes, false);
      expect(ef.ErrorFormatPresets.minimal.includeErrorPaths, false);
      expect(ef.ErrorFormatPresets.minimal.includeReceivedValues, false);
      expect(ef.ErrorFormatPresets.minimal.includeExpectedValues, false);
      expect(ef.ErrorFormatPresets.minimal.includeContext, false);
    });

    test('detailed should have detailed configuration', () {
      expect(ef.ErrorFormatPresets.detailed.includeErrorCodes, true);
      expect(ef.ErrorFormatPresets.detailed.includeErrorPaths, true);
      expect(ef.ErrorFormatPresets.detailed.includeReceivedValues, true);
      expect(ef.ErrorFormatPresets.detailed.includeExpectedValues, true);
      expect(ef.ErrorFormatPresets.detailed.includeContext, true);
    });

    test('humanFriendly should have human-friendly configuration', () {
      expect(ef.ErrorFormatPresets.humanFriendly.includeErrorCodes, false);
      expect(ef.ErrorFormatPresets.humanFriendly.includeErrorPaths, true);
      expect(ef.ErrorFormatPresets.humanFriendly.includeReceivedValues, false);
      expect(ef.ErrorFormatPresets.humanFriendly.includeExpectedValues, false);
      expect(ef.ErrorFormatPresets.humanFriendly.includeContext, false);
      expect(ef.ErrorFormatPresets.humanFriendly.pathSeparator, ' → ');
    });

    test('developer should have developer configuration', () {
      expect(ef.ErrorFormatPresets.developer.includeErrorCodes, true);
      expect(ef.ErrorFormatPresets.developer.includeErrorPaths, true);
      expect(ef.ErrorFormatPresets.developer.includeReceivedValues, true);
      expect(ef.ErrorFormatPresets.developer.includeExpectedValues, true);
      expect(ef.ErrorFormatPresets.developer.includeContext, true);
      expect(ef.ErrorFormatPresets.developer.groupByPath, true);
      expect(ef.ErrorFormatPresets.developer.sortByPath, true);
    });

    test('compact should have compact configuration', () {
      expect(ef.ErrorFormatPresets.compact.includeErrorCodes, false);
      expect(ef.ErrorFormatPresets.compact.includeErrorPaths, false);
      expect(ef.ErrorFormatPresets.compact.includeReceivedValues, false);
      expect(ef.ErrorFormatPresets.compact.includeExpectedValues, false);
      expect(ef.ErrorFormatPresets.compact.includeContext, false);
    });

    test('json should have json configuration', () {
      expect(ef.ErrorFormatPresets.json.includeErrorCodes, true);
      expect(ef.ErrorFormatPresets.json.includeErrorPaths, true);
      expect(ef.ErrorFormatPresets.json.includeReceivedValues, true);
      expect(ef.ErrorFormatPresets.json.includeExpectedValues, true);
      expect(ef.ErrorFormatPresets.json.includeContext, true);
      expect(ef.ErrorFormatPresets.json.groupByPath, true);
    });
  });

  group('ErrorMessages', () {
    tearDown(() {
      ef.ErrorMessages.clearMessages();
    });

    test('should set and get single message', () {
      ef.ErrorMessages.setMessage('test_error', 'Test message');

      expect(ef.ErrorMessages.getMessage('test_error'), 'Test message');
      expect(ef.ErrorMessages.hasMessage('test_error'), true);
      expect(ef.ErrorMessages.hasMessage('unknown_error'), false);
    });

    test('should set multiple messages', () {
      ef.ErrorMessages.setMessages({
        'error1': 'Message 1',
        'error2': 'Message 2',
      });

      expect(ef.ErrorMessages.getMessage('error1'), 'Message 1');
      expect(ef.ErrorMessages.getMessage('error2'), 'Message 2');
      expect(ef.ErrorMessages.hasMessage('error1'), true);
      expect(ef.ErrorMessages.hasMessage('error2'), true);
    });

    test('should remove message', () {
      ef.ErrorMessages.setMessage('test_error', 'Test message');
      expect(ef.ErrorMessages.hasMessage('test_error'), true);

      ef.ErrorMessages.removeMessage('test_error');
      expect(ef.ErrorMessages.hasMessage('test_error'), false);
      expect(ef.ErrorMessages.getMessage('test_error'), isNull);
    });

    test('should clear all messages', () {
      ef.ErrorMessages.setMessages({
        'error1': 'Message 1',
        'error2': 'Message 2',
      });

      expect(ef.ErrorMessages.getAllMessages().length, 2);

      ef.ErrorMessages.clearMessages();
      expect(ef.ErrorMessages.getAllMessages().length, 0);
    });

    test('should get all messages as unmodifiable map', () {
      ef.ErrorMessages.setMessages({
        'error1': 'Message 1',
        'error2': 'Message 2',
      });

      final messages = ef.ErrorMessages.getAllMessages();
      expect(messages, {
        'error1': 'Message 1',
        'error2': 'Message 2',
      });

      // Should be unmodifiable
      expect(() => messages['error3'] = 'Message 3', throwsUnsupportedError);
    });

    test('should handle null return for unknown error', () {
      expect(ef.ErrorMessages.getMessage('unknown_error'), isNull);
    });
  });

  group('ValidationErrorFormatting extension', () {
    test('format should use ErrorFormatter.formatError', () {
      const error = ValidationError(
        message: 'Test message',
        path: ['field'],
        received: 'value',
        expected: 'string',
      );

      final result = error.format();
      expect(result, contains('Test message'));
    });

    test('format should use provided config', () {
      const error = ValidationError(
        message: 'Test message',
        path: ['field'],
        received: 'value',
        expected: 'string',
      );

      const config = ef.ErrorFormatConfig(includeReceivedValues: false);
      final result = error.format(config);
      expect(result, isNot(contains('(received:')));
    });

    test('formatForHumans should use human-friendly config', () {
      const error = ValidationError(
        code: 'test_error',
        message: 'Test message',
        path: ['user', 'name'],
        received: 'value',
        expected: 'string',
        context: {'info': 'test'},
      );

      final result = error.formatForHumans();
      expect(result, contains('[user → name]'));
      expect(result, contains('Test message'));
      expect(result, isNot(contains('[test_error]')));
      expect(result, isNot(contains('(received:')));
    });

    test('formatCompact should use compact config', () {
      const error = ValidationError(
        code: 'test_error',
        message: 'Test message',
        path: ['field'],
        received: 'value',
        expected: 'string',
      );

      final result = error.formatCompact();
      expect(result, 'Test message');
      expect(result, isNot(contains('[')));
      expect(result, isNot(contains('(received:')));
    });

    test('toJson should return proper JSON structure', () {
      const error = ValidationError(
        code: 'test_error',
        message: 'Test message',
        path: ['field'],
        received: 'value',
        expected: 'string',
        context: {'info': 'test'},
      );

      final json = error.toJson();
      expect(json['message'], 'Test message');
      expect(json['path'], ['field']);
      expect(json['received'], 'value');
      expect(json['expected'], 'string');
      expect(json['code'], 'test_error');
      expect(json['context'], {'info': 'test'});
    });
  });

  group('ValidationErrorCollectionFormatting extension', () {
    late ValidationErrorCollection errors;

    setUp(() {
      errors = const ValidationErrorCollection([
        ValidationError(
          code: 'test_error',
          message: 'Error 1',
          path: ['field1'],
          received: 'value1',
          expected: 'valid',
        ),
        ValidationError(
          code: 'test_error',
          message: 'Error 2',
          path: ['field2'],
          received: 'value2',
          expected: 'valid',
        ),
      ]);
    });

    test('format should use ErrorFormatter.formatErrors', () {
      final result = errors.format();
      expect(result, contains('Error 1'));
      expect(result, contains('Error 2'));
    });

    test('formatForHumans should use ErrorFormatter.formatErrorsForHumans', () {
      final result = errors.formatForHumans();
      expect(result, contains('Error 1'));
      expect(result, isNot(contains('[test_error]')));
    });

    test('formatCompact should use ErrorFormatter.formatErrorsCompact', () {
      final result = errors.formatCompact();
      expect(result, 'Error 1; Error 2');
    });

    test('toJsonFormat should use ErrorFormatter.formatErrorsAsJson', () {
      final result = errors.toJsonFormat();
      expect(result, isA<Map<String, dynamic>>());
      expect(result['count'], 2);
      expect(result['errors'], isA<List>());
    });

    test('toStructured should use ErrorFormatter.formatErrorsAsStructured', () {
      final result = errors.toStructured();
      expect(result, isA<Map<String, List<Map<String, dynamic>>>>());
      expect(result.keys, containsAll(['field1', 'field2']));
    });

    test('groupByPath should use ErrorFormatter.formatErrorsGroupedByPath', () {
      final result = errors.groupByPath();
      expect(result, isA<Map<String, List<String>>>());
      expect(result.keys, containsAll(['field1', 'field2']));
    });

    test('groupByCode should use ErrorFormatter.formatErrorsGroupedByCode', () {
      final result = errors.groupByCode();
      expect(result, isA<Map<String, List<String>>>());
      expect(result.keys, contains('test_error'));
      expect(result['test_error']!.length, 2);
    });

    test('all methods should accept optional config', () {
      const config = ef.ErrorFormatConfig(includeErrorCodes: false);

      final formatResult = errors.format(config);
      final humanResult = errors.formatForHumans(config);
      final compactResult = errors.formatCompact(config);
      final jsonResult = errors.toJsonFormat(config);
      final structuredResult = errors.toStructured(config);
      final pathResult = errors.groupByPath(config);
      final codeResult = errors.groupByCode(config);

      expect(formatResult, isNot(contains('[test_error]')));
      expect(humanResult, isA<String>());
      expect(compactResult, isA<String>());
      expect(jsonResult, isA<Map<String, dynamic>>());
      expect(structuredResult, isA<Map<String, List<Map<String, dynamic>>>>());
      expect(pathResult, isA<Map<String, List<String>>>());
      expect(codeResult, isA<Map<String, List<String>>>());
    });
  });

  group('Private Method Coverage', () {
    // Test class to trigger fallback toString() paths in _formatValue and _serializeValue
    test('should handle custom objects in error formatting', () {
      // Create a custom object that will trigger the fallback toString() case
      // in _formatValue (line 413) and _serializeValue (line 424)
      final customObject = DateTime.now();
      
      final error = ValidationError(
        message: 'Test error with custom object',
        path: ['field'],
        received: customObject,
        expected: 'string',
        code: 'test_error',
      );
      
      // This should trigger _formatValue's fallback toString() case
      final formatted = ef.ErrorFormatter.formatError(error);
      expect(formatted, contains(customObject.toString()));
      
      // This should trigger _serializeValue's fallback toString() case
      final json = error.toJson();
      expect(json['received'], equals(customObject.toString()));
    });

    test('should handle custom class objects in error formatting', () {
      // Create a custom class to trigger fallback cases
      final customObject = Uri.parse('https://example.com');
      
      final error = ValidationError(
        message: 'Test error with URI object',
        path: ['url'],
        received: customObject,
        expected: 'string',
        code: 'invalid_url',
      );
      
      final formatted = ef.ErrorFormatter.formatError(error);
      expect(formatted, contains('https://example.com'));
      
      final json = error.toJson();
      expect(json['received'], equals('https://example.com'));
    });

    test('should handle Duration objects in error formatting', () {
      // Test with Duration object to trigger toString() fallback
      final duration = Duration(hours: 2, minutes: 30);
      
      final error = ValidationError(
        message: 'Invalid duration',
        path: ['timeout'],
        received: duration,
        expected: 'number',
        code: 'invalid_duration',
      );
      
      final formatted = ef.ErrorFormatter.formatError(error);
      expect(formatted, contains(duration.toString()));
      
      final json = error.toJson();
      expect(json['received'], equals(duration.toString()));
    });

    test('should handle RegExp objects in error formatting', () {
      // Test with RegExp object to trigger toString() fallback
      final regex = RegExp(r'^\d+$');
      
      final error = ValidationError(
        message: 'Pattern mismatch',
        path: ['pattern'],
        received: regex,
        expected: 'string',
        code: 'pattern_error',
      );
      
      final formatted = ef.ErrorFormatter.formatError(error);
      expect(formatted, contains(regex.toString()));
      
      final json = error.toJson();
      expect(json['received'], equals(regex.toString()));
    });
  });
}
