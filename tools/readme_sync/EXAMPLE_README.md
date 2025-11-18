# Example README with Markers

This is an example showing the correct placement of section markers in a package README.

---

<!-- BEGIN:nonstop-header -->
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
</p>
<!-- END:nonstop-header -->

# example_package

<!-- BEGIN:badges -->
[![Build Status](https://img.shields.io/pub/v/example_package.svg)](https://github.com/nonstopio/flutter_forge/tree/main/packages/example_package)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
<!-- END:badges -->

A brief description of what your package does. This content is NOT managed and can be customized per package.

## Features

- Feature 1
- Feature 2
- Feature 3

**Note**: This section is package-specific and won't be touched by the sync tool.

<!-- BEGIN:getting-started -->
## Getting Started

1. Open your project's `pubspec.yaml` file.
2. Add the `example_package` package to your dependencies, replacing `[version]` with the latest version:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     example_package: ^[version]
   ```
3. Run `flutter pub get` to fetch the package.
<!-- END:getting-started -->

<!-- BEGIN:import-package -->
## Import the Package

```dart
import 'package:example_package/example_package.dart';
```
<!-- END:import-package -->

## Usage

This section contains package-specific usage examples and is NOT managed by the sync tool.

### Basic Example

```dart
// Your package-specific example code here
void main() {
  // Example usage
}
```

### Advanced Example

```dart
// More complex examples
class MyExample {
  // Implementation
}
```

## Configuration

Any package-specific configuration details go here. This content is preserved.

## API Reference

Document your package's API here. This is package-specific content.

## Troubleshooting

Common issues and solutions specific to your package.

---

<!-- BEGIN:contributing -->
## Contributing

We welcome contributions in various forms:

- Proposing new features or enhancements.
- Reporting and fixing bugs.
- Engaging in discussions to help make decisions.
- Improving documentation, as it is essential.
- Sending Pull Requests is greatly appreciated!

A big thank you to all our contributors! 🙌
<!-- END:contributing -->

---

<!-- BEGIN:connect -->
## 🔗 Connect with NonStop

<p align="center">
  <a href="https://www.linkedin.com/company/nonstopio"><img src="https://img.shields.io/badge/-LinkedIn-blue?style=flat-square&logo=Linkedin&logoColor=white" alt="LinkedIn"></a>
  <a href="https://x.com/nonstopio"><img src="https://img.shields.io/badge/-X.com-000000?style=flat-square&logo=X&logoColor=white" alt="X.com"></a>
  <a href="https://www.instagram.com/nonstopio/"><img src="https://img.shields.io/badge/-Instagram-E4405F?style=flat-square&logo=Instagram&logoColor=white" alt="Instagram"></a>
  <a href="https://www.youtube.com/@nonstopio"><img src="https://img.shields.io/badge/-YouTube-FF0000?style=flat-square&logo=YouTube&logoColor=white" alt="YouTube"></a>
  <a href="mailto:hello@nonstopio.com"><img src="https://img.shields.io/badge/-Email-D14836?style=flat-square&logo=Gmail&logoColor=white" alt="Email"></a>
</p>
<!-- END:connect -->

---

<!-- BEGIN:star-footer -->
<div align="center">

>  ⭐ Star us on [GitHub](https://github.com/nonstopio/flutter_forge) if this helped you!

</div>
<!-- END:star-footer -->

<!-- BEGIN:license -->
## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
<!-- END:license -->

<!-- BEGIN:founded-by -->
<div align="center">

> 🎉 [Founded by Your Name](https://github.com/yourusername) 🎉**

</div>
<!-- END:founded-by -->

---

## Key Points About Markers

### ✅ Correct Usage

1. **Exact syntax**: `<!-- BEGIN:section-id -->` and `<!-- END:section-id -->`
2. **Case-sensitive**: Section IDs must match exactly
3. **No extra spaces**: Markers must be exact
4. **Paired properly**: Every BEGIN must have matching END
5. **Full lines**: Markers should be on their own lines

### ❌ Common Mistakes

```markdown
<!-- BEGIN: section-id -->          ❌ Extra space after colon
<!-- Begin:section-id -->            ❌ Wrong capitalization
<!-- BEGIN:section-id-->             ❌ Missing space before -->
<!--BEGIN:section-id -->             ❌ Missing space after <!--
<!-- BEGIN:section-id -->
Some content
<!-- END:different-id -->            ❌ Mismatched section IDs
```

### 📋 Available Section IDs

- `nonstop-header`
- `badges`
- `getting-started`
- `import-package`
- `contributing`
- `connect`
- `star-footer`
- `license`
- `founded-by`

### 🎯 Best Practices

1. **Place markers around entire sections** including headings
2. **Keep package-specific content outside markers**
3. **Maintain blank lines** between sections for readability
4. **Use horizontal rules (`---`)** to visually separate sections
5. **Test with --dry-run** before applying changes
6. **Validate with --validate** after adding markers

### 🔄 Workflow

1. Copy this example as a starting point
2. Replace `example_package` with your package name
3. Add your package-specific content in unmarked sections
4. Run validation: `dart run tools/readme_sync/readme_sync.dart --validate --package your_package`
5. Preview changes: `dart run tools/readme_sync/readme_sync.dart --dry-run --package your_package`
6. Apply sync: `dart run tools/readme_sync/readme_sync.dart --package your_package`
