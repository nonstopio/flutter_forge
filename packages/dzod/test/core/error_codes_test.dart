import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('ValidationErrorCode', () {
    group('Basic properties', () {
      test('should have code and defaultMessage', () {
        const errorCode = ValidationErrorCode.typeMismatch;
        expect(errorCode.code, 'type_mismatch');
        expect(errorCode.defaultMessage, 'Value is not of the expected type');
      });

      test('should implement toString correctly', () {
        const errorCode = ValidationErrorCode.typeMismatch;
        expect(errorCode.toString(), 'type_mismatch');
      });
    });

    group('Error creation methods', () {
      test('createError should create ValidationError with custom message', () {
        const errorCode = ValidationErrorCode.typeMismatch;
        final error = errorCode.createError(
          path: ['test'],
          received: 'invalid',
          expected: 'valid',
          message: 'Custom message',
          context: {'extra': 'info'},
        );

        expect(error.message, 'Custom message');
        expect(error.path, ['test']);
        expect(error.received, 'invalid');
        expect(error.expected, 'valid');
        expect(error.code, 'type_mismatch');
        expect(error.context, {'extra': 'info'});
      });

      test('createError should use default message when none provided', () {
        const errorCode = ValidationErrorCode.typeMismatch;
        final error = errorCode.createError(
          path: ['test'],
          received: 'invalid',
        );

        expect(error.message, 'Value is not of the expected type');
        expect(error.expected, 'valid value');
      });

      test('createSimpleError should create simple ValidationError', () {
        const errorCode = ValidationErrorCode.validationFailed;
        final error = errorCode.createSimpleError(
          path: ['test'],
          received: 'invalid',
          message: 'Simple error',
          context: {'extra': 'info'},
        );

        expect(error.message, 'Simple error');
        expect(error.path, ['test']);
        expect(error.received, 'invalid');
        expect(error.code, 'validation_failed');
      });

      test('createSimpleError should use default message when none provided',
          () {
        const errorCode = ValidationErrorCode.validationFailed;
        final error = errorCode.createSimpleError(
          path: ['test'],
          received: 'invalid',
        );

        expect(error.message, 'Validation failed');
      });

      test('createTypeMismatchError should create type mismatch error', () {
        const errorCode = ValidationErrorCode.typeMismatch;
        final error = errorCode.createTypeMismatchError(
          path: ['test'],
          received: 'invalid',
          expected: 'string',
          message: 'Type error',
        );

        expect(error.message, 'Type error');
        expect(error.path, ['test']);
        expect(error.received, 'invalid');
        expect(error.expected, 'string');
        expect(error.code, 'type_mismatch');
      });

      test(
          'createTypeMismatchError should use ValidationError.typeMismatch when no message provided',
          () {
        const errorCode = ValidationErrorCode.typeMismatch;
        final error = errorCode.createTypeMismatchError(
          path: ['test'],
          received: 'invalid',
          expected: 'string',
        );

        expect(error.path, ['test']);
        expect(error.received, 'invalid');
        expect(error.expected, 'string');
        expect(error.code, 'type_mismatch');
      });

      test(
          'createConstraintViolationError should create constraint violation error',
          () {
        const errorCode = ValidationErrorCode.constraintViolation;
        final error = errorCode.createConstraintViolationError(
          path: ['test'],
          received: 'invalid',
          constraint: 'must be positive',
          message: 'Constraint error',
          context: {'min': 0},
        );

        expect(error.message, 'Constraint error');
        expect(error.path, ['test']);
        expect(error.received, 'invalid');
        expect(error.code, 'constraint_violation');
        expect(error.context, {'min': 0});
      });

      test(
          'createConstraintViolationError should use ValidationError.constraintViolation when no message provided',
          () {
        const errorCode = ValidationErrorCode.constraintViolation;
        final error = errorCode.createConstraintViolationError(
          path: ['test'],
          received: 'invalid',
          constraint: 'must be positive',
          context: {'min': 0},
        );

        expect(error.path, ['test']);
        expect(error.received, 'invalid');
        expect(error.code, 'constraint_violation');
        expect(error.context, {'min': 0});
      });
    });

    group('Static methods', () {
      test('fromCode should return error code by string', () {
        final errorCode = ValidationErrorCode.fromCode('type_mismatch');
        expect(errorCode, ValidationErrorCode.typeMismatch);
      });

      test('fromCode should return null for unknown code', () {
        final errorCode = ValidationErrorCode.fromCode('unknown_code');
        expect(errorCode, null);
      });

      test('getByCategory should return error codes by category', () {
        final stringErrors = ValidationErrorCode.getByCategory('string_');
        expect(stringErrors, contains(ValidationErrorCode.stringTooShort));
        expect(stringErrors, contains(ValidationErrorCode.stringTooLong));
        expect(stringErrors, contains(ValidationErrorCode.stringEmpty));
        expect(
            stringErrors, isNot(contains(ValidationErrorCode.numberTooSmall)));
      });

      test('getByCategory should return empty list for non-existent category',
          () {
        final errors = ValidationErrorCode.getByCategory('nonexistent_');
        expect(errors, isEmpty);
      });
    });

    group('Category getters', () {
      test('stringErrorCodes should return all string-related error codes', () {
        final stringErrors = ValidationErrorCode.stringErrorCodes;
        expect(stringErrors, contains(ValidationErrorCode.stringTooShort));
        expect(stringErrors, contains(ValidationErrorCode.stringTooLong));
        expect(stringErrors, contains(ValidationErrorCode.stringEmpty));
        expect(stringErrors, contains(ValidationErrorCode.stringEmail));
        expect(stringErrors, contains(ValidationErrorCode.stringUrl));
        expect(
            stringErrors, isNot(contains(ValidationErrorCode.numberTooSmall)));
      });

      test('numberErrorCodes should return all number-related error codes', () {
        final numberErrors = ValidationErrorCode.numberErrorCodes;
        expect(numberErrors, contains(ValidationErrorCode.numberTooSmall));
        expect(numberErrors, contains(ValidationErrorCode.numberTooLarge));
        expect(numberErrors, contains(ValidationErrorCode.numberNotInteger));
        expect(numberErrors, contains(ValidationErrorCode.numberNotPositive));
        expect(
            numberErrors, isNot(contains(ValidationErrorCode.stringTooShort)));
      });

      test('arrayErrorCodes should return all array-related error codes', () {
        final arrayErrors = ValidationErrorCode.arrayErrorCodes;
        expect(arrayErrors, contains(ValidationErrorCode.arrayTooSmall));
        expect(arrayErrors, contains(ValidationErrorCode.arrayTooLarge));
        expect(arrayErrors, contains(ValidationErrorCode.arrayEmpty));
        expect(arrayErrors, contains(ValidationErrorCode.arrayDuplicate));
        expect(
            arrayErrors, isNot(contains(ValidationErrorCode.stringTooShort)));
      });

      test('objectErrorCodes should return all object-related error codes', () {
        final objectErrors = ValidationErrorCode.objectErrorCodes;
        expect(
            objectErrors, contains(ValidationErrorCode.objectMissingProperty));
        expect(
            objectErrors, contains(ValidationErrorCode.objectInvalidProperty));
        expect(
            objectErrors, contains(ValidationErrorCode.objectUnknownProperty));
        expect(objectErrors, contains(ValidationErrorCode.objectEmpty));
        expect(
            objectErrors, isNot(contains(ValidationErrorCode.stringTooShort)));
      });

      test('asyncErrorCodes should return all async-related error codes', () {
        final asyncErrors = ValidationErrorCode.asyncErrorCodes;
        expect(asyncErrors, contains(ValidationErrorCode.asyncInSyncContext));
        expect(
            asyncErrors, contains(ValidationErrorCode.asyncValidationFailed));
        expect(asyncErrors, contains(ValidationErrorCode.asyncTimeout));
        expect(
            asyncErrors, isNot(contains(ValidationErrorCode.stringTooShort)));
      });
    });

    group('All error codes coverage', () {
      test('should have all expected type-related error codes', () {
        expect(ValidationErrorCode.typeMismatch.code, 'type_mismatch');
        expect(ValidationErrorCode.invalidType.code, 'invalid_type');
        expect(ValidationErrorCode.nullValue.code, 'null_value');
      });

      test('should have all expected string-related error codes', () {
        expect(ValidationErrorCode.stringTooShort.code, 'string_too_short');
        expect(ValidationErrorCode.stringTooLong.code, 'string_too_long');
        expect(ValidationErrorCode.stringInvalidFormat.code,
            'string_invalid_format');
        expect(ValidationErrorCode.stringEmpty.code, 'string_empty');
        expect(ValidationErrorCode.stringPattern.code, 'string_pattern');
        expect(ValidationErrorCode.stringEmail.code, 'string_email');
        expect(ValidationErrorCode.stringUrl.code, 'string_url');
        expect(ValidationErrorCode.stringUuid.code, 'string_uuid');
        expect(ValidationErrorCode.stringCuid.code, 'string_cuid');
        expect(ValidationErrorCode.stringCuid2.code, 'string_cuid2');
        expect(ValidationErrorCode.stringUlid.code, 'string_ulid');
        expect(ValidationErrorCode.stringBase64.code, 'string_base64');
        expect(ValidationErrorCode.stringEmoji.code, 'string_emoji');
        expect(ValidationErrorCode.stringNanoid.code, 'string_nanoid');
        expect(ValidationErrorCode.stringDatetime.code, 'string_datetime');
        expect(ValidationErrorCode.stringIp.code, 'string_ip');
        expect(ValidationErrorCode.stringIpv4.code, 'string_ipv4');
        expect(ValidationErrorCode.stringIpv6.code, 'string_ipv6');
      });

      test('should have all expected number-related error codes', () {
        expect(ValidationErrorCode.numberTooSmall.code, 'number_too_small');
        expect(ValidationErrorCode.numberTooLarge.code, 'number_too_large');
        expect(ValidationErrorCode.numberNotInteger.code, 'number_not_integer');
        expect(ValidationErrorCode.numberNotFinite.code, 'number_not_finite');
        expect(
            ValidationErrorCode.numberNotPositive.code, 'number_not_positive');
        expect(
            ValidationErrorCode.numberNotNegative.code, 'number_not_negative');
        expect(ValidationErrorCode.numberNotNonPositive.code,
            'number_not_non_positive');
        expect(ValidationErrorCode.numberNotNonNegative.code,
            'number_not_non_negative');
        expect(
            ValidationErrorCode.numberNotMultiple.code, 'number_not_multiple');
        expect(ValidationErrorCode.numberNotStep.code, 'number_not_step');
        expect(ValidationErrorCode.numberInvalidPrecision.code,
            'number_invalid_precision');
      });

      test('should have all expected boolean-related error codes', () {
        expect(ValidationErrorCode.booleanInvalid.code, 'boolean_invalid');
      });

      test('should have all expected array-related error codes', () {
        expect(ValidationErrorCode.arrayTooSmall.code, 'array_too_small');
        expect(ValidationErrorCode.arrayTooLarge.code, 'array_too_large');
        expect(ValidationErrorCode.arrayInvalidLength.code,
            'array_invalid_length');
        expect(ValidationErrorCode.arrayEmpty.code, 'array_empty');
        expect(ValidationErrorCode.arrayInvalidElement.code,
            'array_invalid_element');
        expect(ValidationErrorCode.arrayDuplicate.code, 'array_duplicate');
        expect(ValidationErrorCode.arrayMissing.code, 'array_missing');
        expect(ValidationErrorCode.arrayInvalidType.code, 'array_invalid_type');
      });

      test('should have all expected tuple-related error codes', () {
        expect(ValidationErrorCode.tupleInvalidLength.code,
            'tuple_invalid_length');
        expect(ValidationErrorCode.tupleInvalidElement.code,
            'tuple_invalid_element');
      });

      test('should have all expected object-related error codes', () {
        expect(ValidationErrorCode.objectMissingProperty.code,
            'object_missing_property');
        expect(ValidationErrorCode.objectInvalidProperty.code,
            'object_invalid_property');
        expect(ValidationErrorCode.objectUnknownProperty.code,
            'object_unknown_property');
        expect(ValidationErrorCode.objectTooFewProperties.code,
            'object_too_few_properties');
        expect(ValidationErrorCode.objectTooManyProperties.code,
            'object_too_many_properties');
        expect(ValidationErrorCode.objectEmpty.code, 'object_empty');
        expect(ValidationErrorCode.objectInvalidKey.code, 'object_invalid_key');
        expect(ValidationErrorCode.objectInvalidValue.code,
            'object_invalid_value');
      });

      test('should have all expected record-related error codes', () {
        expect(ValidationErrorCode.recordInvalidKey.code, 'record_invalid_key');
        expect(ValidationErrorCode.recordInvalidValue.code,
            'record_invalid_value');
        expect(ValidationErrorCode.recordMissingKey.code, 'record_missing_key');
        expect(ValidationErrorCode.recordUnknownKey.code, 'record_unknown_key');
      });

      test('should have all expected enum-related error codes', () {
        expect(ValidationErrorCode.enumInvalidValue.code, 'enum_invalid_value');
        expect(ValidationErrorCode.enumInvalidType.code, 'enum_invalid_type');
      });

      test('should have all expected union-related error codes', () {
        expect(ValidationErrorCode.unionInvalid.code, 'union_invalid');
        expect(ValidationErrorCode.unionAmbiguous.code, 'union_ambiguous');
      });

      test('should have all expected discriminated union-related error codes',
          () {
        expect(ValidationErrorCode.discriminatedUnionInvalidDiscriminator.code,
            'discriminated_union_invalid_discriminator');
        expect(ValidationErrorCode.discriminatedUnionMissingDiscriminator.code,
            'discriminated_union_missing_discriminator');
      });

      test('should have all expected literal-related error codes', () {
        expect(ValidationErrorCode.literalMismatch.code, 'literal_mismatch');
      });

      test('should have all expected intersection-related error codes', () {
        expect(ValidationErrorCode.intersectionInvalid.code,
            'intersection_invalid');
        expect(ValidationErrorCode.intersectionConflict.code,
            'intersection_conflict');
      });

      test('should have all expected refinement-related error codes', () {
        expect(ValidationErrorCode.refinementFailed.code, 'refinement_failed');
        expect(ValidationErrorCode.asyncRefinementFailed.code,
            'async_refinement_failed');
      });

      test('should have all expected transformation-related error codes', () {
        expect(ValidationErrorCode.transformationFailed.code,
            'transformation_failed');
        expect(ValidationErrorCode.asyncTransformationFailed.code,
            'async_transformation_failed');
        expect(ValidationErrorCode.preprocessingFailed.code,
            'preprocessing_failed');
        expect(ValidationErrorCode.postprocessingFailed.code,
            'postprocessing_failed');
      });

      test('should have all expected coercion-related error codes', () {
        expect(ValidationErrorCode.coercionFailed.code, 'coercion_failed');
        expect(ValidationErrorCode.coercionInvalidType.code,
            'coercion_invalid_type');
      });

      test('should have all expected date-related error codes', () {
        expect(ValidationErrorCode.dateInvalid.code, 'date_invalid');
        expect(ValidationErrorCode.dateTimeInvalid.code, 'datetime_invalid');
        expect(ValidationErrorCode.dateInPast.code, 'date_in_past');
        expect(ValidationErrorCode.dateInFuture.code, 'date_in_future');
        expect(ValidationErrorCode.dateBeforeMin.code, 'date_before_min');
        expect(ValidationErrorCode.dateAfterMax.code, 'date_after_max');
      });

      test('should have all expected file-related error codes', () {
        expect(ValidationErrorCode.fileInvalidType.code, 'file_invalid_type');
        expect(ValidationErrorCode.fileTooLarge.code, 'file_too_large');
        expect(ValidationErrorCode.fileTooSmall.code, 'file_too_small');
        expect(
            ValidationErrorCode.fileInvalidFormat.code, 'file_invalid_format');
      });

      test('should have all expected network-related error codes', () {
        expect(
            ValidationErrorCode.networkInvalidUrl.code, 'network_invalid_url');
        expect(ValidationErrorCode.networkInvalidDomain.code,
            'network_invalid_domain');
        expect(ValidationErrorCode.networkInvalidPort.code,
            'network_invalid_port');
      });

      test('should have all expected async-related error codes', () {
        expect(ValidationErrorCode.asyncInSyncContext.code,
            'async_in_sync_context');
        expect(ValidationErrorCode.asyncValidationFailed.code,
            'async_validation_failed');
        expect(ValidationErrorCode.asyncTimeout.code, 'async_timeout');
      });

      test('should have all expected general error codes', () {
        expect(ValidationErrorCode.constraintViolation.code,
            'constraint_violation');
        expect(ValidationErrorCode.validationFailed.code, 'validation_failed');
        expect(ValidationErrorCode.unknownError.code, 'unknown_error');
      });

      test('should have all expected schema-related error codes', () {
        expect(ValidationErrorCode.schemaInvalid.code, 'schema_invalid');
        expect(ValidationErrorCode.schemaCircular.code, 'schema_circular');
        expect(ValidationErrorCode.schemaMismatch.code, 'schema_mismatch');
      });

      test('should have all expected context-related error codes', () {
        expect(ValidationErrorCode.contextMissing.code, 'context_missing');
        expect(ValidationErrorCode.contextInvalid.code, 'context_invalid');
      });

      test('should have custom error code', () {
        expect(ValidationErrorCode.custom.code, 'custom');
      });
    });
  });

  group('ValidationErrorCodeUtils', () {
    group('isTypeError', () {
      test('should return true for type-related errors', () {
        expect(ValidationErrorCodeUtils.isTypeError('type_mismatch'), true);
        expect(
            ValidationErrorCodeUtils.isTypeError('array_invalid_type'), true);
        expect(ValidationErrorCodeUtils.isTypeError('null_value'), true);
      });

      test('should return false for non-type errors', () {
        expect(ValidationErrorCodeUtils.isTypeError('string_too_short'), false);
        expect(ValidationErrorCodeUtils.isTypeError('number_too_small'), false);
        expect(ValidationErrorCodeUtils.isTypeError('constraint_violation'),
            false);
      });
    });

    group('isConstraintError', () {
      test('should return true for constraint-related errors', () {
        expect(ValidationErrorCodeUtils.isConstraintError('string_too_short'),
            true);
        expect(ValidationErrorCodeUtils.isConstraintError('number_too_large'),
            true);
        expect(
            ValidationErrorCodeUtils.isConstraintError(
                'object_missing_property'),
            true);
        expect(ValidationErrorCodeUtils.isConstraintError('array_empty'), true);
        expect(
            ValidationErrorCodeUtils.isConstraintError('constraint_violation'),
            true);
      });

      test('should return false for non-constraint errors', () {
        expect(
            ValidationErrorCodeUtils.isConstraintError('type_mismatch'), false);
        expect(
            ValidationErrorCodeUtils.isConstraintError('async_timeout'), false);
      });
    });

    group('isAsyncError', () {
      test('should return true for async-related errors', () {
        expect(ValidationErrorCodeUtils.isAsyncError('async_timeout'), true);
        expect(ValidationErrorCodeUtils.isAsyncError('async_validation_failed'),
            true);
        expect(ValidationErrorCodeUtils.isAsyncError('async_refinement_failed'),
            true);
      });

      test('should return false for non-async errors', () {
        expect(ValidationErrorCodeUtils.isAsyncError('type_mismatch'), false);
        expect(
            ValidationErrorCodeUtils.isAsyncError('string_too_short'), false);
      });
    });

    group('isTransformationError', () {
      test('should return true for transformation-related errors', () {
        expect(
            ValidationErrorCodeUtils.isTransformationError(
                'transformation_failed'),
            true);
        expect(
            ValidationErrorCodeUtils.isTransformationError(
                'preprocessing_failed'),
            true);
        expect(
            ValidationErrorCodeUtils.isTransformationError(
                'postprocessing_failed'),
            true);
        expect(
            ValidationErrorCodeUtils.isTransformationError('coercion_failed'),
            true);
      });

      test('should return false for non-transformation errors', () {
        expect(ValidationErrorCodeUtils.isTransformationError('type_mismatch'),
            false);
        expect(
            ValidationErrorCodeUtils.isTransformationError('string_too_short'),
            false);
      });
    });

    group('groupByCategory', () {
      test('should group error codes by category', () {
        final groups = ValidationErrorCodeUtils.groupByCategory();

        expect(groups['string'], contains(ValidationErrorCode.stringTooShort));
        expect(groups['string'], contains(ValidationErrorCode.stringTooLong));
        expect(groups['string'],
            isNot(contains(ValidationErrorCode.numberTooSmall)));

        expect(groups['number'], contains(ValidationErrorCode.numberTooSmall));
        expect(groups['number'], contains(ValidationErrorCode.numberTooLarge));
        expect(groups['number'],
            isNot(contains(ValidationErrorCode.stringTooShort)));

        expect(groups['array'], contains(ValidationErrorCode.arrayTooSmall));
        expect(groups['array'], contains(ValidationErrorCode.arrayTooLarge));

        expect(groups['object'],
            contains(ValidationErrorCode.objectMissingProperty));
        expect(groups['object'],
            contains(ValidationErrorCode.objectInvalidProperty));
      });

      test('should have all categories represented', () {
        final groups = ValidationErrorCodeUtils.groupByCategory();

        expect(groups.keys, contains('string'));
        expect(groups.keys, contains('number'));
        expect(groups.keys, contains('array'));
        expect(groups.keys, contains('object'));
        expect(groups.keys, contains('boolean'));
        expect(groups.keys, contains('tuple'));
        expect(groups.keys, contains('record'));
        expect(groups.keys, contains('enum'));
        expect(groups.keys, contains('union'));
        expect(groups.keys, contains('discriminated'));
        expect(groups.keys, contains('literal'));
        expect(groups.keys, contains('intersection'));
        expect(groups.keys, contains('refinement'));
        expect(groups.keys, contains('transformation'));
        expect(groups.keys, contains('preprocessing'));
        expect(groups.keys, contains('postprocessing'));
        expect(groups.keys, contains('coercion'));
        expect(groups.keys, contains('date'));
        expect(groups.keys, contains('datetime'));
        expect(groups.keys, contains('file'));
        expect(groups.keys, contains('network'));
        expect(groups.keys, contains('async'));
        expect(groups.keys, contains('constraint'));
        expect(groups.keys, contains('validation'));
        expect(groups.keys, contains('unknown'));
        expect(groups.keys, contains('schema'));
        expect(groups.keys, contains('context'));
        expect(groups.keys, contains('type'));
        expect(groups.keys, contains('invalid'));
        expect(groups.keys, contains('null'));
        expect(groups.keys, contains('custom'));
      });
    });

    group('getCategoryName', () {
      test('should return correct category names', () {
        expect(ValidationErrorCodeUtils.getCategoryName('string_too_short'),
            'String Validation');
        expect(ValidationErrorCodeUtils.getCategoryName('number_too_small'),
            'Number Validation');
        expect(ValidationErrorCodeUtils.getCategoryName('array_too_large'),
            'Array Validation');
        expect(
            ValidationErrorCodeUtils.getCategoryName('object_missing_property'),
            'Object Validation');
        expect(ValidationErrorCodeUtils.getCategoryName('boolean_invalid'),
            'Boolean Validation');
        expect(ValidationErrorCodeUtils.getCategoryName('date_invalid'),
            'Date Validation');
        expect(ValidationErrorCodeUtils.getCategoryName('file_too_large'),
            'File Validation');
        expect(ValidationErrorCodeUtils.getCategoryName('network_invalid_url'),
            'Network Validation');
        expect(ValidationErrorCodeUtils.getCategoryName('async_timeout'),
            'Async Validation');
        expect(ValidationErrorCodeUtils.getCategoryName('union_invalid'),
            'Union Validation');
        expect(ValidationErrorCodeUtils.getCategoryName('intersection_invalid'),
            'Intersection Validation');
        expect(ValidationErrorCodeUtils.getCategoryName('enum_invalid_value'),
            'Enum Validation');
        expect(ValidationErrorCodeUtils.getCategoryName('record_invalid_key'),
            'Record Validation');
        expect(ValidationErrorCodeUtils.getCategoryName('tuple_invalid_length'),
            'Tuple Validation');
        expect(ValidationErrorCodeUtils.getCategoryName('refinement_failed'),
            'Custom Validation');
        expect(
            ValidationErrorCodeUtils.getCategoryName('transformation_failed'),
            'Transformation');
        expect(ValidationErrorCodeUtils.getCategoryName('coercion_failed'),
            'Type Coercion');
        expect(ValidationErrorCodeUtils.getCategoryName('schema_invalid'),
            'Schema Validation');
        expect(ValidationErrorCodeUtils.getCategoryName('context_missing'),
            'Context Validation');
        expect(ValidationErrorCodeUtils.getCategoryName('type_mismatch'),
            'Type Validation');
        expect(ValidationErrorCodeUtils.getCategoryName('unknown_error'),
            'General Validation');
      });

      test('should return general validation for unknown categories', () {
        expect(
            ValidationErrorCodeUtils.getCategoryName('unknown_category_error'),
            'General Validation');
        expect(ValidationErrorCodeUtils.getCategoryName('made_up_error'),
            'General Validation');
      });
    });
  });
}
