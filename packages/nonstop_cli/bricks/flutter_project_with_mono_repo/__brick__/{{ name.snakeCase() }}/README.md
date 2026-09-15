# {{ name.titleCase() }}

{{{description}}}

[![nonstop_cli](https://img.shields.io/badge/started%20with-nonstop_cli-166C4E.svg?style=flat-square)](https://pub.dev/packages/nonstop_cli)
[![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)

## Layout

```
apps/{{name.snakeCase()}}      the application shell: bootstrap, router, splash
features/                      vertical slices (ui + state + data)
packages/                      shared capabilities
plugins/                       native integrations
```

Dependencies point inward: apps depend on features, features depend on
packages, packages depend on nothing above them.

### What is already wired

| Module | Role |
| --- | --- |
| `packages/core` | logger, DI bootstrap, route observers, error types, BLoC observer |
| `packages/di` | service locator (GetIt) behind a small interface |
| `packages/design_system` | Material 3 theme, shared components, toasts, loaders |
| `packages/localization` | type-safe strings generated from YAML (i69n) |
| `packages/utils` | dependency-light helpers |
{{#network}}| `packages/network` | Dio client, auth + logging interceptors, typed errors |
{{/network}}{{#analytics}}| `packages/analytics` | event tracking behind a swappable client |
{{/analytics}}{{#crashlytics}}| `packages/crashlytics` | crash and non-fatal reporting |
{{/crashlytics}}{{#notifications}}| `packages/notifications` | FCM, permissions, device-token registration |
{{/notifications}}{{#feature_flags}}| `packages/feature_flags` | Remote Config flags with a widget wrapper |
{{/feature_flags}}{{#developer}}| `packages/developer` | in-app dev tools, reachable by a hidden 5-tap gesture |
{{/developer}}{{#auth}}| `features/auth` | Firebase Auth (email, Google, Apple) + route guards |
{{/auth}}{{#dashboard}}| `features/dashboard` | bottom-navigation shell with starter tabs |
{{/dashboard}}

## Getting started

```sh
dart pub get
dart run melos bootstrap
```
{{#firebase}}
### Firebase

This project uses Firebase, so run this before those features will work.
The rest of the app still boots without it:

```sh
dart pub global activate flutterfire_cli
cd apps/{{name.snakeCase()}}
flutterfire configure
```
{{/firebase}}
### Run

```sh
cd apps/{{name.snakeCase()}}
flutter run --dart-define=BASE_URL=https://api.example.com
```

Every environment value is a `--dart-define` read in
`packages/core/lib/constants/environment.dart`. Add new ones there rather than
scattering `String.fromEnvironment` around the codebase.
{{#firebase}}
To run against the Firebase emulator suite, add
`--dart-define=USE_EMULATORS=true`.
{{/firebase}}
## Day-to-day

```sh
dart run melos run lint       # format-check and analyze
dart run melos run test       # run every package's tests
dart run melos run coverage   # tests + strict 100% line-coverage gate
dart run melos run generate   # rebuild serializers
dart run melos run generate:i69n  # rebuild localization
```

## Adding to the monorepo

```sh
nonstop create my_feature --template package -o features
nonstop create my_package --template package -o packages
nonstop create my_second_app --template app -o apps
nonstop create my_plugin --template plugin -o plugins
```

## Where to start

1. Replace the {{#dashboard}}placeholder tabs in `features/dashboard`{{/dashboard}}{{^dashboard}}placeholder home screen in the app router{{/dashboard}}.
2. Put your product strings in `packages/localization/lib/messages.i69n.yaml`.
3. Set the palette in `packages/design_system/lib/generated/theme.dart`.
4. Add feature modules and spread their routes into
   `apps/{{name.snakeCase()}}/lib/router/router.dart`.

## Architecture and testing

The starter separates the app view, routing, startup and foreground lifecycle.
Clients accept injected SDKs, loggers and transports; feature code consumes small
interfaces rather than subclassing platform SDKs. See [architecture](docs/architecture.md)
for the SOLID boundaries and an example of adding a tested feature.

Every generated package has tests. Unit and widget tests run without a Firebase
account or network service; Firebase integration tests use offline platform doubles.
The strict gate imports otherwise-unloaded libraries, runs all suites, merges their
LCOV records and requires **100% executable-line coverage of workspace `lib/` code**.
It includes entrypoints, startup, theme and error paths. Only compiler-generated
`.g.dart`, `.freezed.dart` and `.i69n.dart` files are excluded.

```sh
dart run tool/coverage.dart
# Inspect existing reports without rerunning tests (not a validation run):
dart run tool/coverage.dart --report-only
```

The gate fails for failed tests, missing tests/reports, or uncovered lines.
The merged report is `coverage/lcov.info`. Do not run two coverage jobs in the
same checkout: each owns a temporary `test/coverage_imports_test.dart` fixture,
removed on normal completion. After an interrupted run, inspect and remove only
that generated fixture before retrying.

Coverage is not a proof of correctness, branch completeness, security, or native
plugin compatibility. Keep assertions about behavior, and add device integration
tests for your Firebase project, native permissions, provider sign-in and backend.
The generated GitHub Actions workflow checks analysis, tests, coverage and a web build.

{{#auth}}### Authentication and demo mode

`GoAuthRoute` denies access when authentication is missing or signed out.
{{#dashboard}}The starter dashboard explicitly allows **unconfigured demo mode** so
you can explore it before `flutterfire configure`. It contains no protected data.
Do not use `allowUnconfigured: true` for real protected routes.
{{/dashboard}}Client-side guards are navigation helpers; enforce authorization in
backend endpoints and Firebase security rules.
{{/auth}}
{{#notifications}}### Notifications

The SDK client owns subscriptions, not navigation or toast widgets. The app
supplies callbacks, queues cold-start routes until the router is ready, and owns
foreground lifecycle handling. Device IDs are random per installation and
persisted locally; they are not hardware fingerprints.

Implement the `POST /device-tokens/me` and `DELETE /device-tokens/me/:deviceId`
backend endpoints before enabling token registration in production. Configure
native capabilities, Firebase messaging and your app's permission explanation.
{{/notifications}}
