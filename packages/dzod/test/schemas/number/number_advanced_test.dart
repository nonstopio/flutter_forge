import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('NumberSchema Advanced Validations', () {
    group('Step validation', () {
      test('should validate numbers that conform to step size', () {
        final schema = Z.number().step(0.1);

        final validNumbers = [0, 0.1, 0.2, 0.3, 0.5, 1.0, -0.1, -0.5];

        for (final number in validNumbers) {
          final result = schema.validate(number);
          expect(result.isSuccess, isTrue, reason: 'Should validate $number');
          expect(result.data, equals(number));
        }
      });

      test('should validate numbers with custom start point', () {
        final schema = Z.number().step(0.5, start: 1.0);

        final validNumbers = [1.0, 1.5, 2.0, 2.5, 0.5, -0.5, -1.0];

        for (final number in validNumbers) {
          final result = schema.validate(number);
          expect(result.isSuccess, isTrue, reason: 'Should validate $number');
        }
      });

      test('should reject numbers that do not conform to step size', () {
        final schema = Z.number().step(0.1);

        final invalidNumbers = [0.05, 0.15, 0.33, 1.11, -0.05];

        for (final number in invalidNumbers) {
          final result = schema.validate(number);
          expect(result.isFailure, isTrue, reason: 'Should reject $number');
          expect(result.errors?.first?.code, equals('invalid_step'));
        }
      });

      test('should handle integer steps', () {
        final schema = Z.number().step(5);

        expect(schema.validate(0).isSuccess, isTrue);
        expect(schema.validate(5).isSuccess, isTrue);
        expect(schema.validate(10).isSuccess, isTrue);
        expect(schema.validate(-5).isSuccess, isTrue);

        expect(schema.validate(3).isFailure, isTrue);
        expect(schema.validate(7).isFailure, isTrue);
        expect(schema.validate(-3).isFailure, isTrue);
      });
    });

    group('Precision validation', () {
      test('should validate numbers with correct decimal precision', () {
        final schema2 = Z.number().precision(2);
        final schema0 = Z.number().precision(0);

        // 2 decimal places
        expect(schema2.validate(1.23).isSuccess, isTrue);
        expect(schema2.validate(0.1).isSuccess, isTrue);
        expect(schema2.validate(5.0).isSuccess, isTrue);
        expect(schema2.validate(10).isSuccess, isTrue);

        // 0 decimal places (integers)
        expect(schema0.validate(1).isSuccess, isTrue);
        expect(schema0.validate(100).isSuccess, isTrue);
        expect(schema0.validate(-50).isSuccess, isTrue);
      });

      test('should reject numbers with too many decimal places', () {
        final schema = Z.number().precision(2);

        final invalidNumbers = [1.234, 0.123, 5.999999, -1.001];

        for (final number in invalidNumbers) {
          final result = schema.validate(number);
          expect(result.isFailure, isTrue, reason: 'Should reject $number');
          expect(result.errors?.first?.code, equals('invalid_precision'));
        }
      });

      test('should handle edge cases in precision validation', () {
        final schema = Z.number().precision(3);

        expect(schema.validate(1.000).isSuccess, isTrue);
        expect(schema.validate(0.001).isSuccess, isTrue);
        expect(schema.validate(123.456).isSuccess, isTrue);
        expect(schema.validate(0.0001).isFailure, isTrue);
      });
    });

    group('Precise multipleOf validation', () {
      test('should validate multiples with floating-point precision', () {
        final schema = Z.number().multipleOfPrecise(0.1);

        expect(schema.validate(0.1).isSuccess, isTrue);
        expect(schema.validate(0.2).isSuccess, isTrue);
        expect(schema.validate(0.3).isSuccess, isTrue);
        expect(schema.validate(1.0).isSuccess, isTrue);
        expect(schema.validate(-0.5).isSuccess, isTrue);
      });

      test('should handle floating-point precision issues', () {
        final schema = Z.number().multipleOfPrecise(0.1);

        // These might fail with regular modulo due to floating-point precision
        expect(schema.validate(0.3).isSuccess, isTrue);
        expect(schema.validate(0.7).isSuccess, isTrue);
        expect(schema.validate(1.4).isSuccess, isTrue);
      });

      test('should allow custom tolerance', () {
        final schema = Z.number().multipleOfPrecise(0.3, tolerance: 1e-5);

        expect(schema.validate(0.3).isSuccess, isTrue);
        expect(schema.validate(0.6).isSuccess, isTrue);
        expect(schema.validate(0.9).isSuccess, isTrue);
      });

      test('should reject non-multiples', () {
        final schema = Z.number().multipleOfPrecise(0.1);

        final invalidNumbers = [0.05, 0.15, 0.33, 0.77];

        for (final number in invalidNumbers) {
          final result = schema.validate(number);
          expect(result.isFailure, isTrue, reason: 'Should reject $number');
          expect(result.errors?.first?.code, equals('not_multiple_of_precise'));
        }
      });
    });

    group('Safe integer validation', () {
      test('should validate safe JavaScript integers', () {
        final schema = Z.number().safeInteger();

        final validIntegers = [
          0, 1, -1, 100, -100,
          9007199254740991, // MAX_SAFE_INTEGER
          -9007199254740991, // MIN_SAFE_INTEGER
        ];

        for (final number in validIntegers) {
          final result = schema.validate(number);
          expect(result.isSuccess, isTrue, reason: 'Should validate $number');
        }
      });

      test('should reject unsafe integers and non-integers', () {
        final schema = Z.number().safeInteger();

        final invalidNumbers = [
          9007199254740992, // Beyond MAX_SAFE_INTEGER
          -9007199254740992, // Beyond MIN_SAFE_INTEGER
          1.5, 2.7, -3.14, // Non-integers
          double.infinity, // Infinity
          double.negativeInfinity, // Negative infinity
          double.nan, // NaN
        ];

        for (final number in invalidNumbers) {
          final result = schema.validate(number);
          expect(result.isFailure, isTrue, reason: 'Should reject $number');
          expect(result.errors?.first?.code, equals('not_safe_js_integer'));
        }
      });
    });

    group('Percentage validation', () {
      test('should validate valid percentages', () {
        final schema = Z.number().percentage();

        final validPercentages = [0, 25, 50, 75, 100, 0.5, 99.99];

        for (final percentage in validPercentages) {
          final result = schema.validate(percentage);
          expect(result.isSuccess, isTrue,
              reason: 'Should validate $percentage');
        }
      });

      test('should reject invalid percentages', () {
        final schema = Z.number().percentage();

        final invalidPercentages = [-1, 101, -0.1, 100.1, 150];

        for (final percentage in invalidPercentages) {
          final result = schema.validate(percentage);
          expect(result.isFailure, isTrue, reason: 'Should reject $percentage');
          expect(result.errors?.first?.code, equals('invalid_percentage'));
        }
      });
    });

    group('Probability validation', () {
      test('should validate valid probabilities', () {
        final schema = Z.number().probability();

        final validProbabilities = [0, 0.25, 0.5, 0.75, 1, 0.001, 0.999];

        for (final probability in validProbabilities) {
          final result = schema.validate(probability);
          expect(result.isSuccess, isTrue,
              reason: 'Should validate $probability');
        }
      });

      test('should reject invalid probabilities', () {
        final schema = Z.number().probability();

        final invalidProbabilities = [-0.1, 1.1, -1, 2, 1.001];

        for (final probability in invalidProbabilities) {
          final result = schema.validate(probability);
          expect(result.isFailure, isTrue,
              reason: 'Should reject $probability');
          expect(result.errors?.first?.code, equals('invalid_probability'));
        }
      });
    });

    group('Latitude validation', () {
      test('should validate valid latitudes', () {
        final schema = Z.number().latitude();

        final validLatitudes = [-90, -45, 0, 45, 90, -89.999, 89.999];

        for (final latitude in validLatitudes) {
          final result = schema.validate(latitude);
          expect(result.isSuccess, isTrue, reason: 'Should validate $latitude');
        }
      });

      test('should reject invalid latitudes', () {
        final schema = Z.number().latitude();

        final invalidLatitudes = [-91, 91, -90.1, 90.1, 180, -180];

        for (final latitude in invalidLatitudes) {
          final result = schema.validate(latitude);
          expect(result.isFailure, isTrue, reason: 'Should reject $latitude');
          expect(result.errors?.first?.code, equals('invalid_latitude'));
        }
      });
    });

    group('Longitude validation', () {
      test('should validate valid longitudes', () {
        final schema = Z.number().longitude();

        final validLongitudes = [-180, -90, 0, 90, 180, -179.999, 179.999];

        for (final longitude in validLongitudes) {
          final result = schema.validate(longitude);
          expect(result.isSuccess, isTrue,
              reason: 'Should validate $longitude');
        }
      });

      test('should reject invalid longitudes', () {
        final schema = Z.number().longitude();

        final invalidLongitudes = [-181, 181, -180.1, 180.1, 270, -270];

        for (final longitude in invalidLongitudes) {
          final result = schema.validate(longitude);
          expect(result.isFailure, isTrue, reason: 'Should reject $longitude');
          expect(result.errors?.first?.code, equals('invalid_longitude'));
        }
      });
    });

    group('Power of two validation', () {
      test('should validate powers of two', () {
        final schema = Z.number().powerOfTwo();

        final validPowers = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024];

        for (final power in validPowers) {
          final result = schema.validate(power);
          expect(result.isSuccess, isTrue, reason: 'Should validate $power');
        }
      });

      test('should reject non-powers of two', () {
        final schema = Z.number().powerOfTwo();

        final invalidPowers = [0, 3, 5, 6, 7, 9, 10, 15, 17, -1, -2, 1.5];

        for (final power in invalidPowers) {
          final result = schema.validate(power);
          expect(result.isFailure, isTrue, reason: 'Should reject $power');
          expect(result.errors?.first?.code, equals('not_power_of_two'));
        }
      });
    });

    group('Prime number validation', () {
      test('should validate prime numbers', () {
        final schema = Z.number().prime();

        final validPrimes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 97];

        for (final prime in validPrimes) {
          final result = schema.validate(prime);
          expect(result.isSuccess, isTrue, reason: 'Should validate $prime');
        }
      });

      test('should reject non-prime numbers', () {
        final schema = Z.number().prime();

        final invalidPrimes = [0, 1, 4, 6, 8, 9, 10, 12, 14, 15, 16, -2, 2.5];

        for (final prime in invalidPrimes) {
          final result = schema.validate(prime);
          expect(result.isFailure, isTrue, reason: 'Should reject $prime');
          expect(result.errors?.first?.code, equals('not_prime'));
        }
      });
    });

    group('Perfect square validation', () {
      test('should validate perfect squares', () {
        final schema = Z.number().perfectSquare();

        final validSquares = [0, 1, 4, 9, 16, 25, 36, 49, 64, 81, 100, 144];

        for (final square in validSquares) {
          final result = schema.validate(square);
          expect(result.isSuccess, isTrue, reason: 'Should validate $square');
        }
      });

      test('should reject non-perfect squares', () {
        final schema = Z.number().perfectSquare();

        final invalidSquares = [
          2,
          3,
          5,
          6,
          7,
          8,
          10,
          11,
          12,
          13,
          14,
          15,
          -1,
          1.5
        ];

        for (final square in invalidSquares) {
          final result = schema.validate(square);
          expect(result.isFailure, isTrue, reason: 'Should reject $square');
          expect(result.errors?.first?.code, equals('not_perfect_square'));
        }
      });
    });

    group('Range with step validation', () {
      test('should validate numbers in range with step', () {
        final schema = Z.number().rangeWithStep(0, 10, 2);

        final validNumbers = [0, 2, 4, 6, 8, 10];

        for (final number in validNumbers) {
          final result = schema.validate(number);
          expect(result.isSuccess, isTrue, reason: 'Should validate $number');
        }
      });

      test('should reject numbers outside range or not matching step', () {
        final schema = Z.number().rangeWithStep(0, 10, 2);

        final invalidNumbers = [-1, 1, 3, 5, 7, 9, 11, 12];

        for (final number in invalidNumbers) {
          final result = schema.validate(number);
          expect(result.isFailure, isTrue, reason: 'Should reject $number');
          expect(result.errors?.first?.code, equals('invalid_range_step'));
        }
      });

      test('should handle decimal ranges with steps', () {
        final schema = Z.number().rangeWithStep(0.5, 2.5, 0.5);

        expect(schema.validate(0.5).isSuccess, isTrue);
        expect(schema.validate(1.0).isSuccess, isTrue);
        expect(schema.validate(1.5).isSuccess, isTrue);
        expect(schema.validate(2.0).isSuccess, isTrue);
        expect(schema.validate(2.5).isSuccess, isTrue);

        expect(schema.validate(0.75).isFailure, isTrue);
        expect(schema.validate(1.25).isFailure, isTrue);
        expect(schema.validate(3.0).isFailure, isTrue);
      });
    });

    group('Enhanced existing validations', () {
      test('should work with existing finite validation', () {
        final schema = Z.number().finite();

        expect(schema.validate(123).isSuccess, isTrue);
        expect(schema.validate(-456.789).isSuccess, isTrue);

        expect(schema.validate(double.infinity).isFailure, isTrue);
        expect(schema.validate(double.negativeInfinity).isFailure, isTrue);
        expect(schema.validate(double.nan).isFailure, isTrue);
      });

      test('should work with existing safeInt validation', () {
        final schema = Z.number().safeInt();

        expect(schema.validate(123).isSuccess, isTrue);
        expect(schema.validate(-456).isSuccess, isTrue);
        expect(schema.validate(9007199254740991).isSuccess, isTrue);

        expect(schema.validate(1.5).isFailure, isTrue);
        expect(schema.validate(9007199254740992).isFailure, isTrue);
      });
    });

    group('Chaining validations', () {
      test('should chain multiple validations', () {
        final schema = Z.number().positive().step(0.5);

        expect(schema.validate(1.0).isSuccess, isTrue);
        expect(schema.validate(2.5).isSuccess, isTrue);
        expect(schema.validate(5.0).isSuccess, isTrue);

        expect(schema.validate(-1.0).isFailure, isTrue); // Not positive
        expect(schema.validate(1.25).isFailure, isTrue); // Wrong step
      });

      test('should chain with coordinate validations', () {
        final latSchema = Z.number().latitude();
        final lngSchema = Z.number().longitude();

        expect(latSchema.validate(40.712776).isSuccess, isTrue);
        expect(lngSchema.validate(-74.005974).isSuccess, isTrue);

        expect(latSchema.validate(91).isFailure, isTrue);
        expect(lngSchema.validate(181).isFailure, isTrue);
      });

      test('should chain mathematical validations', () {
        final schema = Z.number().positive().integer().prime();

        expect(schema.validate(2).isSuccess, isTrue);
        expect(schema.validate(7).isSuccess, isTrue);
        expect(schema.validate(13).isSuccess, isTrue);

        expect(schema.validate(-2).isFailure, isTrue); // Not positive
        expect(schema.validate(2.5).isFailure, isTrue); // Not integer
        expect(schema.validate(4).isFailure, isTrue); // Not prime
      });
    });

    group('Error handling', () {
      test('should provide appropriate error codes', () {
        expect(Z.number().step(0.1).validate(0.05).errors?.first?.code,
            equals('invalid_step'));
        expect(Z.number().precision(2).validate(1.234).errors?.first?.code,
            equals('invalid_precision'));
        expect(
            Z
                .number()
                .multipleOfPrecise(0.1)
                .validate(0.05)
                .errors
                ?.first
                ?.code,
            equals('not_multiple_of_precise'));
        expect(Z.number().safeInteger().validate(1.5).errors?.first?.code,
            equals('not_safe_js_integer'));
        expect(Z.number().percentage().validate(101).errors?.first?.code,
            equals('invalid_percentage'));
        expect(Z.number().probability().validate(1.1).errors?.first?.code,
            equals('invalid_probability'));
        expect(Z.number().latitude().validate(91).errors?.first?.code,
            equals('invalid_latitude'));
        expect(Z.number().longitude().validate(181).errors?.first?.code,
            equals('invalid_longitude'));
        expect(Z.number().powerOfTwo().validate(3).errors?.first?.code,
            equals('not_power_of_two'));
        expect(Z.number().prime().validate(4).errors?.first?.code,
            equals('not_prime'));
        expect(Z.number().perfectSquare().validate(5).errors?.first?.code,
            equals('not_perfect_square'));
        expect(
            Z.number().rangeWithStep(0, 10, 2).validate(1).errors?.first?.code,
            equals('invalid_range_step'));
      });
    });
  });
}
