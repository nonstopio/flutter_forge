# CLI Utils Examples

This directory contains examples demonstrating how to use the various utilities provided by the `cli_utils` package.

## Running the Examples

```bash
dart run cli_utils_example.dart
```

## What's Demonstrated

1. **Flutter Commands**
   - Creating new Flutter projects
   - Managing project files
   - Running Flutter commands

2. **Melos Commands**
   - Initializing workspaces
   - Managing dependencies
   - Cleaning workspaces

3. **String Case Conversions**
   - Converting between snake_case, camelCase, PascalCase, and Title Case
   - Handling various input formats

4. **File Utilities**
   - Directory creation and management
   - File operations (read, write, copy, delete)
   - YAML file handling
   - Mono-repo detection

## Example Output

```
// String Case Examples
my_awesome_project
myAwesomeProject
MyAwesomeProject
My Awesome Project

// File Utility Examples
Directory created: output/logs
Config content: name: example
version: 1.0.0
description: An example configuration
Is mono-repo? true
```