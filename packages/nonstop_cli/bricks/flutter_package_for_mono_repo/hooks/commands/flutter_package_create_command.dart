import 'package:mason/mason.dart';
import 'package:cli_core/cli_core.dart' show BaseFlutterCommand;

final class FlutterPackageCreateCommand extends BaseFlutterCommand {
  @override
  Future<void> run(HookContext context) async {
    final String name = context.vars['name'];
    final String description = context.vars['description'];
    final appName = name.snakeCase;

    await createFlutterProject(
      context: context,
      name: appName,
      description: description,
      outputPath: '.',
      template: 'package',
    );

    final isMonoRepo = context.vars['is_mono_repo'] ?? false;
    if (isMonoRepo) {
      await removeAnalysisOptions(
        context: context,
        projectPath: appName,
      );
    }
  }
}
