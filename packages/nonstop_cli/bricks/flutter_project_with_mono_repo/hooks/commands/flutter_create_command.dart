import 'dart:async';
import 'dart:io';

import 'package:cli_core/cli_core.dart' show CliCommand, FileUtils;
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import 'checked_process.dart';

/// Scaffolds the application with `flutter create`.
///
/// This runs in pre-gen, so the brick's own `lib/` and `pubspec.yaml` are
/// written over the counter-app that `flutter create` produces.
final class FlutterCreateCommand extends CliCommand {
  @override
  Future<void> run(HookContext context) async {
    final String name = context.vars['name'];
    final String description = context.vars['description'];
    final String orgName = context.vars['org_name'] ?? 'com.example';
    final appName = name.snakeCase;
    final appsPath = p.normalize('$appName/apps');

    await FileUtils.ensureDirectory(appsPath);

    await runChecked(
      context,
      startMessage: 'Creating Flutter app: $appName',
      endMessage: 'Flutter app created',
      executable: 'flutter',
      arguments: [
        'create',
        appName,
        '--template=app',
        '--platforms=ios,android,web',
        '--description=$description',
        '--org=$orgName',
      ],
      workingDirectory: appsPath,
    );

    final appPath = p.join(appsPath, appName);

    // The workspace owns lint configuration.
    await FileUtils.deleteFile(p.join(appPath, 'analysis_options.yaml'));

    // `flutter create` leaves a widget test for the counter app it just wrote;
    // the brick replaces that app, so the test would not compile.
    await FileUtils.deleteFile(p.join(appPath, 'test', 'widget_test.dart'));
    final testDir = Directory(p.join(appPath, 'test'));
    if (testDir.existsSync() && testDir.listSync().isEmpty) {
      await testDir.delete();
    }
  }
}
