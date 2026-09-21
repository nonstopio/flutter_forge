import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../tool/verify_template.dart' as verifier;

class _Stdout extends Mock implements Stdout {}

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('verify-template-test-');
  });

  tearDown(() => root.delete(recursive: true));

  const modules = [
    'network',
    'auth',
    'firestore',
    'notifications',
    'analytics',
    'crashlytics',
    'feature-flags',
    'developer',
    'dashboard',
  ];
  for (final profile in [
    'full',
    'default',
    'minimal',
    'auth-only',
    'firestore-only',
    'network-only',
  ]) {
    test('$profile renders its flags then lints, measures coverage and builds',
        () async {
      final output = Directory(p.join(root.path, 'generated'));
      final workspace = p.join(output.path, 'verified_app');
      final cli = p.join(root.path, 'cli');
      final calls = <(String, List<String>, String)>[];
      final messages = <String>[];
      var temporaryDirectories = 0;

      await verifier.main(
        [profile],
        script: File(p.join(cli, 'tool', 'verify_template.dart')).uri,
        createTemporaryDirectory: (prefix) async {
          expect(prefix, 'nonstop-verify-');
          temporaryDirectories++;
          return output;
        },
        writeLine: messages.add,
        runProcess: (executable, arguments, directory) async {
          calls.add((executable, arguments, directory));
          return 0;
        },
      );

      expect(temporaryDirectories, 1);
      final expectedCalls = [
        (
          'dart',
          [
            'run',
            'bin/nonstop.dart',
            'create',
            'verified_app',
            '--defaults',
            if (profile != 'default')
              for (final module in modules)
                '--${profile == 'full' || profile == '$module-only' ? '' : 'no-'}$module',
            '--output-directory',
            output.path,
          ],
          cli,
        ),
        ('dart', ['run', 'melos', 'run', 'lint'], workspace),
        ('dart', ['run', 'melos', 'run', 'coverage'], workspace),
        (
          'flutter',
          ['build', 'web'],
          p.join(workspace, 'apps', 'verified_app')
        ),
      ];
      expect(calls, hasLength(expectedCalls.length));
      for (var index = 0; index < expectedCalls.length; index++) {
        expect(calls[index].$1, expectedCalls[index].$1);
        expect(calls[index].$2, expectedCalls[index].$2);
        expect(calls[index].$3, expectedCalls[index].$3);
      }
      expect(messages, [
        'Verifying $profile in $workspace',
        'Verified $profile: analysis, tests, 100% coverage, web build.',
      ]);
    });
  }

  test(
      'no arguments uses full with real script, temporary directory and stdout',
      () async {
    final output = _Stdout();
    final calls = <(String, List<String>, String)>[];
    Directory? generated;
    try {
      await IOOverrides.runZoned(() async {
        await verifier.main([],
            runProcess: (executable, arguments, directory) async {
          calls.add((executable, arguments, directory));
          if (calls.length == 1) {
            generated = Directory(arguments.last);
            expect(generated!.existsSync(), isTrue);
            expect(p.basename(generated!.path), startsWith('nonstop-verify-'));
            expect(directory,
                p.dirname(p.dirname(File.fromUri(Platform.script).path)));
          }
          return 0;
        });
      }, stdout: () => output);
      expect(calls, hasLength(4));
      expect(calls.first.$2.sublist(5, 14), [
        for (final module in modules) '--$module',
      ]);
      expect(generated!.existsSync(), isTrue,
          reason: 'The workspace remains available for diagnosis.');
      verify(() => output.writeln(
              'Verifying full in ${p.join(generated!.path, 'verified_app')}'))
          .called(1);
      verify(() => output.writeln(
              'Verified full: analysis, tests, 100% coverage, web build.'))
          .called(1);
    } finally {
      if (generated != null) await generated!.delete(recursive: true);
    }
  });

  for (final arguments in [
    ['unknown'],
    ['full', 'minimal'],
  ]) {
    test('rejects $arguments before filesystem or process work', () async {
      var sideEffects = 0;
      await expectLater(
        verifier.main(
          arguments,
          createTemporaryDirectory: (_) async {
            sideEffects++;
            return root;
          },
          writeLine: (_) => sideEffects++,
          runProcess: (_, __, ___) async {
            sideEffects++;
            return 0;
          },
        ),
        arguments.length == 1 ? throwsArgumentError : throwsStateError,
      );
      expect(sideEffects, 0);
    });
  }

  for (var failedStep = 0; failedStep < 4; failedStep++) {
    test(
        'failure at step $failedStep stops later steps and retains diagnostics',
        () async {
      final calls = <(String, List<String>, String)>[];
      final messages = <String>[];
      await expectLater(
        verifier.main(
          ['minimal'],
          createTemporaryDirectory: (_) async => root,
          writeLine: messages.add,
          runProcess: (executable, arguments, directory) async {
            calls.add((executable, arguments, directory));
            return calls.length == failedStep + 1 ? 37 : 0;
          },
        ),
        throwsA(isA<ProcessException>()
            .having((error) => error.errorCode, 'errorCode', 37)
            .having((error) => error.executable, 'executable',
                failedStep == 3 ? 'flutter' : 'dart')
            .having((error) => error.arguments, 'arguments',
                predicate<List<String>>((args) => args == calls.last.$2))
            .having(
                (error) => error.message,
                'message',
                predicate<String>((message) =>
                    message == 'Verification failed in ${calls.last.$3}'))),
      );
      expect(calls, hasLength(failedStep + 1));
      expect(messages, hasLength(1));
      expect(messages.single, startsWith('Verifying minimal in '));
      expect(root.existsSync(), isTrue);
    });
  }

  test('process launch errors propagate without reporting verification success',
      () async {
    final failure = ProcessException('dart', [], 'Cannot start');
    final messages = <String>[];
    var calls = 0;
    await expectLater(
      verifier.main(
        ['default'],
        createTemporaryDirectory: (_) async => root,
        writeLine: messages.add,
        runProcess: (_, __, ___) async {
          calls++;
          throw failure;
        },
      ),
      throwsA(same(failure)),
    );
    expect(calls, 1);
    expect(messages, hasLength(1));
  });

  test('real process adapter passes arguments, working directory and exit code',
      () async {
    final script = File(p.join(root.path, 'probe.dart'));
    await script.writeAsString('''
import 'dart:io';
void main(List<String> args) {
  File('result.txt').writeAsStringSync(args.single);
  exitCode = 37;
}
''');
    final result = await verifier.runInheritedProcess(
        Platform.resolvedExecutable,
        [script.path, 'argument with spaces'],
        root.path);
    expect(result, 37);
    expect(await File(p.join(root.path, 'result.txt')).readAsString(),
        'argument with spaces');
  });
}
