import 'dart:io';

import 'package:mason/mason.dart';
import 'package:nonstop_cli/commands/create/nonstop_project_bundle.dart';
import 'package:nonstop_cli/template.dart';
import 'package:nonstop_cli/utils/utils.dart';

class ProjectTemplate extends Template {
  ProjectTemplate()
      : super(
          name: 'project',
          bundle: nonstopProjectBundle,
          help: 'Generate a Flutter Project with a Melos.',
        );

  @override
  Future<void> onGenerateComplete(Logger logger, Directory outputDir) async {
    templateSummary(
      logger: logger,
      outputDir: outputDir,
      message: 'Created a Flutter Project with Melos! 🚀',
    );
  }
}
