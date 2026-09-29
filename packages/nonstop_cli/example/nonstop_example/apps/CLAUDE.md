# Nonstop Example: `apps/`

Each app is a **composition root**: it wires features and packages together and
owns nothing else. Read the root `CLAUDE.md` first.

## What lives where

| File | Owns | Must not |
|---|---|---|
| `lib/main.dart` | `startApp()`: bootstrap, build router, mount widget tree | contain business logic |
| `lib/bootstrap.dart` | `init()`: bring modules up in dependency order | render widgets |
| `lib/app.dart` | `App`: `MaterialApp.router` with theme and localization | resolve services itself |
| `lib/router/router.dart` | The single `GoRouter`; spreads each feature's `routes`; passes cross-feature callbacks (auth guard, `AppRouter.signOut`) | define feature screens |
| `lib/notification_lifecycle.dart` | Foreground/background notification wiring | navigate outside the router |
| `lib/ui/` | App-only screens (splash) | grow into a feature: move it to `features/` |

## Rules

- **Bootstrap order is a contract.** `core.init()` (logger) first, then
  Firebase, then crashlytics, analytics, feature flags and auth, then network,
  then notifications, then your features. `auth.init()` must run before
  `network.init()`: network looks up `AuthTokenProvider` in `di` once, at init.
  A module that needs another must be initialised after it. Firebase-backed modules are
  skipped when `firebaseReady` is false; keep that guard for new ones.
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
- Each app has its own `CLAUDE.md` (`apps/nonstop_example/CLAUDE.md`).
  App-only UI (splash) follows the `design-system` skill.

## Tests

`test/` covers startup order, entrypoint, Firebase-absent boot and the
notification lifecycle. Adding a bootstrap step means adding a test that proves
it runs, and that the app still boots when it is unavailable.

Run from the root: `dart run melos run coverage`. For a quick loop:
`cd apps/nonstop_example && flutter test`.
