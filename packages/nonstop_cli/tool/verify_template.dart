import 'dart:io';

import 'package:nonstop_cli/commands/create/modules.dart';
import 'package:path/path.dart' as p;

/// Run from packages/nonstop_cli: dart run tool/verify_template.dart [profile].
/// Leaves its temporary workspace available for diagnosis, never edits a repo.
Future<void> main(List<String> args) async {
  final profile = args.isEmpty ? 'full' : args.single;
  const profiles = [
    'full',
    'default',
    'minimal',
    'auth-only',
    'firestore-only',
    'network-only'
  ];
  if (!profiles.contains(profile)) {
    throw ArgumentError('Choose one of $profiles');
  }
  final cli = p.dirname(p.dirname(File.fromUri(Platform.script).path));
  final output = await Directory.systemTemp.createTemp('nonstop-verify-');
  const name = 'verified_app';
  final workspace = p.join(output.path, name);
  stdout.writeln('Verifying $profile in $workspace');
  Future<void> run(
      String executable, List<String> arguments, String directory) async {
    final process = await Process.start(executable, arguments,
        workingDirectory: directory, mode: ProcessStartMode.inheritStdio);
    final result = await process.exitCode;
    if (result != 0) {
      throw ProcessException(
          executable, arguments, 'Verification failed in $directory', result);
    }
  }

  final flags = <String>[];
  if (profile != 'default') {
    for (final module in templateModules) {
      final enabled = profile == 'full' || profile == '${module.flag}-only';
      flags.add('--${enabled ? '' : 'no-'}${module.flag}');
    }
  }
  await run(
      'dart',
      [
        'run',
        'bin/nonstop.dart',
        'create',
        name,
        '--defaults',
        ...flags,
        '--output-directory',
        output.path
      ],
      cli);
  await run('dart', ['run', 'melos', 'run', 'lint'], workspace);
  await run('dart', ['run', 'melos', 'run', 'coverage'], workspace);
  await run('flutter', ['build', 'web'], p.join(workspace, 'apps', name));
  stdout
      .writeln('Verified $profile: analysis, tests, 100% coverage, web build.');
}
