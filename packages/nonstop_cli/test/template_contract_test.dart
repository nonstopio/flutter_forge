import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:mason/mason.dart';
import 'package:nonstop_cli/commands/create/flutter_project_with_mono_repo_bundle.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../bricks/flutter_project_with_mono_repo/hooks/commands/module_vars.dart';

class _Context implements HookContext {
  _Context(this.vars);
  @override
  Map<String, dynamic> vars;
  @override
  final Logger logger = Logger(level: Level.quiet);
}

class _MemoryTarget extends GeneratorTarget {
  final files = <String, List<int>>{};
  @override
  Future<GeneratedFile> createFile(
    String name,
    List<int> contents, {
    Logger? logger,
    OverwriteRule? overwriteRule,
  }) async {
    files[path.posix.normalize(name.replaceAll(r'\', '/'))] = contents;
    return GeneratedFile.created(path: name);
  }
}

void main() {
  test('bundled template files exactly match the reviewed brick source', () {
    const brick = 'bricks/flutter_project_with_mono_repo/__brick__';
    final expected = Directory(brick)
        .listSync(recursive: true)
        .whereType<File>()
        .map((file) => path.relative(file.path, from: brick))
        .toSet();
    final bundled = flutterProjectWithMonoRepoBundle.files;
    expect(bundled.map((file) => file.path).toSet(), expected);
    for (final file in bundled) {
      expect(base64Decode(file.data),
          File(path.join(brick, file.path)).readAsBytesSync(),
          reason: file.path);
    }
  });

  test('bundled hooks exactly match the reviewed hook source', () {
    const root = 'bricks/flutter_project_with_mono_repo/hooks';
    final expected = Directory(root)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) =>
            !path.split(path.relative(file.path, from: root)).any((part) =>
                ['test', 'coverage', '.dart_tool', 'build'].contains(part)) &&
            (file.path.endsWith('.dart') ||
                path.basename(file.path) == 'pubspec.yaml'))
        .map((file) => path.relative(file.path, from: root))
        .toSet();
    final bundled = flutterProjectWithMonoRepoBundle.hooks;
    expect(bundled.map((file) => file.path).toSet(), expected);
    for (final file in bundled) {
      final source = File(path.join(root, file.path));
      final expectedBytes = file.path == 'pubspec.yaml'
          ? utf8.encode(source.readAsStringSync().replaceAll(
              RegExp(r'^resolution:\s*workspace\s*$', multiLine: true), ''))
          : source.readAsBytesSync();
      expect(base64Decode(file.data), expectedBytes, reason: file.path);
    }
  });

  test(
      'all 512 module selections render parseable Dart with no disabled-module imports',
      () async {
    // Rendering is pure here: Flutter scaffolding and dependency installation
    // are exercised by the end-to-end generation job, not by unit tests.
    final bundle = flutterProjectWithMonoRepoBundle;
    final generator = MasonGenerator(bundle.name, bundle.description, files: [
      for (final file in bundle.files)
        TemplateFile.fromBytes(file.path, base64Decode(file.data)),
    ]);
    final modules = [...optionalModules, 'firestore'];
    for (var mask = 0; mask < 1 << modules.length; mask++) {
      final context = _Context({
        'name': 'contract_app',
        'description': 'A contract test',
        'org_name': 'com.example',
        for (var i = 0; i < modules.length; i++)
          modules[i]: mask & (1 << i) != 0,
      });
      resolveModuleVars(context);
      final target = _MemoryTarget();
      await generator.generate(target,
          vars: context.vars, logger: context.logger);
      expect(
          target.files.containsKey(
              'contract_app/apps/contract_app/test/entrypoint_test.dart'),
          isTrue,
          reason: 'mask $mask');
      expect(
          target.files.containsKey('contract_app/tool/coverage.dart'), isTrue);
      final manifests = {
        for (final entry in target.files.entries
            .where((entry) => entry.key.endsWith('/pubspec.yaml')))
          entry.key: loadYaml(utf8.decode(entry.value)) as YamlMap,
      };
      final workspace = manifests['contract_app/pubspec.yaml']!;
      expect(workspace['melos'], isA<YamlMap>());
      final members = (workspace['workspace'] as YamlList).cast<String>();
      expect(
        members.toSet(),
        manifests.keys
            .where((file) => file != 'contract_app/pubspec.yaml')
            .map((file) => path.posix
                .relative(path.posix.dirname(file), from: 'contract_app'))
            .toSet(),
        reason: 'mask $mask: workspace members must match generated packages',
      );
      for (final member in members) {
        expect(manifests['contract_app/$member/pubspec.yaml']!['resolution'],
            'workspace',
            reason: '$member, mask $mask');
      }
      for (final entry in target.files.entries
          .where((entry) => entry.key.endsWith('.dart'))) {
        final source = utf8.decode(entry.value);
        expect(source, isNot(contains('{{')),
            reason: '${entry.key}, mask $mask: unresolved template');
        final parsed = parseString(
          content: source,
          // Parse the language version promised by the generated workspace,
          // rather than unreleased language experiments in a newer analyzer.
          featureSet: FeatureSet.latestLanguageVersion()
              .restrictToVersion(Version(3, 8, 0)),
          throwIfDiagnostics: false,
        );
        expect(parsed.errors, isEmpty, reason: '${entry.key}, mask $mask');
        for (final directive
            in parsed.unit.directives.whereType<UriBasedDirective>()) {
          final uri = directive.uri.stringValue;
          if (uri == null || !uri.startsWith('package:')) continue;
          final importedPackage =
              uri.substring('package:'.length).split('/').first;
          if (optionalModules.contains(importedPackage)) {
            expect(context.vars[importedPackage], isTrue,
                reason:
                    '${entry.key}, mask $mask imports disabled $importedPackage');
          }
        }
      }
    }
    stdout.writeln('Validated ${1 << modules.length} module selections.');
  }, timeout: const Timeout(Duration(minutes: 5)));
}
