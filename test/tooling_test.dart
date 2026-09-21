import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../tools/update_nonstop_cli_bundles.dart' as bundles;
import '../tools/update_nonstop_cli_version.dart' as version;

void main() {
  late Directory root;
  late Logger logger;

  Future<File> write(String relative, String content) async {
    final file = File(path.join(root.path, relative));
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
    return file;
  }

  Future<bundles.BundlePath> brick(String name) async {
    await write('$name/brick.yaml', 'name: $name\n');
    await write('$name/__brick__/main.dart', 'void main() {}\n');
    await write('$name/hooks/pre_gen.dart', 'void run() {}\n');
    await write(
      '$name/hooks/pubspec.yaml',
      'name: ${name}_hooks\nresolution: workspace\ndependencies:\n  mason: ^0.1.2\n',
    );
    return bundles.BundlePath(
      input: path.join(root.path, name),
      output: path.join(root.path, 'output'),
      fileName: '${name}_bundle.dart',
    );
  }

  setUp(() async {
    root = await Directory.systemTemp.createTemp('tooling_test_');
    logger = Logger(level: Level.quiet);
    final originalExitCode = exitCode;
    addTearDown(() => exitCode = originalExitCode);
  });

  tearDown(() => root.delete(recursive: true));

  test(
    'version command writes declared version and stages only changed output',
    () async {
      await write('pubspec.yaml', 'name: sample\nversion: 1.2.3+4\n');
      await Directory(path.join(root.path, 'lib')).create();
      final calls = <List<String>>[];
      await version.main(
        cliDirectory: root.path,
        logger: logger,
        runProcess: (executable, arguments) async {
          calls.add([executable, ...arguments]);
          return ProcessResult(1, arguments.first == 'diff' ? 1 : 0, '', '');
        },
      );
      expect(exitCode, 0);
      final generated = File(path.join(root.path, 'lib/version.dart'));
      expect(
        await generated.readAsString(),
        contains("const packageVersion = '1.2.3+4';"),
      );
      expect(calls, [
        ['git', 'diff', '--quiet', generated.path],
        ['git', 'add', generated.path],
      ]);

      calls.clear();
      await version.main(
        cliDirectory: root.path,
        logger: logger,
        runProcess: (executable, arguments) async {
          calls.add([executable, ...arguments]);
          return ProcessResult(1, 0, '', '');
        },
      );
      expect(exitCode, 0);
      expect(calls, [
        ['git', 'diff', '--quiet', generated.path],
      ]);
    },
  );

  test(
    'version command reports IO and process failures without exiting host',
    () async {
      await version.main(cliDirectory: root.path);
      expect(exitCode, 1);
      await write('pubspec.yaml', 'name: sample\nversion: 1.0.0\n');
      await Directory(path.join(root.path, 'lib')).create();
      await version.main(
        cliDirectory: root.path,
        logger: logger,
        runProcess: (_, _) async =>
            throw const ProcessException('git', [], 'failed'),
      );
      expect(exitCode, 1);
    },
  );

  test(
    'standalone brick staging preserves source and removes local caches',
    () async {
      final input = await brick('sample');
      await write('sample/hooks/.dart_tool/package_config.json', '{}');
      await write('sample/hooks/coverage/lcov.info', 'temporary coverage');
      await write('sample/hooks/test/hook_test.dart', 'test code');
      await write('sample/hooks/build/temp', 'temporary build');
      await Link(
        path.join(input.input, '__brick__/linked.dart'),
      ).create('main.dart');
      final sourceManifest = File(path.join(input.input, 'hooks/pubspec.yaml'));
      final original = await sourceManifest.readAsString();
      final staged = await bundles.stageStandaloneBrick(Directory(input.input));
      addTearDown(() => staged.parent.delete(recursive: true));
      expect(await sourceManifest.readAsString(), original);
      expect(
        await File(path.join(staged.path, 'hooks/pubspec.yaml')).readAsString(),
        allOf(
          contains('mason: ^0.1.2'),
          isNot(contains('resolution: workspace')),
        ),
      );
      expect(
        await File(
          path.join(staged.path, '__brick__/main.dart'),
        ).readAsString(),
        'void main() {}\n',
      );
      expect(
        await Link(path.join(staged.path, '__brick__/linked.dart')).target(),
        'main.dart',
      );
      for (final cache in ['.dart_tool', 'coverage', 'build', 'test']) {
        expect(
          Directory(path.join(staged.path, 'hooks', cache)).existsSync(),
          isFalse,
        );
      }
    },
  );

  test(
    'staging cleans its temporary directory if the source is missing',
    () async {
      Set<String> stagedDirectories() => Directory.systemTemp
          .listSync()
          .whereType<Directory>()
          .where((dir) => path.basename(dir.path).startsWith('nonstop_bundle_'))
          .map((dir) => dir.path)
          .toSet();
      final before = stagedDirectories();
      await expectLater(
        bundles.stageStandaloneBrick(
          Directory(path.join(root.path, 'missing')),
        ),
        throwsA(isA<FileSystemException>()),
      );
      expect(stagedDirectories(), before);
    },
  );

  test(
    'bundle command formats and commits each changed generated file',
    () async {
      final inputs = [await brick('first'), await brick('second')];
      final calls = <List<String>>[];
      final stages = <String>[];
      await bundles.main(
        bundles: inputs,
        logger: logger,
        runProcess: (executable, arguments) async {
          calls.add([executable, ...arguments]);
          if (executable == 'mason') {
            stages.add(arguments[1]);
            expect(
              await File(
                path.join(arguments[1], 'hooks/pubspec.yaml'),
              ).readAsString(),
              isNot(contains('resolution: workspace')),
            );
            expect(arguments, [
              'bundle',
              arguments[1],
              '-t',
              'dart',
              '-o',
              inputs.first.output,
            ]);
          }
          return ProcessResult(1, arguments.first == 'diff' ? 1 : 0, '', '');
        },
      );
      expect(exitCode, 0);
      expect(calls.first, ['dart', 'pub', 'global', 'activate', 'mason_cli']);
      expect(calls.where((call) => call[0] == 'mason'), hasLength(2));
      expect(
        calls.where((call) => call[0] == 'git' && call[1] == 'commit'),
        hasLength(2),
      );
      expect(
        calls,
        contains(
          equals([
            'dart',
            'format',
            path.join(inputs.first.output, inputs.first.fileName),
          ]),
        ),
      );
      for (final stage in stages) {
        expect(Directory(stage).parent.existsSync(), isFalse);
      }
      expect(bundles.bundlePaths, hasLength(4));
      expect(
        bundles.bundlePaths.map((bundle) => bundle.fileName).toSet(),
        hasLength(4),
      );
    },
  );

  test('bundle command does not stage or commit unchanged output', () async {
    final input = await brick('sample');
    final calls = <List<String>>[];
    await bundles.main(
      bundles: [input],
      runProcess: (executable, arguments) async {
        calls.add([executable, ...arguments]);
        return ProcessResult(1, 0, '', '');
      },
    );
    expect(exitCode, 0);
    expect(calls.where((call) => call[0] == 'git').map((call) => call[1]), [
      'diff',
    ]);
  });

  test('bundle failure returns error and removes the staged copy', () async {
    final input = await brick('sample');
    String? staged;
    await bundles.main(
      bundles: [input],
      logger: logger,
      runProcess: (executable, arguments) async {
        if (executable == 'mason') staged = arguments[1];
        return ProcessResult(1, executable == 'mason' ? 1 : 0, '', 'failed');
      },
    );
    expect(exitCode, 1);
    expect(Directory(staged!).parent.existsSync(), isFalse);
    expect(
      await File(path.join(input.input, 'hooks/pubspec.yaml')).readAsString(),
      contains('resolution: workspace'),
    );
  });

  test('thrown process failure removes staging and reports error', () async {
    final input = await brick('sample');
    String? staged;
    await bundles.main(
      bundles: [input],
      logger: logger,
      runProcess: (executable, arguments) async {
        if (executable == 'mason') {
          staged = arguments[1];
          throw const ProcessException('mason', [], 'not available');
        }
        return ProcessResult(1, 0, '', '');
      },
    );
    expect(exitCode, 1);
    expect(Directory(staged!).parent.existsSync(), isFalse);
  });
}
