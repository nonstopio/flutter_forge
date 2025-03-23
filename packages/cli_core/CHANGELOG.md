## 0.0.2-dev.3

 - **FIX**: remove the cli_core path and use the version instead.

## 0.0.2-dev.2

 - **REFACTOR**(cli_core): rename cli_utils to cli_core.
 - **DOCS**: update README and CHANGELOG for cli_core branding and features.

# Changelog

## 0.0.2-dev.1
- First pre-release version
- Package renamed to cli_core
- Added proper package metadata for pub.dev
- Enhanced documentation and examples
- Added LICENSE file
- Removed string_utils module
- Updated dependencies to latest versions

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
  - Comprehensive test coverage
  - Documentation and examples