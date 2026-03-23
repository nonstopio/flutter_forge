#!/usr/bin/env dart

import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

/// README Sync Tool
///
/// Synchronizes standardized sections across all package READMEs.
/// Uses HTML comment markers to identify managed sections.

void main(List<String> args) async {
  final config = Config.fromArgs(args);

  if (config.showHelp) {
    printHelp();
    exit(0);
  }

  final syncer = ReadmeSyncer(config);

  try {
    await syncer.run();
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    if (config.verbose) {
      print(stackTrace);
    }
    exit(1);
  }
}

class Config {
  final bool dryRun;
  final bool verbose;
  final bool validate;
  final bool addMarkers;
  final String? specificPackage;
  final bool showHelp;
  final String scriptDir;

  Config({
    required this.dryRun,
    required this.verbose,
    required this.validate,
    required this.addMarkers,
    required this.specificPackage,
    required this.showHelp,
    required this.scriptDir,
  });

  factory Config.fromArgs(List<String> args) {
    final scriptPath = Platform.script.toFilePath();
    final scriptDir = path.dirname(scriptPath);

    return Config(
      dryRun: args.contains('--dry-run') || args.contains('-d'),
      verbose: args.contains('--verbose') || args.contains('-v'),
      validate: args.contains('--validate'),
      addMarkers: args.contains('--add-markers'),
      specificPackage: _extractPackageName(args),
      showHelp: args.contains('--help') || args.contains('-h'),
      scriptDir: scriptDir,
    );
  }

  static String? _extractPackageName(List<String> args) {
    final packageIndex = args.indexOf('--package');
    if (packageIndex != -1 && packageIndex + 1 < args.length) {
      return args[packageIndex + 1];
    }
    return null;
  }
}

class ReadmeSyncer {
  final Config config;
  late final Map<String, SectionTemplate> sections;
  late final List<PackageConfig> packages;
  final String repoRoot;

  ReadmeSyncer(this.config) : repoRoot = _findRepoRoot(config.scriptDir);

  static String _findRepoRoot(String scriptDir) {
    var current = Directory(scriptDir);
    while (current.path != current.parent.path) {
      if (Directory(path.join(current.path, '.git')).existsSync()) {
        return current.path;
      }
      current = current.parent;
    }
    throw Exception('Could not find git repository root');
  }

  Future<void> run() async {
    print('🔧 README Sync Tool');
    print('━' * 50);

    // Load configurations
    await _loadConfigurations();

    // Filter packages if specific package requested
    var packagesToProcess = packages;
    if (config.specificPackage != null) {
      packagesToProcess = packages
          .where((p) => p.name == config.specificPackage)
          .toList();

      if (packagesToProcess.isEmpty) {
        throw Exception('Package "${config.specificPackage}" not found in configuration');
      }
    }

    print('📦 Processing ${packagesToProcess.length} package(s)...\n');

    if (config.validate) {
      await _validatePackages(packagesToProcess);
      return;
    }

    if (config.addMarkers) {
      await _addMarkersToPackages(packagesToProcess);
      return;
    }

    // Sync packages
    var successCount = 0;
    var errorCount = 0;

    for (final package in packagesToProcess) {
      try {
        await _syncPackage(package);
        successCount++;
      } catch (e) {
        print('❌ Error processing ${package.name}: $e');
        errorCount++;
      }
    }

    print('\n' + '━' * 50);
    if (config.dryRun) {
      print('🔍 Dry run completed (no files modified)');
    } else {
      print('✅ Sync completed');
    }
    print('   Successful: $successCount');
    if (errorCount > 0) {
      print('   Errors: $errorCount');
    }
  }

