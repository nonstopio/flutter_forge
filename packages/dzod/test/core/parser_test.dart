import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('Parser', () {
    final stringSchema = Z.string();
    final objectSchema = Z.object({
      'name': Z.string(),
      'age': Z.number(),
    });

    group('parse', () {
      test('should parse valid input', () {
        final result = Parser.parse(stringSchema, 'hello');
        expect(result, 'hello');
      });

      test('should throw ValidationException for invalid input', () {
        expect(
          () => Parser.parse(stringSchema, 123),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should parse with path', () {
        final result = Parser.parse(stringSchema, 'hello', ['test']);
        expect(result, 'hello');
      });
    });

    group('safeParse', () {
      test('should return parsed value for valid input', () {
        final result = Parser.safeParse(stringSchema, 'hello');
        expect(result, 'hello');
      });

      test('should return null for invalid input', () {
        final result = Parser.safeParse(stringSchema, 123);
        expect(result, null);
      });

      test('should work with path', () {
        final result = Parser.safeParse(stringSchema, 'hello', ['test']);
        expect(result, 'hello');
      });
    });

    group('validate', () {
      test('should return success result for valid input', () {
        final result = Parser.validate(stringSchema, 'hello');
        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });

      test('should return failure result for invalid input', () {
        final result = Parser.validate(stringSchema, 123);
        expect(result.isFailure, true);
        expect(result.errors, isNotNull);
      });

      test('should work with path', () {
        final result = Parser.validate(stringSchema, 'hello', ['test']);
        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });
    });

    group('isValid', () {
      test('should return true for valid input', () {
        final result = Parser.isValid(stringSchema, 'hello');
        expect(result, true);
      });

      test('should return false for invalid input', () {
        final result = Parser.isValid(stringSchema, 123);
        expect(result, false);
      });

      test('should work with path', () {
        final result = Parser.isValid(stringSchema, 'hello', ['test']);
        expect(result, true);
      });
    });

    group('parseMany', () {
      test('should parse all valid inputs', () {
        final result = Parser.parseMany(stringSchema, ['hello', 'world']);
        expect(result, ['hello', 'world']);
      });

      test('should throw ValidationException for any invalid input', () {
        expect(
          () => Parser.parseMany(stringSchema, ['hello', 123]),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should work with path', () {
        final result =
            Parser.parseMany(stringSchema, ['hello', 'world'], ['test']);
        expect(result, ['hello', 'world']);
      });

      test('should handle empty list', () {
        final result = Parser.parseMany(stringSchema, []);
        expect(result, []);
      });
    });

    group('safeParseMany', () {
      test('should parse all valid inputs', () {
        final result = Parser.safeParseMany(stringSchema, ['hello', 'world']);
        expect(result, ['hello', 'world']);
      });

      test('should skip invalid inputs', () {
        final result =
            Parser.safeParseMany(stringSchema, ['hello', 123, 'world']);
        expect(result, ['hello', 'world']);
      });

      test('should work with path', () {
        final result =
            Parser.safeParseMany(stringSchema, ['hello', 'world'], ['test']);
        expect(result, ['hello', 'world']);
      });

      test('should handle empty list', () {
        final result = Parser.safeParseMany(stringSchema, []);
        expect(result, []);
      });
    });

    group('validateMany', () {
      test('should return success for all valid inputs', () {
        final result = Parser.validateMany(stringSchema, ['hello', 'world']);
        expect(result.isSuccess, true);
        expect(result.data, ['hello', 'world']);
      });

      test('should return failure for any invalid input', () {
        final result = Parser.validateMany(stringSchema, ['hello', 123]);
        expect(result.isFailure, true);
        expect(result.errors, isNotNull);
      });

      test('should work with path', () {
        final result =
            Parser.validateMany(stringSchema, ['hello', 'world'], ['test']);
        expect(result.isSuccess, true);
        expect(result.data, ['hello', 'world']);
      });

      test('should handle empty list', () {
        final result = Parser.validateMany(stringSchema, []);
        expect(result.isSuccess, true);
        expect(result.data, []);
      });
    });

    group('parseJson', () {
      test('should parse valid JSON object', () {
        final result =
            Parser.parseJson(objectSchema, {'name': 'John', 'age': 30});
        expect(result, {'name': 'John', 'age': 30});
      });

      test('should throw ValidationException for invalid JSON', () {
        expect(
          () => Parser.parseJson(objectSchema, {'name': 'John'}),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should work with path', () {
        final result = Parser.parseJson(
            objectSchema, {'name': 'John', 'age': 30}, ['test']);
        expect(result, {'name': 'John', 'age': 30});
      });
    });

    group('safeParseJson', () {
      test('should parse valid JSON object', () {
        final result =
            Parser.safeParseJson(objectSchema, {'name': 'John', 'age': 30});
        expect(result, {'name': 'John', 'age': 30});
      });

      test('should return null for invalid JSON', () {
        final result = Parser.safeParseJson(objectSchema, {'name': 'John'});
        expect(result, null);
      });

      test('should work with path', () {
        final result = Parser.safeParseJson(
            objectSchema, {'name': 'John', 'age': 30}, ['test']);
        expect(result, {'name': 'John', 'age': 30});
      });
    });

    group('validateJson', () {
      test('should return success for valid JSON object', () {
        final result =
            Parser.validateJson(objectSchema, {'name': 'John', 'age': 30});
        expect(result.isSuccess, true);
        expect(result.data, {'name': 'John', 'age': 30});
      });

      test('should return failure for invalid JSON', () {
        final result = Parser.validateJson(objectSchema, {'name': 'John'});
        expect(result.isFailure, true);
        expect(result.errors, isNotNull);
      });

      test('should work with path', () {
        final result = Parser.validateJson(
            objectSchema, {'name': 'John', 'age': 30}, ['test']);
        expect(result.isSuccess, true);
        expect(result.data, {'name': 'John', 'age': 30});
      });
    });

    group('parseJsonArray', () {
      test('should parse valid JSON array', () {
        final result = Parser.parseJsonArray(stringSchema, ['hello', 'world']);
        expect(result, ['hello', 'world']);
      });

      test('should throw ValidationException for invalid JSON array', () {
        expect(
          () => Parser.parseJsonArray(stringSchema, ['hello', 123]),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should work with path', () {
        final result =
            Parser.parseJsonArray(stringSchema, ['hello', 'world'], ['test']);
        expect(result, ['hello', 'world']);
      });
    });

    group('safeParseJsonArray', () {
      test('should parse valid JSON array', () {
        final result =
            Parser.safeParseJsonArray(stringSchema, ['hello', 'world']);
        expect(result, ['hello', 'world']);
      });

      test('should skip invalid items in JSON array', () {
        final result =
            Parser.safeParseJsonArray(stringSchema, ['hello', 123, 'world']);
        expect(result, ['hello', 'world']);
      });

      test('should work with path', () {
        final result = Parser.safeParseJsonArray(
            stringSchema, ['hello', 'world'], ['test']);
        expect(result, ['hello', 'world']);
      });
    });

    group('validateJsonArray', () {
      test('should return success for valid JSON array', () {
        final result =
            Parser.validateJsonArray(stringSchema, ['hello', 'world']);
        expect(result.isSuccess, true);
        expect(result.data, ['hello', 'world']);
      });

      test('should return failure for invalid JSON array', () {
        final result = Parser.validateJsonArray(stringSchema, ['hello', 123]);
        expect(result.isFailure, true);
        expect(result.errors, isNotNull);
      });

      test('should work with path', () {
        final result = Parser.validateJsonArray(
            stringSchema, ['hello', 'world'], ['test']);
        expect(result.isSuccess, true);
        expect(result.data, ['hello', 'world']);
      });
    });

    group('transform', () {
      test('should transform valid input', () {
        final parser =
            Parser.transform(stringSchema, (value) => value.toUpperCase());
        final result = parser('hello');
        expect(result.isSuccess, true);
        expect(result.data, 'HELLO');
      });

      test('should return failure for invalid input', () {
        final parser =
            Parser.transform(stringSchema, (value) => value.toUpperCase());
        final result = parser(123);
        expect(result.isFailure, true);
        expect(result.errors, isNotNull);
      });

      test('should handle transformation error', () {
        final parser = Parser.transform(
            stringSchema, (value) => throw Exception('Transform error'));
        final result = parser('hello');
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.message,
            contains('Transformation failed'));
      });

      test('should work with path', () {
        final parser =
            Parser.transform(stringSchema, (value) => value.toUpperCase());
        final result = parser('hello', ['test']);
        expect(result.isSuccess, true);
        expect(result.data, 'HELLO');
      });
    });

    group('refine', () {
      test('should pass refinement for valid input', () {
        final parser = Parser.refine(stringSchema, (value) => value.length > 3);
        final result = parser('hello');
        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });

      test('should fail refinement for invalid input', () {
        final parser = Parser.refine(stringSchema, (value) => value.length > 3);
        final result = parser('hi');
        expect(result.isFailure, true);
        expect(result.errors, isNotNull);
      });

      test('should return failure for invalid schema input', () {
        final parser = Parser.refine(stringSchema, (value) => value.length > 3);
        final result = parser(123);
        expect(result.isFailure, true);
        expect(result.errors, isNotNull);
      });

      test('should use custom message and code', () {
        final parser = Parser.refine(
          stringSchema,
          (value) => value.length > 3,
          message: 'Too short',
          code: 'min_length',
        );
        final result = parser('hi');
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.message, contains('Too short'));
      });

      test('should work with path', () {
        final parser = Parser.refine(stringSchema, (value) => value.length > 3);
        final result = parser('hello', ['test']);
        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });
    });

    group('withDefault', () {
      test('should use default value for null input', () {
        final parser = Parser.withDefault(stringSchema, 'default');
        final result = parser(null);
        expect(result.isSuccess, true);
        expect(result.data, 'default');
      });

      test('should use parsed value for valid input', () {
        final parser = Parser.withDefault(stringSchema, 'default');
        final result = parser('hello');
        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });

      test('should use default value for invalid input', () {
        final parser = Parser.withDefault(stringSchema, 'default');
        final result = parser(123);
        expect(result.isSuccess, true);
        expect(result.data, 'default');
      });

      test('should work with path', () {
        final parser = Parser.withDefault(stringSchema, 'default');
        final result = parser(null, ['test']);
        expect(result.isSuccess, true);
        expect(result.data, 'default');
      });
    });

    group('optional', () {
      test('should return null for null input', () {
        final parser = Parser.optional(stringSchema);
        final result = parser(null);
        expect(result.isSuccess, true);
        expect(result.data, null);
      });

      test('should return parsed value for valid input', () {
        final parser = Parser.optional(stringSchema);
        final result = parser('hello');
        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });

      test('should return failure for invalid input', () {
        final parser = Parser.optional(stringSchema);
        final result = parser(123);
        expect(result.isFailure, true);
        expect(result.errors, isNotNull);
      });

      test('should work with path', () {
        final parser = Parser.optional(stringSchema);
        final result = parser(null, ['test']);
        expect(result.isSuccess, true);
        expect(result.data, null);
      });
    });

    group('withFallback', () {
      test('should use parsed value for valid input', () {
        final parser = Parser.withFallback(stringSchema, 'fallback');
        final result = parser('hello');
        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });

      test('should use fallback value for invalid input', () {
        final parser = Parser.withFallback(stringSchema, 'fallback');
        final result = parser(123);
        expect(result.isSuccess, true);
        expect(result.data, 'fallback');
      });

      test('should work with path', () {
        final parser = Parser.withFallback(stringSchema, 'fallback');
        final result = parser('hello', ['test']);
        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });
    });

    group('preprocess', () {
      test('should preprocess input successfully', () {
        final parser =
            Parser.preprocess(stringSchema, (input) => input.toString());
        final result = parser(123);
        expect(result.isSuccess, true);
        expect(result.data, '123');
      });

      test('should handle preprocessing error', () {
        final parser = Parser.preprocess(
            stringSchema, (input) => throw Exception('Preprocess error'));
        final result = parser('hello');
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.message,
            contains('Preprocessing failed'));
      });

      test('should work with path', () {
        final parser =
            Parser.preprocess(stringSchema, (input) => input.toString());
        final result = parser(123, ['test']);
        expect(result.isSuccess, true);
        expect(result.data, '123');
      });
    });

    group('postprocess', () {
      test('should postprocess output successfully', () {
        final parser =
            Parser.postprocess(stringSchema, (value) => value.toUpperCase());
        final result = parser('hello');
        expect(result.isSuccess, true);
        expect(result.data, 'HELLO');
      });

      test('should return failure for invalid input', () {
        final parser =
            Parser.postprocess(stringSchema, (value) => value.toUpperCase());
        final result = parser(123);
        expect(result.isFailure, true);
        expect(result.errors, isNotNull);
      });

      test('should handle postprocessing error', () {
        final parser = Parser.postprocess(
            stringSchema, (value) => throw Exception('Postprocess error'));
        final result = parser('hello');
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.message,
            contains('Postprocessing failed'));
      });

      test('should work with path', () {
        final parser =
            Parser.postprocess(stringSchema, (value) => value.toUpperCase());
        final result = parser('hello', ['test']);
        expect(result.isSuccess, true);
        expect(result.data, 'HELLO');
      });
    });
  });

  group('ParserExtensions', () {
    final stringSchema = Z.string();
    final objectSchema = Z.object({
      'name': Z.string(),
      'age': Z.number(),
    });

    group('parseInput', () {
      test('should parse valid input', () {
        final result = stringSchema.parseInput('hello');
        expect(result, 'hello');
      });

      test('should throw ValidationException for invalid input', () {
        expect(
          () => stringSchema.parseInput(123),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should work with path', () {
        final result = stringSchema.parseInput('hello', ['test']);
        expect(result, 'hello');
      });
    });

    group('safeParseInput', () {
      test('should return parsed value for valid input', () {
        final result = stringSchema.safeParseInput('hello');
        expect(result, 'hello');
      });

      test('should return null for invalid input', () {
        final result = stringSchema.safeParseInput(123);
        expect(result, null);
      });

      test('should work with path', () {
        final result = stringSchema.safeParseInput('hello', ['test']);
        expect(result, 'hello');
      });
    });

    group('validateInput', () {
      test('should return success result for valid input', () {
        final result = stringSchema.validateInput('hello');
        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });

      test('should return failure result for invalid input', () {
        final result = stringSchema.validateInput(123);
        expect(result.isFailure, true);
        expect(result.errors, isNotNull);
      });

      test('should work with path', () {
        final result = stringSchema.validateInput('hello', ['test']);
        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });
    });

    group('isValidInput', () {
      test('should return true for valid input', () {
        final result = stringSchema.isValidInput('hello');
        expect(result, true);
      });

      test('should return false for invalid input', () {
        final result = stringSchema.isValidInput(123);
        expect(result, false);
      });

      test('should work with path', () {
        final result = stringSchema.isValidInput('hello', ['test']);
        expect(result, true);
      });
    });

    group('parseJson', () {
      test('should parse valid JSON object', () {
        final result = objectSchema.parseJson({'name': 'John', 'age': 30});
        expect(result, {'name': 'John', 'age': 30});
      });

      test('should throw ValidationException for invalid JSON', () {
        expect(
          () => objectSchema.parseJson({'name': 'John'}),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should work with path', () {
        final result =
            objectSchema.parseJson({'name': 'John', 'age': 30}, ['test']);
        expect(result, {'name': 'John', 'age': 30});
      });
    });

    group('safeParseJson', () {
      test('should parse valid JSON object', () {
        final result = objectSchema.safeParseJson({'name': 'John', 'age': 30});
        expect(result, {'name': 'John', 'age': 30});
      });

      test('should return null for invalid JSON', () {
        final result = objectSchema.safeParseJson({'name': 'John'});
        expect(result, null);
      });

      test('should work with path', () {
        final result =
            objectSchema.safeParseJson({'name': 'John', 'age': 30}, ['test']);
        expect(result, {'name': 'John', 'age': 30});
      });
    });

    group('validateJson', () {
      test('should return success for valid JSON object', () {
        final result = objectSchema.validateJson({'name': 'John', 'age': 30});
        expect(result.isSuccess, true);
        expect(result.data, {'name': 'John', 'age': 30});
      });

      test('should return failure for invalid JSON', () {
        final result = objectSchema.validateJson({'name': 'John'});
        expect(result.isFailure, true);
        expect(result.errors, isNotNull);
      });

      test('should work with path', () {
        final result =
            objectSchema.validateJson({'name': 'John', 'age': 30}, ['test']);
        expect(result.isSuccess, true);
        expect(result.data, {'name': 'John', 'age': 30});
      });
    });
  });
}
