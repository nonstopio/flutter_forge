# feature_flags

Remote-config backed feature flags for Nonstop Example: a `FeatureFlag`
contract, a Firebase Remote Config provider and a `FeatureFlagWrapper` widget.

## Initialise

Firebase must be initialised and a `Logger` registered.

```dart
import 'package:feature_flags/feature_flags.dart' as feature_flags;

await feature_flags.init(
  config: const feature_flags.FeatureFlagsConfig(
    defaultParameters: {'developer_screen_enabled': false},
  ),
);
```

`init` registers `FeatureFlagProvider` and `FeatureFlag`, then initialises the
provider. If the Remote Config fetch fails (for example when the device is
offline), a warning is logged and the app starts with cached or default values.
Failures applying settings or defaults still propagate.

Pass `provider:` to use another backend; implement `FeatureFlagProvider`.

## Configure

| `FeatureFlagsConfig` field | Default |
| --- | --- |
| `fetchTimeout` | `FeatureFlagsConfig.defaultFetchTimeout` (10 s) |
| `minimumFetchInterval` | `FeatureFlagsConfig.defaultMinimumFetchInterval` (30 min) |
| `defaultParameters` | `{}` (in-app values used until a fetch succeeds) |

## Reading flags

Depend on the `FeatureFlag` contract (inject it, or read `di.get<FeatureFlag>()`
at a composition edge):

```dart
final flags = di.get<FeatureFlag>();

if (await flags.isEnabled('new_checkout')) { ... }
await flags.hasFlag('new_checkout');
await flags.getConfig('welcome_text', defaultValue: 'Hi');
await flags.getIntConfig('max_items', defaultValue: 10);
await flags.getDoubleConfig('discount', defaultValue: 0.1);
```

Keys without a remote or in-app value return the `defaultValue` you pass.

## Widget

```dart
FeatureFlagWrapper(
  flagKey: 'new_checkout',
  loading: const CircularProgressIndicator(),
  builder: (context, enabled) =>
      enabled ? const NewCheckout() : const OldCheckout(),
);
```

`service` and `logger` are optional constructor parameters. When omitted they
are resolved once per read through `FeatureFlagWrapper.resolve()`, the package's
only locator fallback. With no `FeatureFlag` registered the builder receives
`defaultValue`.

## Errors

- Reading before `init()` completes throws `StateError`.
- Provider read failures return the default value and are logged.
- `FeatureFlagWrapper` logs read failures through `Logger` and renders with
  `defaultValue`.

## Privacy rules

- Flag reads are not logged.
- Do not use Remote Config to deliver secrets or personal data: values are
  readable by anyone with the app.
