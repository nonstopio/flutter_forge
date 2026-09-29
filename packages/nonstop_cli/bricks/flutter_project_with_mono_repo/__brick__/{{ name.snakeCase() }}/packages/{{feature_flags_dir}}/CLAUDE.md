# {{name.titleCase()}}: `packages/feature_flags`

Owns remote feature flags and config values: the `FeatureFlag` contract and its
`FeatureFlagService` implementation, the `FeatureFlagProvider` backend contract
with its Firebase Remote Config adapter, and the `FeatureFlagWrapper` widget. It
does not own flag meaning or product rollout decisions; flag keys and defaults
come from callers. Layer 2: depends on `core`, `di`.

Read the root `CLAUDE.md` and `packages/CLAUDE.md` first.

## Public API

| Symbol | Kind |
|---|---|
| `FeatureFlag` / `FeatureFlagService(provider:, logger:)` | `abstract interface class` (factory `FeatureFlag(...)` builds the service) / implementation: `init`, `isInitialized`, `isEnabled`, `hasFlag`, `getConfig`, `getIntConfig`, `getDoubleConfig`, `dispose` |
| `FeatureFlagProvider` / `FirebaseRemoteConfigProvider(remoteConfig:, logger:, config:)` | `abstract interface class` / Remote Config implementation: `init`, `getBool`, `getString`, `getInt`, `getDouble`, `hasFlag`, `dispose`; adapter also exposes `lastFetchTime`, `lastFetchStatus`, `config` |
| `FeatureFlagsConfig` | `fetchTimeout` (default `defaultFetchTimeout`, 10s), `minimumFetchInterval` (default `defaultMinimumFetchInterval`, 30 min), `defaultParameters` |
| `init({provider, config})` | Registers, then awaits `FeatureFlag.init()` |
| `registerFeatureFlagsWithDI({config, provider})` | Registers `FeatureFlagProvider` (no dispose) and `FeatureFlag` (with dispose) |
| `FeatureFlagWrapper(flagKey:, builder:, defaultValue:, loading:, service:, logger:)`, `FeatureFlagWrapper.resolve()` | Widget rendering `builder(context, enabled)`; `resolve()` is the locator fallback for unpassed collaborators |

## Layout

| Path | Responsibility |
|---|---|
| `lib/feature_flags.dart` | Barrel and `init` |
| `lib/src/client/` | `FeatureFlag` contract, `FeatureFlagService` |
| `lib/src/config/` | `FeatureFlagsConfig` |
| `lib/src/di/` | `registerFeatureFlagsWithDI` |
| `lib/src/providers/` | `FeatureFlagProvider` contract, `FirebaseRemoteConfigProvider` |
| `lib/src/widgets/` | `FeatureFlagWrapper` |

Each folder has an `index.dart` barrel.

## Rules

- **Reads before init throw.** `FeatureFlagService` throws `StateError` from every getter until `init()` succeeds. `init()` is idempotent and a failed one can be retried.
- **Local setup failures propagate; offline fetch does not.** A `setConfigSettings` or `setDefaults` error is logged and rethrown by the adapter, the service and module `init`. A `fetchAndActivate` failure (e.g. offline) is only logged as a warning and startup continues with cached or default values.
- **Read failures fall back.** Adapter getters return the caller's `defaultValue` when the SDK throws. A key whose source is `ValueSource.valueStatic` (unknown to both remote and `defaultParameters`) also returns the caller default. Remote `false`, `0` and `''` are real values.
- **Disposal ownership.** `FeatureFlagService.dispose()` disposes the provider. The provider is registered without a `dispose:` callback so a DI reset disposes it exactly once. Keep it that way.
- **Wrapper.** Caches the read future and re-reads only when `flagKey`, `defaultValue` or `service` changes. Unpassed `service`/`logger` come from `FeatureFlagWrapper.resolve()` (`di.has` guarded, the package's single locator fallback). No registered `FeatureFlag` or a read error renders `defaultValue`; errors are logged. Pass `service:` in tests and leaf widgets.
- **Injected:** `FirebaseRemoteConfig` and `Logger` into the adapter; `FeatureFlagProvider` and `Logger` into the service.

## Common changes

- **Add a flag:** read it with `di.get<FeatureFlag>().isEnabled('key', defaultValue: ...)` or `FeatureFlagWrapper(flagKey: 'key', ...)` at the call site. For a default shared by every read, put it in `FeatureFlagsConfig.defaultParameters` passed to `init` (bootstrap currently calls `feature_flags.init()` with the default empty map). There is no key registry in this package.
- **Add a typed getter:** add it to `FeatureFlagProvider`, implement it in `FirebaseRemoteConfigProvider` with the `valueStatic` check and try/catch, then declare it on `FeatureFlag` and implement it in `FeatureFlagService` behind `_ensureInitialized()`. Extend the "missing keys", "configured false, zero and empty" and "SDK read failures" tests and "typed reads preserve caller defaults".
- **Swap the backend:** implement `FeatureFlagProvider` and pass it as `init(provider: ...)`.

## Tests

`test/feature_flags_test.dart` covers the init guard and idempotency, retry after failure, typed reads with caller defaults, module init and single disposal on `di.reset`, init failure, wrapper caching, fallback and `resolve()` with logged read failures (widget tests), and the Firebase adapter (settings, defaults, metadata, offline startup, missing vs configured values, SDK failures).

Doubles: mocktail `FeatureFlagProvider` (`_Provider`), `FirebaseRemoteConfig` (`_RemoteConfig`), `Logger` (`_Logger`).

`dart run melos exec --scope=feature_flags -- flutter test`; `dart run melos run coverage` must stay 100%.

## Gotchas

- Module `init` still awaits `fetchAndActivate` (bounded by `fetchTimeout`) before bootstrap continues, even though a failed fetch no longer fails it.
- Real-time Remote Config updates are not wired; values change only on the next `init` fetch.
