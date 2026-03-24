<p align="center">
  <a href="https://nonstopio.com">
    <img src="https://github.com/nonstopio.png" alt="Nonstop Logo" height="128" />
  </a>
  <h1 align="center">NonStop</h1>
  <p align="center">Digital Product Development Experts for Startups & Enterprises</p>
  <p align="center">
    <a href="https://nonstopio.com/about-us">About</a> |
    <a href="https://nonstopio.com">Website</a>
  </p>

<h1>🚀 NonStop CLI</h1>

**⚡ Supercharge your Flutter development with mono-repo magic**

[![pub package](https://img.shields.io/pub/v/nonstop_cli.svg?label=nonstop_cli&logo=dart&color=blue&style=for-the-badge)](https://pub.dev/packages/nonstop_cli)
[![License](https://img.shields.io/badge/license-MIT-purple.svg?style=for-the-badge)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-Ready-02569B.svg?style=for-the-badge&logo=flutter)](https://flutter.dev)

---

## 🎯 What is NonStop CLI?

The NonStop CLI simplifies Flutter project setup and management, with a focus on mono-repository structures using Melos.
It provides standardized templates, validation tools for your development environment, and ongoing updates for the best
experience.

> 🎨 **Perfect for teams** who want consistent project structure and streamlined development workflows

## 🚀 Quick Start

```bash
# Install NonStop CLI globally
dart pub global activate nonstop_cli

# Check your development environment
nonstop doctor

# Create your first mono-repo project
nonstop create my_awesome_app

# Navigate and start coding!
cd my_awesome_app
```

## 📖 Commands

### 🏗️ `create` - Project Generator

Creates a new Flutter project based on predefined templates.

```bash
nonstop create <project-name> [arguments]
```


#### 🔧 Arguments

| Argument             | Alias    | Description                                           | Default                                                             |
|----------------------|----------|-------------------------------------------------------|---------------------------------------------------------------------|
| `--template`         | `-t`     | Type of project to create                             | `mono`                                                              |
| `--output-directory` | `-o`     | Output directory for the new project                  | Current directory                                                   |
| `--description`      | `--desc` | Description for the new project                       | "A Melos-managed project for mono-repo, created using NonStop CLI." |
| `--org-name`         | `--org`  | Organization name for the new project                 | `com.example`                                                       |

#### 📦 Template Options

<div align="center">

| Template  | 🎯 Description                                                   | 📁 Structure Created                                                    |
|-----------|------------------------------------------------------------------|-------------------------------------------------------------------------|
| `mono`    | 🏢 Generate a Flutter application along with mono-repo (default) | Complete mono-repo structure with apps, features, packages, and plugins |
| `package` | 📦 Generate a Flutter package for a Melos-managed mono-repo      | Flutter package compatible with mono-repo structure                     |
| `app`     | 📱 Generate a Flutter application for a Melos-managed mono-repo  | Flutter application configured for mono-repo structure                  |
| `plugin`  | 🔌 Generate a Flutter plugin for a Melos-managed mono-repo       | Flutter plugin compatible with mono-repo structure                      |

</div>

#### 💡 Examples

<details>
<summary><strong>🏢 Create a mono-repo project</strong></summary>

```bash
nonstop create youtube
```

This creates the following structure:

```
youtube/
├── 📱 apps/
│   └── youtube/
├── 🧩 features/
├── 📦 packages/
├── 🔌 plugins/
├── 📋 analysis_options.yaml
├── 📖 README.md
├── ⚙️ melos.yaml
└── 📄 pubspec.yaml
```

</details>

<details>
<summary><strong>📦 Create a Flutter package for a mono-repo</strong></summary>

```bash
nonstop create core --template package
```

</details>

<details>
<summary><strong>📱 Create a Flutter application for a mono-repo</strong></summary>

```bash
nonstop create youtube_studio --template app -o ./apps
```

</details>

<details>
<summary><strong>🏢 Create with custom organization</strong></summary>

```bash
nonstop create youtube_music --org-name com.youtube
```

</details>

<details>
<summary><strong>📁 Create in a specific directory</strong></summary>

```bash
nonstop create youtube -o ./projects
```

</details>

---

### 🩺 `doctor` - Environment Checker

Checks your development environment to ensure all required tools are installed and configured correctly.

```bash
nonstop doctor
```

#### 🔍 What it checks:

<div align="center">

| Tool            | 📋 Analysis                            |
|-----------------|----------------------------------------|
| 🐦 **Flutter**  | Installation and version compatibility |
| 🎯 **Dart SDK** | Installation and version compatibility |
| 🔧 **Melos**    | Installation and version compatibility |

</div>

#### 📊 Status Indicators:

- ✅ **Success**: Tool is installed and working properly
- ⚠️ **Partial**: Tool is installed but has issues
- ❌ **Missing**: Tool is not installed or not found

<div align="center">
<img width="678" alt="nonstop doctor output" src="https://github.com/user-attachments/assets/fab74b37-b5f7-4ad1-b0a3-d3d028fa949e">
</div>

---

### 🔄 `update` - Stay Current

Updates the NonStop CLI to the latest version automatically.

```bash
nonstop update
```

#### 🚀 What it does:

1. 🔍 **Checks** the current installed version
2. 🌐 **Compares** with the latest version on pub.dev
3. ⬆️ **Updates** to the latest version if needed

---

## 🔄 Common Workflows

### 🚀 Setting up a new Flutter project with mono-repo

```bash
# 1️⃣ Check if your environment is properly set up
nonstop doctor

# 2️⃣ Create a new Flutter project with mono-repo structure
nonstop create youtube

# 3️⃣ Navigate to the project directory
cd youtube

# 🎉 You're ready to code!
```

### 📦 Adding a new package to an existing mono-repo

```bash
# 1️⃣ Navigate to your mono-repo root
cd youtube/packages

# 2️⃣ Create a new package
nonstop create core --template package

# 3️⃣ Update dependencies
melos bootstrap
```

### 📱 Adding a new app to an existing mono-repo

```bash
# 1️⃣ Create a new app in the apps directory
nonstop create youtube_studio --template app -o ./apps

# 2️⃣ Update dependencies
melos bootstrap
```

---

## 🛠️ Troubleshooting

### ❌ CLI not found after installation

Ensure the Dart SDK bin directory is in your PATH. Follow the instructions at:
📖 [Running a script from your PATH](https://dart.dev/tools/pub/cmd/pub-global#running-a-script-from-your-path)

### ⚠️ Doctor command shows issues

If the `doctor` command shows issues with your development environment:

1. 🐦 Ensure Flutter is installed correctly: [Flutter Installation](https://docs.flutter.dev/get-started/install)
2. 🎯 Verify your Dart SDK installation: `dart --version`
3. 🔧 Install Melos if missing: `dart pub global activate melos`

### 🚫 Template generation fails

If template generation fails:

1. 🔐 Ensure you have proper permissions in the target directory
2. ✅ Check if the project name is valid (should follow Dart package naming rules)
3. 🔍 Run with the `--verbose` flag to see detailed logs: `nonstop create my_project --verbose`

---

## ⚙️ Global Options

<div align="center">

| Option      | Alias | 📝 Description                                         |
|-------------|-------|--------------------------------------------------------|
| `--version` | `-v`  | 📊 Print the current version of the CLI                |
| `--verbose` |       | 🔍 Enable verbose logging including all shell commands |
| `--help`    | `-h`  | ❓ Display help information for commands                |

</div>

---

## 🔗 Command Aliases

<div align="center">

**Choose your preferred way to invoke the CLI:**

```bash
nonstop create my_app    # Full command
ns create my_app         # Short alias
nsio create my_app       # Alternative alias
```

| Alias     | 📝 Description            |
|-----------|---------------------------|
| `nonstop` | 🎯 Full command name      |
| `ns`      | ⚡ Quick shorthand         |
| `nsio`    | 🚀 Alternative short form |

</div>

---

## 🔗 Connect with NonStop

<div align="center">

**Stay connected and get the latest updates!**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/company/nonstop-io)
[![X.com](https://img.shields.io/badge/X-000000?style=for-the-badge&logo=x&logoColor=white)](https://x.com/NonStopio)
[![Instagram](https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/nonstopio_technologies/)
[![YouTube](https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@NonStopioTechnology)
[![Email](https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:contact@nonstopio.com)

</div>

---

<div align="center">

>  ⭐ Star us on [GitHub](https://github.com/nonstopio/flutter_forge) if this helped you!

</div>

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

<div align="center">

> 🎉 [Founded by Ajay Kumar](https://github.com/ProjectAJ14) 🎉**

</div>
