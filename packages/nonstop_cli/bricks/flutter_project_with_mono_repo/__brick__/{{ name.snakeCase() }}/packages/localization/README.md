# Localization

Localization package for {{name.titleCase()}} using i69n for type-safe internationalization.

[![nonstop_cli](https://img.shields.io/badge/started%20with-nonstop_cli-166C4E.svg?style=flat-square)](https://pub.dev/packages/nonstop_cli)
[![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)

## Features ✨

- **Type-safe translations** - Generated classes with compile-time string validation
- **Easy integration** - Simple API with global `strings` access
- **Organized structure** - Categorized messages (auth, profile, generic, etc.)
- **Future-ready** - Built for multi-language support
- **Melos integration** - Seamless monorepo workflow

## Installation 💻

Add to your `pubspec.yaml`:

```yaml
dependencies:
  localization:
    path: ../packages/localization
```

## Usage 🚀

### Basic Usage

```dart
import 'package:localization/localization.dart';

// Simple access to any string
Text(strings.auth.login);           // "Login"
Text(strings.generic.ok);           // "OK"
Text(strings.profile.name);         // "Name"
Text(strings.validation.required_field); // "This field is required"
```

### In Widgets

```dart
class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _login(),
      child: Text(strings.auth.login),
    );
  }
}
```

### Error Handling

```dart
void showError() {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(strings.errors.network_error)),
  );
}
```

### Form Validation

```dart
String? validateEmail(String? value) {
  if (value?.isEmpty ?? true) {
    return strings.validation.required_field;
  }
  if (!value!.contains('@')) {
    return strings.validation.invalid_email;
  }
  return null;
}
```

## Development 🛠️

### Adding New Strings

1. Edit `lib/messages.i69n.yaml`:
```yaml
new_category:
  new_message: "New Message Text"
  another_message: "Another Message"
```

2. Generate code:
```bash
# From the monorepo root
melos run generate:i69n

# Or from this package
dart run build_runner build --delete-conflicting-outputs
```

3. Use the new strings:
```dart
Text(strings.new_category.new_message); // "New Message Text"
```

### Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

### Linting

```bash
# From monorepo root
melos run lint

# Or from this package
dart format . && dart analyze --fatal-infos .
```

## Advanced Usage 🔧

### Using LocalizationProvider

```dart
import 'package:localization/localization.dart';

// Initialize (currently only supports English)
LocalizationProvider.initialize();

// Check supported locales
if (LocalizationProvider.isLocaleSupported('en')) {
  // Handle supported locale
}

// Simple access to any string
Text(strings.auth.login);           // "Login"

```

### Future Multi-language Support

This package is designed to support multiple languages in the future. The current implementation supports English only, but the structure is ready for:

- Spanish (`es`)
- French (`fr`)
- German (`de`)
- Additional languages as needed

## Package Structure 📁

```
packages/localization/
├── lib/
│   ├── localization.dart          # Main export file
│   ├── messages.i69n.dart         # Generated i69n classes
│   ├── messages.i69n.yaml         # Translation source
│   └── src/
│       ├── localization_provider.dart # Advanced utilities
│       └── strings.dart           # Global strings instance
├── test/
│   └── localization_test.dart     # Comprehensive tests
├── build.yaml                     # i69n build configuration
└── pubspec.yaml                   # Package dependencies
```

[flutter_install_link]: https://docs.flutter.dev/get-started/install
