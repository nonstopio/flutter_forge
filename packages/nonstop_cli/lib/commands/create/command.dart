import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
import 'package:nonstop_cli/commands/create/modules.dart';
import 'package:nonstop_cli/commands/create/templates.dart';
import 'package:nonstop_cli/template.dart';
import 'package:nonstop_cli/utils/utils.dart';
import 'package:path/path.dart' as path;

const _defaultOrgName = 'com.example';

/// Characters that cannot survive being written into a double-quoted YAML
/// scalar and a Dart string literal unchanged.
const _unsafeDescriptionCharacters = ['"', r'\', r'$'];
const _defaultDescription =
    'A Melos-managed project for mono-repo, created using NonStop CLI.';

class CreateCommand extends Command<int> {
  CreateCommand({
    required this.logger,
    @visibleForTesting MasonGeneratorFromBundle? generatorFromBundle,
    @visibleForTesting MasonGeneratorFromBrick? generatorFromBrick,
  })  : _generatorFromBundle = generatorFromBundle ?? MasonGenerator.fromBundle,
        _generatorFromBrick = generatorFromBrick ?? MasonGenerator.fromBrick {
    argParser
      ..addOption(
        'output-directory',
        abbr: 'o',
        help: 'The desired output directory when creating a new project.',
      )
      ..addOption(
        'description',
        help: 'The description for this new project.',
        aliases: ['desc'],
        defaultsTo: _defaultDescription,
      )
      ..addOption(
        'org-name',
        help: 'The organization for this new project.',
        defaultsTo: _defaultOrgName,
        aliases: ['org'],
      )
      ..addOption(
        'template',
        abbr: 't',
        help: 'Specify the type of project to create.',
        allowed: ['mono', 'package', 'app', 'plugin'],
        defaultsTo: 'mono',
        allowedHelp: {
          'mono':
              '(default) Generate a Flutter mono-repo structure for a Melos-managed project.',
          'package':
              'Generate a shareable Flutter package for a Melos-managed mono-repo.',
          'app':
              'Generate a Flutter application for a Melos-managed mono-repo.',
          'plugin': 'Generate a Flutter plugin for a Melos-managed mono-repo.',
        },
      )
      ..addFlag(
        'defaults',
        abbr: 'y',
        negatable: false,
        help: 'Skip the module picker and accept the recommended selection.',
      );

    for (final module in templateModules) {
      argParser.addFlag(
        module.flag,
        help: '${module.description}.',
        defaultsTo: null,
        hide: true,
      );
    }
  }

  final Logger logger;
  final MasonGeneratorFromBundle _generatorFromBundle;
  final MasonGeneratorFromBrick _generatorFromBrick;

  @override
  String get name => 'create';

  @override
  String get description =>
      'Create a new Flutter project within a Melos-managed mono-repo';

  Template get template {
    final templateType = argResults['template'] as String;
    switch (templateType) {
      case 'package':
        return FlutterPackageForMonoRepoTemplate();
      case 'app':
        return FlutterAppForMonoRepoTemplate();
      case 'plugin':
        return FlutterPluginForMonoRepoTemplate();
      case 'mono':
      default:
        return FlutterProjectWithMonoRepoTemplate();
    }
  }

  List<Template> templates = [
    FlutterProjectWithMonoRepoTemplate(),
    FlutterPackageForMonoRepoTemplate(),
    FlutterAppForMonoRepoTemplate(),
    FlutterPluginForMonoRepoTemplate(),
  ];

  @visibleForTesting
  ArgResults? argResultOverrides;

  Directory get outputDirectory {
    final directory = argResults['output-directory'] as String? ?? '.';
    return Directory(directory);
  }

  String get projectName {
    final args = argResults.rest;
    _validateProjectName(args);
    return args.first;
  }

  String get projectDescription {
    final description = _askIfUnset(
      'description',
      'Describe ${lightCyan.wrap(projectName)}:',
    );
    _validateDescription(description);
    return description;
  }

  /// The description is interpolated into YAML, Dart string literals and
  /// Markdown, so a few characters would produce a project that does not
  /// parse. Rejecting them beats silently mangling the text.
  void _validateDescription(String description) {
    final offending =
        _unsafeDescriptionCharacters.where(description.contains).toList();
    if (offending.isEmpty) return;

    usageException(
      'The description cannot contain ${offending.map((c) => '"$c"').join(', ')}.\n\n'
      'It is written into pubspec.yaml, Dart string literals and README.md, '
      'and these characters break at least one of them.',
    );
  }

  /// Whether this process can hold an interactive conversation.
  ///
  /// Both ends have to be a terminal: mason_logger reads from stdin but draws
  /// the prompt on stdout, and piping either one is enough to break it.
  bool get _canPrompt =>
      argResults['defaults'] != true && stdin.hasTerminal && stdout.hasTerminal;

  /// Returns [option], prompting for it when the user did not pass it and
  /// there is a terminal to ask on.
  ///
  /// Falling back to the option's default keeps scripted and CI runs working.
  String _askIfUnset(String option, String question) {
    final fallback = argResults[option] as String? ?? '';
    if (argResults.wasParsed(option) || !_canPrompt) return fallback;
    try {
      final answer = logger.prompt(question, defaultValue: fallback).trim();
      return answer.isEmpty ? fallback : answer;
    } catch (error) {
      // Some CI runners advertise a terminal they cannot actually drive.
      logger.detail('Prompt unavailable, using default: $error');
      return fallback;
    }
  }

  @override
  String get invocation => 'nonstop $name <project-name> [arguments]';

  @override
  ArgResults get argResults => argResultOverrides ?? super.argResults!;

  bool _isValidPackageName(String name) {
    final match = identifierRegExp.matchAsPrefix(name);
    return match != null && match.end == name.length;
  }

  void _validateProjectName(List<String> args) {
    logger.detail('Validating project name; args: $args');

    if (args.isEmpty) {
      usageException('No option specified for the project name.');
    }

    if (args.length > 1) {
      usageException('Multiple project names specified.');
    }

    final name = args.first;
    final isValidProjectName = _isValidPackageName(name);
    if (!isValidProjectName) {
      usageException(
        '"$name" is not a valid package name.\n\n'
        'See https://dart.dev/tools/pub/pubspec#name for more information.',
      );
    }
  }

  Future<MasonGenerator> _getGeneratorForTemplate() async {
    try {
      final brick = Brick.version(
        name: template.bundle.name,
        version: '^${template.bundle.version}',
      );
      logger.detail(
        '''Building generator from brick: ${brick.name} ${brick.location.version}''',
      );
      return await _generatorFromBrick(brick);
    } catch (error) {
      logger.detail('Building generator from brick failed: $error');
    }
    logger.detail(
      '''Building generator from bundle ${template.bundle.name} ${template.bundle.version}''',
    );
    return _generatorFromBundle(template.bundle);
  }

  @override
  Future<int> run() async {
    logger.logSignature();
    final template = this.template;
    final generator = await _getGeneratorForTemplate();
    final result = await runCreate(generator, template);

    return result;
  }

  Future<int> runCreate(MasonGenerator generator, Template template) async {
    var vars = getTemplateVars();

    final target = DirectoryGeneratorTarget(outputDirectory);

    await generator.hooks.preGen(
      vars: vars,
      onVarsChanged: (v) => vars = v,
      workingDirectory: target.dir.path,
      logger: logger,
    );

    // The app skeleton is scaffolded by `flutter create` in the pre-gen hook,
    // so the brick's own `lib/` and `pubspec.yaml` are expected to land on top.
    final _ = await generator.generate(
      target,
      vars: vars,
      logger: logger,
      fileConflictResolution: FileConflictResolution.overwrite,
    );

    await generator.hooks.postGen(
      vars: vars,
      onVarsChanged: (v) => vars = v,
      workingDirectory: target.dir.path,
      logger: logger,
    );

    await template.onGenerateComplete(
      logger,
      Directory(path.join(target.dir.path, projectName)),
    );

    return ExitCode.success.code;
  }

  Map<String, dynamic> getTemplateVars() {
    final projectName = this.projectName;
    final projectDescription = this.projectDescription;

    return <String, dynamic>{
      'name': projectName,
      'description': projectDescription,
      'org_name': orgName,
      if (argResults['template'] == 'mono') ...selectedModules(),
    };
  }

  /// Resolves which optional modules the generated mono-repo should contain.
  ///
  /// Explicit `--network` / `--no-network` style flags always win. Whatever is
  /// left is asked for once, as a single multi-select, unless `--defaults` was
  /// passed or there is no terminal to ask on.
  @visibleForTesting
  Map<String, bool> selectedModules() {
    final answered = <String, bool>{
      for (final module in templateModules)
        if (argResults.wasParsed(module.flag))
          module.key: argResults[module.flag] as bool,
    };

    final shouldPrompt = answered.length < templateModules.length && _canPrompt;

    final selection = shouldPrompt ? _promptForModules(answered) : answered;

    final requested = <String, bool>{
      for (final module in templateModules)
        module.key: selection[module.key] ?? module.defaultValue,
    };
    final resolved = resolveModuleImplications(requested);

    for (final module in templateModules) {
      if (resolved[module.key]! && !requested[module.key]!) {
        logger.info(
          '${lightYellow.wrap('+')} ${module.label} is required by '
          '${module.impliedBy.where((o) => resolved[o]!).join(', ')}, '
          'adding it.',
        );
      }
    }

    return resolved;
  }

  Map<String, bool> _promptForModules(Map<String, bool> answered) {
    final pending = templateModules
        .where((module) => !answered.containsKey(module.key))
        .toList();

    logger.info('');
    final List<TemplateModule> chosen;
    try {
      chosen = logger.chooseAny<TemplateModule>(
        'Which modules should ${lightCyan.wrap(projectName)} start with?',
        choices: pending,
        defaultValues: pending.where((module) => module.defaultValue).toList(),
        display: (module) =>
            '${module.label} ${darkGray.wrap('- ${module.description}')}',
      );
    } catch (error) {
      // Some CI runners advertise a terminal they cannot actually drive.
      logger.detail('Module picker unavailable, using defaults: $error');
      return answered;
    }

    return {
      ...answered,
      for (final module in pending) module.key: chosen.contains(module),
    };
  }
}

extension on CreateCommand {
  String get orgName {
    final orgName = _askIfUnset(
      'org-name',
      'What is the organization for ${lightCyan.wrap(projectName)}?',
    );
    _validateOrgName(orgName);
    return orgName;
  }

  void _validateOrgName(String name) {
    logger.detail('Validating org name; $name');
    final isValidOrgName = _isValidOrgName(name);
    if (!isValidOrgName) {
      usageException(
        '"$name" is not a valid org name.\n\n'
        'A valid org name has at least 2 parts separated by "."\n'
        'Each part must start with a letter and only include '
        'alphanumeric characters (A-Z, a-z, 0-9), underscores (_), '
        'and hyphens (-)\n'
        '(ex. nonstopio.com)',
      );
    }
  }

  bool _isValidOrgName(String name) {
    return orgNameRegExp.hasMatch(name);
  }
}