  Future<void> _loadConfigurations() async {
    // Load section templates
    final sectionsFile = File(path.join(config.scriptDir, 'templates', 'sections.yaml'));
    if (!sectionsFile.existsSync()) {
      throw Exception('Templates file not found: ${sectionsFile.path}');
    }

    final sectionsYaml = loadYaml(await sectionsFile.readAsString()) as YamlMap;
    sections = {};

    final sectionsMap = sectionsYaml['sections'] as YamlMap;
    for (final entry in sectionsMap.entries) {
      final id = entry.key as String;
      final data = entry.value as YamlMap;
      sections[id] = SectionTemplate(
        id: id,
        content: (data['content'] as String).trim(),
        variables: (data['variables'] as YamlList?)?.map((e) => e as String).toList() ?? [],
      );
    }

    // Load package configurations
    final packagesFile = File(path.join(config.scriptDir, 'config', 'packages.yaml'));
    if (!packagesFile.existsSync()) {
      throw Exception('Packages config file not found: ${packagesFile.path}');
    }

    final packagesYaml = loadYaml(await packagesFile.readAsString()) as YamlMap;
    packages = [];

    // Load packages
    if (packagesYaml.containsKey('packages')) {
      final packagesList = packagesYaml['packages'] as YamlList;
      for (final item in packagesList) {
        packages.add(PackageConfig.fromYaml(item as YamlMap, repoRoot));
      }
    }

    // Load plugins
    if (packagesYaml.containsKey('plugins')) {
      final pluginsList = packagesYaml['plugins'] as YamlList;
      for (final item in pluginsList) {
        packages.add(PackageConfig.fromYaml(item as YamlMap, repoRoot));
      }
    }

    if (config.verbose) {
      print('Loaded ${sections.length} section templates');
      print('Loaded ${packages.length} package configurations');
    }
  }

  Future<void> _syncPackage(PackageConfig package) async {
    final readmePath = path.join(package.fullPath, 'README.md');
    final readmeFile = File(readmePath);

    if (!readmeFile.existsSync()) {
      throw Exception('README.md not found at $readmePath');
    }

    print('📝 ${package.name}');

    var content = await readmeFile.readAsString();
    var modified = false;

    // Process each section
    for (final sectionId in package.sections) {
      final template = sections[sectionId];
      if (template == null) {
        print('   ⚠️  Unknown section: $sectionId');
        continue;
      }

      // Check if markers exist
      if (!_hasMarkers(content, sectionId)) {
        print('   ⚠️  Missing markers for: $sectionId');
        continue;
      }

      // Render template with variables
      final renderedContent = _renderTemplate(template, package);

      // Replace section content
      final newContent = _replaceSectionContent(content, sectionId, renderedContent);

      if (newContent != content) {
        content = newContent;
        modified = true;
        if (config.verbose) {
          print('   ✓ Updated: $sectionId');
        }
      }
    }

    if (modified) {
      if (config.dryRun) {
        print('   🔍 Would update README (dry-run mode)');
      } else {
        // Create backup
        final backupPath = '$readmePath.bak';
        await readmeFile.copy(backupPath);

        // Write new content
        await readmeFile.writeAsString(content);
        print('   ✅ Updated README');

        // Remove backup after successful write
        await File(backupPath).delete();
      }
    } else {
      print('   ℹ️  No changes needed');
    }
  }

  static const _markerWarning =
      'auto-generated, do not edit. Run `melos sync:readme` to update';

  String _beginMarker(String sectionId) =>
      '<!-- BEGIN:$sectionId — $_markerWarning -->';

  bool _hasMarkers(String content, String sectionId) {
    final hasBegin = content.contains('<!-- BEGIN:$sectionId');
    final endMarker = '<!-- END:$sectionId -->';
    return hasBegin && content.contains(endMarker);
  }

  String _renderTemplate(SectionTemplate template, PackageConfig package) {
    var content = template.content;

    // Replace all variables
    final variables = {
      'package_name': package.name,
      'repo_path': package.repoPath,
      'import_path': package.importPath,
      'author_name': package.authorName,
      'github_username': package.githubUsername,
    };

    for (final entry in variables.entries) {
      content = content.replaceAll('{{${entry.key}}}', entry.value);
    }

    return content;
  }

  String _replaceSectionContent(String readme, String sectionId, String newContent) {
    final beginPrefix = '<!-- BEGIN:$sectionId';
    final endMarker = '<!-- END:$sectionId -->';

    final beginIndex = readme.indexOf(beginPrefix);
    final endIndex = readme.indexOf(endMarker);

    if (beginIndex == -1 || endIndex == -1) {
      return readme;
    }

    // Find the end of the BEGIN marker line (closing -->)
    final beginLineEnd = readme.indexOf('-->', beginIndex) + 3;

    final before = readme.substring(0, beginIndex) + _beginMarker(sectionId);
    final after = readme.substring(endIndex);

    return '$before\n$newContent\n$after';
  }

