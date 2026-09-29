---
name: melos-workspace
description: Operate this Melos + native Dart workspace - bootstrap, run scripts across packages, scope commands to one package, add or remove a package/feature/app/plugin, add dependencies, and add Melos scripts. Use whenever a task touches pubspec.yaml, the workspace member list, melos scripts, or asks to run something "across all packages".
---

# Melos workspace

The root `pubspec.yaml` is the single source of truth: it lists workspace
members under `workspace:` and holds Melos config under `melos:`. There is no
`melos.yaml`. Every member declares `resolution: workspace`, so the whole repo
resolves to **one** root `pubspec.lock`.

Run everything from the repository root with `dart run melos ...`.

## Everyday commands

| Goal | Command |
|---|---|
| Resolve + link everything | `dart pub get && dart run melos bootstrap` |
| List members | `dart run melos list` (`--long` for paths) |
| Lint / test / coverage | `dart run melos run lint` / `test` / `coverage` |
| Codegen | `dart run melos run generate` (json_serializable), `generate:i69n` |
| One command in every package | `dart run melos exec -- <command>` |
| Only some packages | `dart run melos exec --scope=network -- flutter test` |
| Packages that depend on X | `dart run melos list --depends-on=core` |
| Changed since main (+ dependents) | `dart run melos list --diff=origin/main --include-dependents` |

Useful filters: `--scope=<glob>`, `--ignore=<glob>`, `--depends-on=<pkg>`,
`--dir-exists=test`, `--flutter` / `--no-flutter`.

## Add a package, feature, app or plugin

Run `nonstop create` from inside the repo. It adds the new member to the
root `workspace:` list and sets `resolution: workspace` in its pubspec. Then:

1. Scaffold into the right area:
   ```sh
   nonstop create payments --template package -o features
   nonstop create storage  --template package -o packages
   nonstop create admin    --template app     -o apps
   nonstop create camera   --template plugin  -o plugins
   ```
2. Align the new `pubspec.yaml` with the other members:
   ```yaml
   publish_to: 'none'
   environment:
     sdk: ^3.8.0
     flutter: ">=3.47.5"
   # ...dependencies...
   resolution: workspace   # added by nonstop create
   ```
   Internal dependencies use paths: `core: {path: ../../packages/core}`.
   Remove any `analysis_options.yaml` the scaffold left: the root one applies.
3. Check the root `pubspec.yaml` `workspace:` list: the new path is appended
   at the end; move it next to its area if you like. If you scaffolded by
   hand, add it yourself.
4. Add at least one `test/*_test.dart`. `tool/coverage.dart` fails any member
   without tests.
5. Fill in the starter `<member>/CLAUDE.md` that `nonstop create` adds, using
   the sections of an existing member (for example `packages/analytics/CLAUDE.md`): purpose, public API, layout, rules,
   common changes, tests, gotchas.
6. `dart pub get && dart run melos bootstrap`, then `lint` and `coverage`.
7. Respect the layer rules in `packages/CLAUDE.md` / `features/CLAUDE.md`, and
   add the member to the root `README.md` module table.

To remove a member: delete its directory, remove it from `workspace:`, remove
every `path:` dependency on it, then `dart pub get`.

## Dependencies

- Third-party: `cd <member> && dart pub add <pkg>` (or `flutter pub add`). The
  workspace re-resolves the shared lock. Use `dart pub add dev:<pkg>` for
  test-only packages.
- Keep one version of a package across the workspace; a workspace cannot
  resolve two. Prefer a dependency already used by another member.
- Justify each new third-party dependency in the change: what it replaces,
  maintenance status, platforms supported. Prefer the SDK or an existing member.
- Upgrade: `dart pub upgrade` at the root (or `--major-versions` deliberately,
  one package at a time, reading its changelog).

## Add a Melos script

Add it under `melos: scripts:` in the root `pubspec.yaml`, with a
`description`. Use `exec` plus `packageFilters` for per-package work, `run` for
a single root command. Mirror an existing script (e.g. `generate`). Document it
in the root `CLAUDE.md` command table.

## Do not

- Run `flutter pub get` expecting per-package lockfiles; there is one lock.
- Commit `pubspec_overrides.yaml` (Melos writes it for local linking).
- Add a member without `resolution: workspace`: `dart pub get` fails with
  "is not a workspace member" or resolves it separately.
