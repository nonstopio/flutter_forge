import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:nonstop_cli/commands/create/flutter_project_with_mono_repo_bundle.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory workspace;
  late File script;
  late String packages;

  setUpAll(() async {
    packages = (await Isolate.packageConfig)!.toFilePath();
  });

  File write(String name, String contents) {
    final file = File(p.join(workspace.path, name));
    file.parent.createSync(recursive: true);
    return file..writeAsStringSync(contents);
  }

  void package(String directory, String name, String report) {
    write('$directory/pubspec.yaml', 'name: $name\n');
    write('$directory/test/example_test.dart', 'void main() {}\n');
    write('$directory/coverage/lcov.info', report);
  }

  Future<ProcessResult> run() => Process.run(
        Platform.resolvedExecutable,
        ['--packages=$packages', script.path, '--report-only'],
        workingDirectory: workspace.path,
      );

  setUp(() {
    workspace = Directory.systemTemp.createTempSync('nonstop-coverage-test-');
    final bundled = flutterProjectWithMonoRepoBundle.files
        .singleWhere((file) => file.path.endsWith('/tool/coverage.dart'));
    script =
        write('tool/coverage.dart', utf8.decode(base64Decode(bundled.data)));
  });
  tearDown(() => workspace.deleteSync(recursive: true));

  test('merges relative and absolute cross-package hits without hiding misses',
      () async {
    final shared = p.join(workspace.path, 'packages/shared/lib/shared.dart');
    write('packages/shared/lib/shared.dart',
        'void first() {}\nvoid second() {}\n');
    package(
        'apps/app',
        'app',
        'SF:lib/app.dart\nDA:1,1\nend_of_record\n'
            'SF:$shared\nDA:1,0\nDA:2,1\nend_of_record\n');
    package('packages/shared', 'shared',
        'SF:lib/shared.dart\nDA:1,1\nDA:2,0\nend_of_record\n');
    final result = await run();
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(result.stdout, contains('3/3 executable lines (100.00%)'));
    final report =
        File(p.join(workspace.path, 'coverage/lcov.info')).readAsStringSync();
    expect(report, contains('SF:packages/shared/lib/shared.dart'));
    expect(report, isNot(contains(workspace.path)));
  });

  test('fails below 100 percent and names the exact uncovered line', () async {
    package(
        'apps/app', 'app', 'SF:lib/app.dart\nDA:1,1\nDA:2,0\nend_of_record\n');
    final result = await run();
    expect(result.exitCode, 1);
    expect(result.stdout, contains('apps/app/lib/app.dart: uncovered lines 2'));
    expect(result.stdout, contains('(50.00%)'));
  });

  test('excludes generated and non-runtime code, not handwritten source',
      () async {
    package(
        'apps/app',
        'app',
        [
          for (final name in [
            'lib/app.dart',
            'lib/model.g.dart',
            'lib/model.freezed.dart',
            'lib/messages.i69n.dart',
            'test/example_test.dart',
            '../../tool/coverage.dart',
            '../../../outside.dart',
          ])
            'SF:$name\nDA:1,${name == 'lib/app.dart' ? 1 : 0}\nend_of_record\n',
        ].join());
    final result = await run();
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(result.stdout, contains('1/1 executable lines (100.00%)'));
  });

  test('fails when there are no executable lines', () async {
    package('apps/app', 'app', '');
    final result = await run();
    expect(result.exitCode, 1);
    expect(result.stdout, contains('0/0 executable lines (0.00%)'));
  });

  test('fails missing reports even if another package has full coverage',
      () async {
    package('apps/app', 'app', 'SF:lib/app.dart\nDA:1,1\nend_of_record\n');
    package('packages/shared', 'shared', '');
    File(p.join(workspace.path, 'packages/shared/coverage/lcov.info'))
        .deleteSync();
    final result = await run();
    expect(result.exitCode, 1);
    expect(result.stderr, contains('packages/shared: missing coverage report'));
  });

  test('fails a package without tests instead of silently skipping it',
      () async {
    write('packages/shared/pubspec.yaml', 'name: shared\n');
    final result = await run();
    expect(result.exitCode, 1);
    expect(result.stderr, contains('packages/shared: missing tests'));
  });
}
