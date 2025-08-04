import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('BooleanSchema', () {
    group('Basic validation', () {
      test('should validate true', () {
        const schema = BooleanSchema();
        final result = schema.validate(true);
        expect(result.isSuccess, true);
        expect(result.data, true);
      });

      test('should validate false', () {
        const schema = BooleanSchema();
        final result = schema.validate(false);
        expect(result.isSuccess, true);
        expect(result.data, false);
      });

      test('should reject non-boolean values', () {
        const schema = BooleanSchema();
        final result = schema.validate('not a boolean');
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.code, 'type_mismatch');
        expect(result.errors!.errors.first.expected, 'boolean');
        expect(result.errors!.errors.first.received, 'not a boolean');
      });

      test('should reject null', () {
        const schema = BooleanSchema();
        final result = schema.validate(null);
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.code, 'type_mismatch');
        expect(result.errors!.errors.first.expected, 'boolean');
      });

      test('should reject number', () {
        const schema = BooleanSchema();
        final result = schema.validate(123);
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.code, 'type_mismatch');
        expect(result.errors!.errors.first.expected, 'boolean');
      });
    });

    group('Expected value validation', () {
      test('should validate expected true value', () {
        const schema = BooleanSchema(expectedValue: true);
        final result = schema.validate(true);
        expect(result.isSuccess, true);
        expect(result.data, true);
      });

      test('should validate expected false value', () {
        const schema = BooleanSchema(expectedValue: false);
        final result = schema.validate(false);
        expect(result.isSuccess, true);
        expect(result.data, false);
      });

      test('should reject unexpected true value when expecting false', () {
        const schema = BooleanSchema(expectedValue: false);
        final result = schema.validate(true);
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.code, 'unexpected_boolean_value');
        expect(result.errors!.errors.first.received, true);
        expect(result.errors!.errors.first.context,
            {'expected': false, 'actual': true});
      });

      test('should reject unexpected false value when expecting true', () {
        const schema = BooleanSchema(expectedValue: true);
        final result = schema.validate(false);
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.code, 'unexpected_boolean_value');
        expect(result.errors!.errors.first.received, false);
        expect(result.errors!.errors.first.context,
            {'expected': true, 'actual': false});
      });
    });

    group('Convenience getters', () {
      test('trueValue should create schema expecting true', () {
        final schema = const BooleanSchema().trueValue;
        expect(schema.validate(true).isSuccess, true);
        expect(schema.validate(false).isFailure, true);
      });

      test('falseValue should create schema expecting false', () {
        final schema = const BooleanSchema().falseValue;
        expect(schema.validate(false).isSuccess, true);
        expect(schema.validate(true).isFailure, true);
      });

      test('trueValue should preserve description and metadata', () {
        final schema = const BooleanSchema(
          description: 'test description',
          metadata: {'key': 'value'},
        ).trueValue;
        expect(schema.description, 'test description');
        expect(schema.metadata, {'key': 'value'});
      });

      test('falseValue should preserve description and metadata', () {
        final schema = const BooleanSchema(
          description: 'test description',
          metadata: {'key': 'value'},
        ).falseValue;
        expect(schema.description, 'test description');
        expect(schema.metadata, {'key': 'value'});
      });
    });

    group('Validation methods', () {
      test('isTrue should validate true values', () {
        final schema = const BooleanSchema().isTrue();
        expect(schema.validate(true).isSuccess, true);
        expect(schema.validate(false).isFailure, true);
      });

      test('isFalse should validate false values', () {
        final schema = const BooleanSchema().isFalse();
        expect(schema.validate(false).isSuccess, true);
        expect(schema.validate(true).isFailure, true);
      });

      test('truthy should validate true values', () {
        final schema = const BooleanSchema().truthy();
        expect(schema.validate(true).isSuccess, true);
        expect(schema.validate(false).isFailure, true);
      });

      test('falsy should validate false values', () {
        final schema = const BooleanSchema().falsy();
        expect(schema.validate(false).isSuccess, true);
        expect(schema.validate(true).isFailure, true);
      });

      test('isTrue should provide proper error message', () {
        final schema = const BooleanSchema().isTrue();
        final result = schema.validate(false);
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.message, 'must be true');
        expect(result.errors!.errors.first.code, 'not_true');
      });

      test('isFalse should provide proper error message', () {
        final schema = const BooleanSchema().isFalse();
        final result = schema.validate(true);
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.message, 'must be false');
        expect(result.errors!.errors.first.code, 'not_false');
      });

      test('truthy should provide proper error message', () {
        final schema = const BooleanSchema().truthy();
        final result = schema.validate(false);
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.message, 'must be truthy');
        expect(result.errors!.errors.first.code, 'not_truthy');
      });

      test('falsy should provide proper error message', () {
        final schema = const BooleanSchema().falsy();
        final result = schema.validate(true);
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.message, 'must be falsy');
        expect(result.errors!.errors.first.code, 'not_falsy');
      });
    });

    group('Constructor with metadata', () {
      test('should accept description', () {
        const schema = BooleanSchema(description: 'test description');
        expect(schema.description, 'test description');
      });

      test('should accept metadata', () {
        const schema = BooleanSchema(metadata: {'key': 'value'});
        expect(schema.metadata, {'key': 'value'});
      });

      test('should accept both description and metadata', () {
        const schema = BooleanSchema(
          description: 'test description',
          metadata: {'key': 'value'},
        );
        expect(schema.description, 'test description');
        expect(schema.metadata, {'key': 'value'});
      });

      test('should accept expectedValue with metadata', () {
        const schema = BooleanSchema(
          expectedValue: true,
          description: 'test description',
          metadata: {'key': 'value'},
        );
        expect(schema.description, 'test description');
        expect(schema.metadata, {'key': 'value'});
        expect(schema.validate(true).isSuccess, true);
        expect(schema.validate(false).isFailure, true);
      });
    });

    group('toString method', () {
      test('should return simple string for basic schema', () {
        const schema = BooleanSchema();
        expect(schema.toString(), 'BooleanSchema');
      });

      test('should include expected value in string representation', () {
        const schema = BooleanSchema(expectedValue: true);
        expect(schema.toString(), 'BooleanSchema (expected: true)');
      });

      test('should include expected false value in string representation', () {
        const schema = BooleanSchema(expectedValue: false);
        expect(schema.toString(), 'BooleanSchema (expected: false)');
      });

      test('should handle null expected value', () {
        const schema = BooleanSchema(expectedValue: null);
        expect(schema.toString(), 'BooleanSchema');
      });
    });

    group('Path validation', () {
      test('should include path in error messages', () {
        const schema = BooleanSchema();
        final result = schema.validate('invalid', ['nested', 'field']);
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.path, ['nested', 'field']);
      });

      test('should include path in constraint violation errors', () {
        const schema = BooleanSchema(expectedValue: true);
        final result = schema.validate(false, ['nested', 'field']);
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.path, ['nested', 'field']);
      });

      test('should handle empty path', () {
        const schema = BooleanSchema();
        final result = schema.validate('invalid', []);
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.path, []);
      });

      test('should handle default path', () {
        const schema = BooleanSchema();
        final result = schema.validate('invalid');
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.path, []);
      });
    });

    group('Integration with Z factory', () {
      test('should work with z.boolean()', () {
        final schema = z.boolean();
        expect(schema, isA<BooleanSchema>());
        expect(schema.validate(true).isSuccess, true);
        expect(schema.validate(false).isSuccess, true);
        expect(schema.validate('invalid').isFailure, true);
      });

      test('should work with z.trueValue', () {
        final schema = z.trueValue;
        expect(schema, isA<BooleanSchema>());
        expect(schema.validate(true).isSuccess, true);
        expect(schema.validate(false).isFailure, true);
      });

      test('should work with z.falseValue', () {
        final schema = z.falseValue;
        expect(schema, isA<BooleanSchema>());
        expect(schema.validate(false).isSuccess, true);
        expect(schema.validate(true).isFailure, true);
      });
    });

    group('Chaining with other schema methods', () {
      test('should work with optional', () {
        final schema = const BooleanSchema().optional();
        expect(schema.validate(true).isSuccess, true);
        expect(schema.validate(false).isSuccess, true);
        expect(schema.validate(null).isSuccess, true);
        expect(schema.validate('invalid').isFailure, true);
      });

      test('should work with default', () {
        final schema = const BooleanSchema().defaultTo(true);
        expect(schema.validate(true).isSuccess, true);
        expect(schema.validate(false).isSuccess, true);
        expect(schema.validate(null).data, true);
      });

      test('should work with transform', () {
        final schema =
            const BooleanSchema().transform((value) => value ? 'yes' : 'no');
        expect(schema.validate(true).data, 'yes');
        expect(schema.validate(false).data, 'no');
      });

      test('should work with refine', () {
        final schema = const BooleanSchema().refine(
          (value) => value == true,
          message: 'must be true',
        );
        expect(schema.validate(true).isSuccess, true);
        expect(schema.validate(false).isFailure, true);
      });
    });

    group('Complex scenarios', () {
      test('should handle nested object validation', () {
        final schema = z.object({
          'enabled': const BooleanSchema(),
          'active': const BooleanSchema(expectedValue: true),
        });

        final validResult = schema.validate({
          'enabled': true,
          'active': true,
        });
        expect(validResult.isSuccess, true);

        final invalidResult = schema.validate({
          'enabled': 'not a boolean',
          'active': false,
        });
        expect(invalidResult.isFailure, true);
        expect(invalidResult.errors!.errors.length, 2);
      });

      test('should handle array of booleans', () {
        final schema = z.array(const BooleanSchema());
        final validResult = schema.validate([true, false, true]);
        expect(validResult.isSuccess, true);

        final invalidResult = schema.validate([true, 'not a boolean', false]);
        expect(invalidResult.isFailure, true);
      });

      test('should work in union schemas', () {
        final schema = z.union<dynamic>([z.string(), const BooleanSchema()]);
        expect(schema.validate('hello').isSuccess, true);
        expect(schema.validate(true).isSuccess, true);
        expect(schema.validate(false).isSuccess, true);
        expect(schema.validate(123).isFailure, true);
      });
    });

    group('Error context', () {
      test('should provide context for constraint violations', () {
        const schema = BooleanSchema(expectedValue: true);
        final result = schema.validate(false);
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.context, {
          'expected': true,
          'actual': false,
        });
      });

      test('should provide correct constraint message', () {
        const schema = BooleanSchema(expectedValue: true);
        final result = schema.validate(false);
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.message,
            contains('value must be true'));
      });

      test('should provide correct constraint message for false', () {
        const schema = BooleanSchema(expectedValue: false);
        final result = schema.validate(true);
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.message,
            contains('value must be false'));
      });
    });

    group('Edge cases', () {
      test('should handle validation with different path types', () {
        const schema = BooleanSchema();
        final result = schema.validate('invalid', ['0', 'field', 'nested']);
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.path, ['0', 'field', 'nested']);
      });

      test('should handle very nested paths', () {
        const schema = BooleanSchema();
        final longPath = List.generate(100, (i) => 'field$i');
        final result = schema.validate('invalid', longPath);
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.path, longPath);
      });

      test('should handle empty constraint list in toString', () {
        const schema = BooleanSchema();
        final result = schema.toString();
        expect(result, 'BooleanSchema');
      });
    });
  });
}
