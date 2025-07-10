import 'package:flutter/material.dart';

import '../core/schema.dart';
import '../core/validation_result.dart';

/// Extensions for integrating Dzod schemas with Flutter forms
extension FormIntegration<T> on Schema<T> {
  /// Creates a validator function for use with TextFormField
  ///
  /// Returns a validator function that can be used directly with TextFormField.validator
  /// The validator will return null if validation passes, or an error message if validation fails.
  ///
  /// Example:
  /// ```dart
  /// final nameSchema = Z.string().min(2).max(50);
  ///
  /// TextFormField(
  ///   validator: nameSchema.validator(),
  ///   decoration: InputDecoration(labelText: 'Name'),
  /// )
  /// ```
  FormFieldValidator<String> validator({
    String? customErrorMessage,
    bool useFirstErrorOnly = true,
  }) {
    return (String? value) {
      if (value == null) {
        return customErrorMessage ?? 'This field is required';
      }

      final result = validate(value);
      if (result.isSuccess) {
        return null;
      }

      if (customErrorMessage != null) {
        return customErrorMessage;
      }

      final errors = result.errors;
      if (errors?.isEmpty != false) {
        return 'Validation failed';
      }

      if (useFirstErrorOnly) {
        return errors?.errors.first.message ?? 'Validation failed';
      }

      return errors?.errors.map((e) => e.message).join(', ') ??
          'Validation failed';
    };
  }

  /// Creates a validator function that works with any input type
  ///
  /// This is useful for custom form fields that don't use String values
  ///
  /// Example:
  /// ```dart
  /// final numberSchema = Z.number().min(0).max(100);
  ///
  /// CustomNumberField(
  ///   validator: numberSchema.typedValidator<int>(),
  ///   decoration: InputDecoration(labelText: 'Age'),
  /// )
  /// ```
  FormFieldValidator<U> typedValidator<U>({
    String? customErrorMessage,
    bool useFirstErrorOnly = true,
  }) {
    return (U? value) {
      if (value == null) {
        return customErrorMessage ?? 'This field is required';
      }

      final result = validate(value);
      if (result.isSuccess) {
        return null;
      }

      if (customErrorMessage != null) {
        return customErrorMessage;
      }

      final errors = result.errors;
      if (errors?.isEmpty != false) {
        return 'Validation failed';
      }

      if (useFirstErrorOnly) {
        return errors?.errors.first.message ?? 'Validation failed';
      }

      return errors?.errors.map((e) => e.message).join(', ') ??
          'Validation failed';
    };
  }

  /// Creates an async validator function for use with TextFormField
  ///
  /// Returns an async validator function that can be used with custom form fields
  /// that support async validation.
  ///
  /// Example:
  /// ```dart
  /// final emailSchema = Z.string().email().refineAsync((email) async {
  ///   return await checkEmailExists(email);
  /// });
  ///
  /// // Using with a custom form field that supports async validation
  /// AsyncTextFormField(
  ///   asyncValidator: emailSchema.asyncValidator(),
  ///   decoration: InputDecoration(labelText: 'Email'),
  /// )
  /// ```
  Future<String?> Function(String?) asyncValidator({
    String? customErrorMessage,
    bool useFirstErrorOnly = true,
  }) {
    return (String? value) async {
      if (value == null) {
        return customErrorMessage ?? 'This field is required';
      }

      final result = await validateAsync(value);
      if (result.isSuccess) {
        return null;
      }

      if (customErrorMessage != null) {
        return customErrorMessage;
      }

      final errors = result.errors;
      if (errors?.isEmpty != false) {
        return 'Validation failed';
      }

      if (useFirstErrorOnly) {
        return errors?.errors.first.message ?? 'Validation failed';
      }

      return errors?.errors.map((e) => e.message).join(', ') ??
          'Validation failed';
    };
  }

  /// Creates a typed async validator function
  ///
  /// This is useful for custom form fields that don't use String values
  /// and support async validation
  ///
  /// Example:
  /// ```dart
  /// final userIdSchema = Z.number().refineAsync((id) async {
  ///   return await validateUserId(id);
  /// });
  ///
  /// AsyncNumberField(
  ///   asyncValidator: userIdSchema.typedAsyncValidator<int>(),
  ///   decoration: InputDecoration(labelText: 'User ID'),
  /// )
  /// ```
  Future<String?> Function(U?) typedAsyncValidator<U>({
    String? customErrorMessage,
    bool useFirstErrorOnly = true,
  }) {
    return (U? value) async {
      if (value == null) {
        return customErrorMessage ?? 'This field is required';
      }

      final result = await validateAsync(value);
      if (result.isSuccess) {
        return null;
      }

      if (customErrorMessage != null) {
        return customErrorMessage;
      }

      final errors = result.errors;
      if (errors?.isEmpty != false) {
        return 'Validation failed';
      }

      if (useFirstErrorOnly) {
        return errors?.errors.first.message ?? 'Validation failed';
      }

      return errors?.errors.map((e) => e.message).join(', ') ??
          'Validation failed';
    };
  }
}

