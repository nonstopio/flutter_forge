import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:nonstop_cli/commands/create/flutter_project_with_mono_repo_bundle.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test(
      'quality checks every owned source and never analyzes copied SDK packages',
      () async {
    final workspace = await Directory.systemTemp.createTemp('nonstop-quality-');
    addTearDown(() => workspace.delete(recursive: true));
    File write(String relative, String contents) {
      final file = File(p.join(workspace.path, relative));
      file.parent.createSync(recursive: true);
      return file..writeAsStringSync(contents);
    }

    final bundled = flutterProjectWithMonoRepoBundle.files
        .singleWhere((file) => file.path.endsWith('/tool/check.dart'));
    final script =
        write('tool/check.dart', utf8.decode(base64Decode(bundled.data)));
    write('packages/example/lib/example.dart', 'void example() {}');
    write('packages/example/test/example_test.dart', 'void main() {}');
    write('packages/example/lib/example.g.dart', 'generated code');
    write('build/ios/SourcePackages/vendor/test/vendor_test.dart',
        'external code');
    write('packages/example/lib/build/generated.dart', 'build output');
    write('packages/example/lib/.dart_tool/cached.dart', 'cached code');
    write('packages/example/lib/.symlinks/vendor.dart', 'linked dependency');
    final executable = write('bin/dart', r'''#!/bin/sh
printf '%s\n' "$@" >> "$CAPTURE_FILE"
printf '%s\n' END >> "$CAPTURE_FILE"
''');
    expect(Process.runSync('chmod', ['+x', executable.path]).exitCode, 0);
    final capture = p.join(workspace.path, 'commands.txt');
    final configuration = (await Isolate.packageConfig)!.toFilePath();
    final result = await Process.run(
      Platform.resolvedExecutable,
      ['--packages=$configuration', script.path],
      workingDirectory: workspace.path,
      environment: {'PATH': executable.parent.path, 'CAPTURE_FILE': capture},
    );
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    final commands = File(capture).readAsStringSync().split('END\n');
    final format = commands[0].trim().split('\n');
    final analyze = commands[1].trim().split('\n');
    expect(
        format.take(3), ['format', '--output=none', '--set-exit-if-changed']);
    expect(analyze.take(2), ['analyze', '--fatal-infos']);
    const sources = [
      'packages/example/lib/example.dart',
      'packages/example/test/example_test.dart',
      'tool/check.dart',
    ];
    expect(format.skip(3), sources);
    expect(analyze.skip(2), sources);
  }, skip: Platform.isWindows ? 'The process shim uses a POSIX shell.' : false);
}
