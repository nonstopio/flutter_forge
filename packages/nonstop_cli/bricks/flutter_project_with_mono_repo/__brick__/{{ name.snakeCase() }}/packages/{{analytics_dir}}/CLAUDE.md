# {{name.titleCase()}}: `packages/analytics`

Owns event tracking behind `AnalyticsClient`: the Firebase Analytics adapter,
the event-name catalog, screen tracking and static helpers. It does not own
consent or product policy (the app decides `enableAnalytics`), and holds no
feature logic. Layer 2: depends on `core`, `di`.

Read the root `CLAUDE.md` and `packages/CLAUDE.md` first.

## Public API

| Symbol | Kind |
|---|---|
| `AnalyticsClient` / `FirebaseAnalyticsClient(config, analytics:, logger:)` | `abstract interface class` / Firebase implementation: `logEvent`, `logCustomEvent`, `setUserId`, `setUserProperty`, `resetAnalyticsData`, `setAnalyticsCollectionEnabled`, `logScreenView`, `logAppOpen`, `logLogin`, `logSignUp`, `logPurchase`, `dispose`; plus `initialize()` and `@visibleForTesting static toFirebaseParameters` on the implementation |
| `init({config, analytics})`, `registerAnalyticsWithDI` | Awaits `initialize()`, registers `AnalyticsClient` (with `dispose`) and `AnalyticsConfig` |
| `AnalyticsConfig` (interface) / `DefaultAnalyticsConfig` | `enableAnalytics`, `enableDebugLogging`, `userId`, `defaultUserProperties`, `copyWith` |
| `AnalyticsEvent` | Name + parameters value object |
| `AnalyticsEvents` | Catalog: `user`, `auth`, `navigation`, `feature`, `error`, `app`, `profile` |
| `PredefinedEvents`, `PredefinedParameters` | Firebase standard names |
| `AnalyticsRouteObserver(client:, logger:)` | `NavigatorObserver` logging named `PageRoute`s |
| `AnalyticsHelper` | `abstract final class` of static fire-and-forget wrappers resolving `AnalyticsClient` from `di` per call |

## Layout

| Path | Responsibility |
|---|---|
| `lib/analytics.dart` | Barrel, `init`, `registerAnalyticsWithDI` |
| `lib/src/client/` | Contract and `FirebaseAnalyticsClient` |
| `lib/src/config/` | `AnalyticsConfig`, `DefaultAnalyticsConfig` |
| `lib/src/models/analytics_event.dart` | `AnalyticsEvent`, `PredefinedEvents`, `PredefinedParameters` |
| `lib/src/models/analytics_events.dart` | `AnalyticsEvents` catalog |
| `lib/src/observer/` | `AnalyticsRouteObserver` |
| `lib/src/utils/` | `AnalyticsHelper` |

## Rules

- **Analytics failures never break UI.** Every `FirebaseAnalyticsClient` call except `initialize()` catches and logs through `Logger.e`. `AnalyticsHelper` returns silently when no client is registered and catches client errors. `AnalyticsRouteObserver` tracks with `unawaited` and catches.
- **Startup is not swallowed.** `initialize()` rethrows SDK errors, so `init` fails and nothing is registered.
- **Collection switch.** `_enabled` starts from `config.enableAnalytics`; when false, `logEvent` returns without calling the SDK. `setAnalyticsCollectionEnabled` updates it only after the SDK call succeeds.
- **Parameters** go through `toFirebaseParameters`: nulls are dropped, `String`/`num` pass through, `bool` and other objects become `toString()`.
- **Documented locator facade.** `AnalyticsHelper` is the one allowed service-locator facade: it resolves the client via `di.has`/`di.get` on every call and is a silent no-op when none is registered. Do not add a static cache; code that needs results or testable wiring injects `AnalyticsClient` instead.
- **Privacy.** User IDs, property values and event parameters are never logged; debug logging (`enableDebugLogging`) names only the event or property. A test asserts user IDs stay out of the log. Do not add PII to event parameters.
- **Injected:** `FirebaseAnalytics` and `Logger`. The helpers' `timestamp` parameters use `DateTime.now()` (no clock).
- Screen tracking uses `RouteSettings.name`; unnamed or non-page routes are skipped. The app adds the observer in `apps/{{name.snakeCase()}}/lib/router/router.dart` only when `AnalyticsClient` is registered.

## Common changes

- **Add an event name:** add a getter to the right `_XxxEvents` class in `analytics_events.dart` (or a new group and a `static const` on `AnalyticsEvents`). Append it to both lists in `test/event_names_test.dart`; that test asserts exact strings and uniqueness.
- **Add a semantic helper:** add a static method to `AnalyticsHelper` that goes through `logEvent` or a client method with try/catch, then add it to the `operations` list in `test/helper_test.dart` (absent service, success and failure are covered in one test).
- **Add a client method:** declare it on `AnalyticsClient`, implement it with try/catch in `FirebaseAnalyticsClient`, cover success and SDK failure in `test/client_test.dart`. Any other `AnalyticsClient` implementation, including test fakes, must add it too.

## Tests

| File | Covers |
|---|---|
| `test/client_test.dart` | Semantic event names/params, `initialize` success and failure, null stripping, parameter coercion, user IDs never logged, collection toggle, contained SDK failures, `init` and helpers after `di.reset` |
| `test/helper_test.dart` | Every helper without/with/failing client, route observer push/pop/replace, `AnalyticsEvent` equality, config `copyWith` |
| `test/event_names_test.dart` | Stable, unique catalog strings |
| `test/analytics_test.dart` | Model and config construction |

Doubles: mocktail `FirebaseAnalytics` (`_Sdk`), `AnalyticsClient` (`_Client`), `Logger`.

`dart run melos exec --scope=analytics -- flutter test`; `dart run melos run coverage` must stay 100%.

## Gotchas

- `init` needs `Logger` registered first and Firebase initialized; bootstrap calls it only when Firebase is ready, so code must tolerate `AnalyticsClient` being absent (`di.has`).
