import 'dart:io';

import 'package:mason/mason.dart';

/// Runs [executable] and throws when it fails.
///
/// `cli_core`'s `trackOperation` reports success as soon as the future
/// completes, so a non-zero exit code shows a green tick and generation
/// carries on to produce a half-built project. Every step here is load-bearing
/// - if `flutter create` or `melos bootstrap` fails there is nothing worth
/// continuing for - so the exit code is checked and the child's stderr is
/// surfaced.
Future<void> runChecked(
  HookContext context, {
  required String startMessage,
  required String endMessage,
  required String executable,
  required List<String> arguments,
  String? workingDirectory,
}) async {
  final progress = context.logger.progress(startMessage);

  final ProcessResult result;
  try {
    result = await Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      runInShell: true,
    );
  } catch (error) {
    progress.fail('$startMessage failed: $error');
    rethrow;
  }

  if (result.exitCode != 0) {
    progress.fail('$startMessage failed (exit ${result.exitCode})');
    final details = '${result.stderr}'.trim().isNotEmpty
        ? '${result.stderr}'.trim()
        : '${result.stdout}'.trim();
    if (details.isNotEmpty) context.logger.err(details);
    throw ProcessException(
      executable,
      arguments,
      'exited with ${result.exitCode}',
      result.exitCode,
    );
  }

  progress.complete(endMessage);
}
