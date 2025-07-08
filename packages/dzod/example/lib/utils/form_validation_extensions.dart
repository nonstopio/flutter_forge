import 'package:dzod/dzod.dart';
import 'package:flutter/material.dart';

/// Extension on Schema to provide Flutter Form validation
extension FormValidation<T> on Schema<T> {
  /// Creates a FormFieldValidator that uses this schema for validation
  ///
  /// Returns null if validation passes, or the first error message if validation fails.
  /// Perfect for use with TextFormField.validator and other form fields.
  ///
  /// Example:
  /// ```dart
  /// final emailSchema = Z.string().email().min(5);
  ///
  /// TextFormField(
  ///   validator: emailSchema.validator,
  ///   // ... other properties
  /// )
  /// ```
  FormFieldValidator<String> get validator {
    return (String? value) {
      final result = validate(value);
      if (result.isFailure) {
        // Return the first error message for the field
        final firstError = result.errors!.errors.first;
        return '${firstError.message} is expected';
      }
      return null; // Valid input
    };
  }

  /// Creates a FormFieldValidator with custom error message formatting
  ///
  /// Allows you to customize how error messages are displayed in the form field.
  ///
  /// Example:
  /// ```dart
  /// TextFormField(
  ///   validator: emailSchema.validatorWithFormatter(
  ///     (errors) => "Invalid: ${errors.first.message}",
  ///   ),
  /// )
  /// ```
  FormFieldValidator<String> validatorWithFormatter(
    String Function(List<ValidationError> errors) formatter,
  ) {
    return (String? value) {
      final result = validate(value);
      if (result.isFailure) {
        return formatter(result.errors!.errors);
      }
      return null;
    };
  }

  /// Creates a FormFieldValidator that shows multiple error messages
  ///
  /// Joins all validation errors with the specified separator.
  ///
  /// Example:
  /// ```dart
  /// TextFormField(
  ///   validator: emailSchema.validatorWithMultipleErrors(),
  /// )
  /// ```
  FormFieldValidator<String> validatorWithMultipleErrors({
    String separator = '\n• ',
  }) {
    return (String? value) {
      final result = validate(value);
      if (result.isFailure) {
        final errorMessages =
            result.errors!.errors.map((e) => e.message).join(separator);
        return errorMessages;
      }
      return null;
    };
  }
}

/// Extension on ValidationResult to generate formatted validation messages
extension ValidationResultDisplay<T> on ValidationResult<T> {
  /// Generates a clean, formatted validation result message
  ///
  /// For successful validation, shows basic info about the validated data.
  /// For failed validation, shows the input value and error messages.
  String toDisplayMessage(dynamic input) {
    if (isSuccess) {
      return '''✅ Validation Successful!

Input: "$input"
Type: ${data.runtimeType}''';
    } else {
      final errorMessages =
          errors!.errors.map((e) => '• ${e.message}').join('\n');
      return '''❌ Validation Failed!

Input: "$input"
Type: ${input.runtimeType}

Errors:
$errorMessages''';
    }
  }

  /// Generates a compact validation result message
  ///
  /// Shows minimal information for cleaner display.
  String toCompactMessage(dynamic input) {
    if (isSuccess) {
      return '✅ Valid: "$input"';
    } else {
      final firstError = errors!.errors.first.message;
      return '❌ Invalid: $firstError';
    }
  }

  /// Generates a detailed validation result message
  ///
  /// Shows comprehensive information including all available data.
  String toDetailedMessage(dynamic input) {
    if (isSuccess) {
      final buffer = StringBuffer();
      buffer.writeln('✅ Validation Successful!');
      buffer.writeln();
      buffer.writeln('Input: "$input"');
      buffer.writeln('Type: ${data.runtimeType}');

      // Add type-specific information
      if (data is String) {
        buffer.writeln('Length: ${(data as String).length} characters');
      } else if (data is num) {
        buffer.writeln('Value: $data');
      }

      return buffer.toString().trim();
    } else {
      final buffer = StringBuffer();
      buffer.writeln('❌ Validation Failed!');
      buffer.writeln();
      buffer.writeln('Input: "$input"');
      buffer.writeln('Type: ${input.runtimeType}');
      buffer.writeln();
      buffer.writeln('Errors:');

      for (final error in errors!.errors) {
        buffer.writeln('• ${error.message}');
      }

      return buffer.toString().trim();
    }
  }
}
