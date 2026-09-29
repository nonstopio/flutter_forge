# notifications

Firebase Cloud Messaging for Nonstop Example: permission requests, message
routing, badge clearing and device-token registration with your backend.

## Initialise

Firebase must be initialised, and a `Logger` and a `NetworkClient` must be
registered (the network module does that).

```dart
import 'package:notifications/notifications.dart' as notifications;

await notifications.init(
  config: notifications.NotificationConfig(
    onForeground: (title, body) => Toast.notification(title: title, body: body),
    onOpenRoute: (route) => router.go(route),
  ),
);
```

`init` registers `NotificationClient`, `NotificationTokenManager`,
`NotificationPermissionManager`, `DeviceInfo` and `NotificationConfig`. Nothing
talks to the device until `NotificationClient.init()` runs (the app's
`NotificationLifecycle` widget calls it after the first frame). It:

1. requests permission (stops quietly if denied; call `init()` again to retry),
2. listens for foreground, opened and token-refresh events,
3. handles the message that launched the app, if any,
4. fetches the FCM token and registers it with the backend,
5. clears the app badge where supported.

## Configure

| `NotificationConfig` field | Called with |
| --- | --- |
| `onForeground` | title and body of a message received while the app is open |
| `onOpenRoute` | the `route` data field of a tapped notification |

Background messages are handled by `handleBackgroundNotification`, which is a
no-op: it runs in a separate isolate without DI or navigation.

## Backend contract

| Call | Request |
| --- | --- |
| register (on start and token refresh) | `POST /device-tokens/me` with `fcmToken`, `deviceId`, `deviceName`, `deviceType` |
| `NotificationClient.unregisterDevice()` | `DELETE /device-tokens/me/{deviceId}` |

Call `unregisterDevice()` on sign-out. `dispose()` only cancels subscriptions;
it does not unregister the device.

## Errors

- Startup failures in `NotificationClient.init()` cancel subscriptions and are
  rethrown; the call can be retried.
- Permission errors surface as `NotificationException`.
- Token, presentation, navigation and badge failures after startup are logged
  and contained.
- `unregisterDevice()` propagates backend failures so the caller can decide
  whether sign-out continues.

## Privacy rules

- `deviceId` is a random installation id kept in shared preferences, not a
  hardware identifier.
- FCM tokens are never written to the log.
- Notifications can open only local app paths (`/...`); absolute URLs and
  `//host` routes are ignored.
