import 'dart:async';
import 'dart:io';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../src/cli_command.dart';

/// A command class that provides common Flutter CLI operations.
///
/// This class extends [CliCommand] and provides methods for:
/// - Creating new Flutter projects (apps, packages, plugins)
/// - Managing project files and configurations
/// - Running Flutter commands like pub get
///
/// Example usage:
/// ```dart
/// class MyFlutterCommand extends BaseFlutterCommand {
///   @override
///   Future<void> run(HookContext context) async {
///     await createFlutterProject(
///       context: context,
///       name: 'my_app',
///       description: 'My Flutter application',
///       outputPath: 'path/to/output',
///     );
///   }
/// }
/// ```
base class BaseFlutterCommand extends CliCommand {
  /// Creates a new Flutter project.
  ///
  /// [context] - The Mason hook context
  /// [name] - The name of the project
  /// [description] - A description of the project
  /// [outputPath] - Where to create the project
  /// [template] - The project template to use ('app', 'package', 'plugin')
  /// [platforms] - Target platforms for the project
  /// [orgName] - Organization name (bundle identifier prefix)
  Future<void> createFlutterProject({
    required HookContext context,
    required String name,
    required String description,
    required String outputPath,
    String template = 'app',
    List<String> platforms = const ['ios', 'android', 'web'],
    String? orgName,
  }) =>
      trackOperation(
        context,
        startMessage: 'Creating Flutter $template project: $name',
        endMessage: 'Flutter project created successfully',
        operation: () {
          final args = [
            'create',
            name,
            '--template=$template',
            '--platforms=${platforms.join(",")}',
            '--description=$description',
          ];

          if (orgName != null) {
            args.add('--org=$orgName');
          }

          return Process.run(
            'flutter',
            args,
            workingDirectory: outputPath,
            runInShell: true,
          );
        },
      );

  /// Remove the generated analysis_options.yaml file from a Flutter project
  ///
  /// [context] - The Mason hook context
  /// [projectPath] - Path to the Flutter project
  Future<void> removeAnalysisOptions({
    required HookContext context,
    required String projectPath,
  }) =>
      trackOperation(
        context,
        startMessage: 'Removing analysis_options.yaml',
        endMessage: 'analysis_options.yaml removed',
        operation: () =>
            File(p.normalize('$projectPath/analysis_options.yaml')).delete(),
      );

  /// Run Flutter pub get in a directory
  ///
  /// [context] - The Mason hook context
  /// [projectPath] - Path to the Flutter project
  Future<void> pubGet({
    required HookContext context,
    required String projectPath,
  }) =>
      trackOperation(
        context,
        startMessage: 'Running flutter pub get',
        endMessage: 'Dependencies updated successfully',
        operation: () => Process.run(
          'flutter',
          ['pub', 'get'],
          workingDirectory: projectPath,
          runInShell: true,
        ),
      );
}