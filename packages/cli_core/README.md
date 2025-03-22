<p align="center">
  <a href="https://nonstopio.com">
    <img src="https://github.com/nonstopio.png" alt="Nonstop Logo" height="128" />
  </a>
  <h1 align="center">NonStop</h1>
  <p align="center">Digital Product Development Experts for Startups & Enterprises</p>
  <p align="center">
    <a href="https://nonstopio.com/about">About</a> |
    <a href="https://nonstopio.com">Website</a>
  </p>
</p>

# cli_core

[![cli_core](https://img.shields.io/pub/v/cli_core.svg?label=cli_core&logo=dart&color=blue&style=for-the-badge)](https://pub.dev/packages/cli_core)

A shared utility package for CLI operations in Flutter Forge packages, providing core functionality for CLI commands, Flutter project management, and Melos workspace operations.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Usage](#usage)
  - [Command Infrastructure](#command-infrastructure)
  - [Flutter Commands](#flutter-commands)
  - [Melos Commands](#melos-commands)
  - [File Operations](#file-operations)
- [Contributing](#contributing)
- [Contact](#contact)

## Overview

CLI Core provides the foundational building blocks for creating CLI tools in the Flutter Forge ecosystem. It abstracts common CLI operations, provides progress tracking, and includes utilities for Flutter project management and Melos workspace operations.

## Features

- 🚀 Base CLI command infrastructure with progress tracking
- 📱 Flutter project creation and management utilities
- 📦 Melos workspace management utilities
- 🔧 File system utilities for common operations

## Usage

### Command Infrastructure

Create custom CLI commands by extending the base command classes:

```dart
import 'package:cli_core/cli_core.dart';

class MyCommand extends CliCommand {
  @override
  Future<void> run(HookContext context) async {
    await trackOperation(
      context,
      startMessage: 'Starting operation',
      endMessage: 'Operation completed',
      operation: () => yourOperation(),
    );
  }
}
```

### Flutter Commands

Manage Flutter projects with built-in utilities:

```dart
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

Handle Melos workspace operations:

```dart
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

Perform common file system operations:

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

## Contributing

We welcome contributions! Here's how you can help:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Contact

Follow us, stay up to date or reach out on:

- [LinkedIn](https://www.linkedin.com/company/nonstop-io)
- [X.com](https://x.com/NonStopio)
- [Instagram](https://www.instagram.com/nonstopio_technologies/)
- [YouTube](https://www.youtube.com/@NonStopioTechnology)
- [Email](mailto:contact@nonstopio.com)

---
<p align="center">🚀 Founded by <a href="https://github.com/ProjectAJ14">Ajay Kumar</a> 🎉</p>
