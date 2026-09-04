# Crashlytics

Firebase Crashlytics integration package for {{name.titleCase()}} - providing comprehensive crash reporting and error tracking capabilities.

[![nonstop_cli](https://img.shields.io/badge/started%20with-nonstop_cli-166C4E.svg?style=flat-square)](https://pub.dev/packages/nonstop_cli)
[![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)

## Features ✨

- 🔥 **Firebase Crashlytics Integration** - Complete Firebase Crashlytics implementation
- 🚀 **Automatic Error Handling** - Catches Flutter framework errors automatically
- 👤 **User Context** - Track crashes with user information and metadata
- 🔑 **Custom Attributes** - Add custom key-value pairs for debugging
- 📊 **Custom Logging** - Log custom messages for crash analysis
- ⚙️ **Configurable** - Flexible configuration for different environments
- 🧩 **DI Integration** - Seamless integration with dependency injection
- 🛡️ **Type Safe** - Full TypeScript-style type safety with Dart

## Installation 💻

Add to your `pubspec.yaml`:

```yaml
dependencies:
  crashlytics:
    path: ../packages/crashlytics
```

## Quick Start 🚀

### 1. Initialize in your app

```dart
import 'package:crashlytics/crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize crashlytics with default config
  await crashlytics.init();
  
  runApp(MyApp());
}
```

### 2. Use the service

```dart
import 'package:crashlytics/crashlytics.dart';
import 'package:di/di.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final CrashlyticsService _crashlytics;

  @override
  void initState() {
    super.initState();
    _crashlytics = di.get<CrashlyticsService>();
  }

  void _reportError() async {
    try {
      // Some risky operation
      throw Exception('Something went wrong!');
    } catch (error, stackTrace) {
      // Report the error
      await _crashlytics.reportError(
        error, 
        stackTrace: stackTrace,
        context: {'feature': 'user_action', 'screen': 'home'},
      );
    }
  }
}
```

## Configuration ⚙️

### Basic Configuration

```dart
import 'package:crashlytics/crashlytics.dart';

await crashlytics.init(
  config: CrashlyticsConfig(
    enableInDebugMode: false,
    enableAutomaticDataCollection: true,
    enableCustomLogs: true,
    logBufferSize: 100,
    enableUserMetadata: true,
    customKeys: {
      'app_version': '1.0.0',
      'environment': 'production',
    },
  ),
);
```

### Advanced Configuration

```dart
// Custom configuration for different environments
final config = kDebugMode 
  ? CrashlyticsConfig(
      enableInDebugMode: true,
      enableAutomaticDataCollection: false,
      customKeys: {'environment': 'debug'},
    )
  : CrashlyticsConfig(
      enableAutomaticDataCollection: true,
      logBufferSize: 200,
      customKeys: {'environment': 'production'},
    );

await crashlytics.init(config: config);
```

## Usage Examples 📝

### Error Reporting

```dart
final crashlytics = di.get<CrashlyticsService>();

// Report a non-fatal error
await crashlytics.reportError(
  Exception('Network timeout'),
  stackTrace: StackTrace.current,
  context: {'endpoint': '/api/users', 'timeout': '30s'},
);

// Report a fatal error
await crashlytics.reportError(
  error,
  stackTrace: stackTrace,
  fatal: true,
  userId: 'user123',
);
```

### User Context

```dart
// Set user information
await crashlytics.setUser(
  userId: 'user123',
  email: 'user@example.com',
  name: 'John Doe',
  customAttributes: {
    'subscription': 'premium',
    'last_login': DateTime.now().toIso8601String(),
  },
);

// Clear user information (e.g., on logout)
await crashlytics.clearUser();
```

### Custom Logging

```dart
// Log custom messages
await crashlytics.logMessage('User completed onboarding');
await crashlytics.logMessage('API call started: /users/profile');

// Set custom attributes
await crashlytics.setCustomAttributes({
  'feature_flag_a': true,
  'api_version': 'v2',
  'device_type': 'mobile',
});

// Set individual custom attribute
await crashlytics.setCustomAttribute('current_screen', 'profile');
```

### Manual Crash Reporting

```dart
// Use the client directly for advanced scenarios
final client = di.get<CrashlyticsClient>();

await client.recordError(
  CustomException('Database connection failed'),
  StackTrace.current,
  fatal: false,
  information: ['Database host: db.example.com', 'Connection timeout: 30s'],
);
```

## API Reference 📚

### CrashlyticsService

Main service class for crash reporting:

| Method | Description |
|--------|-------------|
| `reportError()` | Report an error or exception |
| `reportFlutterError()` | Report Flutter framework errors |
| `logMessage()` | Log custom messages |
| `setUser()` | Set user information |
| `clearUser()` | Clear user information |
| `setCustomAttributes()` | Set multiple custom attributes |
| `setCustomAttribute()` | Set single custom attribute |
| `setCrashReportingEnabled()` | Enable/disable crash reporting |
| `sendPendingReports()` | Send unsent crash reports |
| `deletePendingReports()` | Delete unsent crash reports |

### CrashlyticsConfig

Configuration options:

| Property | Default | Description |
|----------|---------|-------------|
| `enableInDebugMode` | `false` | Enable crashlytics in debug mode |
| `enableAutomaticDataCollection` | `true` | Enable automatic error collection |
| `enableCustomLogs` | `true` | Enable custom logging |
| `logBufferSize` | `100` | Maximum log buffer size |
| `enableUserMetadata` | `true` | Enable user metadata collection |
| `customKeys` | `{}` | Default custom keys |

## Integration with DI 🔧

The package integrates seamlessly with the DI container:

```dart
// Get services from DI
final crashlytics = di.get<CrashlyticsService>();
final client = di.get<CrashlyticsClient>();
final config = di.get<CrashlyticsConfig>();

// Services are automatically disposed when DI container is disposed
```

## Testing 🧪

```dart
// Update test file
import 'package:flutter_test/flutter_test.dart';
import 'package:crashlytics/crashlytics.dart';

void main() {
  group('Crashlytics', () {
    test('can be initialized', () async {
      // Test initialization
      expect(() => crashlytics.init(), isNot(throwsException));
    });
  });
}
```

## Best Practices 💡

1. **Initialize Early**: Initialize crashlytics as early as possible in your app
2. **Environment Configuration**: Use different configs for debug/release builds
3. **User Privacy**: Be mindful of user privacy when setting user metadata
4. **Context is Key**: Always provide context when reporting errors
5. **Test in Debug**: Enable debug mode during development to test integration
6. **Monitor Usage**: Regularly check Firebase console for crash reports

## Requirements 📋

- Flutter SDK >=3.19.0
- Dart SDK ^3.3.0
- Firebase project with Crashlytics enabled
- `core` and `di` packages from {{name.titleCase()}} monorepo

[flutter_install_link]: https://docs.flutter.dev/get-started/install