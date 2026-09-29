# {{ name.titleCase() }}

{{ description }}

The contract for agents working in this package. Read the repository root
`CLAUDE.md` and the area `CLAUDE.md` above this directory (`packages/` or `features/`)
first, and do not repeat their rules here. Update this file in the same change as the code it
describes.

## Public API

| Symbol | Kind | Use |
|---|---|---|
| _Each exported class, function and `init()`_ | | |

## Layout

| Path | Responsibility |
|---|---|
| `lib/{{ name.snakeCase() }}.dart` | Public barrel: the only import other members use |
| `lib/src/` | Implementation, grouped by role (`client/`, `config/`, `models/`, ...) |
| `test/` | Tests for every public behavior |

## Rules

- Depend only on lower layers (see `packages/CLAUDE.md`); never on an app or
  another feature.
- Contracts are `abstract interface class`; implementations take their
  dependencies through the constructor.
- User-facing text comes from `localization`; visuals come from
  `design_system` (load the `design-system` skill before UI work).
- Register implementations with `di` only from this package's `init()`.

## Common changes

_Add two to four recipes for the changes people make here, naming the files to
touch and the test to add._

## Tests

Run `dart run melos exec --scope={{ name.snakeCase() }} -- flutter test`. Keep
`dart run melos run coverage` at 100%: the gate fails a member without tests.

## Gotchas

_None yet. Record real ones as you find them._
