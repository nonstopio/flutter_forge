# {{name.titleCase()}}: `apps/`

Each app is a **composition root**: it wires features and packages together and
owns nothing else. Read the root `CLAUDE.md` first.

## What lives where

| File | Owns | Must not |
|---|---|---|
| `lib/main.dart` | `startApp()`: bootstrap, build router, mount widget tree | contain business logic |
| `lib/bootstrap.dart` | `init()`: bring modules up in dependency order | render widgets |
| `lib/app.dart` | `App`: `MaterialApp.router` with theme and localization | resolve services itself |
| `lib/router/router.dart` | The single `GoRouter`; spreads each feature's `routes`{{#auth}}{{#dashboard}}; passes cross-feature callbacks (auth guard, {{#notifications}}`AppRouter.signOut`{{/notifications}}{{^notifications}}`auth.signOut`{{/notifications}}){{/dashboard}}{{/auth}} | define feature screens |
{{#notifications}}| `lib/notification_lifecycle.dart` | Foreground/background notification wiring | navigate outside the router |
{{/notifications}}| `lib/ui/` | App-only screens (splash) | grow into a feature: move it to `features/` |

## Rules

- **Bootstrap order is a contract.** `core.init()` (logger) first, then
  {{#firebase}}Firebase, then {{/firebase}}{{#crashlytics}}crashlytics{{#analytics}}, {{/analytics}}{{^analytics}}{{#feature_flags}}, {{/feature_flags}}{{^feature_flags}}{{#auth}} and {{/auth}}{{^auth}}, then {{/auth}}{{/feature_flags}}{{/analytics}}{{/crashlytics}}{{#analytics}}analytics{{#feature_flags}}, {{/feature_flags}}{{^feature_flags}}{{#auth}} and {{/auth}}{{^auth}}, then {{/auth}}{{/feature_flags}}{{/analytics}}{{#feature_flags}}feature flags{{#auth}} and {{/auth}}{{^auth}}, then {{/auth}}{{/feature_flags}}{{#auth}}auth, then {{/auth}}{{#network}}network,
  then {{/network}}{{#notifications}}notifications, then {{/notifications}}your features.{{#auth}}{{#network}} `auth.init()` must run before
  `network.init()`: network looks up `AuthTokenProvider` in `di` once, at init.{{/network}}{{/auth}}
  A module that needs another must be initialised after it.{{#firebase}} Firebase-backed modules are
  skipped when `firebaseReady` is false; keep that guard for new ones.{{/firebase}}
- Register a feature by calling its `init()` in `bootstrap.dart` (at the
  `TODO` marker) and spreading its `routes` in `router.dart`. Nothing else in
  the app should change to add a feature.
- `di.get` / `di.has` are allowed here: this is the composition edge.
- New `--dart-define` values go in `packages/core/lib/constants/environment.dart`,
  never read directly in the app.
- Platform folders (`android/`, `ios/`, `web/`) are edited deliberately:
  bundle IDs, permissions (`Info.plist`, `AndroidManifest.xml`), capabilities.
  State the user-visible permission text you add.
- `pubspec.lock` is committed for apps only.
- Each app has its own `CLAUDE.md` (`apps/{{name.snakeCase()}}/CLAUDE.md`).
  App-only UI (splash) follows the `design-system` skill.

## Tests

`test/` covers startup order{{#firebase}}, entrypoint{{#notifications}}, Firebase-absent boot and the
notification lifecycle{{/notifications}}{{^notifications}} and Firebase-absent boot{{/notifications}}{{/firebase}}{{^firebase}} and entrypoint{{/firebase}}. Adding a bootstrap step means adding a test that proves
it runs, and that the app still boots when it is unavailable.

Run from the root: `dart run melos run coverage`. For a quick loop:
`cd apps/{{name.snakeCase()}} && flutter test`.
