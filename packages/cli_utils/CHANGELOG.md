# Changelog

## 0.0.2

- **BREAKING**: Renamed base command classes for better clarity
  - `FlutterCommand` -> `BaseFlutterCommand`
  - `MelosCommand` -> `BaseMelosCommand`
- Improved exports in barrel file
- Enhanced documentation and examples
- Clean up of template dependencies

## 0.0.1

Initial release with core utilities:

- **CLI Commands**
  - Base `CliCommand` class with progress tracking
  - `FlutterCommand` for Flutter project operations
  - `MelosCommand` for Melos workspace management

- **File Utilities**
  - Directory and file management
  - YAML file operations
  - Mono-repo detection

- **String Utilities**
  - Case conversion utilities (snake_case, camelCase, PascalCase, Title Case)
  - Comprehensive test coverage
  - Documentation and examples