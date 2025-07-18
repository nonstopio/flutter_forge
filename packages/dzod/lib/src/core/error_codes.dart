import 'error.dart';

/// Standardized error codes for validation failures
///
/// This enum provides consistent error codes across all validation scenarios,
/// making it easier to handle specific error types programmatically.
enum ValidationErrorCode {
  // Type-related errors
  typeMismatch('type_mismatch', 'Value is not of the expected type'),
  invalidType('invalid_type', 'Invalid type provided'),
  nullValue('null_value', 'Value cannot be null'),

  // String validation errors
  stringTooShort('string_too_short', 'String is too short'),
  stringTooLong('string_too_long', 'String is too long'),
  stringInvalidFormat('string_invalid_format', 'String format is invalid'),
  stringEmpty('string_empty', 'String cannot be empty'),
  stringPattern('string_pattern', 'String does not match required pattern'),
  stringEmail('string_email', 'Invalid email format'),
  stringUrl('string_url', 'Invalid URL format'),
  stringUuid('string_uuid', 'Invalid UUID format'),
  stringCuid('string_cuid', 'Invalid CUID format'),
  stringCuid2('string_cuid2', 'Invalid CUID2 format'),
  stringUlid('string_ulid', 'Invalid ULID format'),
  stringBase64('string_base64', 'Invalid base64 format'),
  stringEmoji('string_emoji', 'Invalid emoji format'),
  stringNanoid('string_nanoid', 'Invalid nanoid format'),
  stringDatetime('string_datetime', 'Invalid datetime format'),
  stringIp('string_ip', 'Invalid IP address format'),
  stringIpv4('string_ipv4', 'Invalid IPv4 address format'),
  stringIpv6('string_ipv6', 'Invalid IPv6 address format'),

  // Number validation errors
  numberTooSmall('number_too_small', 'Number is too small'),
  numberTooLarge('number_too_large', 'Number is too large'),
  numberNotInteger('number_not_integer', 'Number must be an integer'),
  numberNotFinite('number_not_finite', 'Number must be finite'),
  numberNotPositive('number_not_positive', 'Number must be positive'),
  numberNotNegative('number_not_negative', 'Number must be negative'),
  numberNotNonPositive(
      'number_not_non_positive', 'Number must be non-positive'),
  numberNotNonNegative(
      'number_not_non_negative', 'Number must be non-negative'),
  numberNotMultiple(
      'number_not_multiple', 'Number is not a multiple of the required value'),
  numberNotStep('number_not_step', 'Number does not match the required step'),
  numberInvalidPrecision(
      'number_invalid_precision', 'Number has invalid precision'),

  // Boolean validation errors
  booleanInvalid('boolean_invalid', 'Invalid boolean value'),

  // Array validation errors
  arrayTooSmall('array_too_small', 'Array is too small'),
  arrayTooLarge('array_too_large', 'Array is too large'),
  arrayInvalidLength('array_invalid_length', 'Array has invalid length'),
  arrayEmpty('array_empty', 'Array cannot be empty'),
  arrayInvalidElement(
      'array_invalid_element', 'Array contains invalid element'),
  arrayDuplicate('array_duplicate', 'Array contains duplicate elements'),
  arrayMissing('array_missing', 'Array is missing required elements'),
  arrayInvalidType('array_invalid_type', 'Array element has invalid type'),

  // Tuple validation errors
  tupleInvalidLength('tuple_invalid_length', 'Tuple has invalid length'),
  tupleInvalidElement(
      'tuple_invalid_element', 'Tuple contains invalid element'),

  // Object validation errors
  objectMissingProperty(
      'object_missing_property', 'Object is missing required property'),
  objectInvalidProperty(
      'object_invalid_property', 'Object contains invalid property'),
  objectUnknownProperty(
      'object_unknown_property', 'Object contains unknown property'),
  objectTooFewProperties(
      'object_too_few_properties', 'Object has too few properties'),
  objectTooManyProperties(
      'object_too_many_properties', 'Object has too many properties'),
  objectEmpty('object_empty', 'Object cannot be empty'),
  objectInvalidKey('object_invalid_key', 'Object contains invalid key'),
  objectInvalidValue('object_invalid_value', 'Object contains invalid value'),

  // Record validation errors
  recordInvalidKey('record_invalid_key', 'Record contains invalid key'),
  recordInvalidValue('record_invalid_value', 'Record contains invalid value'),
  recordMissingKey('record_missing_key', 'Record is missing required key'),
  recordUnknownKey('record_unknown_key', 'Record contains unknown key'),

