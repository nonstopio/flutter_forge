import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('dzod.dart exports', () {
    test('should export core schemas', () {
      expect(Z.string(), isA<StringSchema>());
      expect(Z.number(), isA<NumberSchema>());
      expect(Z.boolean(), isA<BooleanSchema>());
      expect(Z.null_(), isA<NullSchema>());
    });

    test('should export advanced schemas', () {
      expect(Z.discriminatedUnion('type', []), isA<DiscriminatedUnionSchema>());
      expect(Z.pipeline([Z.string()]), isA<PipelineSchema>());
      expect(Z.recursive(() => Z.string()), isA<RecursiveSchema>());
    });

    test('should export collection schemas', () {
      expect(Z.array(Z.string()), isA<ArraySchema>());
      expect(Z.tuple([Z.string()]), isA<TupleSchema>());
      expect(Z.record(), isA<RecordSchema>());
    });

    test('should export specialized schemas', () {
      expect(Z.enum_(['a', 'b']), isA<EnumSchema>());
      expect(Z.literal('test'), isA<Schema>());
    });

    test('should export object schema', () {
      expect(Z.object({}), isA<ObjectSchema>());
    });

    test('should export coercion schemas', () {
      expect(Z.coerce.string(), isA<CoercionSchema>());
      expect(Z.coerce.number(), isA<CoercionSchema>());
      expect(Z.coerce.boolean(), isA<CoercionSchema>());
    });

    test('should export core error classes', () {
      expect(
          ValidationError.typeMismatch(
              expected: 'string', received: 123, path: []),
          isA<ValidationError>());
      expect(const ValidationErrorCollection([]),
          isA<ValidationErrorCollection>());
      expect(const ValidationException('test'), isA<ValidationException>());
    });

    test('should export validation result', () {
      expect(const ValidationResult.success('test'), isA<ValidationResult>());
      expect(const ValidationResult.failure(ValidationErrorCollection([])),
          isA<ValidationResult>());
    });
  });
}
