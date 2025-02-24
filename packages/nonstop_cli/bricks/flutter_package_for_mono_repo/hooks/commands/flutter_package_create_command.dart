import 'dart:async';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import 'cli_command.dart';

final class FlutterPackageCreateCommand extends CliCommand {
  @override
  Future<void> run(HookContext context) async {
    final String name = context.vars['name'];
    final String description = context.vars['description'];
    final appName = name.snakeCase;

    await _create(context, name, description, appName);
    final isMonoRepo = context.vars['is_mono_repo'] ?? false;
    if (isMonoRepo) {
      await _removeAnalysisOptions(context, appName);
    }
  }

  _create(
    HookContext context,
    String name,
    String description,
    String appName,
  ) =>
      trackOperation(
        context,
        startMessage: p.normalize('Setting up the $appName package'),
        endMessage: p.normalize('$appName package ready'),
        operation: (progress) => Process.run(
          'flutter',
          [
            'create',
            name.snakeCase,
            '--template=package',
            '--description=$description',
          ],
          runInShell: true,
        ),
      );

  _removeAnalysisOptions(HookContext context, String appName) => trackOperation(
        context,
        startMessage: p.normalize('Removing $appName/analysis_options.yaml'),
        endMessage: p.normalize('$appName/analysis_options.yaml removed'),
        operation: (progress) =>
            File(p.normalize('$appName/analysis_options.yaml')).delete(),
      );
}
