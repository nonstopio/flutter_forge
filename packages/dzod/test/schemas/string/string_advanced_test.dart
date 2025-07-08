import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('StringSchema Advanced Validations', () {
    group('CUID validation', () {
      test('should validate valid CUIDs', () {
        final schema = Z.string().cuid();

        // Valid CUID format: c + 24 lowercase alphanumeric characters
        final validCuids = [
          'c1234567890abcdefghijklmn',
          'cabcdefghijklmnopqrstuvwx',
          'c000000000000000000000000',
          'czzzzzzzzzzzzzzzzzzzzzzzz',
        ];

        for (final cuid in validCuids) {
          final result = schema.validate(cuid);
          expect(result.isSuccess, isTrue, reason: 'Should validate $cuid');
          expect(result.data, equals(cuid));
        }
      });

      test('should reject invalid CUIDs', () {
        final schema = Z.string().cuid();

        final invalidCuids = [
          'abc123', // Too short
          'c1234567890abcdefghijklmno', // Too long
          'd1234567890abcdefghijklmn', // Doesn\'t start with c
          'c1234567890ABCDEFGHIJKLMN', // Contains uppercase
          'c1234567890abcdefghijklm-', // Contains special chars
          '', // Empty
          'C1234567890abcdefghijklmn', // Capital C
        ];

        for (final cuid in invalidCuids) {
          final result = schema.validate(cuid);
          expect(result.isFailure, isTrue, reason: 'Should reject $cuid');
          expect(result.errors?.first?.code, equals('invalid_cuid'));
        }
      });
    });

    group('CUID2 validation', () {
      test('should validate valid CUID2s', () {
        final schema = Z.string().cuid2();

        final validCuid2s = [
          'abcdefghijklmnopqrstu', // Minimum length (21)
          'abcdefghijklmnopqrstuvwxyz0123456789abcdefghij', // Medium length
          'a' * 50, // Maximum length (50)
          'z0123456789abcdefghijklmnopqrstuv',
        ];

        for (final cuid2 in validCuid2s) {
          final result = schema.validate(cuid2);
          expect(result.isSuccess, isTrue, reason: 'Should validate $cuid2');
          expect(result.data, equals(cuid2));
        }
      });

      test('should reject invalid CUID2s', () {
        final schema = Z.string().cuid2();

        final invalidCuid2s = [
          'a' * 20, // Too short
          'a' * 51, // Too long
          '1abcdefghijklmnopqrstu', // Starts with number
          'Aabcdefghijklmnopqrstu', // Contains uppercase
          'aabcdefghijklmnopqrst-', // Contains special chars
          '', // Empty
          '_abcdefghijklmnopqrstu', // Starts with underscore
        ];

        for (final cuid2 in invalidCuid2s) {
          final result = schema.validate(cuid2);
          expect(result.isFailure, isTrue, reason: 'Should reject $cuid2');
          expect(result.errors?.first?.code, equals('invalid_cuid2'));
        }
      });
    });

    group('ULID validation', () {
      test('should validate valid ULIDs', () {
        final schema = Z.string().ulid();

        final validUlids = [
          '01ARZ3NDEKTSV4RRFFQ69G5FAV', // Example ULID
          '01BX5ZZKBKACTAV9WEVGEMMVRZ', // Another example
          '01C3H2Z3B4EFGH5JKLMNPQRSTW', // Valid format
          '7ZZZZZZZZZZZZZZZZZZZZZZZZZ', // All Z's (valid)
          '01234567890ABCDEFGHJKMNPQR', // Valid Crockford's Base32
        ];

        for (final ulid in validUlids) {
          final result = schema.validate(ulid);
          expect(result.isSuccess, isTrue, reason: 'Should validate $ulid');
          expect(result.data, equals(ulid));
        }
      });

      test('should reject invalid ULIDs', () {
        final schema = Z.string().ulid();

        final invalidUlids = [
          '01ARZ3NDEKTSV4RRFFQ69G5FA', // Too short
          '01ARZ3NDEKTSV4RRFFQ69G5FAVX', // Too long
          '01ARZ3NDEKTSV4RRFFQ69G5FIL', // Contains I (not in Crockford's)
          '01ARZ3NDEKTSV4RRFFQ69G5FOO', // Contains O (not in Crockford's)
          '01arz3ndektsv4rrffq69g5fav', // Lowercase (should be uppercase)
          '', // Empty
          '01ARZ3NDEKTSV4RRFFQ69G5F@V', // Contains special chars
        ];

        for (final ulid in invalidUlids) {
          final result = schema.validate(ulid);
          expect(result.isFailure, isTrue, reason: 'Should reject $ulid');
          expect(result.errors?.first?.code, equals('invalid_ulid'));
        }
      });
    });

    group('Base64 validation', () {
      test('should validate valid Base64 strings', () {
        final schema = Z.string().base64();

        final validBase64s = [
          'SGVsbG8gV29ybGQ=', // "Hello World"
          'VGVzdA==', // "Test"
          'YWJjZGVmZ2hpamtsbW5vcA==', // Longer string
          'MTIzNDU2Nzg5MA==', // Numbers
          'QQ==', // Single char
          'QUI=', // Two chars
          'QUJD', // Three chars (no padding)
        ];

        for (final base64 in validBase64s) {
          final result = schema.validate(base64);
          expect(result.isSuccess, isTrue, reason: 'Should validate $base64');
          expect(result.data, equals(base64));
        }
      });

      test('should reject invalid Base64 strings', () {
        final schema = Z.string().base64();

        final invalidBase64s = [
          'SGVsbG8gV29ybGQ', // Missing padding
          'SGVsbG8gV29ybGQ===', // Too much padding
          'SGVsbG8@V29ybGQ=', // Invalid character
          'SGVsbG8 V29ybGQ=', // Contains space
          '', // Empty
          'A', // Invalid length
          'SGVsbG8gV29ybGQ=!', // Invalid character at end
        ];

        for (final base64 in invalidBase64s) {
          final result = schema.validate(base64);
          expect(result.isFailure, isTrue, reason: 'Should reject $base64');
          expect(result.errors?.first?.code, equals('invalid_base64'));
        }
      });
    });

    group('Emoji validation', () {
      test('should validate strings containing only emojis', () {
        final schema = Z.string().emoji();

        final validEmojis = [
          '😀', // Single emoji
          '😀😃😄', // Multiple emojis
          '🌟⭐✨', // Different emoji types
          '🏳️‍🌈', // Complex emoji with ZWJ
          '👨‍👩‍👧‍👦', // Family emoji
          '🇺🇸', // Flag emoji
          '🔥', // Symbol emoji
        ];

        for (final emoji in validEmojis) {
          final result = schema.validate(emoji);
          expect(result.isSuccess, isTrue, reason: 'Should validate $emoji');
          expect(result.data, equals(emoji));
        }
      });

      test('should reject strings with non-emoji content', () {
        final schema = Z.string().emoji();

        final invalidEmojis = [
          'Hello 😀', // Text with emoji
          '😀 World', // Emoji with text
          'ABC', // Regular text
          '123', // Numbers
          '', // Empty
          '😀!', // Emoji with punctuation
          '😀\n😃', // Emoji with newline
        ];

        for (final emoji in invalidEmojis) {
          final result = schema.validate(emoji);
          expect(result.isFailure, isTrue, reason: 'Should reject $emoji');
          expect(result.errors?.first?.code, equals('invalid_emoji'));
        }
      });
    });

    group('NanoID validation', () {
      test('should validate valid NanoIDs with default length', () {
        final schema = Z.string().nanoid();

        final validNanoids = [
          'V1StGXR8_Z5jdHi6B-myT', // 21 chars, valid alphabet
          'a1b2c3d4e5f6g7h8i9j0k', // 21 chars, mixed case
          'ABCDEFGHIJKLMNOPQRSTU', // 21 chars, uppercase
          'abcdefghijklmnopqrstu', // 21 chars, lowercase
          '123456789012345678901', // 21 chars, numbers
          '_-_-_-_-_-_-_-_-_-_-_', // 21 chars, special chars
        ];

        for (final nanoid in validNanoids) {
          final result = schema.validate(nanoid);
          expect(result.isSuccess, isTrue, reason: 'Should validate $nanoid');
          expect(result.data, equals(nanoid));
        }
      });

      test('should validate NanoIDs with custom length', () {
        final schema10 = Z.string().nanoid(length: 10);
        final schema30 = Z.string().nanoid(length: 30);

        final result10 = schema10.validate('abcdefghij');
        expect(result10.isSuccess, isTrue);

        final result30 = schema30.validate('abcdefghijklmnopqrstuvwxyz1234');
        expect(result30.isSuccess, isTrue);
      });

      test('should reject invalid NanoIDs', () {
        final schema = Z.string().nanoid();

        final invalidNanoids = [
          'V1StGXR8_Z5jdHi6B-myT!', // Invalid character
          'V1StGXR8_Z5jdHi6B-my', // Too short
          'V1StGXR8_Z5jdHi6B-myTX', // Too long
          '', // Empty
          'V1StGXR8 Z5jdHi6B-myT', // Contains space
          'V1StGXR8+Z5jdHi6B-myT', // Invalid character +
        ];

        for (final nanoid in invalidNanoids) {
          final result = schema.validate(nanoid);
          expect(result.isFailure, isTrue, reason: 'Should reject $nanoid');
          expect(result.errors?.first?.code, equals('invalid_nanoid'));
        }
      });
    });

    group('JWT validation', () {
      test('should validate valid JWTs', () {
        final schema = Z.string().jwt();

        final validJwts = [
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c',
          'abc.def.ghi', // Simple valid format
          'header.payload.signature', // Valid structure
          'a.b.c', // Minimal valid structure
        ];

        for (final jwt in validJwts) {
          final result = schema.validate(jwt);
          expect(result.isSuccess, isTrue, reason: 'Should validate $jwt');
          expect(result.data, equals(jwt));
        }
      });

      test('should reject invalid JWTs', () {
        final schema = Z.string().jwt();

        final invalidJwts = [
          'header.payload', // Missing signature
          'header.payload.signature.extra', // Too many parts
          'header..signature', // Empty payload
          '.payload.signature', // Empty header
          'header.payload.', // Empty signature
          '', // Empty
          'header.payload.sign@ture', // Invalid character
          'header payload signature', // Spaces instead of dots
        ];

        for (final jwt in invalidJwts) {
          final result = schema.validate(jwt);
          expect(result.isFailure, isTrue, reason: 'Should reject $jwt');
          expect(result.errors?.first?.code, equals('invalid_jwt'));
        }
      });
    });

    group('Hex validation', () {
      test('should validate valid hex strings', () {
        final schema = Z.string().hex();

        final validHexs = [
          '1234567890abcdef', // Lowercase
          '1234567890ABCDEF', // Uppercase
          '0x1234567890abcdef', // With 0x prefix
          '0X1234567890ABCDEF', // With 0X prefix
          'a', // Single char
          'ABC123', // Mixed case
          '0', // Single digit
        ];

        for (final hex in validHexs) {
          final result = schema.validate(hex);
          expect(result.isSuccess, isTrue, reason: 'Should validate $hex');
          expect(result.data, equals(hex));
        }
      });

      test('should reject invalid hex strings', () {
        final schema = Z.string().hex();

        final invalidHexs = [
          'xyz', // Invalid characters
          '123g', // Invalid character g
          '', // Empty
          '0x', // Only prefix
          'hello', // Non-hex string
          '123 456', // Contains space
        ];

        for (final hex in invalidHexs) {
          final result = schema.validate(hex);
          expect(result.isFailure, isTrue, reason: 'Should reject $hex');
          expect(result.errors?.first?.code, equals('invalid_hex'));
        }
      });
    });

    group('Hex color validation', () {
      test('should validate valid hex color codes', () {
        final schema = Z.string().hexColor();

        final validColors = [
          '#ff0000', // Red with #
          'ff0000', // Red without #
          '#FF0000', // Uppercase
          '#f00', // Short form
          'f00', // Short form without #
          '#ff0000ff', // With alpha
          '#rgba', // Short form with alpha
        ];

        for (final color in validColors) {
          final result = schema.validate(color);
          expect(result.isSuccess, isTrue, reason: 'Should validate $color');
          expect(result.data, equals(color));
        }
      });

      test('should reject invalid hex color codes', () {
        final schema = Z.string().hexColor();

        final invalidColors = [
          '#ff', // Too short
          '#ff0000ff00', // Too long
          '#gg0000', // Invalid character
          '', // Empty
          '#', // Only #
          'red', // Named color
          '#ff 00 00', // Contains spaces
        ];

        for (final color in invalidColors) {
          final result = schema.validate(color);
          expect(result.isFailure, isTrue, reason: 'Should reject $color');
          expect(result.errors?.first?.code, equals('invalid_hex_color'));
        }
      });
    });

    group('JSON validation', () {
      test('should validate valid JSON strings', () {
        final schema = Z.string().json();

        final validJsons = [
          '{"name": "John", "age": 30}', // Object
          '[1, 2, 3, 4, 5]', // Array
          '{"nested": {"key": "value"}}', // Nested object
          '[{"id": 1}, {"id": 2}]', // Array of objects
          '{"empty": {}}', // Empty object
          '[]', // Empty array
        ];

        for (final json in validJsons) {
          final result = schema.validate(json);
          expect(result.isSuccess, isTrue, reason: 'Should validate $json');
          expect(result.data, equals(json));
        }
      });

      test('should reject invalid JSON strings', () {
        final schema = Z.string().json();

        final invalidJsons = [
          '{name: "John"}', // Unquoted key
          '{"name": "John",}', // Trailing comma
          '[1, 2, 3,]', // Trailing comma in array
          '"string"', // Plain string (not object/array)
          '123', // Plain number
          'true', // Plain boolean
          'null', // Plain null
          '', // Empty
          '{name}', // Invalid syntax
          'undefined', // JavaScript undefined
        ];

        for (final json in invalidJsons) {
          final result = schema.validate(json);
          expect(result.isFailure, isTrue, reason: 'Should reject $json');
          expect(result.errors?.first?.code, equals('invalid_json'));
        }
      });
    });

    group('Chaining validations', () {
      test('should chain multiple validations', () {
        final schema = Z.string().min(5).cuid();

        const validCuid = 'c1234567890abcdefghijklmn';
        final result = schema.validate(validCuid);
        expect(result.isSuccess, isTrue);

        const shortCuid = 'c123';
        final shortResult = schema.validate(shortCuid);
        expect(shortResult.isFailure, isTrue);
      });
    });
  });
}
