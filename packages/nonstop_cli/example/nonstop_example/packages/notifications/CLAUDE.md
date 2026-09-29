# Nonstop Example: `packages/notifications`

Owns Firebase Cloud Messaging subscriptions, permission requests, the FCM token
lifecycle (fetch, backend registration, refresh), a persisted installation ID
and badge clearing. It does not own presentation or navigation: toasts and
routing are `NotificationConfig` callbacks from the app. Layer 3: depends on
`core`, `di`, `network`.

Read the root `CLAUDE.md` and `packages/CLAUDE.md` first.

## Public API

| Symbol | Kind |
|---|---|
| `NotificationClient` / `FirebaseNotificationClient` | `abstract interface class` / FCM implementation: `init`, `requestPermissions`, `getFCMToken`, `handleForegroundNotification(message)`, `handleNotificationOpened(message)`, `clearBadge`, `unregisterDevice`, `fcmToken`, `deviceId`, `dispose` |
| `init({config, messaging})`, `registerNotificationWithDI` | Registers config, `DeviceInfo`, managers and `NotificationClient` (with `dispose`) |
| `NotificationConfig` / `DefaultNotificationConfig` | `onForeground(title, body)`, `onOpenRoute(route)` |
| `NotificationTokenManager` / `FirebaseTokenManager(logger:, networkClient:, deviceInfo:, firebaseMessaging:)` | `getFCMToken`, `registerToken` (returns device ID), `unRegisterToken(deviceId)`, `handleTokenRefresh` |
| `NotificationPermissionManager` / `FirebasePermissionManager(logger:, firebaseMessaging:)` | `requestPermissions({provisional})` |
| `DeviceInfo` / `DeviceInfoImpl`, `InstallationIdStore` / `SharedPreferencesInstallationIdStore` | Installation ID + device label |
| `DeviceTokenRequest` | Backend registration DTO (`json_serializable`) |
| `NotificationException` | Extends `CoreException`; thrown by `FirebasePermissionManager` |
| `handleBackgroundNotification` | Top-level `@pragma('vm:entry-point')` background handler (intentionally a no-op) |

## Layout

| Path | Responsibility |
|---|---|
| `lib/notifications.dart` | Barrel and `init` |
| `lib/src/di/notification_di.dart` | Composition edge: resolves `Logger`/`NetworkClient` once and injects them into every service |
| `lib/src/client/` | Contract, `FirebaseNotificationClient`, background handler |
| `lib/src/services/` | Token manager (backend calls), permission manager |
| `lib/src/device_info/` | `DeviceInfo`, installation ID store |
| `lib/src/models/` | Token DTO; `device_token_models.g.dart` is generated |
| `lib/src/config/`, `lib/src/exceptions/` | Config callbacks, `NotificationException` |

## Rules

- **Subscription ownership.** Only `FirebaseNotificationClient` listens to `onMessage`, `onMessageOpenedApp` and `onTokenRefresh`. `init()` is idempotent and concurrent calls share one future; a startup failure cancels all subscriptions and rethrows so `init()` can be retried. `dispose()` cancels them and blocks late startup work; `init()` after dispose throws `StateError`.
- **Permission denied** means no subscriptions and no token; a later `init()` asks again.
- **Route safety.** `handleNotificationOpened(message)` (initial message and `onMessageOpenedApp` alike) forwards `data['route']` only if it is a `String` starting with `/` and not `//`. Anything else is ignored.
- **Contained failures.** Callback, stream, badge and token-registration errors are logged, never thrown. A failed registration clears `fcmToken`/`deviceId` and returns null.
- **Backend rejection is a failure.** `FirebaseTokenManager` passes responses through `handleSuccessResponse`, so an `ErrorResponse` throws.
- **Privacy.** Token logs say "obtained"/"registered", never the token. The installation ID is 16 random bytes (`Random.secure`) in `SharedPreferences` key `nonstop.installation_id`; no hardware identifiers.
- **Background isolate** has no DI or navigation: keep `handleBackgroundNotification` self-contained.
- **Sign-out.** `unregisterDevice()` deletes this device's backend registration and clears `deviceId`; no-op if never registered. Backend errors propagate; the app's `AppRouter.signOut` logs them and still signs out.
- **Injected (constructor, never `di.get` inside services):** `FirebaseMessaging`, `Logger`, `NetworkClient`, `DeviceInfo`, managers, and optional streams/badge/background-registration functions on the client; `DeviceInfoPlugin`, `InstallationIdStore`, `createId` on `DeviceInfoImpl`.

## Common changes

- **Handle a new payload key or route rule:** edit `handleNotificationOpened` in `firebase_notification_client.dart`; add cases to the rejected-data loop in `test/client_test.dart` ("foreground, opened, initial and token-refresh events reach their owners").
- **Change the device-token endpoint or payload:** edit `notification_token_manager.dart` and `device_token_models.dart` (`DeviceTokenRequest`), run `dart run melos run generate`, update "registers metadata, refreshes and unregisters" in `test/services_test.dart`.
- **React to a notification in the app:** pass a new callback through `NotificationConfig` from `apps/nonstop_example/lib/bootstrap.dart`; do not import app code here.

## Tests

| File | Covers |
|---|---|
| `test/client_test.dart` | Single init, denial/retry, event routing, route filtering, contained failures, `unregisterDevice`, failed-startup cleanup, dispose |
| `test/services_test.dart` | `init` composition and failure, permission status mapping, token manager calls and backend rejection, DTO JSON |
| `test/device_info_test.dart` | ID persistence and concurrency, storage failure/retry, device name fallback |

Doubles: mocktail `FirebaseMessaging`, `NotificationTokenManager`, `NotificationPermissionManager`, `NetworkClient`, `DeviceInfo`; broadcast `StreamController`s for FCM streams; `_Store` for `InstallationIdStore`; `SharedPreferences.setMockInitialValues`.

`dart run melos exec --scope=notifications -- flutter test`; `dart run melos run coverage` must stay 100%.

## Gotchas

- `init` needs `Logger` and `NetworkClient` in `di` first (`registerNotificationWithDI` resolves them); call `network.init` before it, as bootstrap does.
- Backend endpoints required: `POST /device-tokens/me` and `DELETE /device-tokens/me/{deviceId}` on the configured `baseUrl`.
- `device_token_models.g.dart` is generated: `dart run melos run generate`.
- The client's `init()` is run by `NotificationLifecycle` in the app after the first frame, not by the package `init`.
