import 'package:dzod/dzod.dart'
    show
        FormIntegration,
        ValidationError,
        ValidationException,
        Z,
        ZodFormHelper,
        ZodStateExtensions,
        ZodValidationState;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Flutter Extensions Tests', () {
    group('ColorSchema', () {
      test('should validate Color objects', () {
        final schema = Z.color();
        final result = schema.parse(Colors.red);
        expect(result, equals(Colors.red));
      });

      test('should validate hex color strings', () {
        final schema = Z.color();
        final result = schema.parse('#FF0000');
        expect(result, equals(const Color(0xFFFF0000)));
      });

      test('should validate hex color strings without #', () {
        final schema = Z.color();
        final result = schema.parse('FF0000');
        expect(result, equals(const Color(0xFFFF0000)));
      });

      test('should validate short hex color strings', () {
        final schema = Z.color();
        final result = schema.parse('#F00');
        expect(result, equals(const Color(0xFFFF0000)));
      });

      test('should validate named colors', () {
        final schema = Z.color();
        final result = schema.parse('red');
        expect(result, equals(Colors.red));
      });

      test('should validate integer colors', () {
        final schema = Z.color();
        final result = schema.parse(0xFF0000FF);
        expect(result, equals(const Color(0xFF0000FF)));
      });

      test('should validate alpha values', () {
        final schema = Z.color().alpha(255);
        final result = schema.parse(Colors.red);
        expect(result, equals(Colors.red));
      });

      test('should fail for invalid alpha values', () {
        final schema = Z.color().alpha(128);
        expect(
          () => schema.parse(Colors.red),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate minimum alpha values', () {
        final schema = Z.color().minAlpha(100);
        final result = schema.parse(Colors.red);
        expect(result, equals(Colors.red));
      });

      test('should validate maximum alpha values', () {
        final schema = Z.color().maxAlpha(200);
        final result = schema.parse(Colors.red);
        expect(result, equals(Colors.red));
      });

      test('should validate opaque colors', () {
        final schema = Z.color().opaque();
        final result = schema.parse(Colors.red);
        expect(result, equals(Colors.red));
      });

      test('should validate transparent colors', () {
        final schema = Z.color().transparent();
        final result = schema.parse(Colors.transparent);
        expect(result, equals(Colors.transparent));
      });

      test('should fail for invalid color types', () {
        final schema = Z.color();
        expect(
          () => schema.parse(123.456),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should fail for invalid hex strings', () {
        final schema = Z.color();
        expect(
          () => schema.parse('#GGGGGG'),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should fail for invalid named colors', () {
        final schema = Z.color();
        expect(
          () => schema.parse('invalidcolor'),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('EdgeInsetsSchema', () {
      test('should validate EdgeInsets objects', () {
        final schema = Z.edgeInsets();
        const edgeInsets = EdgeInsets.all(8.0);
        final result = schema.parse(edgeInsets);
        expect(result, equals(edgeInsets));
      });

      test('should validate double values', () {
        final schema = Z.edgeInsets();
        final result = schema.parse(8.0);
        expect(result, equals(const EdgeInsets.all(8.0)));
      });

      test('should validate int values', () {
        final schema = Z.edgeInsets();
        final result = schema.parse(8);
        expect(result, equals(const EdgeInsets.all(8.0)));
      });

      test('should validate map values', () {
        final schema = Z.edgeInsets();
        final result = schema.parse({
          'left': 8.0,
          'top': 16.0,
          'right': 8.0,
          'bottom': 16.0,
        });
        expect(result, equals(const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0)));
      });

      test('should validate list values - single value', () {
        final schema = Z.edgeInsets();
        final result = schema.parse([8.0]);
        expect(result, equals(const EdgeInsets.all(8.0)));
      });

      test('should validate list values - two values', () {
        final schema = Z.edgeInsets();
        final result = schema.parse([8.0, 16.0]);
        expect(
            result,
            equals(
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0)));
      });

      test('should validate list values - four values', () {
        final schema = Z.edgeInsets();
        final result = schema.parse([8.0, 16.0, 8.0, 16.0]);
        expect(result, equals(const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0)));
      });

      test('should validate uniform EdgeInsets', () {
        final schema = Z.edgeInsets().uniform();
        final result = schema.parse(const EdgeInsets.all(8.0));
        expect(result, equals(const EdgeInsets.all(8.0)));
      });

      test('should fail for non-uniform EdgeInsets', () {
        final schema = Z.edgeInsets().uniform();
        expect(
          () => schema.parse(const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0)),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate minimum values', () {
        final schema = Z.edgeInsets().minAll(5.0);
        final result = schema.parse(const EdgeInsets.all(8.0));
        expect(result, equals(const EdgeInsets.all(8.0)));
      });

      test('should fail for values below minimum', () {
        final schema = Z.edgeInsets().minAll(10.0);
        expect(
          () => schema.parse(const EdgeInsets.all(8.0)),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate maximum values', () {
        final schema = Z.edgeInsets().maxAll(10.0);
        final result = schema.parse(const EdgeInsets.all(8.0));
        expect(result, equals(const EdgeInsets.all(8.0)));
      });

      test('should fail for values above maximum', () {
        final schema = Z.edgeInsets().maxAll(5.0);
        expect(
          () => schema.parse(const EdgeInsets.all(8.0)),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate horizontal range', () {
        final schema = Z.edgeInsets().horizontalRange(10.0, 20.0);
        final result =
            schema.parse(const EdgeInsets.symmetric(horizontal: 8.0));
        expect(result, equals(const EdgeInsets.symmetric(horizontal: 8.0)));
      });

      test('should validate vertical range', () {
        final schema = Z.edgeInsets().verticalRange(10.0, 20.0);
        final result = schema.parse(const EdgeInsets.symmetric(vertical: 8.0));
        expect(result, equals(const EdgeInsets.symmetric(vertical: 8.0)));
      });

      test('should fail for invalid EdgeInsets type', () {
        final schema = Z.edgeInsets();
        expect(
          () => schema.parse('invalid'),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('DurationSchema', () {
      test('should validate Duration objects', () {
        final schema = Z.duration();
        const duration = Duration(seconds: 30);
        final result = schema.parse(duration);
        expect(result, equals(duration));
      });

      test('should validate int values as milliseconds', () {
        final schema = Z.duration();
        final result = schema.parse(1000);
        expect(result, equals(const Duration(milliseconds: 1000)));
      });

      test('should validate double values as milliseconds', () {
        final schema = Z.duration();
        final result = schema.parse(1500.0);
        expect(result, equals(const Duration(milliseconds: 1500)));
      });

      test('should validate map values', () {
        final schema = Z.duration();
        final result = schema.parse({
          'hours': 1,
          'minutes': 30,
          'seconds': 45,
        });
        expect(
            result, equals(const Duration(hours: 1, minutes: 30, seconds: 45)));
      });

      test('should validate ISO 8601 duration strings', () {
        final schema = Z.duration();
        final result = schema.parse('PT1H30M');
        expect(result, equals(const Duration(hours: 1, minutes: 30)));
      });

      test('should validate minimum duration', () {
        final schema = Z.duration().min(const Duration(seconds: 10));
        final result = schema.parse(const Duration(seconds: 30));
        expect(result, equals(const Duration(seconds: 30)));
      });

      test('should fail for duration below minimum', () {
        final schema = Z.duration().min(const Duration(seconds: 60));
        expect(
          () => schema.parse(const Duration(seconds: 30)),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate maximum duration', () {
        final schema = Z.duration().max(const Duration(minutes: 5));
        final result = schema.parse(const Duration(seconds: 30));
        expect(result, equals(const Duration(seconds: 30)));
      });

      test('should fail for duration above maximum', () {
        final schema = Z.duration().max(const Duration(seconds: 10));
        expect(
          () => schema.parse(const Duration(seconds: 30)),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate positive duration', () {
        final schema = Z.duration().positive();
        final result = schema.parse(const Duration(seconds: 30));
        expect(result, equals(const Duration(seconds: 30)));
      });

      test('should fail for non-positive duration', () {
        final schema = Z.duration().positive();
        expect(
          () => schema.parse(Duration.zero),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate negative duration', () {
        final schema = Z.duration().negative();
        final result = schema.parse(const Duration(seconds: -30));
        expect(result, equals(const Duration(seconds: -30)));
      });

      test('should fail for non-negative duration', () {
        final schema = Z.duration().negative();
        expect(
          () => schema.parse(const Duration(seconds: 30)),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate zero duration', () {
        final schema = Z.duration().zero();
        final result = schema.parse(Duration.zero);
        expect(result, equals(Duration.zero));
      });

      test('should fail for non-zero duration', () {
        final schema = Z.duration().zero();
        expect(
          () => schema.parse(const Duration(seconds: 30)),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should fail for invalid duration type', () {
        final schema = Z.duration();
        expect(
          () => schema.parse('invalid'),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('SizeSchema', () {
      test('should validate Size objects', () {
        final schema = Z.size();
        const size = Size(100.0, 200.0);
        final result = schema.parse(size);
        expect(result, equals(size));
      });

      test('should validate double values as square', () {
        final schema = Z.size();
        final result = schema.parse(100.0);
        expect(result, equals(const Size.square(100.0)));
      });

      test('should validate int values as square', () {
        final schema = Z.size();
        final result = schema.parse(100);
        expect(result, equals(const Size.square(100.0)));
      });

      test('should validate list values', () {
        final schema = Z.size();
        final result = schema.parse([100.0, 200.0]);
        expect(result, equals(const Size(100.0, 200.0)));
      });

      test('should validate map values', () {
        final schema = Z.size();
        final result = schema.parse({
          'width': 100.0,
          'height': 200.0,
        });
        expect(result, equals(const Size(100.0, 200.0)));
      });

      test('should validate square sizes', () {
        final schema = Z.size().square();
        final result = schema.parse(const Size.square(100.0));
        expect(result, equals(const Size.square(100.0)));
      });

      test('should fail for non-square sizes', () {
        final schema = Z.size().square();
        expect(
          () => schema.parse(const Size(100.0, 200.0)),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate minimum width', () {
        final schema = Z.size().minWidth(50.0);
        final result = schema.parse(const Size(100.0, 200.0));
        expect(result, equals(const Size(100.0, 200.0)));
      });

      test('should fail for width below minimum', () {
        final schema = Z.size().minWidth(150.0);
        expect(
          () => schema.parse(const Size(100.0, 200.0)),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate minimum height', () {
        final schema = Z.size().minHeight(100.0);
        final result = schema.parse(const Size(100.0, 200.0));
        expect(result, equals(const Size(100.0, 200.0)));
      });

      test('should fail for height below minimum', () {
        final schema = Z.size().minHeight(250.0);
        expect(
          () => schema.parse(const Size(100.0, 200.0)),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate maximum width', () {
        final schema = Z.size().maxWidth(150.0);
        final result = schema.parse(const Size(100.0, 200.0));
        expect(result, equals(const Size(100.0, 200.0)));
      });

      test('should fail for width above maximum', () {
        final schema = Z.size().maxWidth(50.0);
        expect(
          () => schema.parse(const Size(100.0, 200.0)),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate maximum height', () {
        final schema = Z.size().maxHeight(250.0);
        final result = schema.parse(const Size(100.0, 200.0));
        expect(result, equals(const Size(100.0, 200.0)));
      });

      test('should fail for height above maximum', () {
        final schema = Z.size().maxHeight(100.0);
        expect(
          () => schema.parse(const Size(100.0, 200.0)),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate aspect ratio', () {
        final schema = Z.size().aspectRatio(0.4, 0.6);
        final result = schema.parse(const Size(100.0, 200.0));
        expect(result, equals(const Size(100.0, 200.0)));
      });

      test('should fail for aspect ratio outside range', () {
        final schema = Z.size().aspectRatio(0.8, 1.2);
        expect(
          () => schema.parse(const Size(100.0, 200.0)),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should fail for invalid size type', () {
        final schema = Z.size();
        expect(
          () => schema.parse('invalid'),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should fail for invalid list length', () {
        final schema = Z.size();
        expect(
          () => schema.parse([100.0]),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should fail for invalid map structure', () {
        final schema = Z.size();
        expect(
          () => schema.parse({'width': 100.0}),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('Form Integration', () {
      test('should create validator function', () {
        final schema = Z.string().min(3);
        final validator = schema.validator();

        expect(validator('hello'), isNull);
        expect(validator('hi'), isNotNull);
        expect(validator(null), isNotNull);
      });

      test('should create validator with custom error message', () {
        final schema = Z.string().min(3);
        final validator = schema.validator(customErrorMessage: 'Custom error');

        expect(validator('hello'), isNull);
        expect(validator('hi'), equals('Custom error'));
        expect(validator(null), equals('Custom error'));
      });

      test('should create typed validator', () {
        final schema = Z.number().min(0);
        final validator = schema.typedValidator<int>();

        expect(validator(5), isNull);
        expect(validator(-1), isNotNull);
        expect(validator(null), isNotNull);
      });

      test('should validate multiple fields', () {
        final results = ZodFormHelper.validateMultipleSync({
          'name': (Z.string().min(2), 'John'),
          'age': (Z.number().min(18), 25),
        });

        expect(results['name']?.isSuccess, isTrue);
        expect(results['age']?.isSuccess, isTrue);
      });

      test('should validate form and return first error', () {
        final error = ZodFormHelper.validateFormSync({
          'name': (Z.string().min(5), 'John'),
          'age': (Z.number().min(18), 25),
        });

        expect(error, isNotNull);
        expect(error, contains('name'));
      });

      test('should validate form and return null when valid', () {
        final error = ZodFormHelper.validateFormSync({
          'name': (Z.string().min(2), 'John'),
          'age': (Z.number().min(18), 25),
        });

        expect(error, isNull);
      });
    });

    group('State Management', () {
      test('should create ZodValidationState', () {
        final state = ZodValidationState.initial('test');

        expect(state.value, equals('test'));
        expect(state.isValid, isTrue);
        expect(state.isLoading, isFalse);
      });

      test('should create loading state', () {
        final state = ZodValidationState.loading('test');

        expect(state.value, equals('test'));
        expect(state.isValid, isTrue);
        expect(state.isLoading, isTrue);
      });

      test('should create failure state', () {
        final errors = [
          const ValidationError(
            code: 'custom',
            message: 'Test error',
            path: [],
            expected: 'valid value',
            received: 'invalid value',
          )
        ];
        final state = ZodValidationState.failure('test', errors);

        expect(state.value, equals('test'));
        expect(state.isValid, isFalse);
        expect(state.isLoading, isFalse);
        expect(state.errors, equals(errors));
      });

      test('should copy state with new values', () {
        final state = ZodValidationState.initial('test');
        final newState = state.copyWith(value: 'new test');

        expect(newState.value, equals('new test'));
        expect(newState.isValid, isTrue);
        expect(newState.isLoading, isFalse);
      });

      test('should transform valid state', () {
        final state = ZodValidationState.initial('test');
        final newState = state.mapValid<int>((value) => value.length);

        expect(newState.value, equals(4));
        expect(newState.isValid, isTrue);
      });

      test('should fold state', () {
        final state = ZodValidationState.initial('test');
        final result = state.fold<String>(
          onValid: (value) => 'Valid: $value',
          onInvalid: (errors) => 'Invalid: ${errors.first.message}',
          onLoading: () => 'Loading...',
        );

        expect(result, equals('Valid: test'));
      });
    });
  });
}
