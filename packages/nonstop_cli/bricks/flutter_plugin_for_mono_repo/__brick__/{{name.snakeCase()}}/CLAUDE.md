# {{ name.titleCase() }}

{{ description }}

The contract for agents working in this plugin. Read the repository root
`CLAUDE.md` and the area `CLAUDE.md` above this directory (`plugins/`)
first, and do not repeat their rules here. Update this file in the same change as the code it
describes.

## Public API

| Symbol | Kind | Use |
|---|---|---|
| _The Dart contract other members use_ | | |

## Layout

| Path | Responsibility |
|---|---|
| `lib/` | Dart contract; channel names and argument maps stay private |
| `android/`, `ios/`, ... | Native implementations for each declared platform |
| `test/` | Channel tests with `TestDefaultBinaryMessengerBinding` |

## Rules

- A plugin depends on nothing in `apps/`, `features/` or `packages/`.
- Convert `PlatformException` into typed exceptions at the boundary.
- Every platform declared in `pubspec.yaml` is implemented or throws
  `UnimplementedError` with a clear message.
- Never block the platform main thread in native code.

## Common changes

_Add two to four recipes for the changes people make here, naming the files to
touch and the test to add._

## Tests

Run `dart run melos exec --scope={{ name.snakeCase() }} -- flutter test`. Keep
`dart run melos run coverage` at 100%: the gate fails a member without tests.

## Gotchas

_None yet. Record real ones as you find them._