  Future<void> _validatePackages(List<PackageConfig> packagesToProcess) async {
    print('🔍 Validating README markers...\n');

    var totalIssues = 0;

    for (final package in packagesToProcess) {
      final readmePath = path.join(package.fullPath, 'README.md');
      final readmeFile = File(readmePath);

      if (!readmeFile.existsSync()) {
        print('❌ ${package.name}: README.md not found');
        totalIssues++;
        continue;
      }

      final content = await readmeFile.readAsString();
      final issues = <String>[];

      for (final sectionId in package.sections) {
        if (!_hasMarkers(content, sectionId)) {
          issues.add('Missing markers for: $sectionId');
        }
      }

      if (issues.isEmpty) {
        print('✅ ${package.name}: All markers present');
      } else {
        print('⚠️  ${package.name}:');
        for (final issue in issues) {
          print('   - $issue');
          totalIssues++;
        }
      }
    }

    print('\n' + '━' * 50);
    if (totalIssues == 0) {
      print('✅ Validation passed: All markers are present');
    } else {
      print('⚠️  Validation found $totalIssues issue(s)');
      print('Run with --add-markers to add missing markers');
    }
  }

  Future<void> _addMarkersToPackages(List<PackageConfig> packagesToProcess) async {
    print('➕ Adding markers to READMEs...\n');

    for (final package in packagesToProcess) {
      final readmePath = path.join(package.fullPath, 'README.md');
      final readmeFile = File(readmePath);

      if (!readmeFile.existsSync()) {
        print('❌ ${package.name}: README.md not found');
        continue;
      }

      print('📝 ${package.name}');
      print('   ⚠️  Manual intervention required');
      print('   Add markers like: <!-- BEGIN:section-name --> and <!-- END:section-name -->');
      print('   Sections needed: ${package.sections.join(", ")}');
    }

    print('\nℹ️  Marker format:');
    print('   <!-- BEGIN:section-id -->');
    print('   [content to be managed]');
    print('   <!-- END:section-id -->');
  }
}

class SectionTemplate {
  final String id;
  final String content;
  final List<String> variables;

  SectionTemplate({
    required this.id,
    required this.content,
    required this.variables,
  });
}

class PackageConfig {
  final String name;
  final String relativePath;
  final String fullPath;
  final String repoPath;
  final String importPath;
  final String authorName;
  final String githubUsername;
  final List<String> sections;

  PackageConfig({
    required this.name,
    required this.relativePath,
    required this.fullPath,
    required this.repoPath,
    required this.importPath,
    required this.authorName,
    required this.githubUsername,
    required this.sections,
  });

  factory PackageConfig.fromYaml(YamlMap yaml, String repoRoot) {
    final relativePath = yaml['path'] as String;
    return PackageConfig(
      name: yaml['name'] as String,
      relativePath: relativePath,
      fullPath: path.join(repoRoot, relativePath),
      repoPath: yaml['repo_path'] as String,
      importPath: yaml['import_path'] as String,
      authorName: yaml['author_name'] as String,
      githubUsername: yaml['github_username'] as String,
      sections: (yaml['sections'] as YamlList).map((e) => e as String).toList(),
    );
  }
}

void printHelp() {
  print('''
README Sync Tool - Standardize README sections across packages

USAGE:
  dart readme_sync.dart [OPTIONS]

OPTIONS:
  --dry-run, -d          Preview changes without modifying files
  --verbose, -v          Show detailed output
  --validate             Check if all packages have proper markers
  --add-markers          Show instructions for adding markers
  --package <name>       Sync only specific package
  --help, -h             Show this help message

EXAMPLES:
  dart readme_sync.dart                           # Sync all packages
  dart readme_sync.dart --dry-run                 # Preview changes
  dart readme_sync.dart --package timer_button    # Sync one package
  dart readme_sync.dart --validate                # Validate markers
  dart readme_sync.dart --verbose                 # Show detailed output

For more information, see tools/readme_sync/README.md
''');
}
