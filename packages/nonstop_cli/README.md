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

# nonstop_cli

[![nonstop_cli](https://img.shields.io/pub/v/nonstop_cli.svg?label=nonstop_cli&logo=dart&color=blue&style=for-the-badge)](https://pub.dev/packages/nonstop_cli)

A command-line interface for Flutter that generates projects from predefined templates and helps manage the development environment.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Global Options](#global-options)
- [Commands](#commands)
  - [create](#create)
  - [doctor](#doctor)
  - [update](#update)
- [Common Workflows](#common-workflows)
- [Troubleshooting](#troubleshooting)

## Overview

The NonStop CLI simplifies Flutter project setup and management, with a focus on mono-repository structures using Melos. It provides standardized templates, validation tools for your development environment, and ongoing updates for the best experience.

## Installation

Install the latest version:

```sh
dart pub global activate nonstop_cli
```

Install a specific version:

```sh
dart pub global activate nonstop_cli <version>
```

> If you haven't already, you might need to
> [set up your path](https://dart.dev/tools/pub/cmd/pub-global#running-a-script-from-your-path).

Alternative usage (e.g., in CI environments):

```sh
dart pub global run nonstop_cli:nonstop <command> <args>
```

## Global Options

The following options can be used with any command:

| Option      | Alias | Description                                         |
|-------------|-------|-----------------------------------------------------|
| `--version` | `-v`  | Print the current version of the CLI                |
| `--verbose` |       | Enable verbose logging including all shell commands |
| `--help`    | `-h`  | Display help information for commands               |

## Commands

### create

Creates a new Flutter project based on predefined templates.

```sh
nonstop create <project-name> [arguments]
```

**Arguments:**

| Argument             | Alias    | Description                                           | Default                                                             |
|----------------------|----------|-------------------------------------------------------|---------------------------------------------------------------------|
| `--template`         | `-t`     | Type of project to create                             | `mono`                                                              |
| `--output-directory` | `-o`     | Output directory for the new project                  | Current directory                                                   |
| `--description`      | `--desc` | Description for the new project                       | "A Melos-managed project for mono-repo, created using NonStop CLI." |
| `--org-name`         | `--org`  | Organization name for the new project                 | `com.example`                                                       |
| `--application-id`   |          | Bundle identifier on iOS or application id on Android | `<org-name>.<project-name>`                                         |

**Template Options:**

| Template  | Description                                                   | Structure Created                                                       |
|-----------|---------------------------------------------------------------|-------------------------------------------------------------------------|
| `mono`    | Generate a Flutter application along with mono-repo (default) | Complete mono-repo structure with apps, features, packages, and plugins |
| `package` | Generate a Flutter package for a Melos-managed mono-repo      | Flutter package compatible with mono-repo structure                     |
| `app`     | Generate a Flutter application for a Melos-managed mono-repo  | Flutter application configured for mono-repo structure                  |

**Example: Create a mono-repo project**

```sh
nonstop create youtube
```

This creates the following structure:

```
youtube
    ├── apps
    │    └── youtube
    ├── features
    ├── packages
    ├── plugins
    ├── analysis_options.yaml
    ├── README.md
    ├── melos.yaml
    └── pubspec.yaml
```

**Example: Create a Flutter package for a mono-repo**

```sh
nonstop create core --template package
```

**Example: Create a Flutter application for a mono-repo**

```sh
nonstop create youtube_studio --template app -o ./apps
```

**Example: Create with custom organization**

```sh
nonstop create youtube_music --org-name com.youtube
```

**Example: Create in a specific directory**

```sh
nonstop create youtube -o ./projects
```

### doctor

Checks your development environment to ensure all required tools are installed and configured correctly.

```sh
nonstop doctor
```

The command analyzes your environment and reports on:
- Flutter installation and version
- Dart SDK installation and version
- Melos installation and version

For each tool, the doctor command indicates:
- ✓ Success: Tool is installed and working properly
- ⚠ Partial: Tool is installed but has issues
- ✗ Missing: Tool is not installed or not found

<img width="678" alt="nonstop doctor" src="https://github.com/user-attachments/assets/fab74b37-b5f7-4ad1-b0a3-d3d028fa949e">


### update

Updates the NonStop CLI to the latest version.

```sh
nonstop update
```

The command:
1. Checks the current installed version
2. Compares it with the latest version available on pub.dev
3. Updates to the latest version if needed

**Example:**

```sh
nonstop update
```

## Common Workflows

### Setting up a new Flutter project with mono-repo

```sh
# Check if your environment is properly set up
nonstop doctor

# Create a new Flutter project with mono-repo structure
nonstop create youtube

# Navigate to the project directory
cd youtube
```

### Adding a new package to an existing mono-repo

```sh
# Navigate to your mono-repo root
cd youtube/packages

# Create a new package
nonstop create core --template package

# Update dependencies
melos bootstrap
```

### Adding a new app to an existing mono-repo

```sh
# Create a new app in the apps directory
nonstop create youtube_studio --template app -o ./apps

# Update dependencies
melos bootstrap
```

## Troubleshooting

### CLI not found after installation

Ensure the Dart SDK bin directory is in your PATH. Follow the instructions at:
[Running a script from your PATH](https://dart.dev/tools/pub/cmd/pub-global#running-a-script-from-your-path)

### Doctor command shows issues

If the `doctor` command shows issues with your development environment:

1. Ensure Flutter is installed correctly: [Flutter Installation](https://docs.flutter.dev/get-started/install)
2. Verify your Dart SDK installation: `dart --version`
3. Install Melos if missing: `dart pub global activate melos`

### Template generation fails

If template generation fails:

1. Ensure you have proper permissions in the target directory
2. Check if the project name is valid (should follow Dart package naming rules)
3. Run with the `--verbose` flag to see detailed logs: `nonstop create my_project --verbose`

## Contact

Follow us, stay up to date or reach out on:

- [LinkedIn](https://www.linkedin.com/company/nonstop-io)
- [X.com](https://x.com/NonStopio)
- [Instagram](https://www.instagram.com/nonstopio_technologies/)
- [YouTube](https://www.youtube.com/@NonStopioTechnology)
- [Email](mailto:contact@nonstopio.com)

---

<p align="center">Made with ❤️ by <a href="https://github.com/ProjectAJ14">Ajay Kumar</a></p>

