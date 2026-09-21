# Tests and dependency maintenance

The [verified coverage report](coverage-report.md) records the package totals, generated-template builds, native coverage, and dependency compatibility limits.

Use Flutter 3.47.5 (Dart 3.13.4), Python 3.10 or newer, and Node.js 24 or newer. The repository uses a native Dart pub workspace and Melos 8; configuration lives in the root `pubspec.yaml`.

```sh
flutter pub get --enforce-lockfile
dart run melos run lint
python3 -m unittest discover -s tools/tests
python3 tools/coverage.py
# Equivalent full coverage command:
dart run melos run test
```

The coverage command discovers workspace packages rather than selecting only folders that already have tests. It includes libraries, executable entrypoints, example applications, Mason hook packages, README synchronization, repository version/bundle tools, and the generated-template verification script. Every package must have real unit or widget tests and a nonempty report. The gate requires every executable Dart line to be hit; it compares integer counts rather than a rounded percentage. Compile-time constants and export-only libraries do not contain executable lines.

Production libraries are loaded alongside an existing test suite so a never-imported library cannot silently disappear. Missing source records fail unless the file contains only recognized declarations without executable code. Temporary coverage entrypoints are restored or removed after the run. Each Flutter run clears its generated test kernel cache to avoid stale source metadata. Flutter coverage is collected without VM package filters, then restricted to the package’s owned files; this avoids a Dart 3.13.4 source-report crash and includes entrypoints outside `lib/`. The generated runner lives under `coverage/` and uses the installed Flutter tool without modifying the SDK. Raw logs and LCOV reports are written to each package's `coverage/` directory; the complete result is `coverage/summary.json`. These generated reports are ignored by Git.

Run a focused package while developing:

```sh
python3 tools/coverage.py --package ns_utils
python3 tools/coverage.py --package packages/timer_button/example
```

`--report-only` inspects existing reports and writes `summary-existing.json`; it does not establish a fresh passing result.

Mustache brick source is not runnable Dart until rendered. The separate generated-template workflow renders representative module combinations, analyzes them, and requires 100% handwritten Dart coverage inside the generated workspace. The template contract suite additionally validates every module selection. Hook bundles exclude local tests/build artifacts and workspace-only `resolution` metadata.

## Dependencies

The shared root `pubspec.lock` and `pnpm-lock.yaml` are checked in. CI enforces the Dart lockfile so dependency resolution cannot drift between package jobs. When intentionally upgrading dependencies, run:

```sh
flutter pub upgrade --major-versions
flutter pub outdated
pnpm install --frozen-lockfile
pnpm audit
```

After an upgrade, rerun the full coverage gate, strict analysis, and generated-template checks. Some newest releases cannot coexist with Flutter SDK pins or upstream package constraints: the current graph uses Equatable 2.1 (required by fake_cloud_firestore) and analyzer 13.3/test 1.31.1 (compatible with Flutter's test_api pin). Do not force incompatible versions with dependency overrides.

The development-only `tmp` override selects a patched release because all-contributors-cli's transitive external-editor dependency requests an obsolete version. Its temporary-file creation and cleanup API is smoke-tested during the upgrade.

The Melos upgrade moves workspace configuration from `melos.yaml` into the root `pubspec.yaml`; run bootstrap and scripts from the repository root. DZod string refinements now correctly return `Schema<String>` instead of throwing an invalid cast. Place string-specific checks before those refinements, for example `z.string().min(3).startsWith('abc')`.

## Native permission-plugin tests

Run the Android Kotlin and Apple Swift/Objective-C unit suites on macOS with Xcode command-line tools and Java 21:

```sh
python3 plugins/contact_permission/native_tests/run.py
```

Use `--platform android` for the JVM suite alone or `--platform apple` for the Apple suite. The checked-in Gradle wrapper resolves the JVM test tooling. Both suites compile the production plugin files and require 100% measured native line coverage; reports are under `plugins/contact_permission/native_tests/coverage/` and the Android test build directory.

Platform test doubles make permission states, callbacks, registration, and lifecycle behavior deterministic. These unit tests do not open OS permission dialogs or establish device-level integration coverage. The separate `native-permissions` CI job runs both suites on macOS.
