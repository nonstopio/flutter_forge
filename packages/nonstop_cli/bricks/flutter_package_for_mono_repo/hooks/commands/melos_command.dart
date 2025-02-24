import 'dart:async';
import 'dart:io';

import 'package:mason/mason.dart';

import 'cli_command.dart';

final class MelosCommand extends CliCommand {
  @override
  Future<void> run(HookContext context) async {
    final String name = context.vars['name'];
    final appName = name.snakeCase;

    await trackOperation(
      context,
      startMessage: 'Verify Melos globally',
      endMessage: 'Melos Verification Completed',
      operation: (progress) async {
        // Verify Melos is installed globally
        final result = await Process.run(
          'dart',
          ['pub', 'global', 'list'],
          runInShell: true,
        );
        if (!result.stdout.toString().contains('melos')) {
          await Process.run(
            'dart',
            ['pub', 'global', 'activate', 'melos'],
            runInShell: true,
          );
        } else {
          progress.update('Melos is already installed globally');
        }
      },
    );

    await trackOperation(
      context,
      startMessage: 'Running `melos bootstrap` on apps/$appName',
      endMessage: 'Melos bootstrap completed for apps/$appName',
      operation: (progress) async {
        await Process.run(
          'melos',
          ['bootstrap'],
          workingDirectory: appName,
          runInShell: true,
        );
      },
    );
  }
}