  // Enum validation errors
  enumInvalidValue('enum_invalid_value', 'Invalid enum value'),
  enumInvalidType('enum_invalid_type', 'Enum value has invalid type'),

  // Union validation errors
  unionInvalid('union_invalid', 'Value does not match any union member'),
  unionAmbiguous('union_ambiguous', 'Value matches multiple union members'),

  // Discriminated union validation errors
  discriminatedUnionInvalidDiscriminator(
      'discriminated_union_invalid_discriminator',
      'Invalid discriminator value'),
  discriminatedUnionMissingDiscriminator(
      'discriminated_union_missing_discriminator',
      'Missing discriminator field'),

  // Literal validation errors
  literalMismatch('literal_mismatch', 'Value does not match literal value'),

  // Intersection validation errors
  intersectionInvalid(
      'intersection_invalid', 'Value does not satisfy intersection'),
  intersectionConflict('intersection_conflict',
      'Value conflicts with intersection requirements'),

  // Refinement validation errors
  refinementFailed('refinement_failed', 'Custom validation failed'),
  asyncRefinementFailed(
      'async_refinement_failed', 'Async custom validation failed'),

  // Transformation errors
  transformationFailed('transformation_failed', 'Value transformation failed'),
  asyncTransformationFailed(
      'async_transformation_failed', 'Async value transformation failed'),

  // Preprocessing errors
  preprocessingFailed('preprocessing_failed', 'Value preprocessing failed'),
  postprocessingFailed('postprocessing_failed', 'Value postprocessing failed'),

  // Coercion errors
  coercionFailed('coercion_failed', 'Value coercion failed'),
  coercionInvalidType('coercion_invalid_type', 'Cannot coerce from this type'),

  // Date/Time validation errors
  dateInvalid('date_invalid', 'Invalid date'),
  dateTimeInvalid('datetime_invalid', 'Invalid datetime'),
  dateInPast('date_in_past', 'Date must be in the past'),
  dateInFuture('date_in_future', 'Date must be in the future'),
  dateBeforeMin('date_before_min', 'Date is before minimum allowed'),
  dateAfterMax('date_after_max', 'Date is after maximum allowed'),

  // File validation errors
  fileInvalidType('file_invalid_type', 'Invalid file type'),
  fileTooLarge('file_too_large', 'File is too large'),
  fileTooSmall('file_too_small', 'File is too small'),
  fileInvalidFormat('file_invalid_format', 'Invalid file format'),

  // Network validation errors
  networkInvalidUrl('network_invalid_url', 'Invalid URL'),
  networkInvalidDomain('network_invalid_domain', 'Invalid domain'),
  networkInvalidPort('network_invalid_port', 'Invalid port'),

  // Async validation errors
  asyncInSyncContext('async_in_sync_context',
      'Async validation not supported in sync context'),
  asyncValidationFailed('async_validation_failed', 'Async validation failed'),
  asyncTimeout('async_timeout', 'Async validation timed out'),

  // General validation errors
  constraintViolation('constraint_violation', 'Value violates constraint'),
  validationFailed('validation_failed', 'Validation failed'),
  unknownError('unknown_error', 'Unknown validation error'),

  // Schema composition errors
  schemaInvalid('schema_invalid', 'Invalid schema'),
  schemaCircular('schema_circular', 'Circular schema reference'),
  schemaMismatch('schema_mismatch', 'Schema mismatch'),

  // Context-specific errors
  contextMissing('context_missing', 'Required context is missing'),
  contextInvalid('context_invalid', 'Invalid context provided'),

  // Custom error code for user-defined validations
  custom('custom', 'Custom validation error');

  const ValidationErrorCode(this.code, this.defaultMessage);

  /// The string code identifier
  final String code;

  /// The default error message for this error code
  final String defaultMessage;

  /// Creates a ValidationError with this error code
  ValidationError createError({
    required List<String> path,
    required dynamic received,
    String? expected,
    String? message,
    Map<String, dynamic>? context,
  }) {
    return ValidationError(
      message: message ?? defaultMessage,
      path: path,
      received: received,
      expected: expected ?? 'valid value',
      code: code,
      context: context,
    );
  }

  /// Creates a simple ValidationError with this error code
  ValidationError createSimpleError({
    required List<String> path,
    required dynamic received,
    String? message,
    Map<String, dynamic>? context,
  }) {
    return ValidationError.simple(
      message: message ?? defaultMessage,
      path: path,
      received: received,
      code: code,
    );
  }

