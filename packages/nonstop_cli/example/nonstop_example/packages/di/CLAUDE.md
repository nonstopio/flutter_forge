# Nonstop Example: `packages/di`

The service-locator abstraction (layer 0): the `DependencyInjection` contract,
its GetIt implementation, and the global `di` instance. It owns registration,
lookup and ordered disposal, nothing else. It must not know about any other
workspace package or contain app types.

Read the root `CLAUDE.md` and `packages/CLAUDE.md` first.

## Public API

| Symbol | Kind | Notes |
|---|---|---|
| `di` | global | `final di = GetItDependencyInjection();` over `GetIt.instance` |
| `DependencyInjection` | contract (`abstract interface class`) | `dispose`, `register`, `unregister`, `get`, `has`, `reset` |
| `GetItDependencyInjection({GetIt? getIt, DisposeErrorHandler? onDisposeError})` | implementation | Pass `GetIt.asNewInstance()` for an isolated container |
| `DisposeFunc<T>` | typedef | `FutureOr Function(T param)` |
| `DisposeErrorHandler` | typedef | `void Function(Object error, StackTrace stack)` |
| `onDisposeError` | settable field | Receives dispose-callback failures; defaults to `dart:developer` `log(name: 'di')`. `core.init()` points it at the `Logger` |
| `register<T>(instance, {dispose})` | method | Singleton; `dispose` is stored per type `T` |
| `unregister<T>(instance)` | method | No-op if `T` is not registered; `ArgumentError` if `instance` is not the registered one |
| `has<T>()` / `get<T>()` | methods | `get` throws `StateError` when missing |
| `reset()` | method | Same as `dispose()`; the container is reusable afterwards |
| `getIt` | getter | Underlying `GetIt` (tests use `di.getIt.isRegistered`) |

## Layout

| Path | Responsibility |
|---|---|
| `lib/di.dart` | Barrel + global `di` |
| `lib/src/dependency_injection.dart` | Contract and `DisposeFunc` |
| `lib/src/dependency_injection_imp.dart` | GetIt implementation, `DisposeErrorHandler`, dispose bookkeeping |

## Rules

- `get_it` is imported only here (`pubspec.yaml` depends on `get_it` and Flutter, nothing in the workspace).
- `dispose()` runs dispose callbacks in **reverse registration order**, awaits each, reports failures to `onDisposeError` and keeps going, then clears its maps and calls `GetIt.reset()`. Register dependencies before their dependents.
- `unregister` removes the registration even when its dispose callback throws; a wrong-instance call throws before any disposal.
- Instances and dispose callbacks are keyed by the type argument `T`, so always register with an explicit type (`di.register<Logger>(...)`) matching how consumers `get` it.
- There is no `init()`; the container is usable as soon as it is constructed.
- A registration without `dispose:` is dropped on reset with no cleanup; anything holding streams, timers or SDK handles must pass `dispose:`.

## Common changes

- **Change disposal semantics:** edit `dispose()` / `unregister()` in `dependency_injection_imp.dart` and extend `test/lifecycle_test.dart` (ordering, awaited async cleanup, failure isolation).
- **Add a contract method:** add it to `DependencyInjection`, implement it in `GetItDependencyInjection`, and add a group in `test/di_test.dart`. Every consumer uses `di`, so keep it additive.

## Tests

- `test/di_test.dart`: register/get/has, dispose callbacks on unregister and dispose, registration with no prior setup, missing-type errors, unregistering unknown types, reset, multiple dependencies.
- `test/lifecycle_test.dart`: reverse-order awaited disposal that continues past a throwing callback, idempotent second reset, unregister cleanup failure, failures routed to `onDisposeError`, wrong-instance unregistration without side effects.
- Pattern: a fresh `GetItDependencyInjection(getIt: GetIt.asNewInstance())` per test, disposed in `tearDown`. Never test against the global `di` here.

Run: `dart run melos exec --scope=di -- flutter test`. `dart run melos run coverage` must stay 100%.

## Gotchas

- `di` wraps the process-wide `GetIt.instance`; other packages' tests share it, which is why they use `tearDown(di.reset)`.
- Registering the same `T` twice throws from GetIt; `unregister<T>` or `reset` first.
- This package cannot depend on `core`, so dispose failures reach the `Logger` only after `core.init()` sets `di.onDisposeError`; before that (and for isolated containers) they go to `dart:developer` logs.
