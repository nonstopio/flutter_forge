# Nonstop Example: `packages/crashlytics`

Owns crash and non-fatal error reporting behind `CrashlyticsClient`: the
Firebase Crashlytics adapter, global Flutter/platform error handlers, custom
keys, user metadata and breadcrumbs. It does not decide consent or what user
data is reported; the app does. Layer 2: depends on `core`, `di`.

Read the root `CLAUDE.md` and `packages/CLAUDE.md` first.

## Public API

| Symbol | Kind |
|---|---|
| `CrashlyticsClient` / `FirebaseCrashlyticsClient(config:, logger:, crashlytics:)` | `abstract interface class` / Firebase implementation: `initialize`, `recordError`, `recordFlutterFatalError`, `log`, `setUserIdentifier`, `setUserMetadata`, `setCustomKey(s)`, `isCrashlyticsCollectionEnabled`, `setCrashlyticsCollectionEnabled`, `send`/`delete`/`checkForUnsentReports`, `dispose`; plus `bufferedLogs`, `clearLogBuffer` on the implementation |
| `init({config, crashlytics})`, `registerCrashlyticsWithDI` | Initializes, sends pending reports, then registers `CrashlyticsConfig` and `CrashlyticsClient` (with `dispose`) |
| `CrashlyticsConfig` / `DefaultCrashlyticsConfig` | `enableInDebugMode`, `installGlobalErrorHandlers`, `enableCustomLogs`, `logBufferSize`, `enableUserMetadata`, `customKeys` |
| `UserMetadata` | `userId` (opaque, e.g. auth uid) and `customAttributes` |

## Layout

| Path | Responsibility |
|---|---|
| `lib/crashlytics.dart` | Barrel, `init`, `registerCrashlyticsWithDI` |
| `lib/src/client/` | Contract and `FirebaseCrashlyticsClient` |
| `lib/src/config/crashlytics_config.dart` | Config with value equality |
| `lib/src/models/` | `UserMetadata` |

## Rules

- **Only a fully initialized client is registered.** If `initialize()` or the unsent-report check throws, `registerCrashlyticsWithDI` disposes the client, logs, rethrows, and registers nothing; `init` can be retried.
- **Collection** is `config.enableInDebugMode || kReleaseMode`. Startup `customKeys` are applied before the client counts as initialized.
- **Handler ownership.** `installGlobalErrorHandlers` (default true) installs `FlutterError.onError` and `PlatformDispatcher.instance.onError`. Both record the error as fatal, then call the previous handler. `dispose()` puts the previous handlers back only if ours are still the installed ones. Never set these handlers anywhere else.
- **Failure policy.** After startup every call catches SDK errors and logs them. Before `initialize()`, or after `dispose()`, calls are no-ops (`recordError` logs a warning).
- **Opt-outs.** `enableCustomLogs: false` disables `log`; `enableUserMetadata: false` disables `setUserIdentifier` and `setUserMetadata`.
- **Privacy.** `UserMetadata` carries only an opaque `userId` and non-personal `customAttributes` (sent as custom keys); never put an email or name in either. `setUserIdentifier` does not log the ID, `setCustomKey` logs only the key, and `log` does not echo the message to the app logger.
- **Injected:** `FirebaseCrashlytics` and `Logger`. The breadcrumb buffer (`logBufferSize`, oldest dropped first) is stamped with `DateTime.now()`.

## Common changes

- **Add a reporting method:** declare it on `CrashlyticsClient`, implement it in `FirebaseCrashlyticsClient` with the `_isInitialized` guard and try/catch, add the call to `exerciseClient()` in `test/client_test.dart` (runs before init, after init, and with a failing SDK) and stub the SDK in `setUp`.
- **Add a config option:** add the field to `CrashlyticsConfig` and to `copyWith`, `toMap`, `toString`, `==`, `hashCode` and the `DefaultCrashlyticsConfig` constructor. Extend "crash configuration copying..." in `test/models_test.dart`.
- **Attach context to fatal Flutter errors:** use `recordFlutterFatalError(..., context:)`, which writes the context as custom keys first.

## Tests

| File | Covers |
|---|---|
| `test/client_test.dart` | Guarded no-ops, idempotent init, buffer trimming, contained SDK failures, retryable init, handler chaining and restore, `init` with and without pending reports, nothing registered on failure |
| `test/models_test.dart` | `UserMetadata`/config equality, hashing, `copyWith`, `toMap` |
| `test/crashlytics_test.dart` | Default and custom construction |

Doubles: mocktail `FirebaseCrashlytics` (`_Sdk`), `Logger`, `UserMetadata`. Handler tests save and restore the real `FlutterError.onError` / `PlatformDispatcher.instance.onError` in `finally`.

`dart run melos exec --scope=crashlytics -- flutter test`; `dart run melos run coverage` must stay 100%.

## Gotchas

- Tests that call `initialize()` with default config install global handlers; construct with `installGlobalErrorHandlers: false` unless the test restores them.
- `init` needs `Logger` in `di`, and runs only when Firebase is ready (see `apps/nonstop_example/lib/bootstrap.dart`), so consumers must handle a missing `CrashlyticsClient`.
- In debug builds collection is off unless `enableInDebugMode` is set; reports will not appear in the console.
