# CLI Utils

[![pub package](https://img.shields.io/pub/v/cli_utils.svg)](https://pub.dev/packages/cli_utils)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A shared utility package for CLI operations in Flutter Forge packages.

## Installation 💻

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  cli_utils: ^0.0.2-dev.1
```

## Features ✨

- 🚀 Base CLI command infrastructure with progress tracking
- 📱 Flutter project creation and management utilities
- 📦 Melos workspace management utilities
- 🔧 File system utilities for common operations

## Usage 📖

### Command Infrastructure
```dart
import 'package:cli_utils/cli_utils.dart';

// Using Flutter commands
class MyFlutterCommand extends BaseFlutterCommand {
  Future<void> execute(HookContext context) async {
    await createFlutterProject(
      context: context,
      name: 'my_app',
      description: 'My Flutter application',
      outputPath: 'path/to/output',
    );
  }
}
```

### Melos Commands
```dart
// Using Melos commands
class MyMelosCommand extends BaseMelosCommand {
  Future<void> execute(HookContext context) async {
    await bootstrap(
      context: context,
      workspacePath: 'path/to/workspace',
    );
  }
}
```

### File Operations
```dart
// Using file utilities
Future<void> fileOperations() async {
  // Create directories
  await FileUtils.ensureDirectory('path/to/dir');
  
  // Write YAML files
  await FileUtils.writeYamlFile('config.yaml', 'content: value');
  
  // Read YAML files
  final content = await FileUtils.readYamlFile('config.yaml');
  
  // Copy files
  await FileUtils.copyFile('source.txt', 'dest.txt');
  
  // Check for mono-repo
  final isMonoRepo = await FileUtils.isMonoRepo();
}
```

## Contributing 🤝

We welcome contributions! Here's how you can help:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License ⚖️

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Packages 📦

- [nonstop_cli](https://pub.dev/packages/nonstop_cli) - CLI tool for Flutter project generation and management
- [connectivity_wrapper](https://pub.dev/packages/connectivity_wrapper) - A Flutter package for handling connectivity states