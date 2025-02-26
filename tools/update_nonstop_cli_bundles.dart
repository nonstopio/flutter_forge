import 'dart:io';

import 'package:mason_logger/mason_logger.dart';

const _cliDirectory = 'packages/nonstop_cli';

final bundlePaths = [
  _GenBundlePath(
    input: '$_cliDirectory/bricks/flutter_project_with_mono_repo',
    output: '$_cliDirectory/lib/commands/create',
    fileName: 'flutter_project_with_mono_repo_bundle.dart',
  ),
  _GenBundlePath(
    input: '$_cliDirectory/bricks/flutter_package_for_mono_repo',
    output: '$_cliDirectory/lib/commands/create',
    fileName: 'flutter_package_for_mono_repo_bundle.dart',
  ),
  _GenBundlePath(
    input: '$_cliDirectory/bricks/flutter_app_for_mono_repo',
    output: '$_cliDirectory/lib/commands/create',
    fileName: 'flutter_app_for_mono_repo_bundle.dart',
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
  try {
    logger.info('Activating mason_cli');
    await Process.run('dart', ['pub', 'global', 'activate', 'mason_cli']);
    int updateCount = 0;
    for (final bundle in bundlePaths) {
      logger.info('Bundling ${bundle.fileName}');

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
        logger.info('Committing changes to ${bundle.fileName}');
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
        logger.info('Successfully updated bundles for ${bundle.fileName}');
      } else {
        logger.info('No changes detected for ${bundle.fileName}');
      }
    }
    if (updateCount > 0) {
      logger.info(
        'Successfully updated $updateCount '
        'bundle${updateCount > 1 ? 's' : ''}',
      );
    } else {
      logger.info('No changes detected');
    }
  } catch (e) {
    logger.err('An error occurred while updating bundles $e');
    exit(1);
  }
}
