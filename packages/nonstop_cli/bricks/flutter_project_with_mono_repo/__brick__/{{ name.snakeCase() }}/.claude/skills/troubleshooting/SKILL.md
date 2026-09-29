---
name: troubleshooting
description: Diagnose and fix failures in this Flutter mono-repo - SDK version mismatches, dart pub get / melos bootstrap resolution errors, lint and analyzer failures, build_runner and i69n codegen problems, coverage-gate failures, {{#firebase}}Firebase not configured, {{/firebase}}and iOS/Android/web build errors. Use when any command, test, build or run fails, before changing code.
---

# Troubleshooting

Find the root cause before editing. Reproduce with the exact failing command
from the repo root, read the **first** error (later ones are usually fallout),
and fix that. Never make a check pass by excluding files, lowering the
coverage bar, or adding `// ignore:` without an explanation.

## Triage in this order

1. `flutter --version`: must be **3.47.5 or newer** (members declare
   `flutter: ">=3.47.5"`). With FVM, run `fvm use` and prefix commands
   with `fvm`.
2. `git status`: is the failure caused by an uncommitted change?
3. `dart pub get` at the root: does the workspace resolve?
4. The failing command, alone, for one package
   (`dart run melos exec --scope=<pkg> -- flutter test`).

## Resolution and bootstrap

| Symptom | Cause | Fix |
|---|---|---|
| `requires Flutter SDK version >=3.47.5` | Old SDK on `PATH` | Upgrade Flutter or switch FVM version |
| `... is not a workspace member` / package resolved separately | Missing `resolution: workspace` or not listed under root `workspace:` | Add both (see `melos-workspace` skill) |
| `version solving failed` after adding a dep | Two members need incompatible versions | Align constraints; one version per package in a workspace |
| Stale imports / `Target of URI doesn't exist` | Links out of date | `dart pub get && dart run melos bootstrap`; restart the analysis server |
| Melos command not found / wrong version | Global melos differs | Use `dart run melos ...` |

## Lint and analyzer

- `dart run melos run lint` runs `tool/check.dart`: format check, then
  `dart analyze --fatal-infos`. **Infos fail the build.**
- Formatting: `dart format <files>` (the Claude hook formats edited files
  automatically).
- `require_trailing_commas` is on; the formatter adds them.
- Try `dart run melos run fix:dry` then `fix` for mechanical fixes.

## Codegen

| Symptom | Fix |
|---|---|
| `*.g.dart` missing or outdated | `dart run melos run generate` |
| `Conflicting outputs` | Already handled by `--delete-conflicting-outputs`; if it persists, delete the package's `.dart_tool/build` and rerun |
| New string not found on `strings.` | Key added to `messages.i69n.yaml`? Then `dart run melos run generate:i69n` |
| i69n YAML parse error | Quote values containing `:` or `#`; keep 2-space indentation |

Never hand-edit generated files; the hook blocks it.

## Coverage gate (`dart run melos run coverage`)

| Output | Meaning | Fix |
|---|---|---|
| `<area>/<pkg>: missing tests` | Member has no `*_test.dart` | Add real tests for it |
| `<area>/<pkg>: missing coverage report` | Its tests failed or crashed | Run `flutter test` in that package and fix the failure |
| `<file>: uncovered lines 12, 40` | Lines never executed | Add a test that exercises that behavior; delete the code if it is dead |
| Leftover `test/coverage_imports_test.dart` | A previous run was interrupted | Delete only that generated file, then rerun. Never run two coverage jobs at once |

`--report-only` re-reads existing reports without running tests; it is not a
validation run.

## Runtime

| Symptom | Cause | Fix |
|---|---|---|
{{#firebase}}| Log: `Firebase not configured yet; skipping Firebase modules` | `flutterfire configure` not run | Expected in demo mode; run it in `apps/{{name.snakeCase()}}` for {{#auth}}auth{{#analytics}}, {{/analytics}}{{^analytics}}{{#notifications}}, {{/notifications}}{{/analytics}}{{/auth}}{{#analytics}}analytics{{#notifications}}, {{/notifications}}{{/analytics}}{{#notifications}}notifications{{/notifications}}{{^auth}}{{^analytics}}{{^notifications}}the Firebase-backed modules{{/notifications}}{{/analytics}}{{/auth}} |
{{/firebase}}{{#auth}}| Auth routes always redirect to sign-in | Firebase absent or user signed out | Configure Firebase{{#dashboard}}; `allowUnconfigured` is for the demo dashboard only{{/dashboard}} |
{{/auth}}{{#emulators}}| Emulator connection refused | Suite not running | `firebase emulators:start`, then run with `--dart-define=USE_EMULATORS=true` |
{{/emulators}}{{#network}}| Requests go to `api.example.com` | `BASE_URL` not defined | `flutter run --dart-define=BASE_URL=...` |
{{/network}}| `GetIt: Object/factory with type X is not registered` | Module `init()` not called, or called in the wrong order | Check `bootstrap.dart` order; in tests, register the fake before pumping |

## Platform builds

- **iOS**: `cd apps/{{name.snakeCase()}}/ios && pod repo update && pod install`;
  deployment target must satisfy {{#firebase}}Firebase{{/firebase}}{{^firebase}}plugin{{/firebase}} pods (raise it in `Podfile` and the
  Xcode project together). After SDK upgrades: `flutter clean` then rebuild.
- **Android**: check `minSdk` against plugin requirements in
  `android/app/build.gradle(.kts)`; Gradle/AGP errors after upgrades usually
  need `flutter clean` and matching Kotlin/AGP versions.
- **Web**: `flutter build web` from the app directory; CI runs this too.
- Last resort for weird state: `dart run melos run clean:flutter`, then
  `dart pub get && dart run melos bootstrap`.

## Report back

State the root cause in one line, the fix, the command you ran to prove it,
and anything you could not verify (device builds, {{#firebase}}Firebase project, {{/firebase}}backend).
