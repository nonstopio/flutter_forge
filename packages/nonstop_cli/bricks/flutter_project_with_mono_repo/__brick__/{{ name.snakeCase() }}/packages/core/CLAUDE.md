# {{name.titleCase()}}: `packages/core`

Cross-cutting foundation (layer 1): the `Logger` contract and its Talker
implementation, build-time `Environment`, shared route/query-key constants,
bloc and route observers, the app-wide event channel, JSON/date converters and
the base `CoreException`. It must not own feature logic, screens, product copy
or anything only one package uses. Its only workspace deps are `di` and `localization`.

Read the root `CLAUDE.md` and `packages/CLAUDE.md` first.

## Public API

Exported from `package:core/core.dart` unless noted.

| Symbol | Kind | Notes |
|---|---|---|
| `init()` | function | Calls `registerLoggerWithDI()`, sets `di.onDisposeError` to log through the `Logger`, logs "Core module initialized". Called first in app `bootstrap.dart` and in tests via `setUp(core.init)` |
| `Logger` | `abstract interface class` | `d`, `i`, `w`, `e(message, [error, stackTrace])`, `Object get logger` (raw backend) |
| `registerLoggerWithDI()` | function | `di.register<Logger>(TalkerLoggerImpl(TalkerFlutter.init()))` |
| `TalkerLoggerImpl` | implementation | Not in the barrel; import `package:core/logger/talker_logger_impl.dart` |
| `Environment` | constants | {{#emulators}}`useEmulators` (`USE_EMULATORS`){{#network}}, {{/network}}{{/emulators}}{{#network}}`baseUrl` (`BASE_URL`){{/network}}{{^emulators}}{{^network}}Build-time `--dart-define` values{{/network}}{{/emulators}} |
| `CoreRoutes`, `Keys`, `Defaults` | constants | Shell paths, query/extra keys, `defaultPageSize` |
| `CoreRouter` | `abstract interface class` | `List<RouteBase> get routes`; feature/package routers `implements` it |
| `CoreBlocObserver`, `CoreRouteObserver` | observers | Optional `logger:`; fall back to `di.get<Logger>()` |
| `GlobalEventChannel({required maxRecentEvents, Logger? logger})` + `GlobalEventChannelProvider/Builder/Listener/Consumer` | bloc | App-wide events; `context.fire(GlobalEventType)` extension |
| `GlobalEventType`, `FireGlobalEvent`, `GlobalEventState` | events/state | No concrete events ship; subclass `GlobalEventType` |
| `CoreException`, `UserNotFoundException` | errors | Other packages extend `CoreException` (e.g. `NotificationException`) |
| `DateTimeConverter` | formatter | `toViewFormat`, `toViewFormatWithTime`, `toViewFormatTime`; all convert to local time |
| `TimestampConverter`, `TimestampConverterNullable` | converters | Accept ISO string, {{#firestore}}Firestore `Timestamp`, {{/firestore}}`{_seconds,_nanoseconds}` |
| `BasicStringExtensions.asBool` | extension | `'true'`/`'1'` (case-insensitive) -> true |
| `emulators.init({host})` | function | `package:core/developer/emulators.dart`, not in the barrel{{^emulators}}; a no-op, as no emulated services are enabled{{/emulators}} |

## Layout

| Path | Responsibility |
|---|---|
| `lib/core.dart` | Barrel + `init()` |
| `lib/logger/` | `Logger` contract, `registerLoggerWithDI`, `TalkerLoggerImpl` |
| `lib/constants/` | `Environment`, `CoreRoutes`, `Keys`, `Defaults` |
| `lib/observer/` | `CoreBlocObserver`, `CoreRouteObserver` (logs `push/pop/remove/replace route named X` at debug) |
| `lib/bloc/` | Global event channel bloc, state, events, widgets; `global_event_extension.dart` holds the `fire` extension |
| `lib/errors/exceptions.dart` | `CoreException`, `UserNotFoundException` (message from `strings.errors`) |
| `lib/converters/` | Date display formats and timestamp JSON converters |
| `lib/extensions/basic.dart` | `String?` helpers |
| `lib/router/core_router.dart` | `CoreRouter` contract |
| `lib/developer/emulators.dart` | {{#emulators}}Points {{#auth}}Auth (9099){{#firestore}}, {{/firestore}}{{/auth}}{{#firestore}}Firestore (8080), Functions (5001){{/firestore}} at the emulator host{{/emulators}}{{^emulators}}No-op `init` (no emulated services in this project){{/emulators}} |

## Rules

- `core.init()` is the only registration this package performs (`Logger`); it also routes `di` dispose failures to that logger. Everything else here is stateless or owned by the widget tree.
- `Environment` is the single place `String/bool.fromEnvironment` is called.
- `GlobalEventChannel` is created and closed by `GlobalEventChannelProvider` (a `BlocProvider`). `context.fire` requires that provider above the caller.
- `GlobalEventChannel` falls back to `di.get<Logger>()` when no `logger:` is passed (as `GlobalEventChannelProvider` does), so `core.init()` must run before it is constructed.
- Observers accept any `Logger`; do not type them against Talker.
{{#emulators}}- `emulators.init` rethrows setup failures after logging; do not swallow them. Host defaults to `10.0.2.2` on Android, `localhost` elsewhere; ports must match `firebase.json`.
{{/emulators}}- Keep global events rare (see the doc comment in `bloc/global_event.dart`).

## Common changes

- **Add an environment value:** add a `static const` to `Environment` in `lib/constants/environment.dart`, pass it from the app's `bootstrap.dart` into the consuming package's `init(config:)`. Document the `--dart-define` in the root `CLAUDE.md` Run section.
- **Add a global event:** subclass `GlobalEventType` in `lib/bloc/global_event.dart` (override `props` if it carries data); add a case to `test/core_test.dart` asserting `eventCounts` / `current`.
- **Add a shared query key or shell route:** add to `Keys` or `CoreRoutes`. A route used by one feature belongs in that feature's `constants/routes.dart`.
- **Swap the logger backend:** `implements Logger`, register it in place of `TalkerLoggerImpl` in `registerLoggerWithDI`{{#developer}}; `packages/developer` falls back to a plain message when `logger` is not a `Talker`{{/developer}}.

## Tests

`test/core_test.dart` covers: {{#emulators}}emulator init failing before Firebase init{{/emulators}}{{^emulators}}the no-op emulator init{{/emulators}}, event equality and `Logger` registration after `init`, DI dispose failures reported through the logger, `context.fire`, bounded history with total counts, provider/builder/listener/consumer, date and `asBool` helpers, timestamp converter shapes and invalid input, every `TalkerLoggerImpl` level, and all observer callbacks with named and unnamed routes. Pattern: `setUp(init)`, `tearDown(di.reset)`; Talker with `useConsoleLogs: false` for log assertions.

Run: `dart run melos exec --scope=core -- flutter test`. `dart run melos run coverage` must stay 100%.

## Gotchas

- `TimestampConverter.fromJson` throws `ArgumentError` on unsupported input; the nullable variant returns `null`. String input is converted `.toLocal()`.
- `CoreRouteObserver` skips routes whose `settings.name` is null.
{{#emulators}}- `emulators.init` calls `di.get<Logger>()` first, so `core.init()` must have run.
{{/emulators}}- `lib/logger/index.dart` exports `TalkerLoggerImpl`, but the `core.dart` barrel exports only `logger/logger.dart`.
