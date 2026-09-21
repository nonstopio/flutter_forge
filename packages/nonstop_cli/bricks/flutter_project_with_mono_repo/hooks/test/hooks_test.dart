import 'dart:io';

import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../commands/checked_process.dart';
import '../commands/flutter_create_command.dart';
import '../commands/format_command.dart';
import '../commands/melos_command.dart';
import '../commands/module_vars.dart';
import '../commands/next_steps_command.dart';
import '../post_gen.dart' as post;
import '../pre_gen.dart' as pre;

class _Context extends Mock implements HookContext {}

class _Logger extends Mock implements Logger {}

class _Progress extends Mock implements Progress {}

void main() {
  late _Context context;
  late _Logger logger;
  late _Progress progress;
  late Map<String, dynamic> variables;
  late Directory temporary;
  late Directory original;

  setUp(() async {
    context = _Context();
    logger = _Logger();
    progress = _Progress();
    variables = {'name': 'Sample App', 'description': 'An example'};
    when(() => context.vars).thenReturn(variables);
    when(() => context.logger).thenReturn(logger);
    when(() => logger.progress(any())).thenReturn(progress);
    temporary = await Directory.systemTemp.createTemp('mono_hook_');
    original = Directory.current;
    Directory.current = temporary;
  });

  tearDown(() async {
    Directory.current = original;
    await temporary.delete(recursive: true);
  });

  test('default commands use the system process runner', () {
    expect(FlutterCreateCommand().runProcess, Process.run);
    expect(FormatCommand().runProcess, Process.run);
    expect(MelosCommand().runProcess, Process.run);
  });

  group('checked process', () {
    test('waits for success before completing progress', () async {
      var ran = false;
      await runChecked(
        context,
        startMessage: 'Start',
        endMessage: 'Done',
        executable: 'example',
        arguments: ['--flag'],
        workingDirectory: 'workspace',
        runProcess: (executable, arguments,
            {workingDirectory, runInShell = false}) async {
          expect(executable, 'example');
          expect(arguments, ['--flag']);
          expect(workingDirectory, 'workspace');
          expect(runInShell, isTrue);
          verifyNever(() => progress.complete(any()));
          ran = true;
          return ProcessResult(1, 0, 'success', '');
        },
      );
      expect(ran, isTrue);
      verify(() => progress.complete('Done')).called(1);
      verifyNever(() => progress.fail(any()));
    });

    test('process launch failures fail progress and retain original exception',
        () async {
      final error = ProcessException('missing', [], 'missing executable');
      await expectLater(
          runChecked(
            context,
            startMessage: 'Start',
            endMessage: 'Done',
            executable: 'missing',
            arguments: [],
            runProcess: (_, __, {workingDirectory, runInShell = false}) async =>
                throw error,
          ),
          throwsA(same(error)));
      verify(() => progress.fail('Start failed: $error')).called(1);
      verifyNever(() => progress.complete(any()));
    });

    for (final output in [
      ('stdout detail', '  stderr detail  ', 'stderr detail'),
      ('  stdout detail  ', '   ', 'stdout detail'),
      ('', '', ''),
    ]) {
      test('nonzero exits surface available output ${output.$3}', () async {
        await expectLater(
            runChecked(
              context,
              startMessage: 'Start',
              endMessage: 'Done',
              executable: 'example',
              arguments: ['--flag'],
              runProcess: (_, __,
                      {workingDirectory, runInShell = false}) async =>
                  ProcessResult(1, 9, output.$1, output.$2),
            ),
            throwsA(isA<ProcessException>()
                .having((e) => e.executable, 'executable', 'example')
                .having((e) => e.arguments, 'arguments', ['--flag']).having(
                    (e) => e.errorCode, 'exit', 9)));
        verify(() => progress.fail('Start failed (exit 9)')).called(1);
        verifyNever(() => progress.complete(any()));
        if (output.$3.isNotEmpty) {
          verify(() => logger.err(output.$3)).called(1);
        } else {
          verifyNever(() => logger.err(any()));
        }
      });
    }
  });

  test(
      'pre-generation detects workspace, resolves modules and removes obsolete scaffold',
      () async {
    await File('pubspec.yaml').writeAsString('name: parent\nworkspace: []\n');
    variables.addAll(
        {'org_name': 'io.nonstop', 'notifications': true, 'developer': true});
    await pre.run(context, runProcess: (executable, arguments,
        {workingDirectory, runInShell = false}) async {
      expect(variables['is_mono_repo'], isTrue);
      expect(variables['network_dir'], 'network');
      expect(variables['feature_flags_dir'], 'feature_flags');
      expect(executable, 'flutter');
      expect(arguments, [
        'create',
        'sample_app',
        '--template=app',
        '--platforms=ios,android,web',
        '--description=An example',
        '--org=io.nonstop'
      ]);
      expect(workingDirectory, 'sample_app/apps');
      expect(await Directory(workingDirectory!).exists(), isTrue);
      await Directory('sample_app/apps/sample_app/test')
          .create(recursive: true);
      await File('sample_app/apps/sample_app/analysis_options.yaml')
          .writeAsString('old lints');
      await File('sample_app/apps/sample_app/test/widget_test.dart')
          .writeAsString('old test');
      return ProcessResult(1, 0, '', '');
    });
    expect(
        await File('sample_app/apps/sample_app/analysis_options.yaml').exists(),
        isFalse);
    expect(
        await Directory('sample_app/apps/sample_app/test').exists(), isFalse);
    verify(() => progress.complete('Flutter app created')).called(1);
  });

  test(
      'Flutter creation defaults organization and preserves non-scaffold tests',
      () async {
    final command = FlutterCreateCommand(runProcess: (executable, arguments,
        {workingDirectory, runInShell = false}) async {
      expect(arguments.last, '--org=com.example');
      await Directory('sample_app/apps/sample_app/test')
          .create(recursive: true);
      await File('sample_app/apps/sample_app/test/custom_test.dart')
          .writeAsString('keep');
      return ProcessResult(1, 0, '', '');
    });
    await command.run(context);
    expect(
        await File('sample_app/apps/sample_app/test/custom_test.dart')
            .readAsString(),
        'keep');
  });

  test('Flutter creation tolerates a scaffold with no test directory',
      () async {
    await FlutterCreateCommand(
        runProcess: (_, __, {workingDirectory, runInShell = false}) async =>
            ProcessResult(1, 0, '', '')).run(context);
    expect(await Directory('sample_app/apps').exists(), isTrue);
  });

  test('post-generation bootstraps before formatting and prints setup guidance',
      () async {
    variables['firebase'] = true;
    final calls = <List<Object?>>[];
    await post.run(context, runProcess: (executable, arguments,
        {workingDirectory, runInShell = false}) async {
      calls.add([executable, arguments, workingDirectory, runInShell]);
      return ProcessResult(1, 0, '', '');
    });
    expect(calls, [
      [
        'dart',
        ['pub', 'get'],
        'sample_app',
        true
      ],
      [
        'dart',
        ['run', 'melos', 'bootstrap'],
        'sample_app',
        true
      ],
      [
        'dart',
        ['format', '.'],
        'sample_app',
        true
      ],
    ]);
    verify(() =>
            logger.warn('Firebase modules are enabled but not configured yet.'))
        .called(1);
    verify(() => logger.info(
        '  cd sample_app/apps/sample_app && flutterfire configure')).called(1);
    verify(() => logger.info('  dart run melos run coverage')).called(1);
    verify(() => logger.info('  cd sample_app/apps/sample_app && flutter run'))
        .called(1);
  });

  test('failed dependency setup prevents formatting and next steps', () async {
    final calls = <String>[];
    await expectLater(
        post.run(context, runProcess: (executable, arguments,
            {workingDirectory, runInShell = false}) async {
          calls.add(arguments.first);
          return ProcessResult(1, 1, '', 'dependency resolution failed');
        }),
        throwsA(isA<ProcessException>()));
    expect(calls, ['pub']);
    verifyNever(() => logger.info(any()));
  });

  test('next steps omit Firebase setup when no Firebase modules are enabled',
      () async {
    await NextStepsCommand().run(context);
    verifyNever(() => logger.warn(any()));
    verify(() => logger.info('Verify the workspace (from sample_app):'))
        .called(1);
    verify(() => logger.info('  dart run melos run lint')).called(1);
  });

  group('module variables', () {
    test('missing flags disable all optional modules and Firebase files', () {
      resolveModuleVars(context);
      for (final module in optionalModules) {
        expect(variables[module], isFalse);
        expect(variables['${module}_dir'], '');
      }
      for (final flag in [
        'firestore',
        'firebase',
        'emulators',
        'firebase_sdk_mocks'
      ]) {
        expect(variables[flag], isFalse);
      }
      for (final file in [
        'firebase_options_file',
        'notification_lifecycle_file',
        'notification_lifecycle_test_file',
        'firebase_bootstrap_test_file',
        'auth_token_provider_test_file'
      ]) {
        expect(variables[file], '');
      }
    });

    test(
        'enabled modules derive required dependencies and generated file names',
        () {
      variables.addAll({for (final module in optionalModules) module: true});
      variables.addAll(
          {'network': false, 'feature_flags': false, 'firestore': true});
      resolveModuleVars(context);
      for (final module in optionalModules) {
        expect(variables[module], isTrue);
        expect(variables['${module}_dir'], module);
      }
      for (final flag in ['firebase', 'emulators', 'firebase_sdk_mocks']) {
        expect(variables[flag], isTrue);
      }
      expect(variables['firebase_options_file'], 'firebase_options.dart');
      expect(variables['notification_lifecycle_file'],
          'notification_lifecycle.dart');
      expect(variables['notification_lifecycle_test_file'],
          'notification_lifecycle_test.dart');
      expect(variables['firebase_bootstrap_test_file'],
          'firebase_bootstrap_test.dart');
      expect(variables['auth_token_provider_test_file'],
          'token_provider_test.dart');
    });

    test('Firestore alone needs Firebase and emulators without SDK mocks', () {
      variables['firestore'] = true;
      resolveModuleVars(context);
      expect(variables['firebase'], isTrue);
      expect(variables['emulators'], isTrue);
      expect(variables['firebase_sdk_mocks'], isFalse);
    });
  });
}
