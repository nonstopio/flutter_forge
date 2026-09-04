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
dart pub global activate melos
melos bootstrap
```
{{#firebase}}
### Firebase

This project uses Firebase, so configure it before the first run - the
generated `lib/firebase_options.dart` deliberately throws until you do:

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
melos lint             # format + analyze everything
melos test             # run every package's tests
melos run generate     # build_runner where it is needed
melos run generate:i69n  # regenerate strings after editing messages.i69n.yaml
```

## Adding to the monorepo

```sh
nonstop create package my_feature -o features
nonstop create package my_package -o packages
nonstop create app my_second_app -o apps
nonstop create plugin my_plugin -o plugins
```

## Where to start

1. Replace the placeholder tabs in `features/dashboard`.
2. Put your product strings in `packages/localization/lib/messages.i69n.yaml`.
3. Set the palette in `packages/design_system/lib/generated/theme.dart`.
4. Add feature modules and spread their routes into
   `apps/{{name.snakeCase()}}/lib/router/router.dart`.
