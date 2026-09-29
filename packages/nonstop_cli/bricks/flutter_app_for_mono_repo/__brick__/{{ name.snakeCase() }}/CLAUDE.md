# {{ name.titleCase() }}

{{ description }}

The contract for agents working in this app. Read the repository root
`CLAUDE.md` and the area `CLAUDE.md` above this directory (`apps/`)
first, and do not repeat their rules here. Update this file in the same change as the code it
describes.

## Composition

| Path | Responsibility |
|---|---|
| `lib/main.dart` | Entry point: bootstrap, build the router, mount the app |
| `lib/` | Wiring only: bootstrap order, router, app-only screens |
| `test/` | Startup, routing and lifecycle tests |

## Rules

- This app is a composition root: it wires features and packages and owns no
  business logic. Move anything reusable into `features/` or `packages/`.
- `di.get` is allowed here; this is the composition edge.
- Environment values are `--dart-define`s declared in
  `packages/core/lib/constants/environment.dart`.
- App-only UI follows the `design-system` skill.

## Common changes

_Add two to four recipes for the changes people make here, naming the files to
touch and the test to add._

## Tests

Run `dart run melos exec --scope={{ name.snakeCase() }} -- flutter test`. Keep
`dart run melos run coverage` at 100%: the gate fails a member without tests.

## Gotchas

_None yet. Record real ones as you find them._
