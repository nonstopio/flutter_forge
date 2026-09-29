# analytics

Event tracking for Nonstop Example behind the `AnalyticsClient` interface,
with a Firebase Analytics implementation, a route observer for screen views and
a static `AnalyticsHelper` facade for UI code.

## Initialise

Firebase must be initialised and a `Logger` registered.

```dart
import 'package:analytics/analytics.dart' as analytics;

await analytics.init(
  config: const analytics.DefaultAnalyticsConfig(
    enableAnalytics: !kDebugMode,
    enableDebugLogging: kDebugMode,
  ),
);
```

`init` applies the config to Firebase, then registers `AnalyticsClient` and
`AnalyticsConfig`. SDK failures during `init` propagate.

## Configure

| `DefaultAnalyticsConfig` field | Default | Effect |
| --- | --- | --- |
| `enableAnalytics` | `true` | collection on/off; when off, events are skipped |
| `enableDebugLogging` | `false` | logs event names (never parameters or user ids) at debug |
| `userId` | `null` | initial analytics user id |
| `defaultUserProperties` | `null` | user properties set at startup |

`setAnalyticsCollectionEnabled` changes collection at runtime.

## Screen tracking

`AnalyticsRouteObserver` logs a `screen_view` for every named `PageRoute` on
push, pop (the route returned to) and replace:

```dart
GoRouter(
  observers: [
    AnalyticsRouteObserver(
      client: di.get<AnalyticsClient>(),
      logger: di.get<Logger>(),
    ),
  ],
  routes: [...],
);
```

## Logging events

From UI code, use `AnalyticsHelper`. It is the one allowed locator facade: it
resolves the registered client per call, does nothing when analytics is not
registered, and logs instead of throwing.

```dart
await AnalyticsHelper.logEvent(
  AnalyticsEvents.feature.tutorialCompleted,
  parameters: {'tutorial_id': 'getting_started', 'duration_seconds': 120},
);
await AnalyticsHelper.logSignIn(method: 'google');
await AnalyticsHelper.logFeatureUsed('export');
await AnalyticsHelper.logButtonPressed('get_started', screenName: 'home');
await AnalyticsHelper.logAppError('network_timeout');
```

Elsewhere, inject `AnalyticsClient`, which also offers `logScreenView`,
`logAppOpen`, `logLogin`, `logSignUp`, `logPurchase`, `setUserId`,
`setUserProperty` and `resetAnalyticsData`.

Event names live in `AnalyticsEvents` (`user`, `auth`, `navigation`, `feature`,
`error`, `app`, `profile`); add your own groups there rather than using string
literals.

Parameter values are converted to what Firebase accepts: `String` and `num`
pass through, `bool` becomes `'true'`/`'false'`, other objects use
`toString()`, and `null` entries are dropped.

## Errors

After `init`, client methods catch SDK failures and log them; analytics never
crashes the app.

## Privacy rules

- User ids are never written to the log.
- Do not put personal data (emails, names, raw ids, free-text errors from the
  backend) into event parameters or user properties.
- Call `resetAnalyticsData()` and `setUserId(null)` on sign-out.
