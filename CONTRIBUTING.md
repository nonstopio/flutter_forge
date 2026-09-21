# Contributing to Flutter Forge

Use an issue to describe a bug or proposed feature before a large change. Keep
each PR focused, include a reproducible example when relevant, and follow our
[Code of Conduct](CODE_OF_CONDUCT.md).

## Local setup

Install Flutter and Node 22+ (for release tooling), then from the repository root:

```sh
flutter pub get --enforce-lockfile
dart run melos --version
dart run melos bootstrap --scope=PACKAGE_NAME --include-dependencies
```

Replace `PACKAGE_NAME` with the package you are changing. All CI and release
workflows use Flutter 3.47.5 and the pinned Melos 8.8.0 workspace dependency.

Run `dart analyze --fatal-infos` inside the affected package. Use `flutter test`
for Flutter packages, or `dart test` for Dart-only packages. Format changed Dart
files with `dart format`. Do not format Mason `__brick__` sources as ordinary
Dart; they contain template syntax. For NonStop templates, also run the contract
and generation checks described in `packages/nonstop_cli`.

For release tooling changes:

```sh
node --test tools/release/*.test.mjs
```

## Pull requests and releases

Use Conventional Commits for commits and PR titles, such as
`fix(timer_button): cancel timer on dispose` or
`feat(ns_utils): add date helper`. Describe breaking changes using the convention's
`!` or `BREAKING CHANGE:` notation. Maintainers should preserve these messages
when merging so Melos can determine version changes.

Do not manually bump package versions or edit generated release changelogs.
Melos handles both when the PR merges to `main`. Include tests for behavior
changes, documentation for public APIs, and migration instructions for breaking
changes. Keep dependencies and generated assets scoped to the change.

New packages need their own README, LICENSE, pubspec metadata and tests. Mark
examples and internal tools with `publish_to: none`. Follow
[the release guide](docs/RELEASING.md) for the first publication and pub.dev
automation setup. Package licenses are defined by their individual LICENSE files.

Report security issues through [SECURITY.md](SECURITY.md), not public bug reports.
