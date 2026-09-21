import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nonstop_cli/commands/create/command.dart';
import 'package:nonstop_cli/commands/create/modules.dart';
import 'package:nonstop_cli/commands/create/templates.dart';
import 'package:nonstop_cli/template.dart';
import 'package:test/test.dart';

class _Logger extends Mock implements Logger {}

class _Stdin extends Mock implements Stdin {}

class _Stdout extends Mock implements Stdout {}

class _Generator extends Mock implements MasonGenerator {}

class _Hooks extends Mock implements GeneratorHooks {}

class _Template extends Mock implements Template {}

T withTerminal<T>(T Function() body, {bool input = true, bool output = true}) {
  final stdin = _Stdin();
  final stdout = _Stdout();
  when(() => stdin.hasTerminal).thenReturn(input);
  when(() => stdout.hasTerminal).thenReturn(output);
  when(() => stdout.supportsAnsiEscapes).thenReturn(false);
  return IOOverrides.runZoned(body, stdin: () => stdin, stdout: () => stdout);
}

CreateCommand commandFor(Logger logger, List<String> arguments) {
  final command = CreateCommand(logger: logger);
  CommandRunner<int>('nonstop', 'test runner').addCommand(command);
  command.argResultOverrides = command.argParser.parse(arguments);
  return command;
}

