import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:localization/localization.dart';
import 'package:network/network.dart';

extension ErrorMessageExtension on Object? {
  String message() {
    return switch (this) {
      NetworkException error => error.displayMessage,
      CoreException error => error.message,
      FormatException _ => strings.errors.format_exception_message(
        ErrorCodes.formatException,
        debugMessage,
      ),
      Error error => error.message(),
      _ => strings.errors.default_error_message,
    };
  }

  String get debugMessage {
    if (kDebugMode) {
      return '\n${toString()}\ntype: $runtimeType';
    }
    return '';
  }
}

// Simple creative error messages with codes
extension ErrorMessageOnError on Error {
  String message() {
    return switch (this) {
      TypeError _ => strings.errors.type_error_message(
        ErrorCodes.typeError,
        debugMessage,
      ),
      IndexError _ => strings.errors.index_error_message(
        ErrorCodes.indexError,
        debugMessage,
      ),
      RangeError _ => strings.errors.range_error_message(
        ErrorCodes.rangeError,
        debugMessage,
      ),
      ArgumentError _ => strings.errors.argument_error_message(
        ErrorCodes.argumentError,
        debugMessage,
      ),
      StateError _ => strings.errors.state_error_message(
        ErrorCodes.stateError,
        debugMessage,
      ),
      UnimplementedError _ => strings.errors.unimplemented_error_message(
        ErrorCodes.unimplementedError,
        debugMessage,
      ),
      UnsupportedError _ => strings.errors.unsupported_error_message(
        ErrorCodes.unsupportedError,
        debugMessage,
      ),
      ConcurrentModificationError _ =>
        strings.errors.concurrent_modification_error_message(
          ErrorCodes.concurrentModificationError,
          debugMessage,
        ),
      OutOfMemoryError _ => strings.errors.out_of_memory_error_message(
        ErrorCodes.outOfMemoryError,
        debugMessage,
      ),
      StackOverflowError _ => strings.errors.stack_overflow_error_message(
        ErrorCodes.stackOverflowError,
        debugMessage,
      ),
      _ => strings.errors.unknown_error_message(
        ErrorCodes.unknownError,
        debugMessage,
      ),
    };
  }
}

sealed class ErrorCodes {
  static const String typeError = "E001";
  static const String argumentError = "E002";
  static const String rangeError = "E003";
  static const String indexError = "E004";
  static const String stateError = "E005";
  static const String unsupportedError = "E006";
  static const String unimplementedError = "E007";
  static const String concurrentModificationError = "E008";
  static const String outOfMemoryError = "E009";
  static const String stackOverflowError = "E010";
  static const String formatException = "E011";
  static const String unknownError = "E999";
  static const String networkException = "E100";
  static const String coreException = "E101";
  static const String defaultError = "E000";
}
