# crashlytics

Crash and non-fatal error reporting for {{name.titleCase()}} behind the
`CrashlyticsClient` interface, implemented with Firebase Crashlytics.

## Initialise

Firebase must be initialised and a `Logger` registered.

```dart
import 'package:crashlytics/crashlytics.dart' as crashlytics;

await crashlytics.init();
```

`init` initialises the client, sends any unsent reports from a previous run,
then registers `CrashlyticsClient` and `CrashlyticsConfig`. If startup fails,
nothing is registered, the error propagates and `init` can be retried.

## Configure

| `CrashlyticsConfig` field | Default | Effect |
| --- | --- | --- |
| `enableInDebugMode` | `false` | collect in debug builds (release builds always collect) |
| `installGlobalErrorHandlers` | `true` | report uncaught Flutter and platform errors as fatal; previous handlers still run and are restored on `dispose()` |
| `enableCustomLogs` | `true` | forward `log()` breadcrumbs |
| `logBufferSize` | `100` | breadcrumbs kept locally in `bufferedLogs` |
| `enableUserMetadata` | `true` | allow `setUserIdentifier` / `setUserMetadata` |
| `customKeys` | `{}` | keys set once at startup |

## Reporting

```dart
final crash = di.get<CrashlyticsClient>();

await crash.recordError(error, stack);                // non-fatal
await crash.recordError(error, stack, fatal: true);   // fatal
await crash.recordFlutterFatalError(
  error,
  stack,
  context: {'screen': 'checkout'},                    // set as custom keys
);
await crash.log('checkout started');
await crash.setUserMetadata(
  UserMetadata(userId: user.uid, customAttributes: {'plan': 'pro'}),
);
await crash.setCustomKey('build_flavor', 'staging');
```

Also available: `setUserIdentifier`, `setCustomKeys`,
`setCrashlyticsCollectionEnabled`, `isCrashlyticsCollectionEnabled`,
`sendUnsentReports`, `deleteUnsentReports`, `checkForUnsentReports`.

## Errors

Calls made before `init` completes are skipped. After that, SDK failures are
logged and contained; reporting never throws.

## Privacy rules

- `UserMetadata` carries only an opaque `userId` plus custom attributes; do not
  put emails, names or other personal data in either.
- `log()` messages and custom key values are sent to Crashlytics but never
  written to the local debug log.
