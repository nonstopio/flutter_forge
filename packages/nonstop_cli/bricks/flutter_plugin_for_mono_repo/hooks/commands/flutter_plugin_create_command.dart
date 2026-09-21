import 'package:cli_core/cli_core.dart' show BaseFlutterCommand, CliCommand;
import 'package:mason/mason.dart';

final class FlutterPluginCreateCommand extends CliCommand {
  FlutterPluginCreateCommand({BaseFlutterCommand? flutter})
      : _flutter = flutter ?? BaseFlutterCommand();

  final BaseFlutterCommand _flutter;

  @override
  Future<void> run(HookContext context) async {
    final String name = context.vars['name'];
    final String description = context.vars['description'];
    final String orgName = context.vars['org_name'] ?? 'com.example';
    final appName = name.snakeCase;

    await _flutter.createFlutterProject(
      context: context,
      name: appName,
      description: description,
      outputPath: '.',
      template: 'plugin',
      orgName: orgName,
    );

    final isMonoRepo = context.vars['is_mono_repo'] ?? false;
    if (isMonoRepo) {
      await _flutter.removeAnalysisOptions(
        context: context,
        projectPath: appName,
      );
    }
  }
}
