import 'dart:io';

import 'package:mason/mason.dart';
import 'package:nonstop_cli/template.dart';
import 'package:nonstop_cli/utils/utils.dart';
import 'package:nonstop_cli/utils/workspace.dart';

import 'flutter_app_for_mono_repo_bundle.dart';
import 'flutter_package_for_mono_repo_bundle.dart';
import 'flutter_plugin_for_mono_repo_bundle.dart';
import 'flutter_project_with_mono_repo_bundle.dart';

class FlutterProjectWithMonoRepoTemplate extends Template {
  FlutterProjectWithMonoRepoTemplate()
      : super(
          name: 'flutterProjectWithMonoRepoBundle',
          bundle: flutterProjectWithMonoRepoBundle,
          help: 'A Flutter project within a Melos-managed mono-repo',
        );

  @override
  Future<void> onGenerateComplete(Logger logger, Directory outputDir) async {
    logger.logSummary(
      outputDir: outputDir,
      message: 'Created a Flutter project within a Melos-managed mono-repo 🚀',
    );
  }
}

class FlutterPackageForMonoRepoTemplate extends Template {
  FlutterPackageForMonoRepoTemplate()
      : super(
          name: 'flutterPackageForMonoRepoBundle',
          bundle: flutterPackageForMonoRepoBundle,
          help: 'A Flutter package for a Melos-managed mono-repo',
        );

  @override
  Future<void> onGenerateComplete(Logger logger, Directory outputDir) async {
    _joinWorkspace(logger, outputDir);
    logger.logSummary(
      outputDir: outputDir,
      message: 'Created a Flutter package for a Melos-managed mono-repo 🚀',
    );
  }
}

class FlutterAppForMonoRepoTemplate extends Template {
  FlutterAppForMonoRepoTemplate()
      : super(
          name: 'flutterAppForMonoRepoBundle',
          bundle: flutterAppForMonoRepoBundle,
          help: 'A Flutter application for a Melos-managed mono-repo',
        );

  @override
  Future<void> onGenerateComplete(Logger logger, Directory outputDir) async {
    _joinWorkspace(logger, outputDir);
    logger.logSummary(
      outputDir: outputDir,
      message: 'Created a Flutter application for a Melos-managed mono-repo 🚀',
    );
  }
}

class FlutterPluginForMonoRepoTemplate extends Template {
  FlutterPluginForMonoRepoTemplate()
      : super(
          name: 'flutterPluginForMonoRepoBundle',
          bundle: flutterPluginForMonoRepoBundle,
          help: 'A Flutter plugin for a Melos-managed mono-repo',
        );

  @override
  Future<void> onGenerateComplete(Logger logger, Directory outputDir) async {
    _joinWorkspace(logger, outputDir);
    logger.logSummary(
      outputDir: outputDir,
      message: 'Created a Flutter plugin for a Melos-managed mono-repo 🚀',
    );
  }
}

void _joinWorkspace(Logger logger, Directory member) {
  final root = registerWorkspaceMember(member);
  if (root != null) {
    logger.info('Added ${member.path} to the workspace in ${root.path}. '
        'Run `dart pub get` at the workspace root.');
  }
}
