import 'dart:async';
import 'dart:io';

import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  // Silently check if we're in a mono repo
  try {
    // Try with melos command first
    final melosResult = await Process.run('melos', ['list', '--json']);
    final isMonoRepo =
        melosResult.exitCode == 0 && melosResult.stdout.toString().isNotEmpty;

    // Set the variable
    context.vars['is_mono_repo'] = isMonoRepo;
  } catch (_) {
    // If melos command fails, check for melos.yaml as fallback
    final currentDir = Directory.current;
    final melosFile = File('${currentDir.path}/melos.yaml');
    final parentMelosFile = File('${currentDir.parent.path}/melos.yaml');

    final isMonoRepo = melosFile.existsSync() || parentMelosFile.existsSync();

    // Set the variable
    context.vars['is_mono_repo'] = isMonoRepo;
  }

  // Continue with generation regardless of mono repo status
  // The template can use the 'is_mono_repo' variable to customize behavior
}