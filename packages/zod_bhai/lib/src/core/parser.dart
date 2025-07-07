import 'error.dart';
import 'schema.dart';
import 'validation_result.dart';

/// Utility class for parsing and validation operations
class Parser {
  const Parser._();

  /// Parses a value using a schema, throwing an exception if validation fails
  static T parse<T>(Schema<T> schema, dynamic input,
      [List<String> path = const []]) {
    return schema.parse(input, path);
  }

  /// Safely parses a value using a schema, returning null if validation fails
  static T? safeParse<T>(Schema<T> schema, dynamic input,
      [List<String> path = const []]) {
    return schema.safeParse(input, path);
  }

  /// Validates a value using a schema, returning a ValidationResult
  static ValidationResult<T> validate<T>(Schema<T> schema, dynamic input,
      [List<String> path = const []]) {
    return schema.validate(input, path);
  }

  /// Checks if a value is valid according to a schema
  static bool isValid<T>(Schema<T> schema, dynamic input,
      [List<String> path = const []]) {
    return schema.isValid(input, path);
  }

  /// Parses multiple values using a schema
  static List<T> parseMany<T>(Schema<T> schema, List<dynamic> inputs,
      [List<String> path = const []]) {
    final results = <T>[];
    final errors = <ValidationError>[];

    for (int i = 0; i < inputs.length; i++) {
      final result = schema.validate(inputs[i], [...path, i.toString()]);
      if (result.isSuccess) {
        results.add(result.data as T);
      } else {
        errors.addAll(result.errors!.errors);
      }
    }

    if (errors.isNotEmpty) {
      throw ValidationException(
        ValidationErrorCollection(errors).formattedErrors,
      );
    }

    return results;
  }

  /// Safely parses multiple values using a schema
  static List<T> safeParseMany<T>(Schema<T> schema, List<dynamic> inputs,
      [List<String> path = const []]) {
    final results = <T>[];

    for (int i = 0; i < inputs.length; i++) {
      final result = schema.safeParse(inputs[i], [...path, i.toString()]);
      if (result != null) {
        results.add(result);
      }
    }

    return results;
  }

