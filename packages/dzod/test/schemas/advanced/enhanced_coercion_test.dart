import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('Enhanced Coercion Tests', () {
    group('Basic Coercion Tests', () {
      test('should handle string coercion', () {
        final schema = Z.coerce.string();

        expect(schema.parse(123.456), equals('123.456'));
        expect(schema.parse(true), equals('true'));
        expect(schema.parse([1, 2, 3]), equals('1,2,3'));
        expect(schema.parse({'test': 'value'}), equals('{test: value}'));
      });

      test('should handle number coercion', () {
        final schema = Z.coerce.number();

        expect(schema.parse('123'), equals(123));
        expect(schema.parse('123.456'), equals(123.456));
        expect(schema.parse(true), equals(1));
        expect(schema.parse(false), equals(0));
      });

      test('should handle boolean coercion', () {
        final schema = Z.coerce.boolean();

        expect(schema.parse('true'), equals(true));
        expect(schema.parse('false'), equals(false));
        expect(schema.parse('yes'), equals(true));
        expect(schema.parse('no'), equals(false));
        expect(schema.parse(1), equals(true));
        expect(schema.parse(0), equals(false));
      });

      test('should handle integer coercion', () {
        final schema = Z.coerce.integer();

        expect(schema.parse('123'), equals(123));
        expect(schema.parse(123.7), equals(124));
        expect(schema.parse(true), equals(1));
        expect(schema.parse(false), equals(0));
      });

      test('should handle decimal coercion', () {
        final schema = Z.coerce.decimal();

        expect(schema.parse('123.456'), equals(123.456));
        expect(schema.parse(123), equals(123.0));
        expect(schema.parse(true), equals(1.0));
        expect(schema.parse(false), equals(0.0));
      });
    });

    group('DateTime and BigInt Coercion', () {
      test('should handle DateTime coercion', () {
        final schema = Z.coerce.date();

        final dateTime = DateTime(2023, 1, 1);
        expect(schema.parse(dateTime), equals(dateTime));
        expect(schema.parse('2023-01-01T00:00:00.000'),
            equals(DateTime(2023, 1, 1)));
        expect(schema.parse(1672531200000),
            equals(DateTime.fromMillisecondsSinceEpoch(1672531200000)));
      });

      test('should handle BigInt coercion', () {
        final schema = Z.coerce.bigInt();

        expect(schema.parse(BigInt.from(123)), equals(BigInt.from(123)));
        expect(schema.parse(123), equals(BigInt.from(123)));
        expect(schema.parse('123456789012345678901234567890'),
            equals(BigInt.parse('123456789012345678901234567890')));
      });
    });

    group('Collection Coercion', () {
      test('should handle List coercion', () {
        final schema = Z.coerce.list();

        expect(schema.parse(['a', 'b', 'c']), equals(['a', 'b', 'c']));
        expect(schema.parse('a,b,c'), equals(['a', 'b', 'c']));
        expect(schema.parse({'a', 'b', 'c'}), equals(['a', 'b', 'c']));
        expect(schema.parse({'0': 'a', '1': 'b'}), equals(['a', 'b']));
      });

      test('should handle Set coercion', () {
        final schema = Z.coerce.set();

        expect(schema.parse({'a', 'b', 'c'}), equals({'a', 'b', 'c'}));
        expect(schema.parse(['a', 'b', 'c']), equals({'a', 'b', 'c'}));
        expect(schema.parse('a,b,c'), equals({'a', 'b', 'c'}));
      });

      test('should handle Map coercion', () {
        final schema = Z.coerce.map();

        expect(schema.parse({'a': 1, 'b': 2}), equals({'a': 1, 'b': 2}));
        expect(schema.parse(['a', 'b', 'c']),
            equals({'0': 'a', '1': 'b', '2': 'c'}));
      });
    });

    group('Error Handling', () {
      test('should handle async coercion', () async {
        final schema = Z.coerce.string();

        final result = await schema.parseAsync(123);
        expect(result, equals('123'));
      });

      test('should handle empty strings for numbers', () {
        final numberSchema = Z.coerce.number();
        final intSchema = Z.coerce.integer();
        final doubleSchema = Z.coerce.decimal();

        expect(numberSchema.parse(''), equals(0));
        expect(intSchema.parse(''), equals(0));
        expect(doubleSchema.parse(''), equals(0.0));
      });

      test('should handle null values for specific types', () {
        final stringSchema = Z.coerce.string();
        final booleanSchema = Z.coerce.boolean();

        expect(stringSchema.parse(null), equals(''));
        expect(booleanSchema.parse(null), equals(false));
      });
    });
  });
}
