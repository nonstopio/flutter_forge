import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

const _cliDirectory = 'packages/nonstop_cli';

final bundlePaths = [
  BundlePath(
    input: '$_cliDirectory/bricks/flutter_project_with_mono_repo',
    output: '$_cliDirectory/lib/commands/create',
    fileName: 'flutter_project_with_mono_repo_bundle.dart',
  ),
  BundlePath(
    input: '$_cliDirectory/bricks/flutter_package_for_mono_repo',
    output: '$_cliDirectory/lib/commands/create',
    fileName: 'flutter_package_for_mono_repo_bundle.dart',
  ),
  BundlePath(
    input: '$_cliDirectory/bricks/flutter_app_for_mono_repo',
    output: '$_cliDirectory/lib/commands/create',
    fileName: 'flutter_app_for_mono_repo_bundle.dart',
  ),
  BundlePath(
    input: '$_cliDirectory/bricks/flutter_plugin_for_mono_repo',
    output: '$_cliDirectory/lib/commands/create',
    fileName: 'flutter_plugin_for_mono_repo_bundle.dart',
  ),
];

class BundlePath {
  final String input;
  final String output;
  final String fileName;

  BundlePath({
    required this.input,
    required this.output,
    required this.fileName,
  });
}

typedef ProcessRunner =
    Future<ProcessResult> Function(String executable, List<String> arguments);

Future<void> main({
  List<BundlePath>? bundles,
  ProcessRunner runProcess = Process.run,
  Logger? logger,
}) async {
  logger ??= Logger();
  exitCode = 0;
  try {
    logger.info('Activating mason_cli');
    await runProcess('dart', ['pub', 'global', 'activate', 'mason_cli']);
    int updateCount = 0;
    for (final bundle in bundles ?? bundlePaths) {
      logger.info('Bundling ${bundle.fileName}');

      // Workspace membership is local to this repository. Bundle an isolated
      // copy so generated projects resolve their hook dependencies standalone.
      final staging = await stageStandaloneBrick(Directory(bundle.input));
      late final ProcessResult bundleResult;
      try {
        bundleResult = await runProcess('mason', [
          'bundle',
          staging.path,
          '-t',
          'dart',
          '-o',
          bundle.output,
        ]);
      } finally {
        await staging.parent.delete(recursive: true);
      }
      if (bundleResult.exitCode != 0) {
        throw Exception('Failed to bundle ${bundle.fileName}');
      }

      // Format the generated file
      final fullPath = '${bundle.output}/${bundle.fileName}';
      await runProcess('dart', ['format', fullPath]);

      // Check if file is modified
      final isModified = await runProcess('git', ['diff', '--quiet', fullPath]);
      if (isModified.exitCode == 1) {
        logger.info('Committing changes to ${bundle.fileName}');
        await runProcess('git', ['add', fullPath]);
        await runProcess('git', [
          'commit',
          '-m',
          'chore(nonstop_cli): update ${bundle.fileName} bundle',
        ]);
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
    exitCode = 1;
  }
}

/// Copies a brick into a temporary directory for standalone packaging.
Future<Directory> stageStandaloneBrick(Directory source) async {
  final temporary = await Directory.systemTemp.createTemp('nonstop_bundle_');
  final staged = Directory(
    path.join(temporary.path, path.basename(source.path)),
  );
  try {
    await staged.create();
    await for (final entry in source.list(
      recursive: true,
      followLinks: false,
    )) {
      final relative = path.relative(entry.path, from: source.path);
      final segments = path.split(relative);
      if ((segments.length >= 2 &&
              segments[0] == 'hooks' &&
              segments[1] == 'test') ||
          segments.any(
            (segment) =>
                segment == '.dart_tool' ||
                segment == 'coverage' ||
                segment == 'build',
          )) {
        continue;
      }
      final destination = path.join(staged.path, relative);
      if (entry is Directory) {
        await Directory(destination).create(recursive: true);
      } else if (entry is File) {
        final file = File(destination);
        await file.parent.create(recursive: true);
        if (relative == path.join('hooks', 'pubspec.yaml')) {
          final content = await entry.readAsString();
          await file.writeAsString(
            content.replaceAll(
              RegExp(r'^resolution:\s*workspace\s*$', multiLine: true),
              '',
            ),
          );
        } else {
          await entry.copy(destination);
        }
      } else if (entry is Link) {
        await Link(destination).create(await entry.target());
      }
    }
    return staged;
  } catch (_) {
    await temporary.delete(recursive: true);
    rethrow;
  }
}
