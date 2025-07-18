import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('StringSchema', () {
    group('Basic validation', () {
      test('should validate valid string', () {
        final schema = z.string();
        final result = schema.validate('hello');
        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });

      test('should reject non-string input', () {
        final schema = z.string();
        final result = schema.validate(123);
        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'type_mismatch');
      });

      test('should reject null input', () {
        final schema = z.string();
        final result = schema.validate(null);
        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'type_mismatch');
      });

      test('should reject boolean input', () {
        final schema = z.string();
        final result = schema.validate(true);
        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'type_mismatch');
      });

      test('should reject array input', () {
        final schema = z.string();
        final result = schema.validate([1, 2, 3]);
        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'type_mismatch');
      });

      test('should reject object input', () {
        final schema = z.string();
        final result = schema.validate({'key': 'value'});
        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'type_mismatch');
      });
    });

    group('Length constraints', () {
      test('should validate minimum length', () {
        final schema = z.string().min(5);
        final result = schema.validate('hello');
        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });

      test('should reject string below minimum length', () {
        final schema = z.string().min(5);
        final result = schema.validate('hi');
        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'min_length');
        expect(result.errors?.first?.context?['expected'], 5);
        expect(result.errors?.first?.context?['actual'], 2);
      });

      test('should validate maximum length', () {
        final schema = z.string().max(10);
        final result = schema.validate('hello');
        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });

      test('should reject string above maximum length', () {
        final schema = z.string().max(5);
        final result = schema.validate('hello world');
        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'max_length');
        expect(result.errors?.first?.context?['expected'], 5);
        expect(result.errors?.first?.context?['actual'], 11);
      });

      test('should validate exact length', () {
        final schema = z.string().length(5);
        final result = schema.validate('hello');
        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });

      test('should reject string with wrong exact length', () {
        final schema = z.string().length(5);
        final result = schema.validate('hi');
        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'exact_length');
        expect(result.errors?.first?.context?['expected'], 5);
        expect(result.errors?.first?.context?['actual'], 2);
      });
    });

    group('Pattern validation', () {
      test('should validate regex pattern', () {
        final schema = z.string().regex(RegExp(r'^[a-z]+$'));
        final result = schema.validate('hello');
        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });

      test('should reject string not matching pattern', () {
        final schema = z.string().regex(RegExp(r'^[a-z]+$'));
        final result = schema.validate('Hello123');
        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'pattern_mismatch');
        expect(result.errors?.first?.context?['pattern'], '^[a-z]+\$');
      });
    });

    group('Email validation', () {
      test('should validate valid email', () {
        final schema = z.string().email();
        final result = schema.validate('test@example.com');
        expect(result.isSuccess, true);
        expect(result.data, 'test@example.com');
      });

      test('should reject invalid email', () {
        final schema = z.string().email();
        final result = schema.validate('invalid-email');
        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'invalid_email');
      });

      test('should reject email without domain', () {
        final schema = z.string().email();
        final result = schema.validate('test@');
        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'invalid_email');
      });

      test('should reject email without @ symbol', () {
        final schema = z.string().email();
        final result = schema.validate('testexample.com');
        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'invalid_email');
      });
    });

    group('URL validation', () {
      test('should validate valid http URL', () {
        final schema = z.string().url();
        final result = schema.validate('http://example.com');
        expect(result.isSuccess, true);
        expect(result.data, 'http://example.com');
      });

      test('should validate valid https URL', () {
        final schema = z.string().url();
        final result = schema.validate('https://example.com');
        expect(result.isSuccess, true);
        expect(result.data, 'https://example.com');
      });

      test('should reject invalid URL', () {
        final schema = z.string().url();
        final result = schema.validate('invalid-url');
        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'invalid_url');
      });

      test('should reject URL without scheme', () {
        final schema = z.string().url();
        final result = schema.validate('example.com');
        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'invalid_url');
      });

      test('should reject URL with invalid scheme', () {
        final schema = z.string().url();
        final result = schema.validate('ftp://example.com');
        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'invalid_url');
      });

      test('should handle malformed URL gracefully', () {
        final schema = z.string().url();
        final result = schema.validate('://example.com');
        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'invalid_url');
      });
    });

    group('UUID validation', () {
      test('should validate valid UUID', () {
        final schema = z.string().uuid();
        final result = schema.validate('550e8400-e29b-41d4-a716-446655440000');
        expect(result.isSuccess, true);
        expect(result.data, '550e8400-e29b-41d4-a716-446655440000');
      });

      test('should validate uppercase UUID', () {
        final schema = z.string().uuid();
        final result = schema.validate('550E8400-E29B-41D4-A716-446655440000');
        expect(result.isSuccess, true);
        expect(result.data, '550E8400-E29B-41D4-A716-446655440000');
      });

      test('should reject invalid UUID', () {
        final schema = z.string().uuid();
        final result = schema.validate('invalid-uuid');
        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'invalid_uuid');
      });

      test('should reject UUID with wrong format', () {
        final schema = z.string().uuid();
        final result = schema.validate('550e8400-e29b-41d4-a716-44665544000');
        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'invalid_uuid');
      });
    });

    group('String transformations', () {
      test('should trim whitespace', () {
        final schema = z.string().trim();
        final result = schema.validate('  hello  ');
        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });

      test('should convert to lowercase', () {
        final schema = z.string().toLowerCase();
        final result = schema.validate('HELLO');
        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });

      test('should convert to uppercase', () {
        final schema = z.string().toUpperCase();
        final result = schema.validate('hello');
        expect(result.isSuccess, true);
        expect(result.data, 'HELLO');
      });

      test('should apply multiple transformations', () {
        final schema = z.string().trim().toLowerCase();
        final result = schema.validate('  HELLO  ');
        expect(result.isSuccess, true);
        expect(result.data, 'hello');
      });

      test('should validate after transformation', () {
        final schema = z.string().trim().min(5);
        final result = schema.validate('  hi  ');
        expect(result.isFailure, true);
        expect(result.errors?.first?.code, 'min_length');
      });
    });

    group('Constructor and toString', () {
      test('should create StringSchema with all parameters', () {
        final schema = z.string()
            .min(5)
            .max(10)
            .email()
            .trim()
            .toLowerCase();
        
        expect(schema.toString(), contains('StringSchema'));
        expect(schema.toString(), contains('min: 5'));
        expect(schema.toString(), contains('max: 10'));
        expect(schema.toString(), contains('email'));
        expect(schema.toString(), contains('trim'));
        expect(schema.toString(), contains('toLowerCase'));
      });

      test('should create StringSchema with exact length', () {
        final schema = z.string().length(10);
        expect(schema.toString(), contains('length: 10'));
      });

      test('should create StringSchema with pattern', () {
        final schema = z.string().regex(RegExp(r'^[a-z]+$'));
        expect(schema.toString(), contains('pattern: ^[a-z]+\$'));
      });

      test('should create StringSchema with URL validation', () {
        final schema = z.string().url();
        expect(schema.toString(), contains('url'));
      });

      test('should create StringSchema with UUID validation', () {
        final schema = z.string().uuid();
        expect(schema.toString(), contains('uuid'));
      });

      test('should create StringSchema with uppercase transformation', () {
        final schema = z.string().toUpperCase();
        expect(schema.toString(), contains('toUpperCase'));
      });

      test('should create basic StringSchema without constraints', () {
        final schema = z.string();
        expect(schema.toString(), equals('StringSchema'));
      });
    });

    group('Helper method coverage', () {
      test('should test _isValidEmail edge cases', () {
        final schema = z.string().email();
        
        // Valid emails
        expect(schema.validate('test@example.com').isSuccess, true);
        expect(schema.validate('user.name@domain.co.uk').isSuccess, true);
        expect(schema.validate('test+tag@example.com').isSuccess, true);
        
        // Invalid emails
        expect(schema.validate('').isFailure, true);
        expect(schema.validate('test').isFailure, true);
        expect(schema.validate('test@').isFailure, true);
        expect(schema.validate('@example.com').isFailure, true);
        expect(schema.validate('test@example').isFailure, true);
        expect(schema.validate('test@example.').isFailure, true);
        expect(schema.validate('test@.com').isFailure, true);
      });

      test('should test _isValidUrl edge cases', () {
        final schema = z.string().url();
        
        // Valid URLs
        expect(schema.validate('http://example.com').isSuccess, true);
        expect(schema.validate('https://example.com').isSuccess, true);
        expect(schema.validate('http://example.com/path').isSuccess, true);
        expect(schema.validate('https://example.com/path?query=value').isSuccess, true);
        
        // Invalid URLs
        expect(schema.validate('').isFailure, true);
        expect(schema.validate('example.com').isFailure, true);
        expect(schema.validate('ftp://example.com').isFailure, true);
        expect(schema.validate('not-a-url').isFailure, true);
      });

      test('should test _isValidUuid edge cases', () {
        final schema = z.string().uuid();
        
        // Valid UUIDs
        expect(schema.validate('550e8400-e29b-41d4-a716-446655440000').isSuccess, true);
        expect(schema.validate('550E8400-E29B-41D4-A716-446655440000').isSuccess, true);
        expect(schema.validate('00000000-0000-0000-0000-000000000000').isSuccess, true);
        
        // Invalid UUIDs
        expect(schema.validate('').isFailure, true);
        expect(schema.validate('550e8400-e29b-41d4-a716-44665544000').isFailure, true);
        expect(schema.validate('550e8400-e29b-41d4-a716-4466554400000').isFailure, true);
        expect(schema.validate('550e8400-e29b-41d4-a716-446655440g00').isFailure, true);
        expect(schema.validate('550e8400e29b41d4a716446655440000').isFailure, true);
      });

      test('should test IPv4 validation helper', () {
        final schema = z.string().ipv4();
        
        // Valid IPv4 addresses
        expect(schema.validate('192.168.1.1').isSuccess, true);
        expect(schema.validate('0.0.0.0').isSuccess, true);
        expect(schema.validate('255.255.255.255').isSuccess, true);
        
        // Invalid IPv4 addresses
        expect(schema.validate('256.256.256.256').isFailure, true);
        expect(schema.validate('192.168.1').isFailure, true);
        expect(schema.validate('192.168.1.1.1').isFailure, true);
        expect(schema.validate('192.168.1.abc').isFailure, true);
        expect(schema.validate('192.168.1.-1').isFailure, true);
      });

      test('should test IPv6 validation helper', () {
        final schema = z.string().ipv6();
        
        // Valid IPv6 addresses
        expect(schema.validate('2001:db8::1').isSuccess, true);
        expect(schema.validate('::1').isSuccess, true);
        expect(schema.validate('2001:db8:85a3::8a2e:370:7334').isSuccess, true);
        
        // Invalid IPv6 addresses
        expect(schema.validate('2001:db8').isFailure, true);
        expect(schema.validate('2001:db8::gggg').isFailure, true);
        expect(schema.validate('2001:db8::10000').isFailure, true);
        expect(schema.validate('invalid:ipv6').isFailure, true);
      });

      test('should test general IP validation helper', () {
        final schema = z.string().ip();
        
        // Valid IP addresses (both IPv4 and IPv6)
        expect(schema.validate('192.168.1.1').isSuccess, true);
        expect(schema.validate('2001:db8::1').isSuccess, true);
        
        // Invalid IP addresses
        expect(schema.validate('not-an-ip').isFailure, true);
        expect(schema.validate('256.256.256.256').isFailure, true);
        expect(schema.validate('invalid:ipv6').isFailure, true);
      });
    });
  });
}