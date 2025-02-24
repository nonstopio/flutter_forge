import 'dart:async';
import 'dart:io';

import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final progress = context.logger.progress('Verifying mono repo structure');

  try {
    // Use 'melos list' command to check if we're in a valid mono repo
    final result = await Process.run('melos', ['list', '--json']);
    context.logger.info('');
    // Check if the command was found and executed successfully
    if (result.exitCode != 0) {
      if (result.stderr.toString().contains('command not found')) {
        progress.fail('Melos not installed');
        context.logger
          ..err('Melos CLI is not installed or not in your PATH.')
          ..info('')
          ..info('Please install Melos first:')
          ..info('')
          ..info('  \$ dart pub global activate melos')
          ..info('');
      } else {
        progress.fail('Not a mono repo!');
        context.logger
          ..err('This template can only be generated within a Melos mono repo.')
          ..info('')
          ..info('Please ensure you are in a directory managed by Melos,')
          ..info('or initialize a new mono repo first with:')
          ..info('')
          ..info('  \$ melos init')
          ..info('');
      }

      // Cancel generation
      context.vars['canceled'] = true;
      throw Exception('Generation canceled: Melos verification failed');
    }

    progress.complete('Mono repo verified!');

    // Add a variable that can be used in mustache templates
    context.vars['is_mono_repo'] = true;
  } catch (e) {
    if (!e.toString().contains('Generation canceled')) {
      progress.fail('Failed to verify mono repo structure');
      context.logger.err('Error: ${e.toString()}');
      context.vars['canceled'] = true;
    }
    rethrow;
  }
}
