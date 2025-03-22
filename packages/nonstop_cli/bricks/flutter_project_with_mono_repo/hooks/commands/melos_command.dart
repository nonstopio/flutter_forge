import 'dart:io';
import 'package:mason/mason.dart';
import 'package:cli_core/cli_core.dart' show BaseMelosCommand;

final class MelosCommand extends BaseMelosCommand {
  @override
  Future<void> run(HookContext context) async {
    final String name = context.vars['name'];
    final appName = name.snakeCase;

    await trackOperation(
      context,
      startMessage: 'Activating Melos globally',
      endMessage: 'Melos activated globally',
      operation: () => Process.run(
        'dart',
        ['pub', 'global', 'activate', 'melos'],
        runInShell: true,
      ),
    );

    await bootstrap(
      context: context,
      workspacePath: appName,
    );
  }
}