/// Helper class for form validation utilities
class ZodFormHelper {
  ZodFormHelper._();

  /// Validates multiple form fields at once
  ///
  /// Returns a map of field names to validation results
  ///
  /// Example:
  /// ```dart
  /// final results = await ZodFormHelper.validateMultiple({
  ///   'name': (Z.string().min(2), nameController.text),
  ///   'email': (Z.string().email(), emailController.text),
  ///   'age': (Z.number().min(18), int.tryParse(ageController.text)),
  /// });
  ///
  /// if (results.values.every((result) => result.isSuccess)) {
  ///   // All validations passed
  /// }
  /// ```
  static Future<Map<String, ValidationResult<dynamic>>> validateMultiple(
    Map<String, (Schema<dynamic>, dynamic)> fields,
  ) async {
    final results = <String, ValidationResult<dynamic>>{};

    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final (schema, value) = entry.value;

      final result = await schema.safeParseAsync(value);
      results[fieldName] = result;
    }

    return results;
  }

  /// Validates multiple form fields synchronously
  ///
  /// Returns a map of field names to validation results
  ///
  /// Example:
  /// ```dart
  /// final results = ZodFormHelper.validateMultipleSync({
  ///   'name': (Z.string().min(2), nameController.text),
  ///   'email': (Z.string().email(), emailController.text),
  ///   'age': (Z.number().min(18), int.tryParse(ageController.text)),
  /// });
  /// ```
  static Map<String, ValidationResult<dynamic>> validateMultipleSync(
    Map<String, (Schema<dynamic>, dynamic)> fields,
  ) {
    final results = <String, ValidationResult<dynamic>>{};

    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final (schema, value) = entry.value;

      final result = schema.safeParse(value);
      results[fieldName] = result;
    }

    return results;
  }

  /// Validates a form and returns the first error message found
  ///
  /// Returns null if all validations pass, or the first error message
  ///
  /// Example:
  /// ```dart
  /// final error = ZodFormHelper.validateFormSync({
  ///   'name': (Z.string().min(2), nameController.text),
  ///   'email': (Z.string().email(), emailController.text),
  /// });
  ///
  /// if (error != null) {
  ///   ScaffoldMessenger.of(context).showSnackBar(
  ///     SnackBar(content: Text(error)),
  ///   );
  /// }
  /// ```
  static String? validateFormSync(
    Map<String, (Schema<dynamic>, dynamic)> fields,
  ) {
    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final (schema, value) = entry.value;

      final result = schema.safeParse(value);
      if (!result.isSuccess && result.errors.isNotEmpty) {
        return '$fieldName: ${result.errors.first.message}';
      }
    }

    return null;
  }

  /// Validates a form asynchronously and returns the first error message found
  ///
  /// Returns null if all validations pass, or the first error message
  ///
  /// Example:
  /// ```dart
  /// final error = await ZodFormHelper.validateForm({
  ///   'email': (emailSchema, emailController.text),
  ///   'password': (passwordSchema, passwordController.text),
  /// });
  ///
  /// if (error != null) {
  ///   ScaffoldMessenger.of(context).showSnackBar(
  ///     SnackBar(content: Text(error)),
  ///   );
  /// }
  /// ```
  static Future<String?> validateForm(
    Map<String, (Schema<dynamic>, dynamic)> fields,
  ) async {
    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final (schema, value) = entry.value;

      final result = await schema.safeParseAsync(value);
      if (!result.isSuccess && result.errors.isNotEmpty) {
        return '$fieldName: ${result.errors.first.message}';
      }
    }

    return null;
  }
}

/// Extension for GlobalKey(FormState) to add Zod validation
extension ZodFormStateExtension on GlobalKey<FormState> {
  /// Validates the form using Zod schemas
  ///
  /// This works with forms that have fields using Zod validators
  ///
  /// Example:
  /// ```dart
  /// final formKey = GlobalKey<FormState>();
  ///
  /// if (formKey.validateWithZod()) {
  ///   // Form is valid
  /// }
  /// ```
  bool validateWithZod() {
    return currentState?.validate() ?? false;
  }

  /// Saves the form and validates it
  ///
  /// Example:
  /// ```dart
  /// final formKey = GlobalKey<FormState>();
  ///
  /// if (formKey.saveAndValidateWithZod()) {
  ///   // Form is saved and valid
  /// }
  /// ```
  bool saveAndValidateWithZod() {
    final state = currentState;
    if (state == null) return false;

    state.save();
    return state.validate();
  }
}
