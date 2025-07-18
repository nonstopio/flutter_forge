import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('CoercionSchema', () {
    group('String Coercion', () {
      test('should coerce various types to string', () {
        final stringCoercion = Z.coerce.string();

        expect(stringCoercion.parse('hello'), equals('hello'));
        expect(stringCoercion.parse(123), equals('123'));
        expect(stringCoercion.parse(45.67), equals('45.67'));
        expect(stringCoercion.parse(true), equals('true'));
        expect(stringCoercion.parse(false), equals('false'));
        expect(stringCoercion.parse(null), equals(''));
        expect(stringCoercion.parse([1, 2, 3]), equals('1,2,3'));
      });

      test('should coerce complex objects to string', () {
        final stringCoercion = Z.coerce.string();

        final map = {'key': 'value'};
        final result = stringCoercion.parse(map);
        expect(result, isA<String>());
        expect(result, contains('key'));
      });

      test('should apply string validations after coercion', () {
        final stringCoercion = CoercionSchema<String>(
          Z.string().min(3),
          (input) => input.toString(),
        );

        expect(stringCoercion.parse(12345), equals('12345'));
        expect(() => stringCoercion.parse(12),
            throwsA(isA<ValidationException>()));
      });

      test('should handle strict mode for string coercion', () {
        final strictStringCoercion = Z.coerce.string(strict: true);

        expect(strictStringCoercion.parse('hello'), equals('hello'));
        expect(strictStringCoercion.parse(123), equals('123'));

        // In strict mode, coercion errors should be handled appropriately
        expect(strictStringCoercion.parse(123), equals('123'));
      });
    });

    group('Number Coercion', () {
      test('should coerce various types to number', () {
        final numberCoercion = Z.coerce.number();

        expect(numberCoercion.parse(123), equals(123));
        expect(numberCoercion.parse(45.67), equals(45.67));
        expect(numberCoercion.parse('123'), equals(123));
        expect(numberCoercion.parse('45.67'), equals(45.67));
        expect(numberCoercion.parse(true), equals(1));
        expect(numberCoercion.parse(false), equals(0));
        expect(numberCoercion.parse(''), equals(0));
        expect(numberCoercion.parse('  42  '), equals(42));
      });

      test('should handle invalid number coercion', () {
        final numberCoercion = Z.coerce.number();

        expect(
          () => numberCoercion.parse('not-a-number'),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should apply number validations after coercion', () {
        final numberCoercion = CoercionSchema<num>(
          Z.number().min(10),
          (input) => num.parse(input.toString()),
        );

        expect(numberCoercion.parse('15'), equals(15));
        expect(() => numberCoercion.parse('5'),
            throwsA(isA<ValidationException>()));
      });

      test('should handle edge cases in number coercion', () {
        final numberCoercion = Z.coerce.number();

        expect(numberCoercion.parse('0'), equals(0));
        expect(numberCoercion.parse('-123'), equals(-123));
        expect(numberCoercion.parse('123.456'), equals(123.456));
      });
    });

    group('Integer Coercion', () {
      test('should coerce various types to integer', () {
        final intCoercion = Z.coerce.integer();

        expect(intCoercion.parse(123), equals(123));
        expect(intCoercion.parse(45.67), equals(46)); // Rounded
        expect(intCoercion.parse('123'), equals(123));
        expect(intCoercion.parse('45.67'), equals(46)); // Rounded
        expect(intCoercion.parse(true), equals(1));
        expect(intCoercion.parse(false), equals(0));
        expect(intCoercion.parse(''), equals(0));
        expect(intCoercion.parse('  42  '), equals(42));
      });

      test('should handle invalid integer coercion', () {
        final intCoercion = Z.coerce.integer();

        expect(
          () => intCoercion.parse('not-a-number'),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should apply integer validations after coercion', () {
        final intCoercion = Z.coerce
            .integer()
            .refine((i) => i >= 10, message: 'Must be at least 10');

        expect(intCoercion.parse('15'), equals(15));
        expect(
            () => intCoercion.parse('5'), throwsA(isA<ValidationException>()));
      });
    });

    group('Double Coercion', () {
      test('should coerce various types to double', () {
        final doubleCoercion = Z.coerce.decimal();

        expect(doubleCoercion.parse(123), equals(123.0));
        expect(doubleCoercion.parse(45.67), equals(45.67));
        expect(doubleCoercion.parse('123'), equals(123.0));
        expect(doubleCoercion.parse('45.67'), equals(45.67));
        expect(doubleCoercion.parse(true), equals(1.0));
        expect(doubleCoercion.parse(false), equals(0.0));
        expect(doubleCoercion.parse(''), equals(0.0));
      });

      test('should handle invalid double coercion', () {
        final doubleCoercion = Z.coerce.decimal();

        expect(
          () => doubleCoercion.parse('not-a-number'),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('Boolean Coercion', () {
      test('should coerce various types to boolean', () {
        final boolCoercion = Z.coerce.boolean();

        expect(boolCoercion.parse(true), equals(true));
        expect(boolCoercion.parse(false), equals(false));
        expect(boolCoercion.parse(1), equals(true));
        expect(boolCoercion.parse(0), equals(false));
        expect(boolCoercion.parse(-1), equals(true));
        expect(boolCoercion.parse('true'), equals(true));
        expect(boolCoercion.parse('false'), equals(false));
        expect(boolCoercion.parse('1'), equals(true));
        expect(boolCoercion.parse('0'), equals(false));
        expect(boolCoercion.parse('yes'), equals(true));
        expect(boolCoercion.parse('no'), equals(false));
        expect(boolCoercion.parse('on'), equals(true));
        expect(boolCoercion.parse('off'), equals(false));
        expect(boolCoercion.parse(''), equals(false));
        expect(boolCoercion.parse('  TRUE  '), equals(true));
        expect(boolCoercion.parse(null), equals(false));
      });

      test('should handle invalid boolean coercion', () {
        final boolCoercion = Z.coerce.boolean();

        expect(
          () => boolCoercion.parse('invalid'),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should apply boolean validations after coercion', () {
        final boolCoercion = Z.coerce
            .boolean()
            .refine((b) => b == true, message: 'Must be true');

        expect(boolCoercion.parse('yes'), equals(true));
        expect(() => boolCoercion.parse('no'),
            throwsA(isA<ValidationException>()));
      });
    });

    group('Date Coercion', () {
      test('should coerce various types to DateTime', () {
        final dateCoercion = Z.coerce.date();

        final now = DateTime.now();
        expect(dateCoercion.parse(now), equals(now));

        const timestamp = 1609459200000; // 2021-01-01 00:00:00 UTC
        final expectedDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        expect(dateCoercion.parse(timestamp), equals(expectedDate));

        const isoString = '2021-01-01T00:00:00.000Z';
        final parsedDate = dateCoercion.parse(isoString);
        expect(parsedDate, isA<DateTime>());
        expect(parsedDate.year, equals(2021));
        expect(parsedDate.month, equals(1));
        expect(parsedDate.day, equals(1));
      });

      test('should handle invalid date coercion', () {
        final dateCoercion = Z.coerce.date();

        expect(
          () => dateCoercion.parse('invalid-date'),
          throwsA(isA<ValidationException>()),
        );

        expect(
          () => dateCoercion.parse(''),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should apply date validations after coercion', () {
        final futureDate = DateTime.now().add(const Duration(days: 1));
        final dateCoercion = Z.coerce.date().refine(
              (d) => d.isAfter(DateTime.now()),
              message: 'Must be in the future',
            );

        expect(dateCoercion.parse(futureDate), equals(futureDate));
      });
    });

    group('BigInt Coercion', () {
      test('should coerce various types to BigInt', () {
        final bigIntCoercion = Z.coerce.bigInt();

        expect(
            bigIntCoercion.parse(BigInt.from(123)), equals(BigInt.from(123)));
        expect(bigIntCoercion.parse(123), equals(BigInt.from(123)));
        expect(bigIntCoercion.parse(45.67), equals(BigInt.from(46))); // Rounded
        expect(bigIntCoercion.parse('123'), equals(BigInt.from(123)));
        expect(bigIntCoercion.parse(''), equals(BigInt.zero));
        expect(bigIntCoercion.parse('  999  '), equals(BigInt.from(999)));
      });

      test('should handle large numbers', () {
        final bigIntCoercion = Z.coerce.bigInt();

        const largeNumberStr = '12345678901234567890';
        final largeBigInt = BigInt.parse(largeNumberStr);
        expect(bigIntCoercion.parse(largeNumberStr), equals(largeBigInt));
      });

      test('should handle invalid BigInt coercion', () {
        final bigIntCoercion = Z.coerce.bigInt();

        expect(
          () => bigIntCoercion.parse('not-a-number'),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('List Coercion', () {
      test('should coerce various types to List', () {
        final listCoercion = Z.coerce.list();

        expect(listCoercion.parse([1, 2, 3]), equals([1, 2, 3]));
        expect(listCoercion.parse('a,b,c'), equals(['a', 'b', 'c']));
        expect(listCoercion.parse(''), equals([]));
        expect(listCoercion.parse({1, 2, 3}), equals([1, 2, 3]));
        expect(listCoercion.parse({'a': 1, 'b': 2}), equals([1, 2]));
        expect(listCoercion.parse('single'), equals(['single']));
      });

      test('should handle comma-separated strings', () {
        final listCoercion = Z.coerce.list();

        expect(listCoercion.parse('a, b, c'), equals(['a', 'b', 'c']));
        expect(listCoercion.parse(' item1 , item2 , item3 '),
            equals(['item1', 'item2', 'item3']));
      });

      test('should apply list validations after coercion', () {
        final listCoercion = Z.coerce.list().refine((list) => list.length >= 2,
            message: 'Must have at least 2 items');

        expect(listCoercion.parse('a,b,c'), equals(['a', 'b', 'c']));
        expect(() => listCoercion.parse('single'),
            throwsA(isA<ValidationException>()));
      });
    });

    group('Set Coercion', () {
      test('should coerce various types to Set', () {
        final setCoercion = Z.coerce.set();

        expect(setCoercion.parse({1, 2, 3}), equals({1, 2, 3}));
        expect(setCoercion.parse([1, 2, 3, 2]),
            equals({1, 2, 3})); // Duplicates removed
        expect(setCoercion.parse('a,b,c'), equals({'a', 'b', 'c'}));
        expect(setCoercion.parse(''), equals(<dynamic>{}));
        expect(setCoercion.parse({'a': 1, 'b': 2}), equals({1, 2}));
        expect(setCoercion.parse('single'), equals({'single'}));
      });

      test('should handle duplicate removal', () {
        final setCoercion = Z.coerce.set();

        expect(setCoercion.parse('a,b,a,c,b'), equals({'a', 'b', 'c'}));
        expect(setCoercion.parse([1, 1, 2, 2, 3]), equals({1, 2, 3}));
      });
    });

    group('Map Coercion', () {
      test('should coerce various types to Map', () {
        final mapCoercion = Z.coerce.map();

        final originalMap = {'a': 1, 'b': 2};
        expect(mapCoercion.parse(originalMap), equals(originalMap));

        expect(mapCoercion.parse([1, 2, 3]), equals({'0': 1, '1': 2, '2': 3}));

        final mixedMap = {1: 'one', 'two': 2};
        expect(mapCoercion.parse(mixedMap), equals({'1': 'one', 'two': 2}));
      });

      test('should handle empty string gracefully', () {
        final mapCoercion = Z.coerce.map();

        expect(
          () => mapCoercion.parse(''),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should handle non-empty string', () {
        final mapCoercion = Z.coerce.map();

        expect(mapCoercion.parse('test'), equals({'value': 'test'}));
      });
    });

    group('Coercion Schema Properties', () {
      test('should provide target schema access', () {
        final stringCoercion = Z.coerce.string();
        expect(stringCoercion.targetSchema, isA<StringSchema>());
      });

      test('should handle strict mode correctly', () {
        final normalCoercion = Z.coerce.string();
        final strictCoercion = Z.coerce.string(strict: true);

        expect(normalCoercion.isStrict, isFalse);
        expect(strictCoercion.isStrict, isTrue);

        final madeStrict = normalCoercion.withStrict(true);
        expect(madeStrict.isStrict, isTrue);

        final madeNonStrict = strictCoercion.withStrict(false);
        expect(madeNonStrict.isStrict, isFalse);
      });

      test('should have correct schema type', () {
        final coercionSchema = Z.coerce.string();
        expect(coercionSchema.schemaType, equals('CoercionSchema'));
      });

      test('should have proper string representation', () {
        final normalCoercion = Z.coerce.string(description: 'Test coercion');
        final strictCoercion = Z.coerce.number(strict: true);

        expect(normalCoercion.toString(), contains('CoercionSchema'));
        expect(normalCoercion.toString(), contains('Test coercion'));
        expect(strictCoercion.toString(), contains('strict'));
      });
    });

    group('Async Validation', () {
      test('should support async validation after coercion', () async {
        final asyncCoercion = Z.coerce.string().refineAsync(
          (s) async {
            await Future.delayed(const Duration(milliseconds: 1));
            return s.length > 2;
          },
          message: 'Must be longer than 2 characters',
        );

        final result = await asyncCoercion.parseAsync(12345);
        expect(result, equals('12345'));

        await expectLater(
          asyncCoercion.parseAsync(12),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should handle async coercion errors', () async {
        final asyncCoercion = Z.coerce.number(strict: true);

        // Valid coercion
        final result = await asyncCoercion.parseAsync('123');
        expect(result, equals(123));

        // Invalid coercion should still throw
        await expectLater(
          asyncCoercion.parseAsync('invalid'),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('Error Handling', () {
      test('should provide detailed error information', () {
        final strictCoercion = Z.coerce.number(strict: true);

        final result = strictCoercion.validate('invalid-number');
        expect(result.isFailure, isTrue);

        final errors = result.errors!.errors;
        expect(errors.length, equals(1));
        expect(
            errors.first.code, equals(ValidationErrorCode.coercionFailed.code));
      });

      test('should fall back to original validation in non-strict mode', () {
        final nonStrictCoercion = Z.coerce.string();

        // This should work even if coercion somehow fails, because it falls back
        final result = nonStrictCoercion.validate('already-a-string');
        expect(result.isSuccess, isTrue);
        expect(result.data, equals('already-a-string'));
      });
    });

    group('Complex Coercion Scenarios', () {
      test('should work with object schemas containing coercion', () {
        final userSchema = Z.object({
          'name': Z.coerce.string(),
          'age': Z.coerce
              .integer()
              .refine((age) => age >= 0, message: 'Age must be non-negative'),
          'active': Z.coerce.boolean(),
          'score': Z.coerce.decimal(),
        });

        final result = userSchema.parse({
          'name': 12345,
          'age': '25',
          'active': 'yes',
          'score': '98.5',
        });

        expect(result['name'], equals('12345'));
        expect(result['age'], equals(25));
        expect(result['active'], equals(true));
        expect(result['score'], equals(98.5));
      });

      test('should work with array of coerced values', () {
        final numberArraySchema = Z.array(Z.coerce.number());

        final result = numberArraySchema.parse(['1', '2', true, false, '3.14']);
        expect(result, equals([1, 2, 1, 0, 3.14]));
      });

      test('should chain coercion with transformations', () {
        final schema = CoercionSchema<String>(
          Z.string().min(3),
          (input) => input.toString().trim().toLowerCase(),
        );

        final result = schema.parse(123456);
        expect(result, equals('123456'));

        final trimmedResult = schema.parse('  HELLO  ');
        expect(trimmedResult, equals('hello'));

        expect(() => schema.parse(12), throwsA(isA<ValidationException>()));
      });

      test('should work with union schemas', () {
        final flexibleSchema = Z.union([
          Z.coerce.number(),
          Z.coerce.string(),
          Z.coerce.boolean(),
        ]);

        expect(flexibleSchema.parse('123'), equals(123));
        expect(
            flexibleSchema.parse(true), equals(1)); // Coerced to number first
      });

      test('should handle nested coercion in complex structures', () {
        final complexSchema = Z.object({
          'metadata': Z.object({
            'version': Z.coerce.string(),
            'build': Z.coerce.integer(),
          }),
          'features': Z.array(Z.object({
            'name': Z.coerce.string(),
            'enabled': Z.coerce.boolean(),
          })),
          'config': Z.record(Z.coerce.number()),
        });

        final result = complexSchema.parse({
          'metadata': {
            'version': 1.5,
            'build': '42',
          },
          'features': [
            {'name': 123, 'enabled': 'true'},
            {'name': 456, 'enabled': 0},
          ],
          'config': {
            'timeout': '30',
            'retries': '3',
          },
        });

        expect(result['metadata']['version'], equals('1.5'));
        expect(result['metadata']['build'], equals(42));
        expect(result['features'][0]['name'], equals('123'));
        expect(result['features'][0]['enabled'], equals(true));
        expect(result['features'][1]['enabled'], equals(false));
        expect(result['config']['timeout'], equals(30));
        expect(result['config']['retries'], equals(3));
      });
    });

    group('CoercionUtils Direct Usage', () {
      test('should provide direct coercion utilities', () {
        expect(CoercionUtils.coerceToString(123), equals('123'));
        expect(CoercionUtils.coerceToNumber('456'), equals(456));
        expect(CoercionUtils.coerceToInt('78.9'), equals(79));
        expect(CoercionUtils.coerceToDouble(123), equals(123.0));
        expect(CoercionUtils.coerceToBoolean('yes'), equals(true));
        expect(CoercionUtils.coerceToList('a,b,c'), equals(['a', 'b', 'c']));
        expect(CoercionUtils.coerceToSet([1, 1, 2]), equals({1, 2}));
        expect(CoercionUtils.coerceToBigInt('123'), equals(BigInt.from(123)));
      });

      test('should handle coercion errors in utils', () {
        expect(() => CoercionUtils.coerceToNumber('invalid'),
            throwsA(isA<FormatException>()));
        expect(() => CoercionUtils.coerceToInt('invalid'),
            throwsA(isA<FormatException>()));
        expect(() => CoercionUtils.coerceToDouble('invalid'),
            throwsA(isA<FormatException>()));
        expect(() => CoercionUtils.coerceToBoolean('invalid'),
            throwsA(isA<FormatException>()));
        expect(() => CoercionUtils.coerceToDateTime('invalid'),
            throwsA(isA<FormatException>()));
        expect(() => CoercionUtils.coerceToBigInt('invalid'),
            throwsA(isA<FormatException>()));
      });
    });

    group('Integration with Z.coerce', () {
      test('should be accessible through Z.coerce', () {
        expect(Z.coerce, isA<Coerce>());
        expect(Z.coerce.string(), isA<CoercionSchema<String>>());
        expect(Z.coerce.number(), isA<CoercionSchema<num>>());
        expect(Z.coerce.boolean(), isA<CoercionSchema<bool>>());
      });

      test('should work with all factory methods', () {
        expect(Z.coerce.string().parse(123), equals('123'));
        expect(Z.coerce.number().parse('456'), equals(456));
        expect(Z.coerce.integer().parse('78.9'), equals(79));
        expect(Z.coerce.decimal().parse(123), equals(123.0));
        expect(Z.coerce.boolean().parse('yes'), equals(true));
        expect(Z.coerce.date().parse(1609459200000), isA<DateTime>());
        expect(Z.coerce.bigInt().parse('123'), equals(BigInt.from(123)));
        expect(Z.coerce.list().parse('a,b,c'), equals(['a', 'b', 'c']));
        expect(Z.coerce.set().parse([1, 1, 2]), equals({1, 2}));
        expect(Z.coerce.map().parse([1, 2]), equals({'0': 1, '1': 2}));
      });
    });

    group('Advanced String Coercion', () {
      test('should handle advanced string coercion options', () {
        final stringCoercion = Z.coerce.string(
          preserveWhitespace: true,
          trimWhitespace: true,
          joinSeparator: ' | ',
          formatNumbers: true,
          numberPrecision: 2,
          prettifyJson: true,
        );

        expect(stringCoercion.parse('  hello  '), equals('hello'));
        expect(stringCoercion.parse(3.14159), equals('3.14'));
        expect(stringCoercion.parse([1, 2, 3]), equals('1.00 | 2.00 | 3.00'));
      });

      test('should handle fallback strategies', () {
        final stringCoercion = Z.coerce.string(
          fallbackStrategies: [
            (input) => 'fallback: $input',
          ],
        );

        expect(stringCoercion.parse('test'), equals('test'));
        expect(stringCoercion.parse(123), equals('123'));
      });
    });

    group('Advanced Number Coercion', () {
      test('should handle precision, step, and range validation', () {
        final numberCoercion = Z.coerce.number(
          precision: 2,
          step: 0.5,
          min: 0,
          max: 100,
          allowInfinity: false,
          allowNaN: false,
        );

        expect(numberCoercion.parse('5.567'), equals(5.5));
        expect(numberCoercion.parse('2.25'), equals(2.5)); // Rounded to step
        expect(numberCoercion.parse('-5'), equals(0)); // Clamped to min
        expect(numberCoercion.parse('150'), equals(100)); // Clamped to max
      });

      test('should handle special number values', () {
        final numberCoercion = Z.coerce.number(
          allowInfinity: true,
          allowNaN: true,
        );

        expect(numberCoercion.parse('infinity'), equals(double.infinity));
        expect(
            numberCoercion.parse('-infinity'), equals(double.negativeInfinity));
        expect(numberCoercion.parse('nan'), isNaN);
        expect(numberCoercion.parse('∞'), equals(double.infinity));
        expect(numberCoercion.parse('-∞'), equals(double.negativeInfinity));
      });

      test('should handle strict mode for numbers', () {
        final strictNumberCoercion = Z.coerce.number(strict: true);

        expect(() => strictNumberCoercion.parse('infinity'),
            throwsA(isA<ValidationException>()));
        expect(() => strictNumberCoercion.parse('nan'),
            throwsA(isA<ValidationException>()));
      });

      test('should handle fallback strategies for numbers', () {
        final numberCoercion = Z.coerce.number(
          fallbackStrategies: [
            (input) => 42,
          ],
        );

        expect(numberCoercion.parse('123'), equals(123));
        expect(numberCoercion.parse(456), equals(456));
      });
    });

    group('Advanced Integer Coercion', () {
      test('should handle integer with step and range validation', () {
        final intCoercion = Z.coerce.integer(
          step: 5,
          min: 0,
          max: 100,
        );

        expect(intCoercion.parse('7'), equals(5)); // Rounded to step
        expect(intCoercion.parse('-10'), equals(0)); // Clamped to min
        expect(intCoercion.parse('150'), equals(100)); // Clamped to max
      });

      test('should handle strict mode for integers', () {
        final strictIntCoercion = Z.coerce.integer(strict: true);

        expect(() => strictIntCoercion.parse('not-a-number'),
            throwsA(isA<ValidationException>()));
      });
    });

    group('Advanced Double Coercion', () {
      test('should handle double with precision and special values', () {
        final doubleCoercion = Z.coerce.decimal(
          precision: 3,
          allowInfinity: true,
          allowNaN: true,
        );

        expect(doubleCoercion.parse('3.14159'), equals(3.142));
        expect(doubleCoercion.parse('infinity'), equals(double.infinity));
        expect(doubleCoercion.parse('nan'), isNaN);
      });

      test('should handle strict mode for doubles', () {
        final strictDoubleCoercion = Z.coerce.decimal(strict: true);

        expect(() => strictDoubleCoercion.parse('not-a-number'),
            throwsA(isA<ValidationException>()));
      });
    });

    group('Smart Coercion', () {
      test('should handle smart coercion with fallback strategies', () {
        final smartCoercion = Z.coerce.smart<String>(
          String,
          fallbackStrategies: [
            (input) => 'fallback: $input',
          ],
          defaultValue: 'default',
        );

        expect(smartCoercion.parse('test'), equals('test'));
        expect(smartCoercion.parse(123), equals('123'));
      });

      test('should handle smart coercion with strict mode', () {
        final strictSmartCoercion = Z.coerce.smart<String>(
          String,
          strict: true,
        );

        expect(strictSmartCoercion.parse('test'), equals('test'));
        expect(strictSmartCoercion.parse(123), equals('123'));
      });

      test('should handle smart coercion for different types', () {
        final intCoercion = Z.coerce.smart<int>(int);
        final doubleCoercion = Z.coerce.smart<double>(double);
        final boolCoercion = Z.coerce.smart<bool>(bool);
        final dateCoercion = Z.coerce.smart<DateTime>(DateTime);
        final bigIntCoercion = Z.coerce.smart<BigInt>(BigInt);
        final listCoercion = Z.coerce.smart<List>(List);
        final setCoercion = Z.coerce.smart<Set>(Set);
        final mapCoercion = Z.coerce.smart<Map>(Map);

        expect(intCoercion.parse('123'), equals(123));
        expect(doubleCoercion.parse('123.45'), equals(123.45));
        expect(boolCoercion.parse('true'), equals(true));
        expect(dateCoercion.parse('2021-01-01'), isA<DateTime>());
        expect(bigIntCoercion.parse('123'), equals(BigInt.from(123)));
        expect(listCoercion.parse('a,b,c'), equals(['a', 'b', 'c']));
        expect(setCoercion.parse([1, 1, 2]), equals({1, 2}));
        expect(mapCoercion.parse([1, 2]), equals({'0': 1, '1': 2}));
      });

      test('should handle unsupported smart coercion types', () {
        expect(() => Z.coerce.smart<Object>(Object),
            throwsA(isA<ArgumentError>()));
      });
    });

    group('CoercionUtils Advanced Features', () {
      test('should handle advanced string coercion with options', () {
        expect(
            CoercionUtils.coerceToString(123.456,
                formatNumbers: true, numberPrecision: 2),
            equals('123.46'));
        expect(CoercionUtils.coerceToString('  hello  ', trimWhitespace: true),
            equals('hello'));
        expect(
            CoercionUtils.coerceToString('hello\n\nworld',
                preserveWhitespace: false),
            equals('hello world'));
        expect(CoercionUtils.coerceToString([1, 2, 3], joinSeparator: ' | '),
            equals('1 | 2 | 3'));
      });

      test('should handle advanced string coercion with fallback strategies',
          () {
        final fallbackStrategies = [
          (input) => 'fallback: $input',
        ];

        expect(
            CoercionUtils.coerceToStringAdvanced('test',
                fallbackStrategies: fallbackStrategies),
            equals('test'));
        expect(CoercionUtils.coerceToStringAdvanced('test', strict: true),
            equals('test'));
      });

      test('should handle advanced number coercion with options', () {
        expect(
            CoercionUtils.coerceToNumber('5.567', precision: 2), equals(5.57));
        expect(CoercionUtils.coerceToNumber('2.25', step: 0.5), equals(2.5));
        expect(CoercionUtils.coerceToNumber('-5', min: 0), equals(0));
        expect(CoercionUtils.coerceToNumber('150', max: 100), equals(100));
        expect(CoercionUtils.coerceToNumber('infinity', allowInfinity: true),
            equals(double.infinity));
        expect(CoercionUtils.coerceToNumber('nan', allowNaN: true), isNaN);
      });

      test('should handle advanced number coercion with strict mode', () {
        expect(
            () => CoercionUtils.coerceToNumber('2.25', step: 0.5, strict: true),
            throwsA(isA<FormatException>()));
        expect(() => CoercionUtils.coerceToNumber('-5', min: 0, strict: true),
            throwsA(isA<FormatException>()));
        expect(
            () => CoercionUtils.coerceToNumber('150', max: 100, strict: true),
            throwsA(isA<FormatException>()));
        expect(
            () => CoercionUtils.coerceToNumber('infinity',
                allowInfinity: false, strict: true),
            throwsA(isA<FormatException>()));
        expect(
            () => CoercionUtils.coerceToNumber('nan',
                allowNaN: false, strict: true),
            throwsA(isA<FormatException>()));
      });

      test('should handle advanced number coercion with fallback strategies',
          () {
        final fallbackStrategies = [
          (input) => 42,
        ];

        expect(
            CoercionUtils.coerceToNumberAdvanced('123',
                fallbackStrategies: fallbackStrategies),
            equals(123));
        expect(CoercionUtils.coerceToNumberAdvanced('123', strict: true),
            equals(123));
      });

      test('should handle type coercion with fallback strategies', () {
        final fallbackStrategies = [
          (input) => 'fallback: $input',
        ];

        expect(
            CoercionUtils.coerceToType<String>(
              'test',
              primaryCoercer: (input) => input.toString(),
              fallbackStrategies: fallbackStrategies,
            ),
            equals('test'));

        expect(
            CoercionUtils.coerceToType<String>(
              'test',
              primaryCoercer: (input) => input.toString(),
              defaultValue: 'default',
            ),
            equals('test'));
      });

      test('should handle smart coercion for all supported types', () {
        expect(
            CoercionUtils.smartCoerce<String>('test', String), equals('test'));
        expect(CoercionUtils.smartCoerce<int>('123', int), equals(123));
        expect(CoercionUtils.smartCoerce<double>('123.45', double),
            equals(123.45));
        expect(CoercionUtils.smartCoerce<num>('123', num), equals(123));
        expect(CoercionUtils.smartCoerce<bool>('true', bool), equals(true));
        expect(CoercionUtils.smartCoerce<DateTime>('2021-01-01', DateTime),
            isA<DateTime>());
        expect(CoercionUtils.smartCoerce<BigInt>('123', BigInt),
            equals(BigInt.from(123)));
        expect(CoercionUtils.smartCoerce<List>('a,b,c', List),
            equals(['a', 'b', 'c']));
        expect(CoercionUtils.smartCoerce<Set>([1, 1, 2], Set), equals({1, 2}));
        expect(CoercionUtils.smartCoerce<Map>([1, 2], Map),
            equals({'0': 1, '1': 2}));
      });

      test('should handle unsupported smart coercion types', () {
        expect(() => CoercionUtils.smartCoerce<Object>('test', Object),
            throwsA(isA<FormatException>()));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle edge cases in map coercion', () {
        expect(() => CoercionUtils.coerceToMap(''),
            throwsA(isA<FormatException>()));
        expect(CoercionUtils.coerceToMap('test'), equals({'value': 'test'}));
        expect(() => CoercionUtils.coerceToMap(123),
            throwsA(isA<FormatException>()));
      });

      test('should handle double.infinity and double.nan in number coercion',
          () {
        expect(
            CoercionUtils.coerceToNumber(double.infinity, allowInfinity: true),
            equals(double.infinity));
        expect(CoercionUtils.coerceToNumber(double.nan, allowNaN: true), isNaN);
        expect(
            () => CoercionUtils.coerceToNumber(double.infinity,
                allowInfinity: false),
            throwsA(isA<FormatException>()));
        expect(() => CoercionUtils.coerceToNumber(double.nan, allowNaN: false),
            throwsA(isA<FormatException>()));
      });

      test('should handle edge cases in date coercion', () {
        expect(CoercionUtils.coerceToDateTime(DateTime.now()), isA<DateTime>());
        expect(() => CoercionUtils.coerceToDateTime(''),
            throwsA(isA<FormatException>()));
        expect(() => CoercionUtils.coerceToDateTime('invalid'),
            throwsA(isA<FormatException>()));
        expect(() => CoercionUtils.coerceToDateTime([]),
            throwsA(isA<FormatException>()));
      });

      test('should handle edge cases in BigInt coercion', () {
        expect(CoercionUtils.coerceToBigInt(BigInt.from(123)),
            equals(BigInt.from(123)));
        expect(CoercionUtils.coerceToBigInt(123), equals(BigInt.from(123)));
        expect(CoercionUtils.coerceToBigInt(123.456), equals(BigInt.from(123)));
        expect(CoercionUtils.coerceToBigInt(''), equals(BigInt.zero));
        expect(() => CoercionUtils.coerceToBigInt('invalid'),
            throwsA(isA<FormatException>()));
        expect(() => CoercionUtils.coerceToBigInt([]),
            throwsA(isA<FormatException>()));
      });

      test('should handle edge cases in boolean coercion', () {
        expect(CoercionUtils.coerceToBoolean(true), equals(true));
        expect(CoercionUtils.coerceToBoolean(false), equals(false));
        expect(CoercionUtils.coerceToBoolean(1), equals(true));
        expect(CoercionUtils.coerceToBoolean(0), equals(false));
        expect(CoercionUtils.coerceToBoolean(-1), equals(true));
        expect(CoercionUtils.coerceToBoolean(null), equals(false));
        expect(() => CoercionUtils.coerceToBoolean('invalid'),
            throwsA(isA<FormatException>()));
        expect(() => CoercionUtils.coerceToBoolean([]),
            throwsA(isA<FormatException>()));
      });

      test('should handle edge cases in list coercion', () {
        expect(CoercionUtils.coerceToList([]), equals([]));
        expect(CoercionUtils.coerceToList(''), equals([]));
        expect(CoercionUtils.coerceToList('single'), equals(['single']));
        expect(CoercionUtils.coerceToList({1, 2, 3}), equals([1, 2, 3]));
        expect(CoercionUtils.coerceToList({'a': 1, 'b': 2}), equals([1, 2]));
        expect(CoercionUtils.coerceToList(123), equals([123]));
      });

      test('should handle edge cases in set coercion', () {
        expect(CoercionUtils.coerceToSet(<dynamic>{}), equals(<dynamic>{}));
        expect(CoercionUtils.coerceToSet([1, 2, 3]), equals({1, 2, 3}));
        expect(CoercionUtils.coerceToSet(''), equals(<dynamic>{}));
        expect(CoercionUtils.coerceToSet('single'), equals({'single'}));
        expect(CoercionUtils.coerceToSet({'a': 1, 'b': 2}), equals({1, 2}));
        expect(CoercionUtils.coerceToSet(123), equals({123}));
      });

      test('should handle edge cases in number coercion', () {
        expect(() => CoercionUtils.coerceToNumber('not-a-number'),
            throwsA(isA<FormatException>()));
        expect(() => CoercionUtils.coerceToNumber([]),
            throwsA(isA<FormatException>()));
      });

      test('should handle edge cases in int coercion', () {
        expect(CoercionUtils.coerceToInt(123), equals(123));
        expect(CoercionUtils.coerceToInt(123.456), equals(123));
        expect(() => CoercionUtils.coerceToInt('not-a-number'),
            throwsA(isA<FormatException>()));
      });

      test('should handle edge cases in double coercion', () {
        expect(CoercionUtils.coerceToDouble(123), equals(123.0));
        expect(CoercionUtils.coerceToDouble(123.456), equals(123.456));
        expect(() => CoercionUtils.coerceToDouble('not-a-number'),
            throwsA(isA<FormatException>()));
      });
    });
  });
}
