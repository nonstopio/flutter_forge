import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('ErrorContext', () {
    group('Basic Construction', () {
      test('should create basic error context', () {
        final context = ErrorContext(
          path: ['user', 'name'],
          schemaType: 'StringSchema',
          fieldName: 'name',
        );

        expect(context.path, ['user', 'name']);
        expect(context.schemaType, 'StringSchema');
        expect(context.fieldName, 'name');
        expect(context.depth, 0);
        expect(context.isAsync, false);
        expect(context.metadata, isEmpty);
        expect(context.parent, isNull);
      });

      test('should create context with all parameters', () {
        final timestamp = DateTime.now();
        final context = ErrorContext(
          path: ['data', 'items', '0'],
          schemaType: 'ArraySchema',
          fieldName: 'items',
          index: 0,
          key: 'data',
          metadata: {'version': '1.0'},
          depth: 2,
          isAsync: true,
          timestamp: timestamp,
          source: 'api_request',
          operation: 'create',
        );

        expect(context.path, ['data', 'items', '0']);
        expect(context.schemaType, 'ArraySchema');
        expect(context.fieldName, 'items');
        expect(context.index, 0);
        expect(context.key, 'data');
        expect(context.metadata, {'version': '1.0'});
        expect(context.depth, 2);
        expect(context.isAsync, true);
        expect(context.timestamp, timestamp);
        expect(context.source, 'api_request');
        expect(context.operation, 'create');
      });

      test('should create root context', () {
        final context = ErrorContext.root();

        expect(context.path, isEmpty);
        expect(context.isRoot, true);
        expect(context.depth, 0);
        expect(context.parent, isNull);
      });

      test('should create root context with metadata', () {
        final context = ErrorContext.root(
          source: 'user_input',
          operation: 'validate',
          metadata: {'component': 'form'},
        );

        expect(context.source, 'user_input');
        expect(context.operation, 'validate');
        expect(context.metadata, {'component': 'form'});
      });
    });

    group('Child Context Creation', () {
      late ErrorContext rootContext;

      setUp(() {
        rootContext = ErrorContext.root(
          source: 'test',
          operation: 'validate',
          metadata: {'base': 'metadata'},
        );
      });

      test('should create child context for field', () {
        final childContext = rootContext.forField(
          'username',
          schemaType: 'StringSchema',
          metadata: {'required': true},
        );

        expect(childContext.path, ['username']);
        expect(childContext.fieldName, 'username');
        expect(childContext.schemaType, 'StringSchema');
        expect(childContext.parent, rootContext);
        expect(childContext.depth, 1);
        expect(childContext.metadata, {'base': 'metadata', 'required': true});
        expect(childContext.source, 'test');
        expect(childContext.operation, 'validate');
      });

      test('should create child context for index', () {
        final childContext = rootContext.forIndex(
          2,
          schemaType: 'NumberSchema',
          metadata: {'position': 'third'},
        );

        expect(childContext.path, ['2']);
        expect(childContext.index, 2);
        expect(childContext.schemaType, 'NumberSchema');
        expect(childContext.parent, rootContext);
        expect(childContext.depth, 1);
        expect(
            childContext.metadata, {'base': 'metadata', 'position': 'third'});
      });

      test('should create child context for key', () {
        final childContext = rootContext.forKey(
          'user_id',
          schemaType: 'StringSchema',
          metadata: {'type': 'identifier'},
        );

        expect(childContext.path, ['user_id']);
        expect(childContext.key, 'user_id');
        expect(childContext.schemaType, 'StringSchema');
        expect(childContext.parent, rootContext);
        expect(childContext.depth, 1);
        expect(
            childContext.metadata, {'base': 'metadata', 'type': 'identifier'});
      });

      test('should create child context for nested validation', () {
        final childContext = rootContext.forNested(
          schemaType: 'ObjectSchema',
          metadata: {'nested': true},
        );

        expect(childContext.path, isEmpty);
        expect(childContext.schemaType, 'ObjectSchema');
        expect(childContext.parent, rootContext);
        expect(childContext.depth, 1);
        expect(childContext.metadata, {'base': 'metadata', 'nested': true});
      });
    });

    group('Context Modification', () {
      test('should create async context', () {
        final context = ErrorContext(path: ['test']);
        final asyncContext = context.asAsync();

        expect(asyncContext.isAsync, true);
        expect(asyncContext.path, ['test']);
        expect(context.isAsync, false); // Original unchanged
      });

      test('should create context with additional metadata', () {
        final context = ErrorContext(
          path: ['test'],
          metadata: {'existing': 'value'},
        );
        final contextWithMeta = context.withMetadata({'new': 'data'});

        expect(contextWithMeta.metadata, {'existing': 'value', 'new': 'data'});
        expect(context.metadata, {'existing': 'value'}); // Original unchanged
      });

      test('should override metadata with same keys', () {
        final context = ErrorContext(
          path: ['test'],
          metadata: {'key': 'old'},
        );
        final contextWithMeta = context.withMetadata({'key': 'new'});

        expect(contextWithMeta.metadata, {'key': 'new'});
      });
    });

    group('Context Properties', () {
      test('should compute full path correctly', () {
        final context = ErrorContext(path: ['user', 'profile', 'name']);
        expect(context.fullPath, 'user.profile.name');
      });

      test('should handle empty path', () {
        final context = ErrorContext(path: []);
        expect(context.fullPath, '');
      });

      test('should return breadcrumbs', () {
        final context = ErrorContext(path: ['a', 'b', 'c']);
        expect(context.breadcrumbs, ['a', 'b', 'c']);
      });

      test('should identify context types', () {
        final arrayContext = ErrorContext(path: ['0'], index: 0);
        final fieldContext = ErrorContext(path: ['name'], fieldName: 'name');
        final keyContext = ErrorContext(path: ['key'], key: 'key');
        final genericContext = ErrorContext(path: ['generic']);

        expect(arrayContext.isArrayElement, true);
        expect(arrayContext.isObjectField, false);
        expect(arrayContext.isMapKey, false);

        expect(fieldContext.isObjectField, true);
        expect(fieldContext.isArrayElement, false);
        expect(fieldContext.isMapKey, false);

        expect(keyContext.isMapKey, true);
        expect(keyContext.isObjectField, false);
        expect(keyContext.isArrayElement, false);

        expect(genericContext.isObjectField, false);
        expect(genericContext.isArrayElement, false);
        expect(genericContext.isMapKey, false);
      });

      test('should determine target type', () {
        final arrayContext = ErrorContext(path: ['0'], index: 0);
        final fieldContext = ErrorContext(path: ['name'], fieldName: 'name');
        final keyContext = ErrorContext(path: ['key'], key: 'key');
        final genericContext = ErrorContext(path: ['generic']);

        expect(arrayContext.targetType, 'array element');
        expect(fieldContext.targetType, 'object field');
        expect(keyContext.targetType, 'map key');
        expect(genericContext.targetType, 'value');
      });
    });

    group('Context Hierarchy', () {
      test('should build ancestor chain', () {
        final root = ErrorContext.root();
        final child1 = root.forField('user');
        final child2 = child1.forField('profile');
        final child3 = child2.forIndex(0);

        expect(child3.ancestors, [root, child1, child2]);
        expect(child2.ancestors, [root, child1]);
        expect(child1.ancestors, [root]);
        expect(root.ancestors, isEmpty);
      });

      test('should find root context', () {
        final root = ErrorContext.root();
        final child1 = root.forField('user');
        final child2 = child1.forField('profile');
        final child3 = child2.forIndex(0);

        expect(child3.root, root);
        expect(child2.root, root);
        expect(child1.root, root);
        expect(root.root, root);
      });

      test('should identify root context', () {
        final root = ErrorContext.root();
        final child = root.forField('user');

        expect(root.isRoot, true);
        expect(child.isRoot, false);
      });
    });

    group('Error Creation', () {
      late ErrorContext context;

      setUp(() {
        context = ErrorContext(
          path: ['user', 'email'],
          schemaType: 'StringSchema',
          fieldName: 'email',
          metadata: {'required': true},
          source: 'form',
          operation: 'validate',
        );
      });

      test('should create basic validation error', () {
        final error = context.createError(
          message: 'Invalid email format',
          received: 'not-an-email',
          expected: 'valid email',
          code: 'invalid_email',
        );

        expect(error.message, 'Invalid email format');
        expect(error.path, ['user', 'email']);
        expect(error.received, 'not-an-email');
        expect(error.expected, 'valid email');
        expect(error.code, 'invalid_email');
        expect(error.context?['schema_type'], 'StringSchema');
        expect(error.context?['field_name'], 'email');
        expect(error.context?['required'], true);
        expect(error.context?['source'], 'form');
        expect(error.context?['operation'], 'validate');
      });

      test('should create type mismatch error', () {
        final error = context.createTypeMismatchError(
          received: 123,
          expected: 'string',
          code: 'wrong_type',
        );

        expect(error.code, 'wrong_type');
        expect(error.received, 123);
        expect(error.expected, 'string');
        expect(error.path, ['user', 'email']);
        expect(error.context?['schema_type'], 'StringSchema');
      });

      test('should create type mismatch error with additional context', () {
        final error = context.createTypeMismatchError(
          received: 123,
          expected: 'string',
          code: 'wrong_type',
          additionalContext: {'extra': 'info'},
        );

        expect(error.code, 'wrong_type');
        expect(error.received, 123);
        expect(error.expected, 'string');
        expect(error.path, ['user', 'email']);
        expect(error.context?['schema_type'], 'StringSchema');
        expect(error.context?['extra'], 'info');
      });

      test('should create constraint violation error', () {
        final error = context.createConstraintViolationError(
          received: 'abc',
          constraint: 'minimum length of 5',
          code: 'too_short',
        );

        expect(error.code, 'too_short');
        expect(error.received, 'abc');
        expect(error.path, ['user', 'email']);
        expect(error.context?['schema_type'], 'StringSchema');
      });

      test('should create constraint violation error with additional context',
          () {
        final error = context.createConstraintViolationError(
          received: 'abc',
          constraint: 'minimum length of 5',
          code: 'too_short',
          additionalContext: {'constraint_value': 5},
        );

        expect(error.code, 'too_short');
        expect(error.received, 'abc');
        expect(error.path, ['user', 'email']);
        expect(error.context?['schema_type'], 'StringSchema');
        expect(error.context?['constraint_value'], 5);
      });

      test('should create error from ValidationErrorCode', () {
        final error = context.createErrorFromCode(
          errorCode: ValidationErrorCode.stringEmail,
          received: 'not-email',
          expected: 'valid email',
          message: 'Custom message',
        );

        expect(error.code, ValidationErrorCode.stringEmail.code);
        expect(error.received, 'not-email');
        expect(error.expected, 'valid email');
        expect(error.message, 'Custom message');
        expect(error.path, ['user', 'email']);
      });

      test(
          'should create error from ValidationErrorCode with additional context',
          () {
        final error = context.createErrorFromCode(
          errorCode: ValidationErrorCode.stringEmail,
          received: 'not-email',
          expected: 'valid email',
          message: 'Custom message',
          additionalContext: {'pattern': '@'},
        );

        expect(error.code, ValidationErrorCode.stringEmail.code);
        expect(error.received, 'not-email');
        expect(error.expected, 'valid email');
        expect(error.message, 'Custom message');
        expect(error.path, ['user', 'email']);
        expect(error.context?['pattern'], '@');
      });

      test('should include additional context in errors', () {
        final error = context.createError(
          message: 'Test error',
          received: 'test',
          additionalContext: {'custom': 'value'},
        );

        expect(error.context?['custom'], 'value');
        expect(error.context?['required'], true); // Original metadata preserved
      });
    });

    group('Context Description and Serialization', () {
      test('should generate human-readable description', () {
        final context = ErrorContext(
          path: ['user', 'profile', 'name'],
          schemaType: 'StringSchema',
          source: 'api_request',
          operation: 'create',
          depth: 2,
          isAsync: true,
        );

        final description = context.description;
        expect(description, contains('Source: api_request'));
        expect(description, contains('Operation: create'));
        expect(description, contains('Path: user.profile.name'));
        expect(description, contains('Schema: StringSchema'));
        expect(description, contains('Depth: 2'));
        expect(description, contains('Async validation'));
      });

      test('should generate description with minimal context', () {
        final context = ErrorContext(path: []);
        final description = context.description;
        expect(description, isEmpty);
      });

      test('should serialize to JSON', () {
        final context = ErrorContext(
          path: ['user', 'name'],
          schemaType: 'StringSchema',
          fieldName: 'name',
          metadata: {'required': true},
          depth: 1,
          source: 'form',
          operation: 'validate',
        );

        final json = context.toJson();
        expect(json['path'], ['user', 'name']);
        expect(json['schema_type'], 'StringSchema');
        expect(json['field_name'], 'name');
        expect(json['metadata'], {'required': true});
        expect(json['depth'], 1);
        expect(json['source'], 'form');
        expect(json['operation'], 'validate');
        expect(json['full_path'], 'user.name');
        expect(json['breadcrumbs'], ['user', 'name']);
        expect(json['target_type'], 'object field');
        expect(json['is_async'], false);
        expect(json['timestamp'], isA<String>());
        expect(json['description'], isA<String>());
      });

      test('should convert to string using description', () {
        final context = ErrorContext(
          path: ['test'],
          source: 'test_source',
        );

        expect(context.toString(), contains('Source: test_source'));
      });
    });

    group('Context Equality', () {
      test('should be equal for same contexts', () {
        final context1 = ErrorContext(
          path: ['user', 'name'],
          schemaType: 'StringSchema',
          fieldName: 'name',
          depth: 1,
          source: 'form',
          operation: 'validate',
        );

        final context2 = ErrorContext(
          path: ['user', 'name'],
          schemaType: 'StringSchema',
          fieldName: 'name',
          depth: 1,
          source: 'form',
          operation: 'validate',
        );

        expect(context1, equals(context2));
        expect(context1.hashCode, equals(context2.hashCode));
      });

      test('should not be equal for different contexts', () {
        final context1 = ErrorContext(path: ['user', 'name'], depth: 1);
        final context2 = ErrorContext(path: ['user', 'email'], depth: 1);

        expect(context1, isNot(equals(context2)));
      });

      test('should be equal to itself', () {
        final context = ErrorContext(path: ['test']);
        expect(context, equals(context));
      });
    });
  });

  group('ErrorContextBuilder', () {
    test('should build context with fluent API', () {
      final context = ErrorContextBuilder()
          .source('api')
          .operation('create')
          .metadata({'version': '1.0'})
          .async()
          .field('username', schemaType: 'StringSchema')
          .build();

      expect(context.source, 'api');
      expect(context.operation, 'create');
      expect(context.metadata, {'version': '1.0'});
      expect(context.isAsync, true);
      expect(context.fieldName, 'username');
      expect(context.schemaType, 'StringSchema');
      expect(context.path, ['username']);
    });

    test('should build context with initial context', () {
      final initial = ErrorContext.root(source: 'initial');
      final context = ErrorContextBuilder(initial)
          .operation('update')
          .field('name')
          .build();

      expect(context.source, 'initial');
      expect(context.operation, 'update');
      expect(context.fieldName, 'name');
    });

    test('should chain multiple field operations', () {
      final context = ErrorContextBuilder()
          .field('user')
          .field('profile')
          .index(0)
          .key('data')
          .build();

      expect(context.path, ['user', 'profile', '0', 'data']);
      expect(context.key, 'data');
      expect(context.depth, 4);
    });

    test('should support nested context', () {
      final context = ErrorContextBuilder()
          .source('test')
          .nested(schemaType: 'ObjectSchema')
          .build();

      expect(context.source, 'test');
      expect(context.schemaType, 'ObjectSchema');
      expect(context.depth, 1);
    });
  });

  group('ErrorContextManager', () {
    tearDown(() {
      ErrorContextManager.clearCurrentContext();
    });

    test('should manage global context', () {
      expect(ErrorContextManager.currentContext, isNull);

      final context = ErrorContext.root(source: 'global');
      ErrorContextManager.setCurrentContext(context);

      expect(ErrorContextManager.currentContext, context);

      ErrorContextManager.clearCurrentContext();
      expect(ErrorContextManager.currentContext, isNull);
    });

    test('should execute function with context', () {
      final context = ErrorContext.root(source: 'test');
      String? capturedSource;

      final result = ErrorContextManager.withContext(context, () {
        capturedSource = ErrorContextManager.currentContext?.source;
        return 'result';
      });

      expect(result, 'result');
      expect(capturedSource, 'test');
      expect(ErrorContextManager.currentContext, isNull);
    });

    test('should restore previous context after execution', () {
      final context1 = ErrorContext.root(source: 'first');
      final context2 = ErrorContext.root(source: 'second');

      ErrorContextManager.setCurrentContext(context1);

      ErrorContextManager.withContext(context2, () {
        expect(ErrorContextManager.currentContext?.source, 'second');
      });

      expect(ErrorContextManager.currentContext?.source, 'first');
    });

    test('should execute with new context from builder', () {
      final baseContext = ErrorContext.root(source: 'base');
      ErrorContextManager.setCurrentContext(baseContext);

      String? capturedSource;
      ErrorContextManager.withNewContext((current) {
        return current!.forField('test');
      }, () {
        capturedSource = ErrorContextManager.currentContext?.source;
        expect(ErrorContextManager.currentContext?.fieldName, 'test');
      });

      expect(capturedSource, 'base');
    });

    test('should create builder from current context', () {
      final context = ErrorContext.root(source: 'test');
      ErrorContextManager.setCurrentContext(context);

      final builder = ErrorContextManager.builder();
      final newContext = builder.operation('validate').build();

      expect(newContext.source, 'test');
      expect(newContext.operation, 'validate');
    });

    test('should create builder with base context', () {
      final baseContext = ErrorContext.root(source: 'base');
      final builder = ErrorContextManager.builder(baseContext);
      final newContext = builder.operation('test').build();

      expect(newContext.source, 'base');
      expect(newContext.operation, 'test');
    });
  });

  group('ErrorContextExtensions', () {
    test('should extract error context from ValidationError', () {
      final originalContext = ErrorContext(
        path: ['user', 'name'],
        schemaType: 'StringSchema',
        fieldName: 'name',
        metadata: {'required': true},
        depth: 1,
        isAsync: true,
        source: 'form',
        operation: 'validate',
      );

      final error = originalContext.createError(
        message: 'Test error',
        received: 'test',
      );

      final extractedContext = error.errorContext;
      expect(extractedContext, isNotNull);
      expect(extractedContext!.path, ['user', 'name']);
      expect(extractedContext.schemaType, 'StringSchema');
      expect(extractedContext.fieldName, 'name');
      expect(extractedContext.depth, 1);
      expect(extractedContext.isAsync, true);
      expect(extractedContext.source, 'form');
      expect(extractedContext.operation, 'validate');
    });

    test('should check if error has context', () {
      const errorWithContext = ValidationError(
        message: 'Test',
        path: [],
        received: 'test',
        expected: 'valid value',
        context: {'data': 'value'},
      );

      const errorWithoutContext = ValidationError(
        message: 'Test',
        path: [],
        received: 'test',
        expected: 'valid value',
      );

      expect(errorWithContext.hasContext, true);
      expect(errorWithoutContext.hasContext, false);
    });

    test('should extract context properties', () {
      final error = ErrorContext(
        path: ['test'],
        schemaType: 'StringSchema',
        source: 'api',
        operation: 'create',
        depth: 2,
        isAsync: true,
      ).createError(
        message: 'Test error',
        received: 'test',
      );

      expect(error.validationSource, 'api');
      expect(error.validationOperation, 'create');
      expect(error.schemaType, 'StringSchema');
      expect(error.validationDepth, 2);
      expect(error.isAsyncValidation, true);
      expect(error.targetType, 'value');
    });

    test('should handle missing context gracefully', () {
      const error = ValidationError(
        message: 'Test',
        path: [],
        received: 'test',
        expected: 'valid value',
      );

      expect(error.validationSource, isNull);
      expect(error.validationOperation, isNull);
      expect(error.schemaType, isNull);
      expect(error.validationDepth, 0);
      expect(error.isAsyncValidation, false);
      expect(error.targetType, isNull);
    });
  });

  group('Integration Tests', () {
    test('should work with nested validation contexts', () {
      final rootContext = ErrorContext.root(
        source: 'integration_test',
        operation: 'validate_user',
      );

      final userContext =
          rootContext.forField('user', schemaType: 'ObjectSchema');
      final profileContext =
          userContext.forField('profile', schemaType: 'ObjectSchema');
      final nameContext =
          profileContext.forField('name', schemaType: 'StringSchema');

      expect(nameContext.path, ['user', 'profile', 'name']);
      expect(nameContext.depth, 3);
      expect(nameContext.root, rootContext);
      expect(nameContext.ancestors, [rootContext, userContext, profileContext]);

      final error = nameContext.createError(
        message: 'Name is required',
        received: null,
      );

      expect(error.path, ['user', 'profile', 'name']);
      expect(error.context?['source'], 'integration_test');
      expect(error.context?['operation'], 'validate_user');
      expect(error.context?['depth'], 3);
    });

    test('should work with array validation contexts', () {
      final rootContext = ErrorContext.root();
      final arrayContext =
          rootContext.forField('items', schemaType: 'ArraySchema');
      final itemContext = arrayContext.forIndex(2, schemaType: 'ObjectSchema');
      final fieldContext =
          itemContext.forField('value', schemaType: 'StringSchema');

      expect(fieldContext.path, ['items', '2', 'value']);
      expect(fieldContext.fullPath, 'items.2.value');
      expect(fieldContext.depth, 3);

      final error = fieldContext.createError(
        message: 'Invalid value',
        received: 123,
        expected: 'string',
      );

      expect(error.path, ['items', '2', 'value']);
      expect(error.context?['depth'], 3);
    });

    test('should handle complex metadata inheritance', () {
      final rootContext = ErrorContext.root(
        metadata: {'session': 'abc123'},
      );

      final fieldContext = rootContext.forField(
        'data',
        metadata: {'required': true},
      );

      final nestedContext = fieldContext.forNested(
        metadata: {'validation': 'strict'},
      );

      expect(nestedContext.metadata, {
        'session': 'abc123',
        'required': true,
        'validation': 'strict',
      });

      final error = nestedContext.createError(
        message: 'Validation failed',
        received: 'test',
        additionalContext: {'custom': 'value'},
      );

      expect(error.context?['session'], 'abc123');
      expect(error.context?['required'], true);
      expect(error.context?['validation'], 'strict');
      expect(error.context?['custom'], 'value');
    });
  });
}
