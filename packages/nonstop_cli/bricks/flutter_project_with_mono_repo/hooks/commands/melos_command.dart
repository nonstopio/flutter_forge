import 'package:cli_core/cli_core.dart' show CliCommand;
import 'package:mason/mason.dart';

import 'checked_process.dart';

final class MelosCommand extends CliCommand {
  @override
  Future<void> run(HookContext context) async {
    final String name = context.vars['name'];
    final appName = name.snakeCase;

    await runChecked(
      context,
      startMessage: 'Activating Melos globally',
      endMessage: 'Melos activated globally',
      executable: 'dart',
      arguments: ['pub', 'global', 'activate', 'melos'],
    );

    await runChecked(
      context,
      startMessage: 'Running melos bootstrap',
      endMessage: 'Dependencies installed',
      executable: 'melos',
      arguments: ['bootstrap'],
      workingDirectory: appName,
    );
  }
}
