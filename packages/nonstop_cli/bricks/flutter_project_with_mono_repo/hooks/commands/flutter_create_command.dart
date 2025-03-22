import 'dart:async';

import 'package:cli_core/cli_core.dart' show BaseFlutterCommand;
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

final class FlutterCreateCommand extends BaseFlutterCommand {
  @override
  Future<void> run(HookContext context) async {
    final String name = context.vars['name'];
    final String description = context.vars['description'];
    final appName = name.snakeCase;
    final outputPath = p.normalize('$appName/apps');

    await createFlutterProject(
      context: context,
      name: appName,
      description: description,
      outputPath: outputPath,
    );

    await removeAnalysisOptions(
      context: context,
      projectPath: p.join(outputPath, appName),
    );
  }
}
