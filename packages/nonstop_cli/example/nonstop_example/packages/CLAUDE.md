# Nonstop Example: `packages/`

Shared capabilities used by features and apps. Read the root `CLAUDE.md` first.
A package knows nothing about the product: no feature names, no screens, no
product copy.

## Layers

A package may depend only on packages in a **lower** row. Adding an upward or
same-row dependency needs a reason stated in the change.

| Layer | Packages | Depends on |
|---|---|---|
| 0 | `di`, `localization`, `utils` | nothing in the workspace |
| 1 | `core` | `di`, `localization` |
| 2 | `analytics`, `crashlytics`, `feature_flags` | `core`, `di` |
| 2 | `network` | `core`, `di`, `localization` |
| 3 | `notifications` | `core`, `di`, `network` |
| 3 | `design_system` | `core`, `di`, `localization`, `network` |
| 3 | `developer` | `core`, `di`, `localization`, `feature_flags` |

`developer` does not depend on `design_system`; keep it that way.

## Package conventions

- Every package has its own `CLAUDE.md`: read it before editing the package,
  and update it in the same change when its API, rules or gotchas change.
- Public API is `lib/<name>.dart`; implementation under `lib/src/`, grouped by
  role (`client/`, `config/`, `models/`, `exceptions/`), each with an
  `index.dart` barrel. `core` and `design_system` are older: their role folders
  sit directly under `lib/`.
- **Contract + implementation** for anything backed by an SDK or I/O:
  `AnalyticsClient` / `FirebaseAnalyticsClient`, `NetworkClient` /
  `DioNetworkClient`. Consumers depend on the contract; the implementation takes
  its SDK, logger and clock through the constructor.
- A package exposes an `init({config})` that registers its implementation with
  `di`. It never reads `Environment` itself; the app passes config in.
- Owned disposables (streams, subscriptions, timers, SDK handlers) are released
  through the `dispose:` callback given to `di.register`.
- Exceptions are typed per package (`network_exceptions.dart`, ...).

## Package-specific notes

- **`core`**: logger (`Logger` contract, Talker implementation), environment,
  `CoreRouter` contract, global event channel, route/bloc observers, base
  exceptions, converters, extensions. Keep it small; a helper
  used by one package belongs in that package.
- **`di`**: the only place `get_it` is imported. Everything else uses the
  `DependencyInjection` interface via `di`.
- **`localization`**: edit `lib/messages.i69n.yaml`, then run
  `dart run melos run generate:i69n`. Never edit `messages.i69n.dart`. Keys are
  grouped by area (`generic`, `errors`, `auth`, ...); add to the right group.
- **`design_system`**: `lib/generated/theme.dart` comes from Material Theme
  Builder; replace the file wholesale when the palette changes. Shared
  components must be stateless where possible, accept everything they render as
  parameters, and meet accessibility basics (semantics labels, 48dp targets,
  contrast).
- **`network`**: bearer headers are attached only for the configured API origin;
  logs omit headers, query values and bodies. Keep both properties when
  changing interceptors. `network_response.g.dart` is generated: run
  `dart run melos run generate`.
- **`notifications`**: owns SDK subscriptions only. Navigation and toasts are
  callbacks supplied by the app.

## Tests

Test the implementation against a fake SDK/transport, and test consumers
against a fake of the contract. No real network, Firebase or platform channels.
Every package must keep at least one `*_test.dart` or the coverage gate fails.
