# Nonstop Example: `apps/nonstop_example`

The composition root (pubspec name `nonstop_example`). It boots modules, builds
the single `GoRouter`, passes cross-feature behavior (auth guard, sign-out,
post-auth landing) into features, and mounts the widget tree. It owns no
business logic, no feature screens and no service implementations; the only
app-owned screen is the splash.

Read the root `CLAUDE.md` and `apps/CLAUDE.md` first.
Load the `design-system` skill before changing UI.

## Public API

Nothing depends on the app. These are its seams, used by its own tests:

| Symbol | File | Used for |
|---|---|---|
| `startApp({initialize, mount})` | `lib/main.dart` | Entrypoint with injectable bootstrap and `runApp` |
| `init({onOpenRoute, firebaseOptions, useEmulators})` | `lib/bootstrap.dart` | Module bring-up; `firebaseOptions` overrides `DefaultFirebaseOptions` in tests |
| `App({required router})` | `lib/app.dart` | `MaterialApp.router` inside `GlobalEventChannelProvider` + `DesignSystemWrapper` |
| `AppRouter.createRouter({initialLocation})` | `lib/router/router.dart` | Builds the router; defaults to `core.CoreRoutes.root` |
| `AppRouter.signOut(context)` | `lib/router/router.dart` | `@visibleForTesting`; unregisters the device push token, then `auth.signOut` |
| `NotificationLifecycle({child, logger, client})` | `lib/notification_lifecycle.dart` | Post-frame `client.init()`, `clearBadge()` on resume |
| `SplashScreen` | `lib/ui/splash_screen.dart` | Root route; `auth.authRedirectLocation(allowUnconfigured: true)` or `DashboardRouter.home` |

## Layout

```
lib/
  main.dart                  startApp(): queue cold-start route, bootstrap, register GoRouter, mount
  bootstrap.dart             init(): core -> Firebase -> Firebase modules -> auth -> network -> notifications
  app.dart                   App widget; renders the injected router, never creates it
  firebase_options.dart      placeholder that throws UnsupportedError until `flutterfire configure`
  notification_lifecycle.dart foreground notification init + badge clearing, errors logged
  router/router.dart         AppRouter: root, /home redirect, dashboard shell, auth, developer, error routes
  ui/splash_screen.dart      first frame; redirects after the first frame
```

## Rules

- `auth.init()` must run **before** `network.init()`: `network.init()` looks up
  `AuthTokenProvider` in `di` once to decide whether to attach bearer tokens.
- Every Firebase-backed step is behind `if (firebaseReady)`. `firebaseReady` is
  only set after `Firebase.initializeApp` succeeds; only `UnsupportedError`
  (the placeholder options) is caught. Emulator failures propagate.
- `auth.init()` takes `DefaultAuthConfig(clientId: iosClientId ?? androidClientId ?? '')`.
- The router is created after bootstrap; `onOpenRoute` stores the route in
  `pendingRoute` until then and uses it as `initialLocation`, afterwards it calls
  `router.go`. Keep that queue when touching `startApp`.
- `startApp` registers the router in `di` with a `dispose`; `App` never disposes it.
- The dashboard shell gets `redirect: auth.authRedirect(allowUnconfigured: true)`
  and `onSignOut: AppRouter.signOut`. Only the app router may connect features.
- `AppRouter.signOut` runs `NotificationClient.unregisterDevice()` first when
  registered; a failure is logged and never blocks `auth.signOut`.
- `AnalyticsRouteObserver` is added only when `di.has<AnalyticsClient>()`;
  `NotificationLifecycle` gets `client: null` when notifications are not registered.

## Common changes

- **Add a feature module:** add the path dependency to `pubspec.yaml`, call its
  `init()` at the `TODO` in `bootstrap.dart` (after what it needs, behind
  `firebaseReady` if Firebase-backed), spread its routes in `router/router.dart`.
  Test it in `test/firebase_bootstrap_test.dart` (registered) and
  `test/entrypoint_test.dart` (boots without Firebase).
- **Change the post-sign-in destination:** edit `AppRouter._onAuthenticated`.
- **Startup work before the first screen:** the `TODO` in `SplashScreen._redirect`.
- **Protect a new top-level route:** pass `auth.authRedirect()` (no
  `allowUnconfigured`) or use `auth.GoAuthRoute`.

## Tests

| File | Covers |
|---|---|
| `app_test.dart` | `App` with an injected router; real routes boot without Firebase, tab switch, `/error`; `AppRouter.signOut` unregisters the device (success and failure) before signing out |
| `entrypoint_test.dart` | real `main()` offline: `NetworkClient` and `GoRouter` registered, unknown route, error route |
| `firebase_bootstrap_test.dart` | configured bootstrap with mocktail FlutterFire platform doubles: every module registered, `app_open` logged, emulator failure throws, sign-in lands on dashboard, foreground toast, signed-out user sent to `SignInScreen` |
| `notification_lifecycle_test.dart` | init after first frame, badge on resume, no badge after dispose, errors logged, null client |
| `startup_test.dart` | cold-start route queued until router exists; later routes navigate directly |

Pattern: hand-written `_Logger`/`_Client` fakes, `mocktail` + `MockPlatformInterfaceMixin`, `tearDown(di.reset)`.

`dart run melos exec --scope=nonstop_example -- flutter test`; `dart run melos run coverage` must stay 100%.

## Gotchas

- `firebase_bootstrap_test.dart` sets `debugDefaultTargetPlatformOverride = TargetPlatform.iOS`
  for bootstrap (so `AppleProvider` is configured) and clears it right after and
  in `addTearDown`; keep both resets when editing that test.
- The `SocialIcons` font in `pubspec.yaml` is required: `firebase_ui_auth` ships
  it without registering it, so Google/Apple buttons render as tofu otherwise.
