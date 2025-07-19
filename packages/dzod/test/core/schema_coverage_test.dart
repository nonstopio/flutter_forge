import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('Schema Coverage Tests', () {
    group('Type getter', () {
      test('should return the correct type', () {
        final schema = z.string();
        expect(schema.type, equals(String));
        
        final numSchema = z.number();
        expect(numSchema.type, equals(num));
        
        final boolSchema = z.boolean();
        expect(boolSchema.type, equals(bool));
      });
    });

    group('defaultToComputed', () {
      test('should provide computed default value when input is null', () {
        var counter = 0;
        final schema = z.string().defaultToComputed(() {
          counter++;
          return 'default$counter';
        });

        final result1 = schema.validate(null);
        expect(result1.isSuccess, true);
        expect(result1.data, 'default1');

        final result2 = schema.validate(null);
        expect(result2.isSuccess, true);
        expect(result2.data, 'default2');
      });

      test('should provide computed default value when validation fails', () {
        final schema = z.string().defaultToComputed(() => 'computed');

        final result = schema.validate(123);
        expect(result.isSuccess, true);
        expect(result.data, 'computed');
      });

      test('should return valid value when validation succeeds', () {
        final schema = z.string().defaultToComputed(() => 'default');

        final result = schema.validate('valid');
        expect(result.isSuccess, true);
        expect(result.data, 'valid');
      });
    });

    group('fallback', () {
      test('should provide fallback value when validation fails', () {
        final schema = z.string().fallback('fallback');

        final result = schema.validate(123);
        expect(result.isSuccess, true);
        expect(result.data, 'fallback');
      });

      test('should return valid value when validation succeeds', () {
        final schema = z.string().fallback('fallback');

        final result = schema.validate('valid');
        expect(result.isSuccess, true);
        expect(result.data, 'valid');
      });
    });

    group('fallbackComputed', () {
      test('should provide computed fallback based on errors', () {
        final schema = z.string().fallbackComputed((errors) {
          return 'Error count: ${errors.errors.length}';
        });

        final result = schema.validate(123);
        expect(result.isSuccess, true);
        expect(result.data, startsWith('Error count:'));
      });

      test('should return valid value when validation succeeds', () {
        final schema = z.string().fallbackComputed((errors) => 'fallback');

        final result = schema.validate('valid');
        expect(result.isSuccess, true);
        expect(result.data, 'valid');
      });
    });

    group('preprocess', () {
      test('should preprocess input before validation', () {
        final schema = z.string().preprocess<dynamic>((input) {
          if (input is num) {
            return input.toString();
          }
          return input;
        });

        final result = schema.validate(123);
        expect(result.isSuccess, true);
        expect(result.data, '123');
      });

      test('should handle preprocessing errors', () {
        final schema = z.string().preprocess<dynamic>((input) {
          throw Exception('Preprocessing error');
        });

        final result = schema.validate('test');
        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.message, contains('Preprocessing failed'));
      });
    });

    group('postprocess', () {
      test('should postprocess output after validation', () {
        final schema = z.string().postprocess((value) => value.toUpperCase());

        final result = schema.validate('hello');
        expect(result.isSuccess, true);
        expect(result.data, 'HELLO');
      });

      test('should handle postprocessing errors', () {
        final schema = z.string().postprocess((value) {
          throw Exception('Postprocessing error');
        });

        final result = schema.validate('test');
        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.message, contains('Postprocessing failed'));
      });
    });

    group('toString methods', () {
      test('should format Schema toString correctly', () {
        final schema = z.string().describe('A test string');
        expect(schema.toString(), contains('A test string'));

        final schema2 = z.string();
        expect(schema2.schemaType, 'StringSchema');
        expect(schema2.toString(), contains('StringSchema'));
      });

      test('should format base Schema toString method', () {
        // Using TransformSchema which doesn't override toString
        final schema = z.string().transform((s) => s.toUpperCase());
        final result = schema.toString();
        expect(result, contains('TransformSchema'));
        expect(result, isNot(contains('()')));
      });

      test('should format DescribeSchema toString', () {
        final schema = z.string().describe('Test description');
        expect(schema.toString(), 'DescribeSchema(Test description)');
      });

      test('should format BrandedSchema toString', () {
        final schema = z.string().brand<String>();
        expect(schema.toString(), 'BrandedSchema<String, String>');
      });

      test('should format Branded toString', () {
        final schema = z.string().brand<String>();
        final result = schema.validate('test');
        expect(result.isSuccess, true);
        expect(result.data.toString(), 'Branded<String, String>(test)');
      });

      test('should format ReadonlySchema toString', () {
        final schema = z.string().readonly();
        expect(schema.toString(), 'ReadonlySchema<String>');
      });

      test('should format Readonly toString', () {
        final schema = z.string().readonly();
        final result = schema.validate('test');
        expect(result.isSuccess, true);
        expect(result.data.toString(), 'Readonly<String>(test)');
      });
    });

    group('TransformSchema error handling', () {
      test('should handle transformation errors in sync validate', () {
        final schema = z.string().transform<int>((value) {
          throw Exception('Transform failed');
        });

        final result = schema.validate('test');
        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.message, contains('Transformation failed'));
      });

      test('should handle transformation errors in async validate', () async {
        final schema = z.string().transform<int>((value) {
          throw Exception('Transform failed');
        });

        final result = await schema.validateAsync('test');
        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.message, contains('Transformation failed'));
      });

      test('should propagate validation failures in async', () async {
        final schema = z.string().transform<String>((value) => value.toUpperCase());

        final result = await schema.validateAsync(123);
        expect(result.isSuccess, false);
      });
    });

    group('AsyncTransformSchema', () {
      test('should propagate validation failures', () async {
        final schema = z.string().transformAsync<String>((value) async {
          await Future.delayed(Duration(milliseconds: 10));
          return value.toUpperCase();
        });

        final result = await schema.validateAsync(123);
        expect(result.isSuccess, false);
      });
    });

    group('RefineSchema async validation', () {
      test('should validate successfully with async refine', () async {
        final schema = z.string().refine((value) => value.length > 2);

        final result = await schema.validateAsync('hello');
        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });

      test('should fail validation with async refine', () async {
        final schema = z.string().refine(
          (value) => value.length > 10,
          message: 'Too short',
          code: 'min_length',
        );

        final result = await schema.validateAsync('hello');
        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.message, 'Too short');
        expect(result.errors!.errors.first.code, 'min_length');
      });

      test('should propagate initial validation failures', () async {
        final schema = z.string().refine((value) => true);

        final result = await schema.validateAsync(123);
        expect(result.isSuccess, false);
      });
    });

    group('DefaultSchema edge cases', () {
      test('should use default for invalid input', () {
        final schema = z.string().defaultTo('default');
        
        final result = schema.validate(123);
        expect(result.isSuccess, true);
        expect(result.data, 'default');
      });
    });

    group('OptionalSchema async validation', () {
      test('should handle null in async validation', () async {
        final schema = z.string().optional();

        final result = await schema.validateAsync(null);
        expect(result.isSuccess, true);
        expect(result.data, null);
      });

      test('should propagate validation errors in async', () async {
        final schema = z.string().min(5).optional();

        final result = await schema.validateAsync('hi');
        expect(result.isSuccess, false);
      });
    });

    group('LazySchema async validation', () {
      test('should support async validation', () async {
        final schema = Schema.lazy(() => z.string());

        final result = await schema.validateAsync('test');
        expect(result.isSuccess, true);
        expect(result.data, 'test');
      });
    });

    group('IntersectionSchema async validation', () {
      test('should validate all schemas async', () async {
        final schema = Schema.intersection([
          z.string(),
          z.string().min(3),
          z.string().max(10),
        ]);

        final result = await schema.validateAsync('hello');
        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });

      test('should fail if any schema fails async', () async {
        final schema = Schema.intersection([
          z.string(),
          z.string().min(10),
        ]);

        final result = await schema.validateAsync('hello');
        expect(result.isSuccess, false);
      });
    });

    group('BrandedSchema async validation', () {
      test('should handle validation failures in async', () async {
        final schema = z.string().brand<String>();

        final result = await schema.validateAsync(123);
        expect(result.isSuccess, false);
      });
    });

    group('ReadonlySchema async validation', () {
      test('should handle validation failures in async', () async {
        final schema = z.string().readonly();

        final result = await schema.validateAsync(123);
        expect(result.isSuccess, false);
      });
    });
  });
}