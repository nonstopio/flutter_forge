import 'dart:convert';

import '../../core/error.dart';
import '../../core/schema.dart';
import '../../core/validation_result.dart';

/// Schema for validating string values
class StringSchema extends Schema<String> {
  /// Minimum length constraint
  final int? _minLength;

  /// Maximum length constraint
  final int? _maxLength;

  /// Exact length constraint
  final int? _exactLength;

  /// Regular expression pattern
  final RegExp? _pattern;

  /// Email validation flag
  final bool _isEmail;

  /// URL validation flag
  final bool _isUrl;

  /// UUID validation flag
  final bool _isUuid;

  /// Trim whitespace flag
  final bool _trim;

  /// Convert to lowercase flag
  final bool _toLowerCase;

  /// Convert to uppercase flag
  final bool _toUpperCase;

  const StringSchema({
    super.description,
    super.metadata,
    int? minLength,
    int? maxLength,
    int? exactLength,
    RegExp? pattern,
    bool isEmail = false,
    bool isUrl = false,
    bool isUuid = false,
    bool trim = false,
    bool toLowerCase = false,
    bool toUpperCase = false,
  })  : _minLength = minLength,
        _maxLength = maxLength,
        _exactLength = exactLength,
        _pattern = pattern,
        _isEmail = isEmail,
        _isUrl = isUrl,
        _isUuid = isUuid,
        _trim = trim,
        _toLowerCase = toLowerCase,
        _toUpperCase = toUpperCase;

