import 'dart:async';
import 'package:mason/mason.dart';

/// Base class for all CLI commands in the utility package.
///
/// This class provides common functionality for:
/// - Running commands with progress tracking
/// - Error handling during command execution
/// - Consistent logging and user feedback
///
/// Extend this class to create specific command implementations:
/// ```dart
/// class MyCommand extends CliCommand {
///   @override
///   Future<void> run(HookContext context) async {
///     await trackOperation(
///       context,
///       startMessage: 'Starting operation',
///       endMessage: 'Operation complete',
///       operation: () => yourOperation(),
///     );
///   }
/// }
/// ```
abstract base class CliCommand {
  /// Run the command with the given HookContext
  ///
  /// Override this method in your command implementation to define
  /// the command's behavior.
  ///
  /// [context] - The Mason hook context containing variables and logger
  Future<void> run(HookContext context) async {}

  /// Track an operation with progress indicator
  ///
  /// This method provides consistent progress tracking and error handling
  /// for long-running operations.
  ///
  /// [context] - The Mason hook context
  /// [startMessage] - Message to show when operation starts
  /// [endMessage] - Message to show when operation completes successfully
  /// [operation] - The async operation to execute and track
  ///
  /// Throws any error that occurs during the operation after marking
  /// the progress as failed.
  Future<void> trackOperation(
    HookContext context, {
    required String startMessage,
    required String endMessage,
    required Future<void> Function() operation,
  }) async {
    final progress = context.logger.progress(startMessage);
    try {
      await operation();
      progress.complete(endMessage);
    } catch (e) {
      progress.fail('Failed: $e');
      rethrow;
    }
  }
}