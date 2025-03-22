import 'dart:async';
import 'dart:io';
import 'package:mason/mason.dart';

import '../src/cli_command.dart';

/// A command class that provides common Melos CLI operations.
///
/// This class extends [CliCommand] and provides methods for:
/// - Managing workspace dependencies
/// - Cleaning workspaces
///
/// Example usage:
/// ```dart
/// class MyMelosCommand extends BaseMelosCommand {
///   @override
///   Future<void> run(HookContext context) async {
///     await bootstrap(
///       context: context,
///       workspacePath: 'path/to/workspace',
///     );
///   }
/// }
/// ```
base class BaseMelosCommand extends CliCommand {
  /// Run Melos bootstrap to install dependencies
  ///
  /// [context] - The Mason hook context
  /// [workspacePath] - Path to the workspace directory
  Future<void> bootstrap({
    required HookContext context,
    required String workspacePath,
  }) =>
      trackOperation(
        context,
        startMessage: 'Running melos bootstrap',
        endMessage: 'Dependencies installed successfully',
        operation: () => Process.run(
          'melos',
          ['bootstrap'],
          workingDirectory: workspacePath,
          runInShell: true,
        ),
      );

  /// Clean Melos workspace
  ///
  /// [context] - The Mason hook context
  /// [workspacePath] - Path to the workspace directory
  Future<void> clean({
    required HookContext context,
    required String workspacePath,
  }) =>
      trackOperation(
        context,
        startMessage: 'Cleaning Melos workspace',
        endMessage: 'Workspace cleaned successfully',
        operation: () => Process.run(
          'melos',
          ['clean'],
          workingDirectory: workspacePath,
          runInShell: true,
        ),
      );
}