  @override
  ValidationResult<String> validate(dynamic input,
      [List<String> path = const []]) {
    // Type check
    if (input is! String) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.typeMismatch(
            path: path,
            received: input,
            expected: 'string',
          ),
        ),
      );
    }

    String value = input;

    // Apply transformations
    if (_trim) {
      value = value.trim();
    }
    if (_toLowerCase) {
      value = value.toLowerCase();
    }
    if (_toUpperCase) {
      value = value.toUpperCase();
    }

    // Length validations
    if (_exactLength != null && value.length != _exactLength) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: value,
            constraint: 'exact length of $_exactLength',
            code: 'exact_length',
            context: {'expected': _exactLength, 'actual': value.length},
          ),
        ),
      );
    }

    if (_minLength != null && value.length < _minLength!) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: value,
            constraint: 'minimum length of $_minLength',
            code: 'min_length',
            context: {'expected': _minLength, 'actual': value.length},
          ),
        ),
      );
    }

    if (_maxLength != null && value.length > _maxLength!) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: value,
            constraint: 'maximum length of $_maxLength',
            code: 'max_length',
            context: {'expected': _maxLength, 'actual': value.length},
          ),
        ),
      );
    }

    // Pattern validation
    if (_pattern != null && !_pattern!.hasMatch(value)) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: value,
            constraint: 'match pattern ${_pattern!.pattern}',
            code: 'pattern_mismatch',
            context: {'pattern': _pattern!.pattern},
          ),
        ),
      );
    }

    // Email validation
    if (_isEmail && !_isValidEmail(value)) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: value,
            constraint: 'valid email address',
            code: 'invalid_email',
          ),
        ),
      );
    }

    // URL validation
    if (_isUrl && !_isValidUrl(value)) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: value,
            constraint: 'valid URL',
            code: 'invalid_url',
          ),
        ),
      );
    }

    // UUID validation
    if (_isUuid && !_isValidUuid(value)) {
      return ValidationResult.failure(
        ValidationErrorCollection.single(
          ValidationError.constraintViolation(
            path: path,
            received: value,
            constraint: 'valid UUID',
            code: 'invalid_uuid',
          ),
        ),
      );
    }

    return ValidationResult.success(value);
  }

  /// Sets minimum length constraint
  StringSchema min(int length) {
    return StringSchema(
      description: description,
      metadata: metadata,
      minLength: length,
      maxLength: _maxLength,
      exactLength: _exactLength,
      pattern: _pattern,
      isEmail: _isEmail,
      isUrl: _isUrl,
      isUuid: _isUuid,
      trim: _trim,
      toLowerCase: _toLowerCase,
      toUpperCase: _toUpperCase,
    );
  }

  /// Sets maximum length constraint
  StringSchema max(int length) {
    return StringSchema(
      description: description,
      metadata: metadata,
      minLength: _minLength,
      maxLength: length,
      exactLength: _exactLength,
      pattern: _pattern,
      isEmail: _isEmail,
      isUrl: _isUrl,
      isUuid: _isUuid,
      trim: _trim,
      toLowerCase: _toLowerCase,
      toUpperCase: _toUpperCase,
    );
  }

  /// Sets exact length constraint
  StringSchema length(int length) {
    return StringSchema(
      description: description,
      metadata: metadata,
      minLength: _minLength,
      maxLength: _maxLength,
      exactLength: length,
      pattern: _pattern,
      isEmail: _isEmail,
      isUrl: _isUrl,
      isUuid: _isUuid,
      trim: _trim,
      toLowerCase: _toLowerCase,
      toUpperCase: _toUpperCase,
    );
  }

  /// Sets regular expression pattern
  StringSchema regex(RegExp pattern) {
    return StringSchema(
      description: description,
      metadata: metadata,
      minLength: _minLength,
      maxLength: _maxLength,
      exactLength: _exactLength,
      pattern: pattern,
      isEmail: _isEmail,
      isUrl: _isUrl,
      isUuid: _isUuid,
      trim: _trim,
      toLowerCase: _toLowerCase,
      toUpperCase: _toUpperCase,
    );
  }

  /// Sets email validation
  StringSchema email() {
    return StringSchema(
      description: description,
      metadata: metadata,
      minLength: _minLength,
      maxLength: _maxLength,
      exactLength: _exactLength,
      pattern: _pattern,
      isEmail: true,
      isUrl: _isUrl,
      isUuid: _isUuid,
      trim: _trim,
      toLowerCase: _toLowerCase,
      toUpperCase: _toUpperCase,
    );
  }

  /// Sets URL validation
  StringSchema url() {
    return StringSchema(
      description: description,
      metadata: metadata,
      minLength: _minLength,
      maxLength: _maxLength,
      exactLength: _exactLength,
      pattern: _pattern,
      isEmail: _isEmail,
      isUrl: true,
      isUuid: _isUuid,
      trim: _trim,
      toLowerCase: _toLowerCase,
      toUpperCase: _toUpperCase,
    );
  }

  /// Sets UUID validation
  StringSchema uuid() {
    return StringSchema(
      description: description,
      metadata: metadata,
      minLength: _minLength,
      maxLength: _maxLength,
      exactLength: _exactLength,
      pattern: _pattern,
      isEmail: _isEmail,
      isUrl: _isUrl,
      isUuid: true,
      trim: _trim,
      toLowerCase: _toLowerCase,
      toUpperCase: _toUpperCase,
    );
  }

  /// Sets trim whitespace
  StringSchema trim() {
    return StringSchema(
      description: description,
      metadata: metadata,
      minLength: _minLength,
      maxLength: _maxLength,
      exactLength: _exactLength,
      pattern: _pattern,
      isEmail: _isEmail,
      isUrl: _isUrl,
      isUuid: _isUuid,
      trim: true,
      toLowerCase: _toLowerCase,
      toUpperCase: _toUpperCase,
    );
  }

  /// Sets convert to lowercase
  StringSchema toLowerCase() {
    return StringSchema(
      description: description,
      metadata: metadata,
      minLength: _minLength,
      maxLength: _maxLength,
      exactLength: _exactLength,
      pattern: _pattern,
      isEmail: _isEmail,
      isUrl: _isUrl,
      isUuid: _isUuid,
      trim: _trim,
      toLowerCase: true,
      toUpperCase: _toUpperCase,
    );
  }

  /// Sets convert to uppercase
  StringSchema toUpperCase() {
    return StringSchema(
      description: description,
      metadata: metadata,
      minLength: _minLength,
      maxLength: _maxLength,
      exactLength: _exactLength,
      pattern: _pattern,
      isEmail: _isEmail,
      isUrl: _isUrl,
      isUuid: _isUuid,
      trim: _trim,
      toLowerCase: _toLowerCase,
      toUpperCase: true,
    );
  }

  /// Checks if string starts with the given prefix
  StringSchema startsWith(String prefix) {
    return refine(
      (value) => value.startsWith(prefix),
      message: 'must start with "$prefix"',
      code: 'starts_with',
    ) as StringSchema;
  }

  /// Checks if string ends with the given suffix
  StringSchema endsWith(String suffix) {
    return refine(
      (value) => value.endsWith(suffix),
      message: 'must end with "$suffix"',
      code: 'ends_with',
    ) as StringSchema;
  }

  /// Checks if string contains the given substring
  StringSchema contains(String substring) {
    return refine(
      (value) => value.contains(substring),
      message: 'must contain "$substring"',
      code: 'contains',
    ) as StringSchema;
  }

  /// Checks if string is non-empty
  Schema<String> nonempty() {
    return refine(
      (value) => value.isNotEmpty,
      message: 'must not be empty',
      code: 'nonempty',
    );
  }

  /// Checks if string is a valid date
  StringSchema date() {
    return refine(
      (value) => DateTime.tryParse(value) != null,
      message: 'must be a valid date',
      code: 'invalid_date',
    ) as StringSchema;
  }

  /// Checks if string is a valid datetime
  StringSchema datetime() {
    return refine(
      (value) => DateTime.tryParse(value) != null,
      message: 'must be a valid datetime',
      code: 'invalid_datetime',
    ) as StringSchema;
  }

  /// Checks if string is a valid IP address
  Schema<String> ip() {
    return refine(
      (value) => _isValidIp(value),
      message: 'must be a valid IP address',
      code: 'invalid_ip',
    );
  }

  /// Checks if string is a valid IPv4 address
  Schema<String> ipv4() {
    return refine(
      (value) => _isValidIpv4(value),
      message: 'must be a valid IPv4 address',
      code: 'invalid_ipv4',
    );
  }

  /// Checks if string is a valid IPv6 address
  Schema<String> ipv6() {
    return refine(
      (value) => _isValidIpv6(value),
      message: 'must be a valid IPv6 address',
      code: 'invalid_ipv6',
    );
  }

  /// Checks if string is a valid CUID (Collision-resistant Unique Identifier)
  Schema<String> cuid() {
    return refine(
      (value) => _isValidCuid(value),
      message: 'must be a valid CUID',
      code: 'invalid_cuid',
    );
  }

  /// Checks if string is a valid CUID2 (CUID version 2)
  Schema<String> cuid2() {
    return refine(
      (value) => _isValidCuid2(value),
      message: 'must be a valid CUID2',
      code: 'invalid_cuid2',
    );
  }

  /// Checks if string is a valid ULID (Universally Unique Lexicographically Sortable Identifier)
  Schema<String> ulid() {
    return refine(
      (value) => _isValidUlid(value),
      message: 'must be a valid ULID',
      code: 'invalid_ulid',
    );
  }

  /// Checks if string is a valid Base64 encoded string
  Schema<String> base64() {
    return refine(
      (value) => _isValidBase64(value),
      message: 'must be a valid Base64 encoded string',
      code: 'invalid_base64',
    );
  }

  /// Checks if string contains only emoji characters
  Schema<String> emoji() {
    return refine(
      (value) => _isValidEmoji(value),
      message: 'must contain only emoji characters',
      code: 'invalid_emoji',
    );
  }

  /// Checks if string is a valid NanoID (URL-safe unique string identifier)
  Schema<String> nanoid({int? length}) {
    return refine(
      (value) => _isValidNanoid(value, length),
      message: length != null
          ? 'must be a valid NanoID with length $length'
          : 'must be a valid NanoID',
      code: 'invalid_nanoid',
    );
  }

  /// Checks if string is a valid JWT (JSON Web Token)
  Schema<String> jwt() {
    return refine(
      (value) => _isValidJwt(value),
      message: 'must be a valid JWT',
      code: 'invalid_jwt',
    );
  }

  /// Checks if string is a valid hexadecimal string
  Schema<String> hex() {
    return refine(
      (value) => _isValidHex(value),
      message: 'must be a valid hexadecimal string',
      code: 'invalid_hex',
    );
  }

  /// Checks if string is a valid color hex code
  Schema<String> hexColor() {
    return refine(
      (value) => _isValidHexColor(value),
      message: 'must be a valid hex color code',
      code: 'invalid_hex_color',
    );
  }

  /// Checks if string is a valid JSON string
  Schema<String> json() {
    return refine(
      (value) => _isValidJson(value),
      message: 'must be a valid JSON string',
      code: 'invalid_json',
    );
  }

  // Helper methods for validation

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  bool _isValidUuid(String uuid) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(uuid);
  }

  bool _isValidIp(String ip) {
    return _isValidIpv4(ip) || _isValidIpv6(ip);
  }

  bool _isValidIpv4(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;

    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }
    return true;
  }

  bool _isValidIpv6(String ip) {
    // Simplified IPv6 validation
    final parts = ip.split(':');
    if (parts.length < 3 || parts.length > 8) return false;

    for (final part in parts) {
      if (part.isEmpty) continue;
      final num = int.tryParse(part, radix: 16);
      if (num == null || num < 0 || num > 65535) return false;
    }
    return true;
  }

  bool _isValidCuid(String cuid) {
    // CUID format: c[timestamp][counter][fingerprint][random]
    // Length: 25 characters, starts with 'c'
    if (cuid.length != 25 || !cuid.startsWith('c')) return false;

    final cuidRegex = RegExp(r'^c[0-9a-z]{24}$');
    return cuidRegex.hasMatch(cuid);
  }

  bool _isValidCuid2(String cuid2) {
    // CUID2 format: [length][timestamp][counter][fingerprint][random]
    // Length: variable (21-50 characters), starts with a letter
    if (cuid2.length < 21 || cuid2.length > 50) return false;

    final cuid2Regex = RegExp(r'^[a-z][0-9a-z]*$');
    return cuid2Regex.hasMatch(cuid2);
  }

  bool _isValidUlid(String ulid) {
    // ULID format: 26 characters, Crockford's Base32 encoding
    if (ulid.length != 26) return false;

    // Crockford's Base32 alphabet: 0123456789ABCDEFGHJKMNPQRSTVWXYZ
    // Excludes I, L, O, U to avoid confusion with 1, 1, 0, V
    final ulidRegex = RegExp(r'^[0-9A-HJKMNP-TV-Z]{26}$');
    return ulidRegex.hasMatch(ulid);
  }

  bool _isValidBase64(String base64) {
    if (base64.isEmpty) return false;

    // Base64 must be properly padded
    final base64Regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
    if (!base64Regex.hasMatch(base64)) return false;

    // Check for proper padding
    final withoutPadding = base64.replaceAll('=', '');
    final remainder = withoutPadding.length % 4;

    // If remainder is 1, it's invalid
    if (remainder == 1) return false;

    // Check if padding matches expected amount
    if (remainder == 2 && !base64.endsWith('==')) return false;
    if (remainder == 3 && !base64.endsWith('=')) return false;
    if (remainder == 0 && base64.contains('=')) return false;

    return true;
  }

  bool _isValidEmoji(String text) {
    if (text.isEmpty) return false;

    // More comprehensive emoji regex including:
    // - Basic emoji ranges
    // - Skin tone modifiers
    // - Zero-width joiner sequences (ZWJ)
    // - Regional indicator symbols (flags)
    // - Variation selectors
    final emojiRegex = RegExp(
      r'('
      r'[\u{1F600}-\u{1F64F}]|' // Emoticons
      r'[\u{1F300}-\u{1F5FF}]|' // Misc Symbols and Pictographs
      r'[\u{1F680}-\u{1F6FF}]|' // Transport and Map
      r'[\u{1F1E0}-\u{1F1FF}]|' // Flags (iOS)
      r'[\u{2600}-\u{26FF}]|' // Misc symbols
      r'[\u{2700}-\u{27BF}]|' // Dingbats
      r'[\u{1F900}-\u{1F9FF}]|' // Supplemental Symbols and Pictographs
      r'[\u{1F018}-\u{1F270}]|' // Various other emoji
      r'[\u{238C}]|' // Pushpin
      r'[\u{2194}-\u{2199}]|' // Arrows
      r'[\u{21A9}-\u{21AA}]|' // Curved arrows
      r'[\u{231A}]|' // Watch
      r'[\u{231B}]|' // Hourglass
      r'[\u{23E9}-\u{23EC}]|' // Play/Pause buttons
      r'[\u{23F0}]|' // Alarm clock
      r'[\u{23F3}]|' // Hourglass with flowing sand
      r'[\u{25FD}-\u{25FE}]|' // Small squares
      r'[\u{2614}-\u{2615}]|' // Umbrella and Hot beverage
      r'[\u{2648}-\u{2653}]|' // Zodiac
      r'[\u{267F}]|' // Wheelchair
      r'[\u{2693}]|' // Anchor
      r'[\u{26A1}]|' // High voltage
      r'[\u{26AA}-\u{26AB}]|' // Circles
      r'[\u{26BD}-\u{26BE}]|' // Sports
      r'[\u{26C4}-\u{26C5}]|' // Weather
      r'[\u{26CE}]|' // Ophiuchus
      r'[\u{26D4}]|' // No entry
      r'[\u{26EA}]|' // Church
      r'[\u{26F2}-\u{26F3}]|' // Fountain
      r'[\u{26F5}]|' // Sailboat
      r'[\u{26FA}]|' // Tent
      r'[\u{26FD}]|' // Fuel pump
      r'[\u{2705}]|' // Check mark
      r'[\u{270A}-\u{270B}]|' // Hands
      r'[\u{2728}]|' // Sparkles
      r'[\u{274C}]|' // Cross mark
      r'[\u{274E}]|' // Cross mark
      r'[\u{2753}-\u{2755}]|' // Question marks
      r'[\u{2757}]|' // Exclamation mark
      r'[\u{2795}-\u{2797}]|' // Plus/minus
      r'[\u{27B0}]|' // Curly loop
      r'[\u{27BF}]|' // Double curly loop
      r'[\u{2B1B}-\u{2B1C}]|' // Squares
      r'[\u{2B50}]|' // Star
      r'[\u{2B55}]|' // Circle
      r'[\u{1FA70}-\u{1FAFF}]|' // Symbols and Pictographs Extended-A
      r'[\u{1F000}-\u{1F02F}]|' // Mahjong tiles
      r'[\u{1F0A0}-\u{1F0FF}]|' // Playing cards
      r'[\u{1F100}-\u{1F1FF}]' // Enclosed characters
      r')'
      r'(?:[\u{1F3FB}-\u{1F3FF}])?' // Optional skin tone modifier
      r'(?:\u{200D}' // Zero-width joiner
      r'(?:'
      r'[\u{1F600}-\u{1F64F}]|'
      r'[\u{1F300}-\u{1F5FF}]|'
      r'[\u{1F680}-\u{1F6FF}]|'
      r'[\u{1F1E0}-\u{1F1FF}]|'
      r'[\u{2600}-\u{26FF}]|'
      r'[\u{2700}-\u{27BF}]|'
      r'[\u{1F900}-\u{1F9FF}]|'
      r'[\u{2640}\u{FE0F}]|' // Female sign
      r'[\u{2642}\u{FE0F}]|' // Male sign
      r'[\u{2695}\u{FE0F}]|' // Medical symbol
      r'[\u{1F308}]|' // Rainbow
      r'[\u{1F3F3}]' // White flag
      r')'
      r'(?:[\u{1F3FB}-\u{1F3FF}])?' // Optional skin tone modifier
      r')*' // Can have multiple ZWJ sequences
      r'|'
      r'[\u{1F3F3}]\u{FE0F}?\u{200D}[\u{1F308}]|' // Rainbow flag
      r'[\u{1F3F4}]\u{200D}[\u{2620}\u{FE0F}]|' // Pirate flag
      r'(?:[\u{1F1E6}-\u{1F1FF}]){2}|' // Country flags
      r'[\u{FE00}-\u{FE0F}]|' // Variation selectors
      r'[\u{E0020}-\u{E007F}]', // Tag characters
      unicode: true,
    );

    // Remove all valid emoji sequences
    var remaining = text;
    remaining = remaining.replaceAll(emojiRegex, '');

    // Also remove any remaining variation selectors and ZWJ that might be orphaned
    remaining = remaining.replaceAll(
        RegExp(r'[\u{FE00}-\u{FE0F}\u{200D}]', unicode: true), '');

    return remaining.isEmpty;
  }

  bool _isValidNanoid(String nanoid, int? expectedLength) {
    if (nanoid.isEmpty) return false;

    // NanoID uses URL-safe alphabet: A-Za-z0-9_-
    final nanoidRegex = RegExp(r'^[A-Za-z0-9_-]+$');
    if (!nanoidRegex.hasMatch(nanoid)) return false;

    // Check length if specified
    if (expectedLength != null && nanoid.length != expectedLength) {
      return false;
    }

    // Default NanoID length is 21
    return expectedLength == null ? nanoid.length == 21 : true;
  }

  bool _isValidJwt(String jwt) {
    // JWT format: header.payload.signature
    final parts = jwt.split('.');
    if (parts.length != 3) return false;

    // Each part should be base64url encoded
    for (final part in parts) {
      if (part.isEmpty) return false;
      // Base64url uses A-Za-z0-9_- instead of A-Za-z0-9+/
      final base64UrlRegex = RegExp(r'^[A-Za-z0-9_-]+$');
      if (!base64UrlRegex.hasMatch(part)) return false;
    }

    return true;
  }

  bool _isValidHex(String hex) {
    if (hex.isEmpty) return false;

    // Remove optional 0x prefix
    final cleanHex =
        hex.toLowerCase().startsWith('0x') ? hex.substring(2) : hex;

    final hexRegex = RegExp(r'^[0-9a-fA-F]+$');
    return hexRegex.hasMatch(cleanHex);
  }

  bool _isValidHexColor(String hexColor) {
    if (hexColor.isEmpty) return false;

    // Remove optional # prefix
    final cleanColor =
        hexColor.startsWith('#') ? hexColor.substring(1) : hexColor;

    // Valid hex color lengths: 3, 4, 6, 8 (RGB, ARGB, RRGGBB, AARRGGBB)
    if (![3, 4, 6, 8].contains(cleanColor.length)) return false;

    final hexRegex = RegExp(r'^[0-9a-fA-F]+$');
    return hexRegex.hasMatch(cleanColor);
  }

  bool _isValidJson(String json) {
    if (json.isEmpty) return false;

    try {
      // Try to parse as JSON
      final decoded = jsonDecode(json);
      // Ensure it's a valid JSON object or array
      return decoded is Map || decoded is List;
    } catch (e) {
      return false;
    }
  }

  /// Public getters for JSON schema generation
  int? get minLength => _minLength;
  int? get maxLength => _maxLength;
  int? get exactLength => _exactLength;
  String? get pattern => _pattern?.pattern;
  String? get format {
    if (_isEmail) return 'email';
    if (_isUrl) return 'uri';
    if (_isUuid) return 'uuid';
    return null;
  }

  @override
  String toString() {
    final constraints = <String>[];

    if (_minLength != null) constraints.add('min: $_minLength');
    if (_maxLength != null) constraints.add('max: $_maxLength');
    if (_exactLength != null) constraints.add('length: $_exactLength');
    if (_pattern != null) constraints.add('pattern: ${_pattern!.pattern}');
    if (_isEmail) constraints.add('email');
    if (_isUrl) constraints.add('url');
    if (_isUuid) constraints.add('uuid');
    if (_trim) constraints.add('trim');
    if (_toLowerCase) constraints.add('toLowerCase');
    if (_toUpperCase) constraints.add('toUpperCase');

    final constraintStr =
        constraints.isNotEmpty ? ' (${constraints.join(', ')})' : '';
    return 'StringSchema$constraintStr';
  }
}
