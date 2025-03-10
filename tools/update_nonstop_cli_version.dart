import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

const _cliDirectory = 'packages/nonstop_cli';

void main() async {
  final logger = Logger();
  logger.info('Starting version update process');

  try {
    // Read the pubspec.yaml file
    final pubspecFile = File('$_cliDirectory/pubspec.yaml');
    logger.info('Reading pubspec.yaml');
    final pubspecContent = await pubspecFile.readAsString();
    final pubspec = Pubspec.parse(pubspecContent);

    // Get the current version
    final version = pubspec.version.toString();
    logger.info('Current version: $version');

    // Update the version.dart file
    final versionFile = File('$_cliDirectory/lib/version.dart');
    logger.info('Updating $_cliDirectory/lib/version.dart');
    await versionFile.writeAsString('''
// Generated code. Do not modify.
// It is generated by the release workflow as post-release hook.

const packageVersion = '$version';
''');

// Check if the file is modified
    final isModified =
        await Process.run('git', ['diff', '--quiet', versionFile.path]);
    if (isModified.exitCode == 1) {
      logger.info('version.dart has been modified');

      // Check if the last commit is a release commit
      final lastCommit = await Process.run('git', ['log', '-1', '--pretty=%B']);
      final commitMessage = lastCommit.stdout.toString().trim();

      if (commitMessage.startsWith('chore(release):')) {
        logger.info('Amending last release commit');

        // Stage and amend the commit
        await Process.run('git', ['add', versionFile.path]);
        await Process.run('git', ['commit', '--amend', '--no-edit']);

        logger.success(
          'Successfully updated version.dart with '
          'version $version in $_cliDirectory',
        );
      } else {
        logger.warn('version.dart has been modified but the '
            'last commit is not a release commit');
      }
    }
    logger.success('No changes detected');
  } catch (e) {
    logger.err('An error occurred while updating the version $e');
    exit(1);
  }
}
