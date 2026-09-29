---
name: flutter-best-practices
description: Flutter and Dart engineering rules for this repo - SOLID applied to Flutter, widget composition, state management with Bloc/Cubit, async and lifecycle safety, performance, accessibility, error handling and testing. Load before writing or reviewing any widget, state class, service or test.
---

# Flutter best practices

Rules first; each has the failure it prevents. Visual rules (colors,
typography, spacing, shared components) are in the `design-system` skill. When a rule conflicts with the
code around you, follow the rule in new code and flag the old code.

## SOLID in Flutter terms

| Principle | Do | Failure it prevents |
|---|---|---|
| Single responsibility | A widget renders; a Cubit decides; a service talks to I/O | 600-line screens mixing HTTP, parsing and layout |
| Open/closed | Add a new implementation of a contract; add a new state subclass | Editing every consumer to support a second backend |
| Liskov | Fakes and real implementations honour the same contract, including errors | Tests pass against a fake that never throws |
| Interface segregation | `abstract interface class` with the 1-3 methods a consumer needs | Mocks with 20 unused stubs |
| Dependency inversion | Constructor-inject contracts; `di.get` only at composition edges | Untestable classes reaching into a global locator |

## Widgets

- Prefer `StatelessWidget`. Use `StatefulWidget` only for ephemeral UI state
  (animation controllers, text controllers, focus nodes) and dispose all of it
  in `dispose()`.
- Extract widgets as **classes**, not helper methods returning `Widget`:
  classes get their own element, rebuild boundaries and `const`.
- Use `const` constructors and `const` instances everywhere they compile.
- `build()` is pure and cheap: no I/O, no object creation you could hoist, no
  side effects, no `di.get` in leaf widgets.
- Keep `build()` under ~80 lines; split by visual region.
- Give list items stable `Key`s (`ValueKey(item.id)`) when the list can reorder.
- Layout: `ListView.builder` / `SliverList` for unbounded lists, never a
  `Column` of `map(...)` over remote data. Avoid `shrinkWrap: true` on long lists.
- Respect `MediaQuery` / `LayoutBuilder` for responsive layouts; no hard-coded
  device widths. Test at small phone and tablet widths.

## State (Bloc / Cubit)

- One Cubit per screen or flow. State classes are immutable and `sealed`, so
  `switch` in the UI is exhaustive.
- Business rules live in the Cubit or a use-case class, never in widgets.
- Emit a new state object; never mutate a list inside the current state.
- Check `isClosed` before `emit` after an `await`.
- Provide Cubits with `BlocProvider(create: ...)` at the route; read with
  `context.read` in callbacks and `BlocBuilder`/`BlocSelector` for rebuilds.
  Use `buildWhen`/`BlocSelector` to avoid rebuilding whole screens.
- Cross-cutting app events go through `core`'s `GlobalEventChannel` bloc, not
  ad-hoc singletons or static streams.

## Async and lifecycle

- After any `await` in a widget, check `if (!context.mounted) return;` before
  using `context`.
- Every `StreamSubscription`, `Timer`, controller and listener has exactly one
  owner that cancels/disposes it.
- Never fire-and-forget a `Future` whose failure matters; `await` it or route
  its error to the logger/crashlytics. Use `unawaited(...)` explicitly when
  intended.
- Long CPU work (large JSON, image processing) goes to `compute`/`Isolate.run`.

## Errors

- Map SDK and transport errors to typed exceptions at the package boundary.
- UI shows a user-facing message from `strings.errors.*`, logs the technical
  detail via `Logger`, and reports unexpected errors to crashlytics.
- Never `catch (_) {}`. Catch the specific type you can handle.
- Validate at trust boundaries: route parameters, API payloads, user input.

## Performance

- Profile in `--profile` mode with DevTools before optimising.
- Use `const`, `RepaintBoundary` for isolated heavy painters, cached network
  images (`design_system`'s `NetworkUrlImage`), and correctly sized images.
- No `setState` on a whole screen for a change in one field.

## Accessibility

- Tap targets are at least 48x48dp; icons-only buttons have a `tooltip` or
  `Semantics(label: ...)`.
- Text scales: never fix heights around text; test with large text scale.
- Colour is never the only signal; contrast >= 4.5:1 for body text (use theme roles).

## Dart style

- `final` by default; `late` only when initialisation is guaranteed.
- No `dynamic` in public APIs; no `!` on values that can really be null.
- Prefer records and pattern matching over ad-hoc tuples/maps.
- Named parameters with `required` for >2 arguments.
- Public APIs get a `///` doc comment saying what, not how.
- Imports: `package:` imports only; no relative imports across `lib/src`
  boundaries of another package.

## Testing

- Unit-test services and Cubits against fakes of their contracts
  (hand-written fakes or `mocktail`). Use `bloc_test`-style expectations of the
  emitted state sequence.
- Widget-test each screen state; find by text from `strings.*`, by `Key`, or by
  semantics, not by widget index.
- Reset the locator between tests: `setUp(core.init)`, `tearDown(di.reset)`.
- Test names describe behavior: `'shows retry when loading orders fails'`.
- No real network, Firebase, timers or platform channels in unit/widget tests;
  inject clocks and transports.
- Coverage is a floor, not a goal: assert outcomes, not just execution.
