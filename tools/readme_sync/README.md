# README Sync Tool

Automated tool to synchronize standardized sections across all package READMEs in the Flutter Forge monorepo.

## Overview

This tool manages common README sections (like headers, contributing guidelines, social links, etc.) from a centralized template, ensuring consistency across all packages while preserving package-specific content.

### Key Features

- **Centralized Templates**: All common sections defined in one place
- **Variable Substitution**: Package-specific variables (name, author, etc.) automatically replaced
- **Non-Destructive**: Only updates content between markers, preserves everything else
- **Safe Operations**: Dry-run mode and automatic backups before modifications
- **Flexible**: Packages can opt-in/out of specific sections

### Statistics

- **~35-40%** of README content is standardized boilerplate
- **9 sections** managed centrally
- **9 packages/plugins** currently configured

## Architecture

```
tools/readme_sync/
├── readme_sync.dart          # Main script
├── pubspec.yaml             # Dependencies
├── templates/
│   └── sections.yaml        # Section templates (centralized content)
├── config/
│   └── packages.yaml        # Package configurations
└── README.md               # This file
```

## How It Works

### 1. Section Markers

READMEs use HTML comments to mark managed sections:

```markdown
<!-- BEGIN:section-id — auto-generated, do not edit. Run `melos sync:readme` to update -->
[This content will be managed by the sync tool]
<!-- END:section-id -->

[Package-specific content here - never touched by the tool]

<!-- BEGIN:another-section — auto-generated, do not edit. Run `melos sync:readme` to update -->
[Another managed section]
<!-- END:another-section -->
```

### 2. Template System

Templates are defined in `templates/sections.yaml`:

```yaml
sections:
  contributing:
    content: |
      ## Contributing

      We welcome contributions...
    variables: []

  badges:
    content: |
      [![Build](https://img.shields.io/pub/v/{{package_name}}.svg)]...
    variables: [package_name, repo_path]
```

### 3. Package Configuration

Each package is configured in `config/packages.yaml`:

```yaml
packages:
  - name: timer_button
    path: packages/timer_button
    repo_path: packages/timer_button
    import_path: timer_button
    author_name: Ajay Kumar
    github_username: ProjectAJ14
    sections:
      - nonstop-header
      - badges
      - getting-started
      - import-package
      - contributing
      - connect
      - star-footer
      - license
      - founded-by
```

## Usage

### Prerequisites

1. Ensure all READMEs have proper section markers
2. Run from repository root or use Melos

### Commands

#### Sync All Packages

```bash
# Using Melos (recommended)
melos sync:readme

# Direct execution
dart run tools/readme_sync/readme_sync.dart
```

#### Sync Specific Package

```bash
dart run tools/readme_sync/readme_sync.dart --package timer_button
```

#### Dry Run (Preview Changes)

```bash
dart run tools/readme_sync/readme_sync.dart --dry-run
```

#### Validate Markers

```bash
dart run tools/readme_sync/readme_sync.dart --validate
```

#### Verbose Output

```bash
dart run tools/readme_sync/readme_sync.dart --verbose
```

#### Get Help

```bash
dart run tools/readme_sync/readme_sync.dart --help
```

## Managed Sections

| Section ID | Description | Variables |
|------------|-------------|-----------|
| `nonstop-header` | NonStop branding header | None |
| `badges` | Build status and license badges | `package_name`, `repo_path` |
| `getting-started` | Installation instructions | `package_name` |
| `import-package` | Import statement | `package_name`, `import_path` |
| `contributing` | Contribution guidelines | None |
| `connect` | Social media links | None |
| `star-footer` | GitHub star CTA | None |
| `license` | MIT license info | None |
| `founded-by` | Founder attribution | `author_name`, `github_username` |

## Adding Markers to a New Package

### Step 1: Add Package Configuration

Edit `config/packages.yaml`:

```yaml
packages:
  - name: my_new_package
    path: packages/my_new_package
    repo_path: packages/my_new_package
    import_path: my_new_package
    author_name: Your Name
    github_username: yourusername
    sections:
      - nonstop-header
      - badges
      - getting-started
      - import-package
      - contributing
      - connect
      - star-footer
      - license
      - founded-by
```

### Step 2: Add Markers to README

In your package's README.md, add markers around sections you want managed:

