import 'package:dzod/dzod.dart';
import 'package:dzod/src/schemas/specialized/enum_schema.dart';
import 'package:test/test.dart';

// Test enum for testing
enum Color { red, green, blue }

void main() {
  group('Enum Schema Tests', () {
    group('Basic Enum Validation', () {
      test('validates string enum values', () {
        final schema = z.enum_(['red', 'green', 'blue']);
        final result = schema.validate('red');

        expect(result.isSuccess, true);
        expect(result.data, 'red');
      });

      test('validates numeric enum values', () {
        final schema = z.enum_([1, 2, 3]);
        final result = schema.validate(2);

        expect(result.isSuccess, true);
        expect(result.data, 2);
      });

      test('validates boolean enum values', () {
        final schema = z.enum_([true, false]);
        final result = schema.validate(true);

        expect(result.isSuccess, true);
        expect(result.data, true);
      });

      test('fails on invalid enum value', () {
        final schema = z.enum_(['red', 'green', 'blue']);
        final result = schema.validate('yellow');

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.code, 'invalid_enum_value');
      });

      test('fails on wrong type', () {
        final schema = z.enum_(['red', 'green', 'blue']);
        final result = schema.validate(123);

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.code, 'invalid_enum_value');
      });
    });

    group('Case-Insensitive String Enum', () {
      test('validates case-insensitive string enum', () {
        final schema = z.enum_(['Red', 'Green', 'Blue']).caseInsensitive();
        final result = schema.validate('red');

        expect(result.isSuccess, true);
        expect(result.data, 'Red'); // Returns the original cased value
      });

      test('validates mixed case input', () {
        final schema = z.enum_(['Hello', 'World']).caseInsensitive();
        final result = schema.validate('HELLO');

        expect(result.isSuccess, true);
        expect(result.data, 'Hello');
      });

      test('fails on invalid case-insensitive value', () {
        final schema = z.enum_(['red', 'green', 'blue']).caseInsensitive();
        final result = schema.validate('yellow');

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.code, 'invalid_enum_value');
      });

      test('case-insensitive only works with string enums', () {
        final schema = z.enum_([1, 2, 3]).caseInsensitive();
        final result = schema.validate(1);

        expect(result.isSuccess, true);
        expect(result.data, 1);
      });
    });

    group('Enum Manipulation Methods', () {
      test('exclude removes specific values', () {
        final schema =
            z.enum_(['red', 'green', 'blue', 'yellow']).exclude(['yellow']);
        final result1 = schema.validate('red');
        final result2 = schema.validate('yellow');

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('exclude throws error when excluding all values', () {
        final schema = z.enum_(['red', 'green']);
        expect(() => schema.exclude(['red', 'green']), throwsArgumentError);
      });

      test('include filters to specific values', () {
        final schema = z
            .enum_(['red', 'green', 'blue', 'yellow']).include(['red', 'blue']);
        final result1 = schema.validate('red');
        final result2 = schema.validate('green');

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('include throws error when no valid values', () {
        final schema = z.enum_(['red', 'green']);
        expect(() => schema.include(['yellow']), throwsArgumentError);
      });

      test('extend adds additional values', () {
        final schema = z.enum_(['red', 'green']).extend(['blue', 'yellow']);
        final result1 = schema.validate('red');
        final result2 = schema.validate('blue');

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, true);
      });

      test('chaining manipulation methods', () {
        final schema = z.enum_(['red', 'green', 'blue', 'yellow']).exclude(
            ['yellow']).extend(['purple']).include(['red', 'purple']);
        final result1 = schema.validate('red');
        final result2 = schema.validate('purple');
        final result3 = schema.validate('green');

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, true);
        expect(result3.isSuccess, false);
      });
    });

    group('Enum Property Access', () {
      test('gets enum values', () {
        final schema = z.enum_(['red', 'green', 'blue']);
        expect(schema.values, ['red', 'green', 'blue']);
      });

      test('gets enum length', () {
        final schema = z.enum_(['red', 'green', 'blue']);
        expect(schema.length, 3);
      });

      test('checks if enum contains value', () {
        final schema = z.enum_(['red', 'green', 'blue']);
        expect(schema.contains('red'), true);
        expect(schema.contains('yellow'), false);
      });

      test('checks if enum is empty', () {
        final schema1 = z.enum_(['red']);

        expect(schema1.isEmpty, false);
        expect(schema1.isNotEmpty, true);
        expect(() => z.enum_(['red']).exclude(['red']),
            throwsArgumentError); // Can't create empty enum
      });

      test('gets first and last values', () {
        final schema = z.enum_(['red', 'green', 'blue']);
        expect(schema.first, 'red');
        expect(schema.last, 'blue');
      });

      test('throws error for first/last on empty enum', () {
        // Test with direct construction of empty enum to check error handling
        const emptyEnum = EnumSchema<String>([]);
        
        expect(() => emptyEnum.first, throwsA(isA<StateError>()));
        expect(() => emptyEnum.last, throwsA(isA<StateError>()));
      });
    });

    group('Enum Transformation Methods', () {
      test('map transforms enum values', () {
        final schema = z.enum_(['red', 'green', 'blue']).map<String>(
            (value) => value.toUpperCase());
        final result = schema.validate('red');

        expect(result.isSuccess, true);
        expect(result.data, 'RED');
      });

      test('where filters enum with condition', () {
        final schema = z
            .enum_(['red', 'green', 'blue']).where((value) => value.length > 3);
        final result1 = schema.validate('green');
        final result2 = schema.validate('red');

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('nullable creates nullable enum', () {
        final schema = z.enum_(['red', 'green', 'blue']).nullable();
        final result1 = schema.validate('red');
        final result2 = schema.validate(null);

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, true);
      });

      test('optional creates optional enum', () {
        final schema = z.enum_(['red', 'green', 'blue']).optional();
        final result1 = schema.validate('red');
        final result2 = schema.validate(null);

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, true);
      });
    });

    group('Enum Factory Methods', () {
      test('creates string enum', () {
        final schema = EnumFactories.stringEnum(['red', 'green', 'blue']);
        final result = schema.validate('red');

        expect(result.isSuccess, true);
        expect(result.data, 'red');
      });

      test('creates numeric enum', () {
        final schema = EnumFactories.numericEnum([1, 2, 3]);
        final result = schema.validate(2);

        expect(result.isSuccess, true);
        expect(result.data, 2);
      });

      test('creates integer enum', () {
        final schema = EnumFactories.intEnum([1, 2, 3]);
        final result = schema.validate(2);

        expect(result.isSuccess, true);
        expect(result.data, 2);
      });

      test('creates boolean enum', () {
        final schema = EnumFactories.boolEnum();
        final result1 = schema.validate(true);
        final result2 = schema.validate(false);

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, true);
      });

      test('creates custom boolean enum', () {
        final schema = EnumFactories.boolEnum([true]);
        final result1 = schema.validate(true);
        final result2 = schema.validate(false);

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false);
      });

      test('creates enum from Dart enum', () {
        final schema = EnumFactories.fromEnum(Color.values);
        final result = schema.validate(Color.red);

        expect(result.isSuccess, true);
        expect(result.data, Color.red);
      });

      test('creates native enum', () {
        final schema = EnumFactories.nativeEnum([Color.red, Color.green]);
        final result = schema.validate(Color.red);

        expect(result.isSuccess, true);
        expect(result.data, Color.red);
      });

      test('factory methods throw on empty values', () {
        expect(() => EnumFactories.stringEnum([]), throwsArgumentError);
        expect(() => EnumFactories.numericEnum([]), throwsArgumentError);
        expect(() => EnumFactories.intEnum([]), throwsArgumentError);
        expect(() => EnumFactories.fromEnum<Color>([]), throwsArgumentError);
        expect(() => EnumFactories.nativeEnum<String>([]), throwsArgumentError);
      });
    });

    group('Enum Schema Equality and HashCode', () {
      test('schemas with same values are equal', () {
        final schema1 = z.enum_(['red', 'green', 'blue']);
        final schema2 = z.enum_(['red', 'green', 'blue']);

        expect(schema1 == schema2, true);
        expect(schema1.hashCode == schema2.hashCode, true);
      });

      test('schemas with different values are not equal', () {
        final schema1 = z.enum_(['red', 'green', 'blue']);
        final schema2 = z.enum_(['red', 'yellow', 'blue']);

        expect(schema1 == schema2, false);
      });

      test('schemas with different case sensitivity are not equal', () {
        final schema1 = z.enum_(['red', 'green', 'blue']);
        final schema2 = z.enum_(['red', 'green', 'blue']).caseInsensitive();

        expect(schema1 == schema2, false);
      });

      test('schemas with same values but different order are not equal', () {
        final schema1 = z.enum_(['red', 'green', 'blue']);
        final schema2 = z.enum_(['blue', 'green', 'red']);

        expect(schema1 == schema2, false);
      });
    });

    group('Enum Schema toString', () {
      test('displays enum values correctly', () {
        final schema = z.enum_(['red', 'green', 'blue']);
        final str = schema.toString();

        expect(str, contains('EnumSchema'));
        expect(str, contains('red'));
        expect(str, contains('green'));
        expect(str, contains('blue'));
      });

      test('displays case-insensitive flag', () {
        final schema = z.enum_(['red', 'green', 'blue']).caseInsensitive();
        final str = schema.toString();

        expect(str, contains('case-insensitive'));
      });

      test('truncates long enum lists', () {
        final schema = z.enum_(['a', 'b', 'c', 'd', 'e', 'f']);
        final str = schema.toString();

        expect(str, contains('...'));
      });
    });

    group('Enum Schema Error Handling', () {
      test('provides detailed error information', () {
        final schema = z.enum_(['red', 'green', 'blue']);
        final result = schema.validate('yellow');

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.code, 'invalid_enum_value');
        expect(result.errors!.errors.first.context!['allowedValues'],
            ['red', 'green', 'blue']);
      });

      test('includes case-insensitive flag in error context', () {
        final schema = z.enum_(['red', 'green', 'blue']).caseInsensitive();
        final result = schema.validate('yellow');

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.context!['caseInsensitive'], true);
      });

      test('preserves error context in refinement', () {
        final schema = z.enum_(['red', 'green', 'blue']).refine(
            (value) => value != 'red',
            message: 'red not allowed');
        final result = schema.validate('red');

        expect(result.isSuccess, false);
        expect(result.errors!.errors.first.message, 'red not allowed');
      });

      test('provides proper error path in nested validation', () {
        final schema = z.array(z.enum_(['red', 'green', 'blue']));
        final result = schema.validate(['red', 'yellow', 'blue']);

        expect(result.isSuccess, false);
        expect(result.errors!.errors.any((e) => e.path.contains('1')), true);
      });
    });

    group('Enum Schema Advanced Usage', () {
      test('works with complex objects', () {
        final userObj = {'type': 'user', 'id': 1};
        final adminObj = {'type': 'admin', 'id': 2};
        final schema = z.enum_([userObj, adminObj]);
        final result = schema.validate(userObj);

        expect(result.isSuccess, true);
        expect(result.data, userObj);
      });

      test('works with mixed types', () {
        final schema = z.enum_([1, 'two', true, null]);
        final result1 = schema.validate(1);
        final result2 = schema.validate('two');
        final result3 = schema.validate(true);
        final result4 = schema.validate(null);

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, true);
        expect(result3.isSuccess, true);
        expect(result4.isSuccess, true);
      });

      test('handles duplicate values', () {
        final schema = z.enum_(['red', 'red', 'green']);
        final result = schema.validate('red');

        expect(result.isSuccess, true);
        expect(result.data, 'red');
      });

      test('works with refinement chains', () {
        final schema = z
            .enum_(['red', 'green', 'blue'])
            .refine((value) => value.length > 3, message: 'too short')
            .refine((value) => value != 'green', message: 'green not allowed');

        final result1 = schema.validate('blue');
        final result2 = schema.validate('red');
        final result3 = schema.validate('green');

        expect(result1.isSuccess, true);
        expect(result2.isSuccess, false); // too short
        expect(result3.isSuccess, false); // green not allowed
      });
    });
  });
}
