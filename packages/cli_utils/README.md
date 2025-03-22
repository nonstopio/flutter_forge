# CLI Utils

A shared utility package for CLI operations in Flutter Forge packages.

## Features

- Base CLI command infrastructure with progress tracking
- Flutter project creation and management utilities
- Melos workspace management utilities
- String case conversion utilities (snake_case, camelCase, PascalCase, etc.)
- File system utilities for common operations

## Usage

```dart
import 'package:cli_utils/cli_utils.dart';

// Using Flutter commands
class MyFlutterCommand extends FlutterCommand {
  Future<void> execute(HookContext context) async {
    await createFlutterProject(
      context: context,
      name: 'my_app',
      description: 'My Flutter application',
      outputPath: 'path/to/output',
    );
  }
}

// Using Melos commands
class MyMelosCommand extends MelosCommand {
  Future<void> execute(HookContext context) async {
    await bootstrap(
      context: context,
      workspacePath: 'path/to/workspace',
    );
  }
}

// Using string utilities
void stringManipulation() {
  final name = 'MyProject';
  print(name.snakeCase);    // my_project
  print(name.camelCase);    // myProject
  print(name.pascalCase);   // MyProject
  print(name.titleCase);    // My Project
}

// Using file utilities
Future<void> fileOperations() async {
  await FileUtils.ensureDirectory('path/to/dir');
  await FileUtils.writeYamlFile('config.yaml', 'content: value');
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.