import 'dart:io';

import 'package:cli_core/cli_core.dart' show CliCommand;
import 'package:mason/mason.dart';

import 'checked_process.dart';

final class MelosCommand extends CliCommand {
  MelosCommand({this.runProcess = Process.run});

  final ProcessRunner runProcess;

  @override
  Future<void> run(HookContext context) async {
    final String name = context.vars['name'];
    final appName = name.snakeCase;

    await runChecked(
      context,
      runProcess: runProcess,
      startMessage: 'Installing workspace tooling',
      endMessage: 'Workspace tooling installed',
      executable: 'dart',
      arguments: ['pub', 'get'],
      workingDirectory: appName,
    );

    await runChecked(
      context,
      runProcess: runProcess,
      startMessage: 'Running melos bootstrap',
      endMessage: 'Dependencies installed',
      executable: 'dart',
      arguments: ['run', 'melos', 'bootstrap'],
      workingDirectory: appName,
    );
  }
}
