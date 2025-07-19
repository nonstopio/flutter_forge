import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('NumberSchema', () {
    group('Basic Validation', () {
      test('should validate number types', () {
        final schema = z.number();

        // Valid numbers
        expect(schema.validate(42).isSuccess, isTrue);
        expect(schema.validate(42.5).isSuccess, isTrue);
        expect(schema.validate(0).isSuccess, isTrue);
        expect(schema.validate(-42).isSuccess, isTrue);
        expect(schema.validate(double.infinity).isSuccess, isTrue);
        expect(schema.validate(double.negativeInfinity).isSuccess, isTrue);
        expect(schema.validate(double.nan).isSuccess, isTrue);

        // Invalid types
        expect(schema.validate('42').isFailure, isTrue);
        expect(schema.validate(true).isFailure, isTrue);
        expect(schema.validate(null).isFailure, isTrue);
        expect(schema.validate([]).isFailure, isTrue);
        expect(schema.validate({}).isFailure, isTrue);
      });

      test('should provide correct error for invalid types', () {
        final schema = z.number();
        final result = schema.validate('42');

        expect(result.isFailure, isTrue);
        expect(result.errors?.first?.message, contains('Expected number'));
      });
    });

    group('Exact Value Constraint', () {
      test('should validate exact value', () {
        final schema = z.number().exact(42);

        expect(schema.validate(42).isSuccess, isTrue);
        expect(schema.validate(42.0).isSuccess, isTrue);

        expect(schema.validate(41).isFailure, isTrue);
        expect(schema.validate(43).isFailure, isTrue);
        expect(schema.validate(42.1).isFailure, isTrue);
      });

      test('should provide correct error for exact value violation', () {
        final schema = z.number().exact(42);
        final result = schema.validate(43);

        expect(result.isFailure, isTrue);
        expect(result.errors?.first?.message, contains('exact value of 42'));
        expect(result.errors?.first?.code, equals('exact_value'));
        expect(result.errors?.first?.context?['expected'], equals(42));
        expect(result.errors?.first?.context?['actual'], equals(43));
      });
    });

    group('Range Constraints', () {
      test('should validate minimum value', () {
        final schema = z.number().min(10);

        expect(schema.validate(10).isSuccess, isTrue);
        expect(schema.validate(11).isSuccess, isTrue);
        expect(schema.validate(100).isSuccess, isTrue);

        expect(schema.validate(9).isFailure, isTrue);
        expect(schema.validate(0).isFailure, isTrue);
        expect(schema.validate(-10).isFailure, isTrue);
      });

      test('should validate maximum value', () {
        final schema = z.number().max(100);

        expect(schema.validate(100).isSuccess, isTrue);
        expect(schema.validate(99).isSuccess, isTrue);
        expect(schema.validate(0).isSuccess, isTrue);

        expect(schema.validate(101).isFailure, isTrue);
        expect(schema.validate(200).isFailure, isTrue);
      });

      test('should validate range', () {
        final schema = z.number().range(10, 100);

        expect(schema.validate(10).isSuccess, isTrue);
        expect(schema.validate(50).isSuccess, isTrue);
        expect(schema.validate(100).isSuccess, isTrue);

        expect(schema.validate(9).isFailure, isTrue);
        expect(schema.validate(101).isFailure, isTrue);
      });

      test('should provide correct errors for range violations', () {
        final minSchema = z.number().min(10);
        final maxSchema = z.number().max(100);

        var result = minSchema.validate(5);
        expect(result.errors?.first?.message, contains('minimum value of 10'));
        expect(result.errors?.first?.code, equals('min_value'));

        result = maxSchema.validate(150);
        expect(result.errors?.first?.message, contains('maximum value of 100'));
        expect(result.errors?.first?.code, equals('max_value'));
      });
    });

    group('Integer Constraint', () {
      test('should validate integer values', () {
        final schema = z.number().integer();

        expect(schema.validate(42).isSuccess, isTrue);
        expect(schema.validate(0).isSuccess, isTrue);
        expect(schema.validate(-42).isSuccess, isTrue);

        expect(schema.validate(42.5).isFailure, isTrue);
        expect(schema.validate(0.1).isFailure, isTrue);
        expect(schema.validate(-42.9).isFailure, isTrue);
      });

      test('should provide correct error for non-integer', () {
        final schema = z.number().integer();
        final result = schema.validate(42.5);

        expect(result.errors?.first?.message, contains('integer value'));
        expect(result.errors?.first?.code, equals('not_integer'));
      });
    });

    group('Sign Constraints', () {
      test('should validate positive values', () {
        final schema = z.number().positive();

        expect(schema.validate(1).isSuccess, isTrue);
        expect(schema.validate(42).isSuccess, isTrue);
        expect(schema.validate(0.1).isSuccess, isTrue);

        expect(schema.validate(0).isFailure, isTrue);
        expect(schema.validate(-1).isFailure, isTrue);
        expect(schema.validate(-42).isFailure, isTrue);
      });

      test('should validate negative values', () {
        final schema = z.number().negative();

        expect(schema.validate(-1).isSuccess, isTrue);
        expect(schema.validate(-42).isSuccess, isTrue);
        expect(schema.validate(-0.1).isSuccess, isTrue);

        expect(schema.validate(0).isFailure, isTrue);
        expect(schema.validate(1).isFailure, isTrue);
        expect(schema.validate(42).isFailure, isTrue);
      });

      test('should validate non-negative values', () {
        final schema = z.number().nonNegative();

        expect(schema.validate(0).isSuccess, isTrue);
        expect(schema.validate(1).isSuccess, isTrue);
        expect(schema.validate(42).isSuccess, isTrue);

        expect(schema.validate(-1).isFailure, isTrue);
        expect(schema.validate(-42).isFailure, isTrue);
      });

      test('should validate non-positive values', () {
        final schema = z.number().nonPositive();

        expect(schema.validate(0).isSuccess, isTrue);
        expect(schema.validate(-1).isSuccess, isTrue);
        expect(schema.validate(-42).isSuccess, isTrue);

        expect(schema.validate(1).isFailure, isTrue);
        expect(schema.validate(42).isFailure, isTrue);
      });

      test('should provide correct errors for sign violations', () {
        final positiveSchema = z.number().positive();
        final negativeSchema = z.number().negative();
        final nonNegativeSchema = z.number().nonNegative();
        final nonPositiveSchema = z.number().nonPositive();

        expect(positiveSchema.validate(0).errors?.first?.code,
            equals('not_positive'));
        expect(negativeSchema.validate(0).errors?.first?.code,
            equals('not_negative'));
        expect(nonNegativeSchema.validate(-1).errors?.first?.code,
            equals('negative'));
        expect(nonPositiveSchema.validate(1).errors?.first?.code,
            equals('positive'));
      });
    });

    group('Finite Constraint', () {
      test('should validate finite values', () {
        final schema = z.number().finite();

        expect(schema.validate(42).isSuccess, isTrue);
        expect(schema.validate(0).isSuccess, isTrue);
        expect(schema.validate(-42).isSuccess, isTrue);
        expect(schema.validate(1.23e10).isSuccess, isTrue);

        expect(schema.validate(double.infinity).isFailure, isTrue);
        expect(schema.validate(double.negativeInfinity).isFailure, isTrue);
        expect(schema.validate(double.nan).isFailure, isTrue);
      });

      test('should provide correct error for non-finite', () {
        final schema = z.number().finite();
        final result = schema.validate(double.infinity);

        expect(result.errors?.first?.message, contains('finite value'));
        expect(result.errors?.first?.code, equals('not_finite'));
      });
    });

    group('Safe Integer Constraint', () {
      test('should validate safe integers', () {
        final schema = z.number().safeInt();

        expect(schema.validate(42).isSuccess, isTrue);
        expect(schema.validate(0).isSuccess, isTrue);
        expect(schema.validate(-42).isSuccess, isTrue);
        expect(schema.validate(9007199254740991).isSuccess, isTrue);
        expect(schema.validate(-9007199254740991).isSuccess, isTrue);

        expect(schema.validate(9007199254740992).isFailure, isTrue);
        expect(schema.validate(-9007199254740992).isFailure, isTrue);
        expect(schema.validate(42.5).isFailure, isTrue);
      });

      test('should provide correct error for unsafe integer', () {
        final schema = z.number().safeInt();
        final result = schema.validate(9007199254740992);

        expect(result.errors?.first?.message, contains('safe integer'));
        expect(result.errors?.first?.code, equals('not_safe_integer'));
        expect(result.errors?.first?.context?['min_safe'],
            equals(-9007199254740991));
        expect(result.errors?.first?.context?['max_safe'],
            equals(9007199254740991));
      });
    });

    group('Refinement Methods', () {
      test('should validate even numbers', () {
        final schema = z.number().even();

        expect(schema.validate(0).isSuccess, isTrue);
        expect(schema.validate(2).isSuccess, isTrue);
        expect(schema.validate(-4).isSuccess, isTrue);
        expect(schema.validate(100).isSuccess, isTrue);

        expect(schema.validate(1).isFailure, isTrue);
        expect(schema.validate(3).isFailure, isTrue);
        expect(schema.validate(-5).isFailure, isTrue);
      });

      test('should validate odd numbers', () {
        final schema = z.number().odd();

        expect(schema.validate(1).isSuccess, isTrue);
        expect(schema.validate(3).isSuccess, isTrue);
        expect(schema.validate(-5).isSuccess, isTrue);
        expect(schema.validate(101).isSuccess, isTrue);

        expect(schema.validate(0).isFailure, isTrue);
        expect(schema.validate(2).isFailure, isTrue);
        expect(schema.validate(-4).isFailure, isTrue);
      });

      test('should validate multiples', () {
        final schema = z.number().multipleOf(5);

        expect(schema.validate(0).isSuccess, isTrue);
        expect(schema.validate(5).isSuccess, isTrue);
        expect(schema.validate(10).isSuccess, isTrue);
        expect(schema.validate(-15).isSuccess, isTrue);

        expect(schema.validate(1).isFailure, isTrue);
        expect(schema.validate(7).isFailure, isTrue);
        expect(schema.validate(13).isFailure, isTrue);
      });

      test('should validate between range', () {
        final schema = z.number().between(10, 20);

        expect(schema.validate(10).isSuccess, isTrue);
        expect(schema.validate(15).isSuccess, isTrue);
        expect(schema.validate(20).isSuccess, isTrue);

        expect(schema.validate(9).isFailure, isTrue);
        expect(schema.validate(21).isFailure, isTrue);
      });

      test('should validate comparison methods', () {
        final gtSchema = z.number().gt(10);
        final gteSchema = z.number().gte(10);
        final ltSchema = z.number().lt(10);
        final lteSchema = z.number().lte(10);

        expect(gtSchema.validate(11).isSuccess, isTrue);
        expect(gtSchema.validate(10).isFailure, isTrue);

        expect(gteSchema.validate(10).isSuccess, isTrue);
        expect(gteSchema.validate(9).isFailure, isTrue);

        expect(ltSchema.validate(9).isSuccess, isTrue);
        expect(ltSchema.validate(10).isFailure, isTrue);

        expect(lteSchema.validate(10).isSuccess, isTrue);
        expect(lteSchema.validate(11).isFailure, isTrue);
      });

      test('should validate zero and non-zero', () {
        final zeroSchema = z.number().zero();
        final nonZeroSchema = z.number().nonZero();

        expect(zeroSchema.validate(0).isSuccess, isTrue);
        expect(zeroSchema.validate(0.0).isSuccess, isTrue);
        expect(zeroSchema.validate(1).isFailure, isTrue);
        expect(zeroSchema.validate(-1).isFailure, isTrue);

        expect(nonZeroSchema.validate(1).isSuccess, isTrue);
        expect(nonZeroSchema.validate(-1).isSuccess, isTrue);
        expect(nonZeroSchema.validate(0.1).isSuccess, isTrue);
        expect(nonZeroSchema.validate(0).isFailure, isTrue);
      });
    });

    group('Domain-Specific Validations', () {
      test('should validate port numbers', () {
        final schema = z.number().port();

        expect(schema.validate(1).isSuccess, isTrue);
        expect(schema.validate(80).isSuccess, isTrue);
        expect(schema.validate(443).isSuccess, isTrue);
        expect(schema.validate(8080).isSuccess, isTrue);
        expect(schema.validate(65535).isSuccess, isTrue);

        expect(schema.validate(0).isFailure, isTrue);
        expect(schema.validate(65536).isFailure, isTrue);
        expect(schema.validate(80.5).isFailure, isTrue);
        expect(schema.validate(-1).isFailure, isTrue);
      });

      test('should validate years', () {
        final schema = z.number().year();

        expect(schema.validate(1900).isSuccess, isTrue);
        expect(schema.validate(2000).isSuccess, isTrue);
        expect(schema.validate(2024).isSuccess, isTrue);
        expect(schema.validate(2100).isSuccess, isTrue);

        expect(schema.validate(1899).isFailure, isTrue);
        expect(schema.validate(2101).isFailure, isTrue);
        expect(schema.validate(2024.5).isFailure, isTrue);
      });

      test('should validate months', () {
        final schema = z.number().month();

        expect(schema.validate(1).isSuccess, isTrue);
        expect(schema.validate(6).isSuccess, isTrue);
        expect(schema.validate(12).isSuccess, isTrue);

        expect(schema.validate(0).isFailure, isTrue);
        expect(schema.validate(13).isFailure, isTrue);
        expect(schema.validate(6.5).isFailure, isTrue);
      });

      test('should validate days', () {
        final schema = z.number().day();

        expect(schema.validate(1).isSuccess, isTrue);
        expect(schema.validate(15).isSuccess, isTrue);
        expect(schema.validate(31).isSuccess, isTrue);

        expect(schema.validate(0).isFailure, isTrue);
        expect(schema.validate(32).isFailure, isTrue);
        expect(schema.validate(15.5).isFailure, isTrue);
      });

      test('should validate hours', () {
        final schema = z.number().hour();

        expect(schema.validate(0).isSuccess, isTrue);
        expect(schema.validate(12).isSuccess, isTrue);
        expect(schema.validate(23).isSuccess, isTrue);

        expect(schema.validate(-1).isFailure, isTrue);
        expect(schema.validate(24).isFailure, isTrue);
        expect(schema.validate(12.5).isFailure, isTrue);
      });

      test('should validate minutes and seconds', () {
        final minuteSchema = z.number().minute();
        final secondSchema = z.number().second();

        for (final schema in [minuteSchema, secondSchema]) {
          expect(schema.validate(0).isSuccess, isTrue);
          expect(schema.validate(30).isSuccess, isTrue);
          expect(schema.validate(59).isSuccess, isTrue);

          expect(schema.validate(-1).isFailure, isTrue);
          expect(schema.validate(60).isFailure, isTrue);
          expect(schema.validate(30.5).isFailure, isTrue);
        }
      });

      test('should validate percentages', () {
        final schema = z.number().percentage();

        expect(schema.validate(0).isSuccess, isTrue);
        expect(schema.validate(50).isSuccess, isTrue);
        expect(schema.validate(100).isSuccess, isTrue);
        expect(schema.validate(75.5).isSuccess, isTrue);

        expect(schema.validate(-1).isFailure, isTrue);
        expect(schema.validate(101).isFailure, isTrue);
        expect(schema.validate(150).isFailure, isTrue);
      });

      test('should validate probabilities', () {
        final schema = z.number().probability();

        expect(schema.validate(0).isSuccess, isTrue);
        expect(schema.validate(0.5).isSuccess, isTrue);
        expect(schema.validate(1).isSuccess, isTrue);
        expect(schema.validate(0.75).isSuccess, isTrue);

        expect(schema.validate(-0.1).isFailure, isTrue);
        expect(schema.validate(1.1).isFailure, isTrue);
        expect(schema.validate(2).isFailure, isTrue);
      });

      test('should validate latitude', () {
        final schema = z.number().latitude();

        expect(schema.validate(-90).isSuccess, isTrue);
        expect(schema.validate(0).isSuccess, isTrue);
        expect(schema.validate(45.5).isSuccess, isTrue);
        expect(schema.validate(90).isSuccess, isTrue);

        expect(schema.validate(-91).isFailure, isTrue);
        expect(schema.validate(91).isFailure, isTrue);
        expect(schema.validate(180).isFailure, isTrue);
      });

      test('should validate longitude', () {
        final schema = z.number().longitude();

        expect(schema.validate(-180).isSuccess, isTrue);
        expect(schema.validate(0).isSuccess, isTrue);
        expect(schema.validate(123.45).isSuccess, isTrue);
        expect(schema.validate(180).isSuccess, isTrue);

        expect(schema.validate(-181).isFailure, isTrue);
        expect(schema.validate(181).isFailure, isTrue);
        expect(schema.validate(360).isFailure, isTrue);
      });
    });

    group('Advanced Validations', () {
      test('should validate step values', () {
        final schema = z.number().step(5);

        expect(schema.validate(0).isSuccess, isTrue);
        expect(schema.validate(5).isSuccess, isTrue);
        expect(schema.validate(10).isSuccess, isTrue);
        expect(schema.validate(-5).isSuccess, isTrue);

        expect(schema.validate(3).isFailure, isTrue);
        expect(schema.validate(7).isFailure, isTrue);
        expect(schema.validate(12).isFailure, isTrue);
      });

      test('should validate step values with custom start', () {
        final schema = z.number().step(5, start: 3);

        expect(schema.validate(3).isSuccess, isTrue);
        expect(schema.validate(8).isSuccess, isTrue);
        expect(schema.validate(13).isSuccess, isTrue);
        expect(schema.validate(-2).isSuccess, isTrue);

        expect(schema.validate(0).isFailure, isTrue);
        expect(schema.validate(5).isFailure, isTrue);
        expect(schema.validate(10).isFailure, isTrue);
      });

      test('should validate decimal precision', () {
        final schema = z.number().precision(2);

        expect(schema.validate(42).isSuccess, isTrue);
        expect(schema.validate(42.5).isSuccess, isTrue);
        expect(schema.validate(42.55).isSuccess, isTrue);
        expect(schema.validate(42.00).isSuccess, isTrue);

        expect(schema.validate(42.555).isFailure, isTrue);
        expect(schema.validate(42.1234).isFailure, isTrue);
      });

      test('should validate precise multiples with tolerance', () {
        final schema = z.number().multipleOfPrecise(0.1, tolerance: 1e-10);

        expect(schema.validate(0.1).isSuccess, isTrue);
        expect(schema.validate(0.2).isSuccess, isTrue);
        expect(schema.validate(0.3).isSuccess, isTrue);
        expect(schema.validate(1.0).isSuccess, isTrue);

        expect(schema.validate(0.15).isFailure, isTrue);
        expect(schema.validate(0.25).isFailure, isTrue);
      });

      test('should validate safe JavaScript integers', () {
        final schema = z.number().safeInteger();

        expect(schema.validate(42).isSuccess, isTrue);
        expect(schema.validate(9007199254740991).isSuccess, isTrue);
        expect(schema.validate(-9007199254740991).isSuccess, isTrue);

        expect(schema.validate(9007199254740992).isFailure, isTrue);
        expect(schema.validate(42.5).isFailure, isTrue);
      });

      test('should validate power of two', () {
        final schema = z.number().powerOfTwo();

        expect(schema.validate(1).isSuccess, isTrue);
        expect(schema.validate(2).isSuccess, isTrue);
        expect(schema.validate(4).isSuccess, isTrue);
        expect(schema.validate(8).isSuccess, isTrue);
        expect(schema.validate(1024).isSuccess, isTrue);

        expect(schema.validate(0).isFailure, isTrue);
        expect(schema.validate(3).isFailure, isTrue);
        expect(schema.validate(5).isFailure, isTrue);
        expect(schema.validate(1000).isFailure, isTrue);
        expect(schema.validate(2.5).isFailure, isTrue);
        expect(schema.validate(-2).isFailure, isTrue);
      });

      test('should validate prime numbers', () {
        final schema = z.number().prime();

        expect(schema.validate(2).isSuccess, isTrue);
        expect(schema.validate(3).isSuccess, isTrue);
        expect(schema.validate(5).isSuccess, isTrue);
        expect(schema.validate(7).isSuccess, isTrue);
        expect(schema.validate(11).isSuccess, isTrue);
        expect(schema.validate(13).isSuccess, isTrue);

        expect(schema.validate(1).isFailure, isTrue);
        expect(schema.validate(4).isFailure, isTrue);
        expect(schema.validate(6).isFailure, isTrue);
        expect(schema.validate(8).isFailure, isTrue);
        expect(schema.validate(9).isFailure, isTrue);
        expect(schema.validate(2.5).isFailure, isTrue);
        expect(schema.validate(-7).isFailure, isTrue);
      });

      test('should validate perfect squares', () {
        final schema = z.number().perfectSquare();

        expect(schema.validate(0).isSuccess, isTrue);
        expect(schema.validate(1).isSuccess, isTrue);
        expect(schema.validate(4).isSuccess, isTrue);
        expect(schema.validate(9).isSuccess, isTrue);
        expect(schema.validate(16).isSuccess, isTrue);
        expect(schema.validate(25).isSuccess, isTrue);
        expect(schema.validate(100).isSuccess, isTrue);

        expect(schema.validate(2).isFailure, isTrue);
        expect(schema.validate(3).isFailure, isTrue);
        expect(schema.validate(5).isFailure, isTrue);
        expect(schema.validate(10).isFailure, isTrue);
        expect(schema.validate(4.5).isFailure, isTrue);
        expect(schema.validate(-4).isFailure, isTrue);
      });

      test('should validate range with step', () {
        final schema = z.number().rangeWithStep(10, 50, 5);

        expect(schema.validate(10).isSuccess, isTrue);
        expect(schema.validate(15).isSuccess, isTrue);
        expect(schema.validate(20).isSuccess, isTrue);
        expect(schema.validate(45).isSuccess, isTrue);
        expect(schema.validate(50).isSuccess, isTrue);

        expect(schema.validate(5).isFailure, isTrue);
        expect(schema.validate(12).isFailure, isTrue);
        expect(schema.validate(55).isFailure, isTrue);
      });
    });

    group('Chaining and Composition', () {
      test('should chain multiple constraints', () {
        final schema = z.number().min(0).max(100).integer().even();

        expect(schema.validate(0).isSuccess, isTrue);
        expect(schema.validate(2).isSuccess, isTrue);
        expect(schema.validate(50).isSuccess, isTrue);
        expect(schema.validate(100).isSuccess, isTrue);

        expect(schema.validate(-2).isFailure, isTrue); // Below min
        expect(schema.validate(102).isFailure, isTrue); // Above max
        expect(schema.validate(50.5).isFailure, isTrue); // Not integer
        expect(schema.validate(51).isFailure, isTrue); // Not even
      });

      test('should preserve metadata and description', () {
        final schema = z
            .number()
            .min(10)
            .max(100)
            .describe('Test number', metadata: {'key': 'value'});

        expect(schema.description, equals('Test number'));
        expect(schema.metadata?['key'], equals('value'));
      });
    });

    group('Edge Cases', () {
      test('should handle floating point precision correctly', () {
        // multipleOf uses exact % which can fail with floating point
        final schema = z.number().multipleOf(5);
        expect(schema.validate(5).isSuccess, isTrue);
        expect(schema.validate(10).isSuccess, isTrue);
        expect(schema.validate(15).isSuccess, isTrue);
        expect(schema.validate(7).isFailure, isTrue);

        // multipleOfPrecise handles floating point better
        final preciseSchema = z.number().multipleOfPrecise(0.1);
        expect(preciseSchema.validate(0.1).isSuccess, isTrue);
        expect(preciseSchema.validate(0.2).isSuccess, isTrue);
        expect(preciseSchema.validate(0.3).isSuccess, isTrue);
        expect(preciseSchema.validate(0.15).isFailure, isTrue);
      });

      test('should handle zero step size gracefully', () {
        final schema = z.number().step(0);

        // Step size of 0 should always fail
        expect(schema.validate(0).isFailure, isTrue);
        expect(schema.validate(5).isFailure, isTrue);
      });

      test('should handle negative precision gracefully', () {
        final schema = z.number().precision(-1);

        // Negative precision should always fail
        expect(schema.validate(42).isFailure, isTrue);
        expect(schema.validate(42.5).isFailure, isTrue);
      });

      test('should handle zero divisor in multipleOfPrecise', () {
        final schema = z.number().multipleOfPrecise(0);

        // Division by zero should always fail
        expect(schema.validate(0).isFailure, isTrue);
        expect(schema.validate(5).isFailure, isTrue);
      });
    });

    group('toString Method', () {
      test('should generate correct string representation', () {
        expect(z.number().toString(), equals('NumberSchema'));
        expect(z.number().min(10).toString(), equals('NumberSchema (min: 10)'));
        expect(
            z.number().max(100).toString(), equals('NumberSchema (max: 100)'));
        expect(z.number().exact(42).toString(),
            equals('NumberSchema (exact: 42)'));
        expect(z.number().integer().toString(), equals('NumberSchema (int)'));
        expect(z.number().positive().toString(),
            equals('NumberSchema (positive)'));
        expect(z.number().negative().toString(),
            equals('NumberSchema (negative)'));
        expect(z.number().nonNegative().toString(),
            equals('NumberSchema (nonNegative)'));
        expect(z.number().nonPositive().toString(),
            equals('NumberSchema (nonPositive)'));
        expect(z.number().finite().toString(), equals('NumberSchema (finite)'));
        expect(
            z.number().safeInt().toString(), equals('NumberSchema (safeInt)'));

        // Multiple constraints
        expect(z.number().min(10).max(100).integer().positive().toString(),
            equals('NumberSchema (min: 10, max: 100, int, positive)'));
      });

      test('should create new schemas with constructor methods', () {
        final baseSchema = z.number();
        
        // Test finite() creates new schema with correct properties
        final finiteSchema = baseSchema.finite();
        expect(finiteSchema, isNot(same(baseSchema)));
        expect(finiteSchema.validate(1.5).isSuccess, true);
        expect(finiteSchema.validate(double.infinity).isFailure, true);
        
        // Test safeInt() creates new schema with correct properties
        final safeIntSchema = baseSchema.safeInt();
        expect(safeIntSchema, isNot(same(baseSchema)));
        expect(safeIntSchema.validate(42).isSuccess, true);
        expect(safeIntSchema.validate(9007199254740992).isFailure, true);
        
        // Test range() creates new schema with correct properties
        final rangeSchema = baseSchema.range(10, 100);
        expect(rangeSchema, isNot(same(baseSchema)));
        expect(rangeSchema.validate(50).isSuccess, true);
        expect(rangeSchema.validate(5).isFailure, true);
        expect(rangeSchema.validate(150).isFailure, true);
      });
    });

    group('Path Handling', () {
      test('should include path in error messages', () {
        final schema = z.number().min(10);
        final result = schema.validate(5, ['user', 'age']);

        expect(result.isFailure, isTrue);
        expect(result.errors?.first?.path, equals(['user', 'age']));
      });
    });
  });
}
