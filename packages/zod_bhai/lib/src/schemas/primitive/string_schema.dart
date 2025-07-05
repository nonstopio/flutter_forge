import '../../core/schema.dart';
import '../../core/validation_result.dart';
import '../../core/error.dart';

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
  ValidationResult<String> validate(dynamic input, [List<String> path = const []]) {
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
  StringSchema nonempty() {
    return refine(
      (value) => value.isNotEmpty,
      message: 'must not be empty',
      code: 'nonempty',
    ) as StringSchema;
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
  StringSchema ip() {
    return refine(
      (value) => _isValidIp(value),
      message: 'must be a valid IP address',
      code: 'invalid_ip',
    ) as StringSchema;
  }

  /// Checks if string is a valid IPv4 address
  StringSchema ipv4() {
    return refine(
      (value) => _isValidIpv4(value),
      message: 'must be a valid IPv4 address',
      code: 'invalid_ipv4',
    ) as StringSchema;
  }

  /// Checks if string is a valid IPv6 address
  StringSchema ipv6() {
    return refine(
      (value) => _isValidIpv6(value),
      message: 'must be a valid IPv6 address',
      code: 'invalid_ipv6',
    ) as StringSchema;
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
    
    final constraintStr = constraints.isNotEmpty ? ' (${constraints.join(', ')})' : '';
    return 'StringSchema$constraintStr';
  }
} 