```markdown
<!-- BEGIN:nonstop-header — auto-generated, do not edit. Run `melos sync:readme` to update -->
<p align="center">
  ... existing content ...
</p>
<!-- END:nonstop-header -->

# my_new_package

<!-- BEGIN:badges — auto-generated, do not edit. Run `melos sync:readme` to update -->
[![Build Status]...]
<!-- END:badges -->

Your package description here...

<!-- BEGIN:getting-started — auto-generated, do not edit. Run `melos sync:readme` to update -->
## Getting Started
...
<!-- END:getting-started -->

<!-- BEGIN:import-package — auto-generated, do not edit. Run `melos sync:readme` to update -->
## Import the Package
...
<!-- END:import-package -->

## Usage

[Your package-specific content - never touched]

<!-- BEGIN:contributing — auto-generated, do not edit. Run `melos sync:readme` to update -->
## Contributing
...
<!-- END:contributing -->

<!-- BEGIN:connect — auto-generated, do not edit. Run `melos sync:readme` to update -->
## 🔗 Connect with NonStop
...
<!-- END:connect -->

<!-- BEGIN:star-footer — auto-generated, do not edit. Run `melos sync:readme` to update -->
<div align="center">
...
<!-- END:star-footer -->

<!-- BEGIN:license — auto-generated, do not edit. Run `melos sync:readme` to update -->
## 📜 License
...
<!-- END:license -->

<!-- BEGIN:founded-by — auto-generated, do not edit. Run `melos sync:readme` to update -->
<div align="center">
...
<!-- END:founded-by -->
```

### Step 3: Test

```bash
# Validate markers are correct
dart run tools/readme_sync/readme_sync.dart --validate --package my_new_package

# Preview changes
dart run tools/readme_sync/readme_sync.dart --dry-run --package my_new_package

# Apply changes
dart run tools/readme_sync/readme_sync.dart --package my_new_package
```

## Updating Templates

To update content across all packages:

1. Edit `templates/sections.yaml`
2. Modify the section content
3. Run the sync tool
4. All packages will automatically update

**Example**: Update contributing guidelines

```yaml
# templates/sections.yaml
sections:
  contributing:
    content: |
      ## Contributing

      Updated contribution guidelines here...
```

```bash
melos sync:readme
```

All 9 packages now have the updated contributing section!

## Safety Features

### Automatic Backups

The tool creates `.bak` files before modifying READMEs. These are automatically deleted after successful write.

### Dry Run Mode

Preview all changes without modifying files:

```bash
dart run tools/readme_sync/readme_sync.dart --dry-run
```

### Marker Validation

Ensures all markers are properly paired (BEGIN/END):

```bash
dart run tools/readme_sync/readme_sync.dart --validate
```

### Content Preservation

- Only content between markers is modified
- Package-specific content is never touched
- Maintains exact formatting and spacing outside markers

## Troubleshooting

### "Missing markers for: section-id"

**Problem**: README doesn't have markers for a configured section.

**Solution**: Add the markers manually:
```markdown
<!-- BEGIN:section-id — auto-generated, do not edit. Run `melos sync:readme` to update -->
[existing content]
<!-- END:section-id -->
```

### "Package not found in configuration"

**Problem**: Package not listed in `config/packages.yaml`.

**Solution**: Add the package configuration (see "Adding Markers" above).

### Changes not applying

**Problem**: Content not updating after sync.

**Solution**:
1. Check markers are exact: `<!-- BEGIN:section-id — auto-generated, do not edit. Run `melos sync:readme` to update -->` (case-sensitive)
2. Ensure no extra spaces in marker comments
3. Run with `--verbose` to see what's happening
4. Validate with `--validate` flag

## Best Practices

1. **Always dry-run first** when making template changes
2. **Validate before syncing** to catch marker issues early
3. **Commit template changes separately** from sync results
4. **Test on one package first** before running on all packages
5. **Keep package-specific content outside markers**

## Integration with CI/CD

You can add validation to your CI pipeline:

```yaml
# .github/workflows/validate-readmes.yml
- name: Validate README markers
  run: dart run tools/readme_sync/readme_sync.dart --validate
```

## Future Enhancements

Potential improvements:

- [ ] Auto-detect and suggest marker placement
- [ ] Support for conditional sections
- [ ] Multi-language README support
- [ ] Section reordering capabilities
- [ ] Git diff preview in dry-run mode
- [ ] Integration with package version updates

## Contributing

To improve this tool:

1. Edit the Dart script: `tools/readme_sync/readme_sync.dart`
2. Update templates: `templates/sections.yaml`
3. Test thoroughly with `--dry-run`
4. Document changes in this README

## License

Part of the Flutter Forge monorepo - MIT License
