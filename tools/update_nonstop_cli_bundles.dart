import 'dart:io';

import 'package:mason_logger/mason_logger.dart';

const _cliDirectory = 'packages/nonstop_cli';

final bundlePaths = [
  _GenBundlePath(
    input: '$_cliDirectory/bricks/nonstop_project',
    output: '$_cliDirectory/lib/commands/create',
    fileName: 'nonstop_project_bundle.dart',
  ),
];

class _GenBundlePath {
  final String input;
  final String output;
  final String fileName;

  _GenBundlePath({
    required this.input,
    required this.output,
    required this.fileName,
  });
}

void main() async {
  final logger = Logger();
  final progress = logger.progress('Starting bundle update process');
  try {
    progress.update('Activating mason_cli');
    await Process.run('dart', ['pub', 'global', 'activate', 'mason_cli']);
    int updateCount = 0;
    for (final bundle in bundlePaths) {
      progress.update('Bundling ${bundle.fileName}');

      // Bundle the brick
      final bundleResult = await Process.run(
        'mason',
        ['bundle', bundle.input, '-t', 'dart', '-o', bundle.output],
      );
      if (bundleResult.exitCode != 0) {
        throw Exception('Failed to bundle ${bundle.fileName}');
      }

      // Format the generated file
      final fullPath = '${bundle.output}/${bundle.fileName}';
      await Process.run('dart', ['format', fullPath]);

      // Check if file is modified
      final isModified =
          await Process.run('git', ['diff', '--quiet', fullPath]);
      if (isModified.exitCode == 1) {
        progress.update('Committing changes to ${bundle.fileName}');
        await Process.run('git', ['add', fullPath]);
        await Process.run(
          'git',
          [
            'commit',
            '-m',
            'chore(nonstop_cli): update ${bundle.fileName} bundle'
          ],
        );
        updateCount++;
        progress.update('Successfully updated bundles for ${bundle.fileName}');
      } else {
        progress.update('No changes detected for ${bundle.fileName}');
      }
    }
    if (updateCount > 0) {
      progress.update(
        'Successfully updated $updateCount '
        'bundle${updateCount > 1 ? 's' : ''}',
      );
    } else {
      progress.update('No changes detected');
    }
  } catch (e) {
    progress.fail('An error occurred while updating the version $e');
    exit(1);
  }
}
