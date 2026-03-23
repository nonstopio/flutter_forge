# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Melos Commands (Primary)
- `melos lint` - Run dart format and analyze on all packages with strict checking
- `melos exec -- flutter pub upgrade` - Upgrade all packages in the workspace
- `melos run update_nonstop_cli_version` - Update CLI version across packages
- `melos run update_nonstop_cli_bundles` - Update CLI bundles
- `melos sync:readme` - Sync standardized README sections across all packages

### Just Commands (Alternative)
- `just upgrade_pub_packages` - Upgrade Flutter and Dart packages across workspace
- `just _generate-json <package> <command>` - Generate JSON serializables for a package

### Testing
- Individual package tests: Navigate to package directory and run `flutter test` or `dart test`
- Tests are located in `test/` directories within each package/plugin

## Repository Architecture

This is a Flutter/Dart monorepo managed by Melos with the following structure:

### Core Organization
- **packages/**: Dart packages (libraries, utilities, CLI tools)
- **plugins/**: Flutter plugins (platform-specific functionality)
- **tools/**: Maintenance scripts for CLI version, bundle updates, and README standardization

### Key Packages
- **nonstop_cli**: CLI tool with Mason bricks for project generation
- **dzod**: Schema validation library (similar to Zod for TypeScript)
- **cli_core**: Core utilities for CLI commands
- **ns_utils**: Common utilities and extensions
- **connectivity_wrapper**: Network connectivity widgets
- **timer_button**: Timer-based button widget
- **ns_intl_phone_input**: International phone number input widget
- **ns_firebase_utils**: Firebase integration utilities

### Key Plugins
- **contact_permission**: Cross-platform contact permission handling

## Development Workflow

### Making Changes
1. Work within individual package/plugin directories
2. Use `melos lint` to ensure code quality before committing
3. Each package has its own `pubspec.yaml` and dependencies
4. Run tests in the specific package you're modifying

### Package Structure
- Standard Flutter/Dart package structure with `lib/`, `test/`, `example/` directories
- Most packages follow the pattern: `lib/src/` for implementation, `lib/package_name.dart` for exports
- Examples are provided in `example/` directories for demonstration

### Schema Validation (dzod)
- Located in `packages/dzod/`
- Provides type-safe validation similar to Zod
- Core classes: `Schema<T>`, `ValidationResult<T>`, `ValidationException`
- Implementation in `lib/src/core/` with specific schema types in `lib/src/schemas/`

### CLI Tools (nonstop_cli)
- Mason bricks for project generation in `bricks/`
- Command structure in `lib/commands/`
- Includes doctor command for environment validation
- Template bundles are auto-updated via tools scripts

## README Standardization (readme_sync)

The repository uses an automated tool to maintain consistency across package READMEs.

### How It Works
- Common sections (headers, contributing, social links, etc.) are defined in centralized templates
- READMEs use HTML comment markers to identify managed sections: `<!-- BEGIN:section-id -->` and `<!-- END:section-id -->`
- Only content between markers is synced; package-specific content is preserved
- Templates support variable substitution (package name, author, repo path, etc.)

### Usage
- **Sync all packages**: `melos sync:readme`
- **Sync specific package**: `dart run tools/readme_sync/readme_sync.dart --package package_name`
- **Preview changes**: `dart run tools/readme_sync/readme_sync.dart --dry-run`
- **Validate markers**: `dart run tools/readme_sync/readme_sync.dart --validate`

### Configuration Files
- **templates/sections.yaml**: Centralized section templates
- **config/packages.yaml**: Package-specific variables and section assignments
- See `tools/readme_sync/README.md` for detailed documentation
- See `tools/readme_sync/EXAMPLE_README.md` for marker placement examples

### When to Use
- After updating common content (contributing guidelines, social links, etc.)
- When adding a new package to ensure consistent README structure
- Before releases to ensure all READMEs are synchronized

## Important Notes

- This is a workspace managed by Melos - always run commands from the root
- Each package/plugin maintains its own changelog and version
- Use `melos exec` to run commands across all packages
- The workspace includes both published packages and internal development tools