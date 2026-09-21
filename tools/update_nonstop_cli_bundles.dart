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
  _GenBundlePath(
    input: '$_cliDirectory/bricks/flutter_plugin_for_mono_repo',
    output: '$_cliDirectory/lib/commands/create',
    fileName: 'flutter_plugin_for_mono_repo_bundle.dart',
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
    final activation = await Process.run(
      'dart',
      ['pub', 'global', 'activate', 'mason_cli', '0.1.2'],
    );
    if (activation.exitCode != 0) {
      throw Exception('Failed to activate mason_cli: ${activation.stderr}');
    }
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
      final format = await Process.run('dart', ['format', fullPath]);
      if (format.exitCode != 0) {
        throw Exception('Failed to format $fullPath: ${format.stderr}');
      }

      // Check if file is modified
      final isModified =
          await Process.run('git', ['diff', '--quiet', fullPath]);
      if (isModified.exitCode == 1) {
        logger.info('Staging changes to ${bundle.fileName}');
        final stage = await Process.run('git', ['add', fullPath]);
        if (stage.exitCode != 0) {
          throw Exception('Failed to stage $fullPath: ${stage.stderr}');
        }
        updateCount++;
        logger.info('Successfully updated bundles for ${bundle.fileName}');
      } else if (isModified.exitCode == 0) {
        logger.info('No changes detected for ${bundle.fileName}');
      } else {
        throw Exception('Failed to inspect $fullPath: ${isModified.stderr}');
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
