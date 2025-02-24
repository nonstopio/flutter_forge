import 'dart:async';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import 'cli_command.dart';

final class FlutterCreateCommand extends CliCommand {
  @override
  Future<void> run(HookContext context) async {
    final String name = context.vars['name'];
    final String description = context.vars['description'];
    final appName = name.snakeCase;

    await _create(context, name, description, appName);
    await _removeAnalysisOptions(context, appName);
  }

  _create(
    HookContext context,
    String name,
    String description,
    String appName,
  ) =>
      trackOperation(
        context,
        startMessage:
            p.normalize('Setting up the Flutter project @ apps/$appName'),
        endMessage: p.normalize('Flutter project ready @ apps/$appName'),
        operation: () => Process.run(
          'flutter',
          [
            'create',
            name.snakeCase,
            '--template=app',
            '--platforms=ios,android,web',
            '--description=$description',
          ],
          workingDirectory: p.normalize('$appName/apps'),
          runInShell: true,
        ),
      );

  _removeAnalysisOptions(HookContext context, String appName) => trackOperation(
        context,
        startMessage: p.normalize('Removing analysis_options.yaml'),
        endMessage: p.normalize('analysis_options.yaml removed'),
        operation: () =>
            File(p.normalize('$appName/apps/$appName/analysis_options.yaml'))
                .delete(),
      );
}