  /// Creates a type mismatch error with this error code
  ValidationError createTypeMismatchError({
    required List<String> path,
    required dynamic received,
    required String expected,
    String? message,
  }) {
    if (message != null) {
      return ValidationError(
        message: message,
        path: path,
        received: received,
        expected: expected,
        code: code,
      );
    }
    return ValidationError.typeMismatch(
      path: path,
      received: received,
      expected: expected,
      code: code,
    );
  }

  /// Creates a constraint violation error with this error code
  ValidationError createConstraintViolationError({
    required List<String> path,
    required dynamic received,
    required String constraint,
    String? message,
    Map<String, dynamic>? context,
  }) {
    if (message != null) {
      return ValidationError(
        message: message,
        path: path,
        received: received,
        expected: constraint,
        code: code,
        context: context,
      );
    }
    return ValidationError.constraintViolation(
      path: path,
      received: received,
      constraint: constraint,
      code: code,
      context: context,
    );
  }

  /// Gets an error code by its string identifier
  static ValidationErrorCode? fromCode(String code) {
    for (final errorCode in ValidationErrorCode.values) {
      if (errorCode.code == code) {
        return errorCode;
      }
    }
    return null;
  }

  /// Gets all error codes for a specific category
  static List<ValidationErrorCode> getByCategory(String category) {
    return ValidationErrorCode.values
        .where((code) => code.code.startsWith(category))
        .toList();
  }

  /// Gets all string-related error codes
  static List<ValidationErrorCode> get stringErrorCodes =>
      getByCategory('string_');

  /// Gets all number-related error codes
  static List<ValidationErrorCode> get numberErrorCodes =>
      getByCategory('number_');

  /// Gets all array-related error codes
  static List<ValidationErrorCode> get arrayErrorCodes =>
      getByCategory('array_');

  /// Gets all object-related error codes
  static List<ValidationErrorCode> get objectErrorCodes =>
      getByCategory('object_');

  /// Gets all async-related error codes
  static List<ValidationErrorCode> get asyncErrorCodes =>
      getByCategory('async_');

  @override
  String toString() => code;
}

/// Utility class for working with validation error codes
class ValidationErrorCodeUtils {
  const ValidationErrorCodeUtils._();

  /// Checks if an error code is related to type validation
  static bool isTypeError(String code) {
    return code.startsWith('type_') ||
        code.contains('_invalid_type') ||
        code == 'null_value';
  }

  /// Checks if an error code is related to constraint validation
  static bool isConstraintError(String code) {
    return code.contains('_too_') ||
        code.contains('_invalid_') ||
        code.contains('_missing_') ||
        code.contains('_empty') ||
        code.contains('_length') ||
        code.contains('_value') ||
        code.contains('_size') ||
        code == 'constraint_violation';
  }

  /// Checks if an error code is related to async validation
  static bool isAsyncError(String code) {
    return code.startsWith('async_') || code.contains('_async_');
  }

  /// Checks if an error code is related to transformation
  static bool isTransformationError(String code) {
    return code.contains('transformation_') ||
        code.contains('preprocessing_') ||
        code.contains('postprocessing_') ||
        code.contains('coercion_');
  }

  /// Groups error codes by their category
  static Map<String, List<ValidationErrorCode>> groupByCategory() {
    final groups = <String, List<ValidationErrorCode>>{};

    for (final errorCode in ValidationErrorCode.values) {
      final category = errorCode.code.split('_').first;
      groups.putIfAbsent(category, () => []).add(errorCode);
    }

    return groups;
  }

  /// Gets a user-friendly category name for an error code
  static String getCategoryName(String code) {
    final category = code.split('_').first;
    switch (category) {
      case 'string':
        return 'String Validation';
      case 'number':
        return 'Number Validation';
      case 'array':
        return 'Array Validation';
      case 'object':
        return 'Object Validation';
      case 'boolean':
        return 'Boolean Validation';
      case 'date':
        return 'Date Validation';
      case 'file':
        return 'File Validation';
      case 'network':
        return 'Network Validation';
      case 'async':
        return 'Async Validation';
      case 'union':
        return 'Union Validation';
      case 'intersection':
        return 'Intersection Validation';
      case 'enum':
        return 'Enum Validation';
      case 'record':
        return 'Record Validation';
      case 'tuple':
        return 'Tuple Validation';
      case 'refinement':
        return 'Custom Validation';
      case 'transformation':
        return 'Transformation';
      case 'coercion':
        return 'Type Coercion';
      case 'schema':
        return 'Schema Validation';
      case 'context':
        return 'Context Validation';
      case 'type':
        return 'Type Validation';
      default:
        return 'General Validation';
    }
  }
}
