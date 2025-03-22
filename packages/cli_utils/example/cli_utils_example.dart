import 'package:mason/mason.dart';
import 'package:cli_utils/cli_utils.dart';

// Example custom Flutter command
class CustomFlutterCommand extends BaseFlutterCommand {
  @override
  Future<void> run(HookContext context) async {
    // Create a new Flutter project
    await createFlutterProject(
      context: context,
      name: 'example_app',
      description: 'An example Flutter application',
      outputPath: 'projects',
      template: 'app',
      platforms: ['ios', 'android'],
      orgName: 'com.example',
    );

    // Clean up analysis options
    await removeAnalysisOptions(
      context: context,
      projectPath: 'projects/example_app',
    );

    // Update dependencies
    await pubGet(
      context: context,
      projectPath: 'projects/example_app',
    );
  }
}

// Example custom Melos command
class CustomMelosCommand extends BaseMelosCommand {
  @override
  Future<void> run(HookContext context) async {
    const workspacePath = 'my_workspace';

    // Initialize Melos workspace
    await initialize(
      context: context,
      workspacePath: workspacePath,
    );

    // Install dependencies
    await bootstrap(
      context: context,
      workspacePath: workspacePath,
    );

    // Clean workspace
    await clean(
      context: context,
      workspacePath: workspacePath,
    );
  }
}

// Example string case conversions
void stringCaseExamples() {
  final projectName = 'MyAwesomeProject';
  print(projectName.snakeCase);   // my_awesome_project
  print(projectName.camelCase);   // myAwesomeProject
  print(projectName.pascalCase);  // MyAwesomeProject
  print(projectName.titleCase);   // My Awesome Project
}

// Example file utilities
Future<void> fileUtilsExamples() async {
  // Directory operations
  final dir = await FileUtils.ensureDirectory('output/logs');
  print('Directory created: ${dir.path}');

  // File operations
  await FileUtils.writeYamlFile(
    'config.yaml',
    '''
name: example
version: 1.0.0
description: An example configuration
    ''',
  );

  final content = await FileUtils.readYamlFile('config.yaml');
  print('Config content: $content');

  await FileUtils.copyFile('config.yaml', 'config.backup.yaml');
  await FileUtils.deleteFile('config.yaml');

  // Mono-repo detection
  final isMonoRepo = await FileUtils.isMonoRepo();
  print('Is mono-repo? $isMonoRepo');
}

Future<void> main() async {
  // Run string case examples
  stringCaseExamples();

  // Run file utility examples
  await fileUtilsExamples();
}