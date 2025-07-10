import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('Schema Introspection Methods', () {
    group('describe() method', () {
      test('should add description to schema', () {
        final schema = Z.string().describe('User name');

        expect(schema.description, equals('User name'));
        expect(schema.metadata, isNull);
      });

      test('should add description and metadata to schema', () {
        final metadata = {'required': true, 'maxLength': 50};
        final schema = Z.string().describe('User name', metadata: metadata);

        expect(schema.description, equals('User name'));
        expect(schema.metadata, equals(metadata));
      });

      test('should preserve validation behavior', () {
        final schema = Z.string().min(3).describe('User name');

        expect(schema.parse('John'), equals('John'));
        expect(() => schema.parse('Jo'), throwsA(isA<ValidationException>()));
      });

      test('should work with async validation', () async {
        final schema = Z
            .string()
            .refineAsync(
              (value) => Future.value(value.length > 2),
              message: 'Must be longer than 2 characters',
            )
            .describe('Async validated name');

        expect(await schema.parseAsync('John'), equals('John'));
        expect(schema.description, equals('Async validated name'));
      });

      test('should chain with other methods', () {
        final schema = Z.string().min(3).describe('User name').optional();

        expect(schema.safeParse(null), isNull);
        expect(schema.safeParse('John'), equals('John'));
      });

      test('should override previous description', () {
        final schema = Z
            .string()
            .describe('First description')
            .describe('Second description');

        expect(schema.description, equals('Second description'));
      });

      test('should work with complex metadata', () {
        final metadata = {
          'validation': {
            'rules': ['min_length', 'no_spaces'],
            'priority': 'high'
          },
          'ui': {
            'placeholder': 'Enter your name',
            'helpText': 'Full name required'
          }
        };

        final schema =
            Z.string().describe('Complex metadata schema', metadata: metadata);

        expect(schema.metadata, equals(metadata));
        expect(schema.metadata!['validation']['rules'], contains('min_length'));
      });
    });

    group('brand() method', () {
      test('should create branded type', () {
        final userIdSchema = Z.string().brand<String>();
        final result = userIdSchema.parse('user123');

        expect(result, isA<Branded<String, String>>());
        expect(result.value, equals('user123'));
      });

      test('should maintain type safety between different brands', () {
        final userIdSchema = Z.string().brand<String>();
        final productIdSchema = Z.string().brand<int>();

        final userId = userIdSchema.parse('user123');
        final productId = productIdSchema.parse('product456');

        expect(userId.runtimeType, isNot(equals(productId.runtimeType)));
        expect(userId, isA<Branded<String, String>>());
        expect(productId, isA<Branded<String, int>>());
      });

      test('should work with validation failures', () {
        final userIdSchema = Z.string().min(5).brand<String>();

        expect(() => userIdSchema.parse('123'),
            throwsA(isA<ValidationException>()));
      });

      test('should work with async validation', () async {
        final schema = Z
            .string()
            .refineAsync(
              (value) => Future.value(value.isNotEmpty),
            )
            .brand<String>();

        final result = await schema.parseAsync('test');
        expect(result, isA<Branded<String, String>>());
        expect(result.value, equals('test'));
      });

      test('should support chaining with other methods', () {
        final schema = Z.string().min(3).brand<String>().optional();

        expect(schema.safeParse(null), isNull);
        final result = schema.safeParse('test');
        expect(result, isA<Branded<String, String>>());
        expect(result!.value, equals('test'));
      });

      test('should work with different base types', () {
        final numberBrandSchema = Z.number().positive().brand<String>();
        final result = numberBrandSchema.parse(42);

        expect(result, isA<Branded<num, String>>());
        expect(result.value, equals(42));
      });

      test('should preserve equality for same values and brands', () {
        final schema = Z.string().brand<String>();
        final value1 = schema.parse('test');
        final value2 = schema.parse('test');

        expect(value1, equals(value2));
        expect(value1.hashCode, equals(value2.hashCode));
      });

      test('should differentiate between different brand types', () {
        final userIdSchema = Z.string().brand<String>();
        final emailSchema = Z.string().brand<int>();

        final userId = userIdSchema.parse('test');
        final email = emailSchema.parse('test');

        expect(userId, isNot(equals(email)));
      });
    });

    group('readonly() method', () {
      test('should create readonly wrapper', () {
        final schema = Z.string().readonly();
        final result = schema.parse('test');

        expect(result, isA<Readonly<String>>());
        expect(result.value, equals('test'));
      });

      test('should work with validation failures', () {
        final schema = Z.string().min(5).readonly();

        expect(() => schema.parse('123'), throwsA(isA<ValidationException>()));
      });

      test('should work with async validation', () async {
        final schema = Z
            .string()
            .refineAsync(
              (value) => Future.value(value.isNotEmpty),
            )
            .readonly();

        final result = await schema.parseAsync('test');
        expect(result, isA<Readonly<String>>());
        expect(result.value, equals('test'));
      });

      test('should support chaining with other methods', () {
        final schema = Z.string().min(3).readonly().optional();

        expect(schema.safeParse(null), isNull);
        final result = schema.safeParse('test');
        expect(result, isA<Readonly<String>>());
        expect(result!.value, equals('test'));
      });

      test('should work with complex objects', () {
        final schema = Z.object({
          'name': Z.string(),
          'age': Z.number(),
        }).readonly();

        final input = {'name': 'John', 'age': 30};
        final result = schema.parse(input);

        expect(result, isA<Readonly<Map<String, dynamic>>>());
        expect(result.value, equals(input));
      });

      test('should work with arrays', () {
        final schema = Z.array(Z.string()).readonly();
        final input = ['a', 'b', 'c'];
        final result = schema.parse(input);

        expect(result, isA<Readonly<List<String>>>());
        expect(result.value, equals(input));
      });

      test('should preserve equality for same values', () {
        final schema = Z.string().readonly();
        final value1 = schema.parse('test');
        final value2 = schema.parse('test');

        expect(value1, equals(value2));
        expect(value1.hashCode, equals(value2.hashCode));
      });

      test('should work with different types', () {
        final stringSchema = Z.string().readonly();
        final numberSchema = Z.number().readonly();

        final stringResult = stringSchema.parse('test');
        final numberResult = numberSchema.parse(42);

        expect(stringResult, isA<Readonly<String>>());
        expect(numberResult, isA<Readonly<num>>());
        expect(stringResult.value, equals('test'));
        expect(numberResult.value, equals(42));
      });
    });

    group('Method combinations', () {
      test('should combine describe, brand, and readonly', () {
        final schema = Z
            .string()
            .min(3)
            .describe('User ID')
            .brand<String>()
            .readonly()
            .optional();

        expect(schema.safeParse(null), isNull);

        final result = schema.safeParse('user123');
        expect(result, isA<Readonly<Branded<String, String>>>());
        expect(result!.value.value, equals('user123'));
      });

      test('should work with complex validation chains', () {
        final schema = Z
            .string()
            .email()
            .describe('User email address')
            .refine((email) => !email.contains('temp'),
                message: 'Temporary emails not allowed')
            .brand<String>()
            .readonly();

        final result = schema.parse('user@example.com');
        expect(result, isA<Readonly<Branded<String, String>>>());
        expect(result.value.value, equals('user@example.com'));

        expect(() => schema.parse('user@temp.com'),
            throwsA(isA<ValidationException>()));
      });

      test('should support async validation in combinations', () async {
        final schema = Z
            .string()
            .describe('Async validated user ID')
            .refineAsync((value) => Future.value(value.length > 5))
            .brand<String>()
            .readonly();

        final result = await schema.parseAsync('user123');
        expect(result, isA<Readonly<Branded<String, String>>>());
        expect(result.value.value, equals('user123'));
      });
    });

    group('Error handling', () {
      test('should preserve error messages in describe chains', () {
        final schema = Z
            .string()
            .min(5)
            .refine((value) => value.length >= 5, message: 'Too short')
            .describe('User name');

        try {
          schema.parse('abc');
          fail('Should have thrown ValidationException');
        } catch (e) {
          expect(e, isA<ValidationException>());
          expect(e.toString(), contains('minimum length'));
        }
      });

      test('should preserve error context in brand chains', () {
        final schema = Z.string().email().brand<String>();

        try {
          schema.parse('invalid-email');
          fail('Should have thrown ValidationException');
        } catch (e) {
          expect(e, isA<ValidationException>());
          expect(e.toString(), contains('email'));
        }
      });

      test('should preserve error context in readonly chains', () {
        final schema = Z.number().positive().readonly();

        try {
          schema.parse(-5);
          fail('Should have thrown ValidationException');
        } catch (e) {
          expect(e, isA<ValidationException>());
          expect(e.toString(), contains('positive'));
        }
      });
    });
  });
}