  /// Validates multiple values using a schema
  static ValidationResult<List<T>> validateMany<T>(
      Schema<T> schema, List<dynamic> inputs,
      [List<String> path = const []]) {
    final results = <T>[];
    final errors = <ValidationError>[];

    for (int i = 0; i < inputs.length; i++) {
      final result = schema.validate(inputs[i], [...path, i.toString()]);
      if (result.isSuccess) {
        results.add(result.data as T);
      } else {
        errors.addAll(result.errors!.errors);
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(ValidationErrorCollection(errors));
    }

    return ValidationResult.success(results);
  }

  /// Parses a JSON object using a schema
  static T parseJson<T>(Schema<T> schema, Map<String, dynamic> json,
      [List<String> path = const []]) {
    return schema.parse(json, path);
  }

  /// Safely parses a JSON object using a schema
  static T? safeParseJson<T>(Schema<T> schema, Map<String, dynamic> json,
      [List<String> path = const []]) {
    return schema.safeParse(json, path);
  }

  /// Validates a JSON object using a schema
  static ValidationResult<T> validateJson<T>(
      Schema<T> schema, Map<String, dynamic> json,
      [List<String> path = const []]) {
    return schema.validate(json, path);
  }

  /// Parses a JSON array using a schema
  static List<T> parseJsonArray<T>(Schema<T> schema, List<dynamic> json,
      [List<String> path = const []]) {
    return parseMany(schema, json, path);
  }

  /// Safely parses a JSON array using a schema
  static List<T> safeParseJsonArray<T>(Schema<T> schema, List<dynamic> json,
      [List<String> path = const []]) {
    return safeParseMany(schema, json, path);
  }

  /// Validates a JSON array using a schema
  static ValidationResult<List<T>> validateJsonArray<T>(
      Schema<T> schema, List<dynamic> json,
      [List<String> path = const []]) {
    return validateMany(schema, json, path);
  }

  /// Creates a parser that applies a transformation after parsing
  static ParserFunction<R> transform<T, R>(
    Schema<T> schema,
    R Function(T value) transformer,
  ) {
    return (dynamic input, [List<String> path = const []]) {
      final result = schema.validate(input, path);
      if (result.isSuccess) {
        try {
          final transformed = transformer(result.data as T);
          return ValidationResult.success(transformed);
        } catch (e) {
          return ValidationResult.failure(
            ValidationErrorCollection.single(
              ValidationError.simple(
                message: 'Transformation failed: $e',
                path: path,
                received: result.data,
              ),
            ),
          );
        }
      }
      return ValidationResult.failure(result.errors!);
    };
  }

  /// Creates a parser that applies additional validation after parsing
  static ParserFunction<T> refine<T>(
    Schema<T> schema,
    bool Function(T value) validator, {
    String? message,
    String? code,
  }) {
    return (dynamic input, [List<String> path = const []]) {
      final result = schema.validate(input, path);
      if (result.isSuccess) {
        final value = result.data as T;
        if (validator(value)) {
          return result;
        } else {
          return ValidationResult.failure(
            ValidationErrorCollection.single(
              ValidationError.constraintViolation(
                path: path,
                received: value,
                constraint: message ?? 'Custom validation failed',
                code: code ?? 'refinement_failed',
              ),
            ),
          );
        }
      }
      return result;
    };
  }

  /// Creates a parser that provides a default value
  static ParserFunction<T> withDefault<T>(Schema<T> schema, T defaultValue) {
    return (dynamic input, [List<String> path = const []]) {
      if (input == null) {
        return ValidationResult.success(defaultValue);
      }
      final result = schema.validate(input, path);
      if (result.isSuccess) {
        return result;
      }
      return ValidationResult.success(defaultValue);
    };
  }

  /// Creates a parser that makes the value optional
  static ParserFunction<T?> optional<T>(Schema<T> schema) {
    return (dynamic input, [List<String> path = const []]) {
      if (input == null) {
        return const ValidationResult.success(null);
      }
      final result = schema.validate(input, path);
      if (result.isSuccess) {
        return ValidationResult.success(result.data);
      }
      return ValidationResult.failure(result.errors!);
    };
  }

  /// Creates a parser that provides a fallback value
  static ParserFunction<T> withFallback<T>(Schema<T> schema, T fallbackValue) {
    return (dynamic input, [List<String> path = const []]) {
      final result = schema.validate(input, path);
      if (result.isSuccess) {
        return result;
      }
      return ValidationResult.success(fallbackValue);
    };
  }

  /// Creates a parser that preprocesses the input
  static ParserFunction<T> preprocess<T, R>(
    Schema<T> schema,
    R Function(dynamic input) preprocessor,
  ) {
    return (dynamic input, [List<String> path = const []]) {
      try {
        final preprocessed = preprocessor(input);
        return schema.validate(preprocessed, path);
      } catch (e) {
        return ValidationResult.failure(
          ValidationErrorCollection.single(
            ValidationError.simple(
              message: 'Preprocessing failed: $e',
              path: path,
              received: input,
            ),
          ),
        );
      }
    };
  }

  /// Creates a parser that postprocesses the output
  static ParserFunction<T> postprocess<T>(
    Schema<T> schema,
    T Function(T value) postprocessor,
  ) {
    return (dynamic input, [List<String> path = const []]) {
      final result = schema.validate(input, path);
      if (result.isSuccess) {
        try {
          final postprocessed = postprocessor(result.data as T);
          return ValidationResult.success(postprocessed);
        } catch (e) {
          return ValidationResult.failure(
            ValidationErrorCollection.single(
              ValidationError.simple(
                message: 'Postprocessing failed: $e',
                path: path,
                received: result.data,
              ),
            ),
          );
        }
      }
      return result;
    };
  }
}

/// Function type for custom parsers
typedef ParserFunction<T> = ValidationResult<T> Function(dynamic input,
    [List<String> path]);

/// Extension methods for easier parsing
extension ParserExtensions<T> on Schema<T> {
  /// Parses the input, throwing an exception if validation fails
  T parseInput(dynamic input, [List<String> path = const []]) {
    return Parser.parse(this, input, path);
  }

  /// Safely parses the input, returning null if validation fails
  T? safeParseInput(dynamic input, [List<String> path = const []]) {
    return Parser.safeParse(this, input, path);
  }

  /// Validates the input, returning a ValidationResult
  ValidationResult<T> validateInput(dynamic input,
      [List<String> path = const []]) {
    return Parser.validate(this, input, path);
  }

  /// Checks if the input is valid
  bool isValidInput(dynamic input, [List<String> path = const []]) {
    return Parser.isValid(this, input, path);
  }

  /// Parses a JSON object
  T parseJson(Map<String, dynamic> json, [List<String> path = const []]) {
    return Parser.parseJson(this, json, path);
  }

  /// Safely parses a JSON object
  T? safeParseJson(Map<String, dynamic> json, [List<String> path = const []]) {
    return Parser.safeParseJson(this, json, path);
  }

  /// Validates a JSON object
  ValidationResult<T> validateJson(Map<String, dynamic> json,
      [List<String> path = const []]) {
    return Parser.validateJson(this, json, path);
  }
}
