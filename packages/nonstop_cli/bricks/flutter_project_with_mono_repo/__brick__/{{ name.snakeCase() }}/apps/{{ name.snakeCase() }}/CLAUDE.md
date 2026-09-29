# {{name.titleCase()}}: `apps/{{name.snakeCase()}}`

The composition root (pubspec name `{{name.snakeCase()}}`). It boots modules, builds
the single `GoRouter`, {{#auth}}passes cross-feature behavior ({{#dashboard}}auth guard, sign-out,
{{/dashboard}}post-auth landing) into features, {{/auth}}and mounts the widget tree. It owns no
business logic, no feature screens and no service implementations; the only
app-owned screen is the splash{{^dashboard}} (plus the placeholder `_HomeScreen` in
`router/router.dart`, to be replaced by your first feature){{/dashboard}}.

Read the root `CLAUDE.md` and `apps/CLAUDE.md` first.
Load the `design-system` skill before changing UI.

## Public API

Nothing depends on the app. These are its seams, used by its own tests:

| Symbol | File | Used for |
|---|---|---|
| `startApp({initialize, mount})` | `lib/main.dart` | Entrypoint with injectable bootstrap and `runApp` |
| {{#firebase}}`init({onOpenRoute, firebaseOptions, useEmulators})`{{/firebase}}{{^firebase}}`init({onOpenRoute})`{{/firebase}} | `lib/bootstrap.dart` | Module bring-up{{#firebase}}; `firebaseOptions` overrides `DefaultFirebaseOptions` in tests{{/firebase}} |
| `App({required router})` | `lib/app.dart` | `MaterialApp.router` inside `GlobalEventChannelProvider` + `DesignSystemWrapper` |
| `AppRouter.createRouter({initialLocation})` | `lib/router/router.dart` | Builds the router; defaults to `core.CoreRoutes.root` |
{{#auth}}{{#dashboard}}{{#notifications}}| `AppRouter.signOut(context)` | `lib/router/router.dart` | `@visibleForTesting`; unregisters the device push token, then `auth.signOut` |
{{/notifications}}{{/dashboard}}{{/auth}}{{#notifications}}| `NotificationLifecycle({child, logger, client})` | `lib/notification_lifecycle.dart` | Post-frame `client.init()`, `clearBadge()` on resume |
{{/notifications}}| `SplashScreen` | `lib/ui/splash_screen.dart` | Root route; {{#auth}}`auth.authRedirectLocation(allowUnconfigured: true)` or {{/auth}}{{#dashboard}}`DashboardRouter.home`{{/dashboard}}{{^dashboard}}`core.CoreRoutes.home`{{/dashboard}} |

## Layout

```
lib/
  main.dart                  startApp(): queue cold-start route, bootstrap, register GoRouter, mount
  bootstrap.dart             init(): core{{#firebase}} -> Firebase{{/firebase}}{{#crashlytics}} -> Firebase modules{{/crashlytics}}{{^crashlytics}}{{#analytics}} -> Firebase modules{{/analytics}}{{^analytics}}{{#feature_flags}} -> Firebase modules{{/feature_flags}}{{/analytics}}{{/crashlytics}}{{#auth}} -> auth{{/auth}}{{#network}} -> network{{/network}}{{#notifications}} -> notifications{{/notifications}}
  app.dart                   App widget; renders the injected router, never creates it
{{#firebase}}  firebase_options.dart      placeholder that throws UnsupportedError until `flutterfire configure`
{{/firebase}}{{#notifications}}  notification_lifecycle.dart foreground notification init + badge clearing, errors logged
{{/notifications}}  router/router.dart         AppRouter: root, /home {{#dashboard}}redirect, dashboard shell{{/dashboard}}{{^dashboard}}placeholder{{/dashboard}}, {{#auth}}auth, {{/auth}}{{#developer}}developer, {{/developer}}error routes
  ui/splash_screen.dart      first frame; redirects after the first frame
```

## Rules

{{#auth}}{{#network}}- `auth.init()` must run **before** `network.init()`: `network.init()` looks up
  `AuthTokenProvider` in `di` once to decide whether to attach bearer tokens.
{{/network}}{{/auth}}{{#firebase}}- Every Firebase-backed step is behind `if (firebaseReady)`. `firebaseReady` is
  only set after `Firebase.initializeApp` succeeds; only `UnsupportedError`
  (the placeholder options) is caught.{{#emulators}} Emulator failures propagate.{{/emulators}}
{{/firebase}}{{#auth}}- `auth.init()` takes `DefaultAuthConfig(clientId: iosClientId ?? androidClientId ?? '')`.
{{/auth}}- The router is created after bootstrap; `onOpenRoute` stores the route in
  `pendingRoute` until then and uses it as `initialLocation`, afterwards it calls
  `router.go`. Keep that queue when touching `startApp`.
- `startApp` registers the router in `di` with a `dispose`; `App` never disposes it.
{{#auth}}{{#dashboard}}- The dashboard shell gets `redirect: auth.authRedirect(allowUnconfigured: true)`
  and `onSignOut: {{#notifications}}AppRouter.signOut{{/notifications}}{{^notifications}}auth.signOut{{/notifications}}`. Only the app router may connect features.
{{/dashboard}}{{^dashboard}}- Only the app router may connect features.
{{/dashboard}}{{/auth}}{{^auth}}- Only the app router may connect features.
{{/auth}}{{#auth}}{{#dashboard}}{{#notifications}}- `AppRouter.signOut` runs `NotificationClient.unregisterDevice()` first when
  registered; a failure is logged and never blocks `auth.signOut`.
{{/notifications}}{{/dashboard}}{{/auth}}{{#analytics}}- `AnalyticsRouteObserver` is added only when `di.has<AnalyticsClient>()`{{#notifications}};
  {{/notifications}}{{^notifications}}.
{{/notifications}}{{/analytics}}{{^analytics}}{{#notifications}}- {{/notifications}}{{/analytics}}{{#notifications}}`NotificationLifecycle` gets `client: null` when notifications are not registered.
{{/notifications}}
## Common changes

- **Add a feature module:** add the path dependency to `pubspec.yaml`, call its
  `init()` at the `TODO` in `bootstrap.dart` (after what it needs{{#firebase}}, behind
  `firebaseReady` if Firebase-backed{{/firebase}}), spread its routes in `router/router.dart`.
  Test it in {{#firebase}}`test/firebase_bootstrap_test.dart` (registered) and
  `test/entrypoint_test.dart` (boots without Firebase){{/firebase}}{{^firebase}}`test/entrypoint_test.dart`{{/firebase}}.
{{#auth}}- **Change the post-sign-in destination:** edit `AppRouter._onAuthenticated`.
{{/auth}}- **Startup work before the first screen:** the `TODO` in `SplashScreen._redirect`.
{{#auth}}- **Protect a new top-level route:** pass `auth.authRedirect()` (no
  `allowUnconfigured`) or use `auth.GoAuthRoute`.
{{/auth}}
## Tests

| File | Covers |
|---|---|
| `app_test.dart` | `App` with an injected router; real routes boot{{#firebase}} without Firebase{{/firebase}}{{#dashboard}}, tab switch{{/dashboard}}, `/error`{{#auth}}{{#dashboard}}{{#notifications}}; `AppRouter.signOut` unregisters the device (success and failure) before signing out{{/notifications}}{{/dashboard}}{{/auth}} |
| `entrypoint_test.dart` | real `main()` offline: {{#network}}`NetworkClient` and {{/network}}`GoRouter` registered, unknown route, error route |
{{#firebase}}| `firebase_bootstrap_test.dart` | configured bootstrap with mocktail FlutterFire platform doubles: every module registered{{#analytics}}, `app_open` logged{{/analytics}}{{#auth}}, emulator failure throws, sign-in {{#dashboard}}lands on dashboard{{/dashboard}}{{^dashboard}}succeeds{{/dashboard}}{{/auth}}{{#notifications}}, foreground toast{{/notifications}}{{#auth}}, signed-out user sent to `SignInScreen`{{/auth}} |
{{/firebase}}{{#notifications}}| `notification_lifecycle_test.dart` | init after first frame, badge on resume, no badge after dispose, errors logged, null client |
{{/notifications}}| `startup_test.dart` | cold-start route queued until router exists; later routes navigate directly |

Pattern: {{#notifications}}hand-written `_Logger`/`_Client` fakes, {{/notifications}}{{#firebase_sdk_mocks}}`mocktail` + `MockPlatformInterfaceMixin`, {{/firebase_sdk_mocks}}`tearDown(di.reset)`.

`dart run melos exec --scope={{name.snakeCase()}} -- flutter test`; `dart run melos run coverage` must stay 100%.
{{#firebase}}
## Gotchas

- `firebase_bootstrap_test.dart` sets `debugDefaultTargetPlatformOverride = TargetPlatform.iOS`
  for bootstrap{{#auth}} (so `AppleProvider` is configured){{/auth}} and clears it right after and
  in `addTearDown`; keep both resets when editing that test.
{{#auth}}- The `SocialIcons` font in `pubspec.yaml` is required: `firebase_ui_auth` ships
  it without registering it, so Google/Apple buttons render as tofu otherwise.
{{/auth}}{{/firebase}}