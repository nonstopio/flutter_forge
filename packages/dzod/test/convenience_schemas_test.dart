import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('Z (Convenience Schemas)', () {
    group('Basic schemas', () {
      test('string should create StringSchema', () {
        final schema = Z.string();
        expect(schema, isA<StringSchema>());
        expect(schema.validate('hello').isSuccess, true);
        expect(schema.validate(123).isFailure, true);
      });

      test('number should create NumberSchema', () {
        final schema = Z.number();
        expect(schema, isA<NumberSchema>());
        expect(schema.validate(123).isSuccess, true);
        expect(schema.validate('hello').isFailure, true);
      });

      test('boolean should create BooleanSchema', () {
        final schema = Z.boolean();
        expect(schema, isA<BooleanSchema>());
        expect(schema.validate(true).isSuccess, true);
        expect(schema.validate('hello').isFailure, true);
      });

      test('null_ should create NullSchema', () {
        final schema = Z.null_();
        expect(schema, isA<NullSchema>());
        expect(schema.validate(null).isSuccess, true);
        expect(schema.validate('hello').isFailure, true);
      });

      test('nullValue should create NullSchema', () {
        final schema = Z.nullValue;
        expect(schema, isA<NullSchema>());
        expect(schema.validate(null).isSuccess, true);
        expect(schema.validate('hello').isFailure, true);
      });
    });

    group('Collection schemas', () {
      test('array should create ArraySchema', () {
        final schema = Z.array(Z.string());
        expect(schema, isA<ArraySchema>());
        expect(schema.validate(['hello', 'world']).isSuccess, true);
        expect(schema.validate(['hello', 123]).isFailure, true);
      });

      test('tuple should create TupleSchema', () {
        final schema = Z.tuple([Z.string(), Z.number()]);
        expect(schema, isA<TupleSchema>());
        expect(schema.validate(['hello', 123]).isSuccess, true);
        expect(schema.validate(['hello', 'world']).isFailure, true);
      });

      test('record should create RecordSchema', () {
        final schema = Z.record();
        expect(schema, isA<RecordSchema>());
        expect(schema.validate({'key': 'value'}).isSuccess, true);
        expect(schema.validate('not a record').isFailure, true);
      });

      test('record with valueSchema should validate values', () {
        final schema = Z.record(Z.string());
        expect(schema.validate({'key': 'value'}).isSuccess, true);
        expect(schema.validate({'key': 123}).isFailure, true);
      });
    });

    group('Specialized schemas', () {
      test('enum_ should create EnumSchema', () {
        final schema = Z.enum_(['red', 'green', 'blue']);
        expect(schema, isA<EnumSchema>());
        expect(schema.validate('red').isSuccess, true);
        expect(schema.validate('yellow').isFailure, true);
      });

      test('trueValue should create BooleanSchema for true', () {
        final schema = Z.trueValue;
        expect(schema, isA<BooleanSchema>());
        expect(schema.validate(true).isSuccess, true);
        expect(schema.validate(false).isFailure, true);
      });

      test('falseValue should create BooleanSchema for false', () {
        final schema = Z.falseValue;
        expect(schema, isA<BooleanSchema>());
        expect(schema.validate(false).isSuccess, true);
        expect(schema.validate(true).isFailure, true);
      });

      test('literal should create literal schema', () {
        final schema = Z.literal('hello');
        expect(schema.validate('hello').isSuccess, true);
        expect(schema.validate('world').isFailure, true);
      });

      test('literal schema should expose value', () {
        final schema = Z.literal('hello');
        expect(schema.validate('hello').isSuccess, true);
        expect(schema.validate('world').isFailure, true);
      });
    });

    group('Advanced schemas', () {
      test('union should create union schema', () {
        final schema = Z.union(<Schema<dynamic>>[Z.string(), Z.number()]);
        expect(schema.validate('hello').isSuccess, true);
        expect(schema.validate(123).isSuccess, true);
        expect(schema.validate(true).isFailure, true);
      });

      test('discriminatedUnion should create DiscriminatedUnionSchema', () {
        final schema = Z.discriminatedUnion('type', [
          Z.object({'type': Z.literal('user'), 'name': Z.string()}),
          Z.object(
              {'type': Z.literal('admin'), 'permissions': Z.array(Z.string())}),
        ]);
        expect(schema, isA<DiscriminatedUnionSchema>());
        expect(
            schema.validate({'type': 'user', 'name': 'John'}).isSuccess, true);
        expect(schema.validate({'type': 'invalid'}).isFailure, true);
      });

      test('discriminatedUnion with metadata should work', () {
        final schema = Z.discriminatedUnion(
          'type',
          [
            Z.object({'type': Z.literal('user'), 'name': Z.string()})
          ],
          description: 'User types',
          metadata: {'version': '1.0'},
        );
        expect(schema, isA<DiscriminatedUnionSchema>());
      });

      test('pipeline should create PipelineSchema', () {
        final schema = Z.pipeline([Z.string(), Z.string()]);
        expect(schema, isA<PipelineSchema>());
        expect(schema.validate('hello').isSuccess, true);
      });

      test('pipeline with metadata should work', () {
        final schema = Z.pipeline(
          [Z.string(), Z.string()],
          description: 'String pipeline',
          metadata: {'version': '1.0'},
        );
        expect(schema, isA<PipelineSchema>());
      });

      test('pipeline should throw for empty stages', () {
        expect(() => Z.pipeline([]), throwsA(isA<ArgumentError>()));
      });

      test('recursive should create RecursiveSchema', () {
        late final Schema<Map<String, dynamic>> schema;
        schema = Z.recursive<Map<String, dynamic>>(() => Z.object({
              'name': Z.string(),
              'children':
                  Z.array(Z.recursive<Map<String, dynamic>>(() => schema)),
            }));
        expect(schema, isA<RecursiveSchema>());
      });

      test('recursive with custom options should work', () {
        final schema = Z.recursive<Map<String, dynamic>>(
          () => Z.object({'name': Z.string()}),
          maxDepth: 100,
          enableCircularDetection: false,
          enableMemoization: false,
          description: 'Recursive schema',
          metadata: {'version': '1.0'},
        );
        expect(schema, isA<RecursiveSchema>());
      });

      test('intersection should create intersection schema', () {
        final schema = Z.intersection([Z.string(), Z.string()]);
        expect(schema.validate('hello').isSuccess, true);
      });

      test('lazy should create lazy schema', () {
        final schema = Z.lazy(() => Z.string());
        expect(schema.validate('hello').isSuccess, true);
        expect(schema.validate(123).isFailure, true);
      });

      test('custom should create custom schema', () {
        final schema = Z.custom<String>((input, path) {
          if (input is String && input.startsWith('custom_')) {
            return ValidationResult.success(input);
          }
          return ValidationResult.failure(
            ValidationErrorCollection.single(
              ValidationError.simple(
                  message: 'Must start with custom_',
                  path: path,
                  received: input),
            ),
          );
        });
        expect(schema.validate('custom_hello').isSuccess, true);
        expect(schema.validate('hello').isFailure, true);
      });
    });

    group('Object schemas', () {
      test('object should create ObjectSchema', () {
        final schema = Z.object({
          'name': Z.string(),
          'age': Z.number(),
        });
        expect(schema, isA<ObjectSchema>());
        expect(schema.validate({'name': 'John', 'age': 30}).isSuccess, true);
        expect(schema.validate({'name': 'John'}).isFailure, true);
      });

      test('object with explicit optional keys should work', () {
        final schema = Z.object({
          'name': Z.string(),
          'age': Z.number(),
        }, optionalKeys: {
          'age'
        });
        expect(schema.validate({'name': 'John'}).isSuccess, true);
        expect(schema.validate({'name': 'John', 'age': 30}).isSuccess, true);
      });

      test('object should auto-detect optional keys', () {
        final schema = Z.object({
          'name': Z.string(),
          'age': Z.number().optional(),
        });
        expect(schema.validate({'name': 'John'}).isSuccess, true);
        expect(schema.validate({'name': 'John', 'age': 30}).isSuccess, true);
      });

      test('object should combine explicit and auto-detected optional keys',
          () {
        final schema = Z.object({
          'name': Z.string(),
          'age': Z.number().optional(),
          'email': Z.string(),
        }, optionalKeys: {
          'email'
        });
        expect(schema.validate({'name': 'John'}).isSuccess, true);
        expect(schema.validate({'name': 'John', 'age': 30}).isSuccess, true);
        expect(
            schema.validate(
                {'name': 'John', 'email': 'john@example.com'}).isSuccess,
            true);
      });
    });

    group('Type schemas', () {
      test('any should accept any value', () {
        final schema = Z.any();
        expect(schema.validate('hello').isSuccess, true);
        expect(schema.validate(123).isSuccess, true);
        expect(schema.validate(true).isSuccess, true);
        expect(schema.validate(null).isSuccess, true);
      });

      test('unknown should accept any value', () {
        final schema = Z.unknown();
        expect(schema.validate('hello').isSuccess, true);
        expect(schema.validate(123).isSuccess, true);
        expect(schema.validate(true).isSuccess, true);
        expect(schema.validate(null).isSuccess, true);
      });

      test('never should reject any value', () {
        final schema = Z.never();
        expect(schema.validate('hello').isFailure, true);
        expect(schema.validate(123).isFailure, true);
        expect(schema.validate(true).isFailure, true);
        expect(schema.validate(null).isFailure, true);
      });

      test('void_ should only accept null', () {
        final schema = Z.void_();
        expect(schema.validate(null).isSuccess, true);
        expect(schema.validate('hello').isFailure, true);
        expect(schema.validate(123).isFailure, true);
      });

      test('voidValue should only accept null', () {
        final schema = Z.voidValue;
        expect(schema.validate(null).isSuccess, true);
        expect(schema.validate('hello').isFailure, true);
        expect(schema.validate(123).isFailure, true);
      });

      test('undefined should only accept null', () {
        final schema = Z.undefined();
        expect(schema.validate(null).isSuccess, true);
        expect(schema.validate('hello').isFailure, true);
        expect(schema.validate(123).isFailure, true);
      });
    });

    group('Date and time schemas', () {
      test('date should accept DateTime', () {
        final schema = Z.date();
        final now = DateTime.now();
        expect(schema.validate(now).isSuccess, true);
        expect(schema.validate('hello').isFailure, true);
      });

      test('date should parse valid date strings', () {
        final schema = Z.date();
        expect(schema.validate('2023-01-01').isSuccess, true);
        expect(schema.validate('2023-01-01T12:00:00').isSuccess, true);
        expect(schema.validate('invalid-date').isFailure, true);
      });
    });

    group('Numeric type schemas', () {
      test('bigint should accept BigInt', () {
        final schema = Z.bigint();
        expect(schema.validate(BigInt.from(123)).isSuccess, true);
        expect(schema.validate(123).isFailure, true);
      });

      test('bigint should parse valid BigInt strings', () {
        final schema = Z.bigint();
        expect(
            schema.validate('123456789012345678901234567890').isSuccess, true);
        expect(schema.validate('not-a-number').isFailure, true);
      });

      test('nan should only accept NaN', () {
        final schema = Z.nan();
        expect(schema.validate(double.nan).isSuccess, true);
        expect(schema.validate(123).isFailure, true);
        expect(schema.validate(double.infinity).isFailure, true);
      });

      test('infinity should accept infinity', () {
        final schema = Z.infinity();
        expect(schema.validate(double.infinity).isSuccess, true);
        expect(schema.validate(double.negativeInfinity).isSuccess, true);
        expect(schema.validate(123).isFailure, true);
      });

      test('negativeInfinity should only accept negative infinity', () {
        final schema = Z.negativeInfinity();
        expect(schema.validate(double.negativeInfinity).isSuccess, true);
        expect(schema.validate(double.infinity).isFailure, true);
        expect(schema.validate(123).isFailure, true);
      });

      test('positiveInfinity should only accept positive infinity', () {
        final schema = Z.positiveInfinity();
        expect(schema.validate(double.infinity).isSuccess, true);
        expect(schema.validate(double.negativeInfinity).isFailure, true);
        expect(schema.validate(123).isFailure, true);
      });

      test('zero should only accept zero', () {
        final schema = Z.zero();
        expect(schema.validate(0).isSuccess, true);
        expect(schema.validate(0.0).isSuccess, true);
        expect(schema.validate(1).isFailure, true);
      });

      test('one should only accept one', () {
        final schema = Z.one();
        expect(schema.validate(1).isSuccess, true);
        expect(schema.validate(1.0).isSuccess, true);
        expect(schema.validate(0).isFailure, true);
      });

      test('negativeOne should only accept negative one', () {
        final schema = Z.negativeOne();
        expect(schema.validate(-1).isSuccess, true);
        expect(schema.validate(-1.0).isSuccess, true);
        expect(schema.validate(1).isFailure, true);
      });
    });

    group('Other type schemas', () {
      test('symbol should accept Symbol', () {
        final schema = Z.symbol();
        expect(schema.validate(#test).isSuccess, true);
        expect(schema.validate('test').isFailure, true);
      });

      test('function should accept Function', () {
        final schema = Z.function();
        expect(schema.validate(() => 'test').isSuccess, true);
        expect(schema.validate('test').isFailure, true);
      });

      test('regex should accept RegExp', () {
        final schema = Z.regex();
        expect(schema.validate(RegExp(r'\d+')).isSuccess, true);
        expect(schema.validate('test').isFailure, true);
      });

      test('map should accept Map<String, dynamic>', () {
        final schema = Z.map();
        expect(schema.validate({'key': 'value'}).isSuccess, true);
        expect(schema.validate('test').isFailure, true);
      });

      test('set should accept Set<dynamic>', () {
        final schema = Z.set();
        expect(schema.validate({1, 2, 3}).isSuccess, true);
        expect(schema.validate([1, 2, 3]).isFailure, true);
      });

      test('promise should accept Future<dynamic>', () {
        final schema = Z.promise();
        expect(schema.validate(Future.value('test')).isSuccess, true);
        expect(schema.validate('test').isFailure, true);
      });
    });

    group('String convenience schemas', () {
      test('emptyString should only accept empty string', () {
        final schema = Z.emptyString();
        expect(schema.validate('').isSuccess, true);
        expect(schema.validate('hello').isFailure, true);
      });

      test('nonEmptyString should reject empty string', () {
        final schema = Z.nonEmptyString();
        expect(schema.validate('hello').isSuccess, true);
        expect(schema.validate('').isFailure, true);
      });

      test('email should validate email format', () {
        final schema = Z.email();
        expect(schema.validate('test@example.com').isSuccess, true);
        expect(schema.validate('invalid-email').isFailure, true);
      });

      test('url should validate URL format', () {
        final schema = Z.url();
        expect(schema.validate('https://example.com').isSuccess, true);
        expect(schema.validate('invalid-url').isFailure, true);
      });

      test('uuid should validate UUID format', () {
        final schema = Z.uuid();
        expect(
            schema.validate('123e4567-e89b-12d3-a456-426614174000').isSuccess,
            true);
        expect(schema.validate('invalid-uuid').isFailure, true);
      });
    });

    group('Number convenience schemas', () {
      test('integer should only accept integers', () {
        final schema = Z.integer();
        expect(schema.validate(123).isSuccess, true);
        expect(schema.validate(123.0).isSuccess, true);
        expect(schema.validate(123.5).isFailure, true);
      });

      test('positive should only accept positive numbers', () {
        final schema = Z.positive();
        expect(schema.validate(1).isSuccess, true);
        expect(schema.validate(0).isFailure, true);
        expect(schema.validate(-1).isFailure, true);
      });

      test('negative should only accept negative numbers', () {
        final schema = Z.negative();
        expect(schema.validate(-1).isSuccess, true);
        expect(schema.validate(0).isFailure, true);
        expect(schema.validate(1).isFailure, true);
      });

      test('nonNegative should accept zero and positive numbers', () {
        final schema = Z.nonNegative();
        expect(schema.validate(0).isSuccess, true);
        expect(schema.validate(1).isSuccess, true);
        expect(schema.validate(-1).isFailure, true);
      });

      test('nonPositive should accept zero and negative numbers', () {
        final schema = Z.nonPositive();
        expect(schema.validate(0).isSuccess, true);
        expect(schema.validate(-1).isSuccess, true);
        expect(schema.validate(1).isFailure, true);
      });

      test('finite should only accept finite numbers', () {
        final schema = Z.finite();
        expect(schema.validate(123).isSuccess, true);
        expect(schema.validate(double.infinity).isFailure, true);
        expect(schema.validate(double.negativeInfinity).isFailure, true);
        expect(schema.validate(double.nan).isFailure, true);
      });

      test('safeInt should only accept safe integers', () {
        final schema = Z.safeInt();
        expect(schema.validate(123).isSuccess, true);
        expect(schema.validate(123.5).isFailure, true);
      });

      test('port should validate port numbers', () {
        final schema = Z.port();
        expect(schema.validate(8080).isSuccess, true);
        expect(schema.validate(0).isFailure, true);
        expect(schema.validate(65536).isFailure, true);
      });

      test('year should validate year numbers', () {
        final schema = Z.year();
        expect(schema.validate(2023).isSuccess, true);
        expect(schema.validate(999).isFailure, true);
        expect(schema.validate(10001).isFailure, true);
      });

      test('month should validate month numbers', () {
        final schema = Z.month();
        expect(schema.validate(1).isSuccess, true);
        expect(schema.validate(12).isSuccess, true);
        expect(schema.validate(0).isFailure, true);
        expect(schema.validate(13).isFailure, true);
      });

      test('day should validate day numbers', () {
        final schema = Z.day();
        expect(schema.validate(1).isSuccess, true);
        expect(schema.validate(31).isSuccess, true);
        expect(schema.validate(0).isFailure, true);
        expect(schema.validate(32).isFailure, true);
      });

      test('hour should validate hour numbers', () {
        final schema = Z.hour();
        expect(schema.validate(0).isSuccess, true);
        expect(schema.validate(23).isSuccess, true);
        expect(schema.validate(-1).isFailure, true);
        expect(schema.validate(24).isFailure, true);
      });

      test('minute should validate minute numbers', () {
        final schema = Z.minute();
        expect(schema.validate(0).isSuccess, true);
        expect(schema.validate(59).isSuccess, true);
        expect(schema.validate(-1).isFailure, true);
        expect(schema.validate(60).isFailure, true);
      });

      test('second should validate second numbers', () {
        final schema = Z.second();
        expect(schema.validate(0).isSuccess, true);
        expect(schema.validate(59).isSuccess, true);
        expect(schema.validate(-1).isFailure, true);
        expect(schema.validate(60).isFailure, true);
      });
    });

    group('Transform and refine schemas', () {
      test('transform should create TransformSchema', () {
        final schema = Z.transform<String, int>((value) => value.length);
        expect(schema, isA<TransformSchema>());
      });

      test('refine should create RefineSchema', () {
        final schema = Z.refine<String>((value) => value.isNotEmpty);
        expect(schema, isA<RefineSchema>());
      });

      test('refine with custom message and code should work', () {
        final schema = Z.refine<String>(
          (value) => value.isNotEmpty,
          message: 'String cannot be empty',
          code: 'empty_string',
        );
        expect(schema, isA<RefineSchema>());
      });

      test('refineAsync should create AsyncRefineSchema', () {
        final schema = Z.refineAsync<String>((value) async => value.isNotEmpty);
        expect(schema, isA<AsyncRefineSchema>());
      });

      test('refineAsync with custom message and code should work', () {
        final schema = Z.refineAsync<String>(
          (value) async => value.isNotEmpty,
          message: 'String cannot be empty',
          code: 'empty_string',
        );
        expect(schema, isA<AsyncRefineSchema>());
      });
    });

    group('Coerce access', () {
      test('coerce should provide access to Coerce instance', () {
        const coerce = Z.coerce;
        expect(coerce, isA<Coerce>());
      });
    });
  });

  group('Individual schema implementations', () {
    group('Internal schema implementations', () {
      test('should have literal schema functionality', () {
        final schema = Z.literal('hello');
        expect(schema.validate('hello').isSuccess, true);
        expect(schema.validate('hello').data, 'hello');
      });

      test('should reject non-matching literal values', () {
        final schema = Z.literal('hello');
        final result = schema.validate('world');
        expect(result.isFailure, true);
        expect(result.errors!.errors.first.code,
            ValidationErrorCode.literalMismatch.code);
      });
    });

    group('Z factory method implementations', () {
      test('should have any schema functionality', () {
        final schema = Z.any();
        expect(schema.validate('hello').isSuccess, true);
        expect(schema.validate(123).isSuccess, true);
        expect(schema.validate(null).isSuccess, true);
      });

      test('should have unknown schema functionality', () {
        final schema = Z.unknown();
        expect(schema.validate('hello').isSuccess, true);
        expect(schema.validate(123).isSuccess, true);
        expect(schema.validate(null).isSuccess, true);
      });

      test('should have never schema functionality', () {
        final schema = Z.never();
        expect(schema.validate('hello').isFailure, true);
        expect(schema.validate(123).isFailure, true);
        expect(schema.validate(null).isFailure, true);
      });

      test('should have void schema functionality', () {
        final schema = Z.void_();
        expect(schema.validate(null).isSuccess, true);
        expect(schema.validate('hello').isFailure, true);
        expect(schema.validate(123).isFailure, true);
      });

      test('should have date schema functionality', () {
        final schema = Z.date();
        final now = DateTime.now();
        expect(schema.validate(now).isSuccess, true);
        expect(schema.validate(now).data, now);
        expect(schema.validate('2023-01-01').isSuccess, true);
        expect(schema.validate('invalid-date').isFailure, true);
        expect(schema.validate(123).isFailure, true);
      });

      test('should have bigint schema functionality', () {
        final schema = Z.bigint();
        final bigInt = BigInt.from(123);
        expect(schema.validate(bigInt).isSuccess, true);
        expect(schema.validate(bigInt).data, bigInt);
        expect(
            schema.validate('123456789012345678901234567890').isSuccess, true);
        expect(schema.validate('not-a-number').isFailure, true);
        expect(schema.validate(123).isFailure, true);
      });

      test('should have symbol schema functionality', () {
        final schema = Z.symbol();
        expect(schema.validate(#test).isSuccess, true);
        expect(schema.validate(#test).data, #test);
        expect(schema.validate('test').isFailure, true);
      });

      test('should have function schema functionality', () {
        final schema = Z.function();
        func() => 'test';
        expect(schema.validate(func).isSuccess, true);
        expect(schema.validate(func).data, func);
        expect(schema.validate('test').isFailure, true);
      });

      test('should have regex schema functionality', () {
        final schema = Z.regex();
        final regex = RegExp(r'\d+');
        expect(schema.validate(regex).isSuccess, true);
        expect(schema.validate(regex).data, regex);
        expect(schema.validate('test').isFailure, true);
      });

      test('should have map schema functionality', () {
        final schema = Z.map();
        final map = {'key': 'value'};
        expect(schema.validate(map).isSuccess, true);
        expect(schema.validate(map).data, map);
        expect(schema.validate('test').isFailure, true);
      });

      test('should have set schema functionality', () {
        final schema = Z.set();
        final set = {1, 2, 3};
        expect(schema.validate(set).isSuccess, true);
        expect(schema.validate(set).data, set);
        expect(schema.validate([1, 2, 3]).isFailure, true);
      });

      test('should have promise schema functionality', () {
        final schema = Z.promise();
        final future = Future.value('test');
        expect(schema.validate(future).isSuccess, true);
        expect(schema.validate(future).data, future);
        expect(schema.validate('test').isFailure, true);
      });

      test('should have undefined schema functionality', () {
        final schema = Z.undefined();
        expect(schema.validate(null).isSuccess, true);
        expect(schema.validate('hello').isFailure, true);
      });

      test('should have nan schema functionality', () {
        final schema = Z.nan();
        expect(schema.validate(double.nan).isSuccess, true);
        expect(schema.validate(123).isFailure, true);
        expect(schema.validate(double.infinity).isFailure, true);
      });

      test('should have infinity schema functionality', () {
        final schema = Z.infinity();
        expect(schema.validate(double.infinity).isSuccess, true);
        expect(schema.validate(double.negativeInfinity).isSuccess, true);
        expect(schema.validate(123).isFailure, true);
      });

      test('should have negative infinity schema functionality', () {
        final schema = Z.negativeInfinity();
        expect(schema.validate(double.negativeInfinity).isSuccess, true);
        expect(schema.validate(double.infinity).isFailure, true);
        expect(schema.validate(123).isFailure, true);
      });

      test('should have positive infinity schema functionality', () {
        final schema = Z.positiveInfinity();
        expect(schema.validate(double.infinity).isSuccess, true);
        expect(schema.validate(double.negativeInfinity).isFailure, true);
        expect(schema.validate(123).isFailure, true);
      });

      test('should have zero schema functionality', () {
        final schema = Z.zero();
        expect(schema.validate(0).isSuccess, true);
        expect(schema.validate(0.0).isSuccess, true);
        expect(schema.validate(1).isFailure, true);
        expect(schema.validate(-1).isFailure, true);
      });

      test('should have one schema functionality', () {
        final schema = Z.one();
        expect(schema.validate(1).isSuccess, true);
        expect(schema.validate(1.0).isSuccess, true);
        expect(schema.validate(0).isFailure, true);
        expect(schema.validate(2).isFailure, true);
      });

      test('should have negative one schema functionality', () {
        final schema = Z.negativeOne();
        expect(schema.validate(-1).isSuccess, true);
        expect(schema.validate(-1.0).isSuccess, true);
        expect(schema.validate(0).isFailure, true);
        expect(schema.validate(1).isFailure, true);
      });

      test('should have custom schema functionality', () {
        final schema = Z.custom<String>((input, path) {
          if (input is String && input.startsWith('custom_')) {
            return ValidationResult.success(input);
          }
          return ValidationResult.failure(
            ValidationErrorCollection.single(
              ValidationError.simple(
                  message: 'Must start with custom_',
                  path: path,
                  received: input),
            ),
          );
        });

        expect(schema.validate('custom_hello').isSuccess, true);
        expect(schema.validate('hello').isFailure, true);
      });
    });
  });
}
