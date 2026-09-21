import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

class _ThrowingString {
  int attempts = 0;

  @override
  String toString() {
    if (attempts++ == 0) throw const FormatException('first conversion failed');
    return 'recovered';
  }
}

class _ExclusiveNumber extends NumberSchema {
  @override
  num get exclusiveMinimum => 1;

  @override
  num get exclusiveMaximum => 10;
}

void main() {
  test('async refinement awaits the preceding async transformation', () async {
    final schema = z
        .string()
        .transformAsync((value) async => value.length)
        .refineAsync((length) async => length > 2, message: 'too short');
    expect((await schema.validateAsync('hello')).data, 5);
    expect((await schema.validateAsync('a')).errors!.first!.message,
        contains('too short'));
    expect((await schema.validateAsync(12)).isFailure, isTrue);
  });

  test('content refinements validate their actual public APIs', () {
    final cases = <(Schema<String>, String, String, String)>[
      (z.string().startsWith('pre'), 'prefix', 'suffix', 'starts_with'),
      (z.string().endsWith('fix'), 'suffix', 'other', 'ends_with'),
      (z.string().contains('middle'), 'a middle b', 'other', 'contains'),
      (z.string().date(), '2025-01-01', 'invalid', 'invalid_date'),
      (
        z.string().datetime(),
        '2025-01-01T12:30:00',
        'invalid',
        'invalid_datetime'
      ),
    ];
    for (final (schema, valid, invalid, code) in cases) {
      expect(schema.parse(valid), valid);
      expect(schema.validate(invalid).errors!.first!.code, code);
      expect(schema.validate(42).isFailure, isTrue);
    }
    expect(z.string().min(4).startsWith('a').validate('a').isFailure, isTrue);
  });

  test('exact constraint getters describe the configured constraints', () {
    expect(z.string().length(3).exactLength, 3);
    expect(z.array(z.string()).length(2).exactItems, 2);
    expect(z.number().exact(7).exactValue, 7);
  });

  test('JSON generation respects exclusive numeric constraints', () {
    expect(
        _ExclusiveNumber().toJsonSchema(), containsPair('exclusiveMinimum', 1));
    expect(_ExclusiveNumber().toJsonSchema(),
        containsPair('exclusiveMaximum', 10));
  });

  test('pipeline factory preserves metadata and validates all stages', () {
    final pipeline = PipelineExtension.pipeline<String, String>(
      [z.string().trim(), z.string().min(3)],
      description: 'trim then validate',
      metadata: {'purpose': 'test'},
    );
    expect(pipeline.parse(' abc '), 'abc');
    expect(pipeline.validate(' a ').isFailure, isTrue);
    expect(pipeline.description, 'trim then validate');
    expect(pipeline.metadata, {'purpose': 'test'});
    expect(() => PipelineExtension.pipeline([]), throwsArgumentError);
  });

  test(
      'string fallback tries strategies in order and retries ultimate conversion',
      () {
    final attempts = <String>[];
    expect(
      CoercionUtils.coerceToStringAdvanced(
        _ThrowingString(),
        fallbackStrategies: [
          (_) {
            attempts.add('first');
            throw const FormatException();
          },
          (_) {
            attempts.add('second');
            return 'fallback';
          },
        ],
      ),
      'fallback',
    );
    expect(attempts, ['first', 'second']);
    expect(
        CoercionUtils.coerceToStringAdvanced(_ThrowingString()), 'recovered');
    expect(
        () => CoercionUtils.coerceToStringAdvanced(_ThrowingString(),
            strict: true),
        throwsFormatException);
  });

  test('number and generic coercion continue after a failing fallback', () {
    expect(
        CoercionUtils.coerceToNumberAdvanced('bad', fallbackStrategies: [
          (_) => throw const FormatException(),
          (_) => 12,
        ]),
        12);
    expect(
        CoercionUtils.coerceToType<int>('bad',
            primaryCoercer: (_) => throw const FormatException(),
            fallbackStrategies: [
              (_) => throw const FormatException(),
              (_) => 13,
            ]),
        13);
  });
}
