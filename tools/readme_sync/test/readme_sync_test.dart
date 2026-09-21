import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../readme_sync.dart' as cli;

const markerWarning =
    'auto-generated, do not edit. Run `melos sync:readme` to update';

Future<List<String>> capture(Future<void> Function() action) async {
  final messages = <String>[];
  await runZoned(action,
      zoneSpecification: ZoneSpecification(print: (_, __, ___, message) {
    messages.add(message);
  }));
  return messages;
}

void main() {
  late Directory root;
  late String scriptDir;

  Future<void> write(String relative, String content) async {
    final file = File(path.join(root.path, relative));
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }

  String packageYaml(String name, {String sections = '[header]'}) => '''
  - name: $name
    path: packages/$name
    repo_path: packages/$name
    import_path: $name/$name.dart
    author_name: Test Author
    github_username: test-author
    sections: $sections
''';

  Future<void> configure({String? packages}) async {
    await write('tools/readme_sync/templates/sections.yaml', '''
sections:
  header:
    content: |
      # {{package_name}}
      {{repo_path}} {{import_path}} {{author_name}} {{github_username}}
    variables: [package_name, author_name]
  footer:
    content: Footer
''');
    await write('tools/readme_sync/config/packages.yaml',
        packages ?? 'packages:\n${packageYaml('demo')}');
  }

  Future<int> run(List<String> args) =>
      cli.runReadmeSync(args, scriptDir: scriptDir);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('readme_sync_test_');
    scriptDir = path.join(root.path, 'tools/readme_sync');
    await Directory(path.join(root.path, '.git')).create();
    await Directory(scriptDir).create(recursive: true);
  });

  tearDown(() async {
    await root.delete(recursive: true);
  });

  test('flags, aliases, missing values, and default script directory parse',
      () {
    final flags = cli.Config.fromArgs([
      '--dry-run',
      '--verbose',
      '--validate',
      '--add-markers',
      '--package',
      'demo',
      '--help',
    ], scriptDir: scriptDir);
    expect(flags.dryRun, isTrue);
    expect(flags.verbose, isTrue);
    expect(flags.validate, isTrue);
    expect(flags.addMarkers, isTrue);
    expect(flags.specificPackage, 'demo');
    expect(flags.showHelp, isTrue);
    expect(flags.scriptDir, scriptDir);
    final short = cli.Config.fromArgs(['-d', '-v', '-h']);
    expect(short.dryRun && short.verbose && short.showHelp, isTrue);
    expect(short.scriptDir, path.dirname(Platform.script.toFilePath()));
    expect(cli.Config.fromArgs(['--package']).specificPackage, isNull);
    expect(cli.Config.fromArgs([]).validate, isFalse);
  });

  test('entry point prints help without touching repository content', () async {
    final oldExitCode = exitCode;
    addTearDown(() => exitCode = oldExitCode);
    final messages = await capture(() => cli.main(['--help']));
    expect(exitCode, 0);
    expect(messages.single, contains('README Sync Tool'));
    expect(messages.single, contains('--dry-run'));
  });

  test('missing repository and configuration failures report a failing status',
      () async {
    await Directory(path.join(root.path, '.git')).delete();
    var messages = await capture(() async => expect(await run([]), 1));
    expect(messages.single, contains('Could not find git repository root'));
    await Directory(path.join(root.path, '.git')).create();
    messages = await capture(() async => expect(await run(['--verbose']), 1));
    expect(messages.join('\n'), contains('Templates file not found'));
    expect(messages.last, contains('_loadConfigurations'));
    await configure();
    await File(path.join(scriptDir, 'config/packages.yaml')).delete();
    messages = await capture(() async => expect(await run([]), 1));
    expect(messages.join('\n'), contains('Packages config file not found'));
  });

  test('sync renders variables, preserves unmanaged text, and is idempotent',
      () async {
    await configure();
    await write('packages/demo/README.md',
        'Before\n<!-- BEGIN:header -->\nstale\n<!-- END:header -->\nAfter\n');
    final file = File(path.join(root.path, 'packages/demo/README.md'));
    var messages = await capture(() async => expect(await run(['-v']), 0));
    final expected = 'Before\n<!-- BEGIN:header — $markerWarning -->\n'
        '# demo\npackages/demo demo/demo.dart Test Author test-author\n'
        '<!-- END:header -->\nAfter\n';
    expect(await file.readAsString(), expected);
    expect(File('${file.path}.bak').existsSync(), isFalse);
    expect(messages.join('\n'), contains('Loaded 2 section templates'));
    expect(messages.join('\n'), contains('Updated: header'));
    messages = await capture(() async => expect(await run([]), 0));
    expect(await file.readAsString(), expected);
    expect(messages.join('\n'), contains('No changes needed'));
  });

  test('dry run previews changes without creating a backup or editing files',
      () async {
    await configure();
    const original = '<!-- BEGIN:header -->old<!-- END:header -->';
    await write('packages/demo/README.md', original);
    final messages = await capture(() async => expect(await run(['-d']), 0));
    final file = File(path.join(root.path, 'packages/demo/README.md'));
    expect(await file.readAsString(), original);
    expect(File('${file.path}.bak').existsSync(), isFalse);
    expect(messages.join('\n'), contains('Would update README'));
    expect(messages.join('\n'), contains('Dry run completed'));
  });

  test('package filtering includes plugins and rejects unknown names',
      () async {
    await configure(
        packages: 'packages:\n${packageYaml('demo')}'
            'plugins:\n${packageYaml('plugin')}');
    await write('packages/plugin/README.md',
        '<!-- BEGIN:header -->old<!-- END:header -->');
    var messages = await capture(
        () async => expect(await run(['--package', 'plugin']), 0));
    expect(messages.join('\n'), contains('Processing 1 package'));
    expect(messages.join('\n'), isNot(contains('README.md not found')));
    expect(
        await File(path.join(root.path, 'packages/plugin/README.md'))
            .readAsString(),
        contains('# plugin'));
    messages = await capture(
        () async => expect(await run(['--package', 'unknown']), 1));
    expect(messages.last, contains('Package "unknown" not found'));
  });

  test('sync reports missing files, missing markers, and unknown templates',
      () async {
    await configure(
        packages: 'packages:\n${packageYaml('missing')}'
            '${packageYaml('demo', sections: '[header, unknown]')}');
    await write('packages/demo/README.md', 'Unmanaged content');
    final messages = await capture(() async => expect(await run([]), 0));
    expect(messages.join('\n'), contains('Error processing missing'));
    expect(messages.join('\n'), contains('Missing markers for: header'));
    expect(messages.join('\n'), contains('Unknown section: unknown'));
    expect(messages.join('\n'), contains('Errors: 1'));
    expect(
        await File(path.join(root.path, 'packages/demo/README.md'))
            .readAsString(),
        'Unmanaged content');
  });

  test('validation reports missing files and incomplete marker pairs',
      () async {
    await configure(
        packages: 'packages:\n${packageYaml('missing')}'
            '${packageYaml('demo', sections: '[header, footer]')}');
    await write('packages/demo/README.md', '<!-- BEGIN:header -->');
    final messages =
        await capture(() async => expect(await run(['--validate']), 0));
    expect(messages.join('\n'), contains('missing: README.md not found'));
    expect(messages.join('\n'), contains('Missing markers for: header'));
    expect(messages.join('\n'), contains('Missing markers for: footer'));
    expect(messages.join('\n'), contains('Validation found 3 issue(s)'));
  });

  test('validation accepts managed sections and add-markers provides guidance',
      () async {
    await configure(
        packages: 'plugins:\n${packageYaml('demo')}${packageYaml('missing')}');
    await write('packages/demo/README.md',
        '<!-- BEGIN:header -->old<!-- END:header -->');
    var messages = await capture(
        () async => expect(await run(['--validate', '--package', 'demo']), 0));
    expect(messages.join('\n'), contains('demo: All markers present'));
    expect(messages.join('\n'), contains('Validation passed'));
    messages =
        await capture(() async => expect(await run(['--add-markers']), 0));
    expect(messages.join('\n'), contains('Manual intervention required'));
    expect(messages.join('\n'), contains('Sections needed: header'));
    expect(messages.join('\n'), contains('missing: README.md not found'));
    expect(messages.join('\n'), contains('<!-- END:section-id -->'));
  });

  test('package configuration resolves paths and preserves metadata', () {
    final yaml = (loadYaml('packages:\n${packageYaml('demo')}')
        as YamlMap)['packages'] as YamlList;
    final config = cli.PackageConfig.fromYaml(yaml.first as YamlMap, root.path);
    expect(config.name, 'demo');
    expect(config.relativePath, 'packages/demo');
    expect(config.fullPath, path.join(root.path, 'packages/demo'));
    expect(config.repoPath, 'packages/demo');
    expect(config.importPath, 'demo/demo.dart');
    expect(config.authorName, 'Test Author');
    expect(config.githubUsername, 'test-author');
    expect(config.sections, ['header']);
  });
}