void main() {
  setUpAll(() {
    registerFallbackValue(DirectoryGeneratorTarget(Directory('.')));
    registerFallbackValue(Directory('.'));
    registerFallbackValue(_Logger());
  });

  test('templates select the correct bundled project type', () {
    final logger = _Logger();
    final expected = <String, Type>{
      'mono': FlutterProjectWithMonoRepoTemplate,
      'package': FlutterPackageForMonoRepoTemplate,
      'app': FlutterAppForMonoRepoTemplate,
      'plugin': FlutterPluginForMonoRepoTemplate,
    };
    for (final entry in expected.entries) {
      final command = commandFor(logger, ['--template', entry.key, 'my_app']);
      expect(command.template.runtimeType, entry.value);
      expect(command.name, 'create');
      expect(command.invocation, 'nonstop create <project-name> [arguments]');
      expect(command.outputDirectory.path, '.');
    }
  });

  test('all templates show output directory and getting-started instructions',
      () async {
    final logger = _Logger();
    for (final template in CreateCommand(logger: logger).templates) {
      await template.onGenerateComplete(logger, Directory('output/my_app'));
      expect(template.help, isNotEmpty);
    }
    verify(() => logger.info(any(that: contains('output/my_app/README.md'))))
        .called(4);
    verify(() => logger.info(any(that: contains('Created a Flutter'))))
        .called(4);
  });

  group('input validation', () {
    for (final args in <List<String>>[
      [],
      ['first', 'second'],
      ['Invalid'],
      ['has-hyphen']
    ]) {
      test('rejects invalid project arguments $args', () {
        final command = commandFor(_Logger(), args);
        expect(() => command.projectName, throwsA(isA<UsageException>()));
      });
    }
    for (final character in ['"', r'\', r'$']) {
      test('rejects unsafe description character $character', () {
        final command = commandFor(
            _Logger(), ['--description', 'has $character', 'my_app']);
        expect(
            () => command.projectDescription, throwsA(isA<UsageException>()));
      });
    }
    test('rejects invalid organization name', () {
      final command =
          commandFor(_Logger(), ['--defaults', '--org', 'invalid', 'my_app']);
      expect(command.getTemplateVars, throwsA(isA<UsageException>()));
    });
    test('maps explicit arguments without prompting', () {
      final logger = _Logger();
      final command = commandFor(logger, [
        '--template',
        'app',
        '--description',
        'My application',
        '--org',
        'com.example',
        '--output-directory',
        'destination',
        'my_app',
      ]);
      expect(withTerminal(command.getTemplateVars), {
        'name': 'my_app',
        'description': 'My application',
        'org_name': 'com.example',
      });
      expect(command.outputDirectory.path, 'destination');
      verifyNever(
          () => logger.prompt(any(), defaultValue: any(named: 'defaultValue')));
    });
    test('uses defaults when either input or output is redirected', () {
      for (final input in [true, false]) {
        final logger = _Logger();
        final command = commandFor(logger, ['my_app']);
        final vars =
            withTerminal(command.getTemplateVars, input: input, output: !input);
        expect(vars['org_name'], 'com.example');
        expect(vars['description'], contains('Melos-managed project'));
        verifyNever(() =>
            logger.prompt(any(), defaultValue: any(named: 'defaultValue')));
      }
    });
  });

  group('interactive inputs', () {
    test('trims answers for description and organization', () {
      final logger = _Logger();
      when(() => logger.prompt(any(), defaultValue: any(named: 'defaultValue')))
          .thenAnswer((call) =>
              (call.positionalArguments.first as String).startsWith('Describe')
                  ? '  Our project  '
                  : '  io.nonstop  ');
      final command = commandFor(logger, ['--template', 'app', 'my_app']);
      expect(withTerminal(command.getTemplateVars), {
        'name': 'my_app',
        'description': 'Our project',
        'org_name': 'io.nonstop',
      });
    });
    test('empty answers retain defaults', () {
      final logger = _Logger();
      when(() => logger.prompt(any(), defaultValue: any(named: 'defaultValue')))
          .thenReturn('  ');
      final command = commandFor(logger, ['--template', 'app', 'my_app']);
      final vars = withTerminal(command.getTemplateVars);
      expect(vars['org_name'], 'com.example');
      expect(vars['description'], contains('Melos-managed project'));
    });
    test('failed prompts retain defaults and explain the fallback', () {
      final logger = _Logger();
      when(() => logger.prompt(any(), defaultValue: any(named: 'defaultValue')))
          .thenThrow(StateError('no tty'));
      final command = commandFor(logger, ['--template', 'app', 'my_app']);
      final vars = withTerminal(command.getTemplateVars);
      expect(vars['org_name'], 'com.example');
      verify(() => logger.detail(
          any(that: contains('Prompt unavailable, using default:')))).called(2);
    });
    test('module picker respects explicit choices and renders every label', () {
      final logger = _Logger();
      when(() => logger.chooseAny<TemplateModule>(
            any(),
            choices: any(named: 'choices'),
            defaultValues: any(named: 'defaultValues'),
            display: any(named: 'display'),
          )).thenAnswer((call) {
        final choices = call.namedArguments[#choices] as List<TemplateModule>;
        final defaults =
            call.namedArguments[#defaultValues] as List<TemplateModule>;
        final display =
            call.namedArguments[#display] as String Function(TemplateModule);
        expect(choices.map((m) => m.key), isNot(contains('auth')));
        expect(defaults.every((m) => m.defaultValue), isTrue);
        for (final module in choices) {
          expect(display(module), contains(module.label));
          expect(display(module), contains(module.description));
          expect(module.toString(), '${module.label} — ${module.description}');
        }
        return choices.where((m) => m.key == 'firestore').toList();
      });
      final command = commandFor(logger, ['--no-auth', 'my_app']);
      final modules = withTerminal(command.selectedModules);
      expect(modules['auth'], isFalse);
      expect(modules['firestore'], isTrue);
      expect(
          modules.entries
              .where((e) => e.key != 'firestore')
              .map((e) => e.value),
          everyElement(isFalse));
    });
    test('failed module picker retains explicit flags and recommended defaults',
        () {
      final logger = _Logger();
      when(() => logger.chooseAny<TemplateModule>(
            any(),
            choices: any(named: 'choices'),
            defaultValues: any(named: 'defaultValues'),
            display: any(named: 'display'),
          )).thenThrow(StateError('no tty'));
      final command = commandFor(logger, ['--no-auth', 'my_app']);
      final modules = withTerminal(command.selectedModules);
      expect(modules['auth'], isFalse);
      expect(modules['network'], isTrue);
      verify(() => logger.detail(any(
              that: contains('Module picker unavailable, using defaults:'))))
          .called(1);
    });
  });

  test(
      'generation passes updated variables through hooks and overwrites skeleton files',
      () async {
    final logger = _Logger();
    final generator = _Generator();
    final hooks = _Hooks();
    final template = _Template();
    final events = <String>[];
    when(() => generator.hooks).thenReturn(hooks);
    when(() => hooks.preGen(
        vars: any(named: 'vars'),
        onVarsChanged: any(named: 'onVarsChanged'),
        workingDirectory: any(named: 'workingDirectory'),
        logger: logger)).thenAnswer((call) async {
      events.add('pre');
      expect(call.namedArguments[#workingDirectory], 'destination');
      final vars = call.namedArguments[#vars] as Map<String, dynamic>;
      expect(vars['name'], 'my_app');
      (call.namedArguments[#onVarsChanged] as void Function(
          Map<String, dynamic>))({...vars, 'prepared': true});
    });
    when(() => generator.generate(any(),
            vars: any(named: 'vars'),
            logger: logger,
            fileConflictResolution: FileConflictResolution.overwrite))
        .thenAnswer((call) async {
      events.add('generate');
      expect(
          (call.positionalArguments.first as DirectoryGeneratorTarget).dir.path,
          'destination');
      expect((call.namedArguments[#vars] as Map)['prepared'], isTrue);
      return [];
    });
    when(() => hooks.postGen(
        vars: any(named: 'vars'),
        onVarsChanged: any(named: 'onVarsChanged'),
        workingDirectory: any(named: 'workingDirectory'),
        logger: logger)).thenAnswer((call) async {
      events.add('post');
      final vars = call.namedArguments[#vars] as Map<String, dynamic>;
      expect(vars['prepared'], isTrue);
      (call.namedArguments[#onVarsChanged] as void Function(
          Map<String, dynamic>))({...vars, 'finished': true});
    });
    when(() => template.onGenerateComplete(logger, any()))
        .thenAnswer((call) async {
      events.add('summary');
      expect((call.positionalArguments[1] as Directory).path,
          'destination/my_app');
    });
    final command =
        commandFor(logger, ['--defaults', '-o', 'destination', 'my_app']);
    expect(await command.runCreate(generator, template), 0);
    expect(events, ['pre', 'generate', 'post', 'summary']);
    final running = CreateCommand(
        logger: logger, generatorFromBundle: (_) async => generator);
    running.argResultOverrides =
        running.argParser.parse(['--defaults', '-o', 'destination', 'my_app']);
    expect(await running.run(), 0);
    expect(events.skip(4), ['pre', 'generate', 'post']);
    verify(() => logger.info(any(that: contains('Created a Flutter project'))))
        .called(1);
  });
}
