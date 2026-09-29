# {{name.titleCase()}}: `packages/developer`

In-app developer tools (layer 4): a hidden multi-tap gesture that opens a
Talker log viewer, and the flag-guarded `/developer` route. It owns dev-only
UI and its route guard. It must not own logging, flag evaluation or product
screens; those come from `core` and `feature_flags`.

Read the root `CLAUDE.md` and `packages/CLAUDE.md` first. Load the
`design-system` skill before changing UI.

## Public API

Exported from `package:developer/developer.dart`. There is no `init()`; nothing is registered with `di`.

| Symbol | Kind | Notes |
|---|---|---|
| `DeveloperRoutes.developer` | constant | `'/developer'` |
| `DeveloperFlags.screenEnabled` | constant | `'developer_screen_enabled'`; gates both the gesture and the route |
| `DeveloperRouter` | `implements core.CoreRouter` | Resolves `Logger` from `di` at construction; one `GoRoute` named `developer-screen`; spread into the app router (`apps/{{name.snakeCase()}}/lib/router/router.dart`) |
| `DeveloperScreen({required Logger logger})` | widget | `TalkerScreen` when `logger.logger is Talker`, otherwise a `Scaffold` showing `strings.developer.no_viewer` |
| `OpenDevToolsWrapper` | widget | `child`, `tapCount = 5`, `tapWindow = 2s`, `enableHaptics = true`, `enableVisualFeedback = false`; {{#dashboard}}used on the profile avatar in `features/dashboard`{{/dashboard}}{{^dashboard}}wraps the placeholder home screen's text in the app router{{/dashboard}} |

## Layout

| Path | Responsibility |
|---|---|
| `lib/developer.dart` | Barrel |
| `lib/src/routes/developer_routes.dart` | `DeveloperRoutes`, `DeveloperFlags`, `DeveloperRouter` with the redirect guard |
| `lib/src/screens/developer_screen.dart` | `DeveloperScreen` |
| `lib/src/widgets/open_dev_tools_wrapper.dart` | Tap counter, reset timer, haptics, optional scale animation and tap-count badge |

## Rules

- The route guard is the real protection: `redirect` sends to `core.CoreRoutes.root` when `FeatureFlag` is not registered, when `isEnabled(DeveloperFlags.screenEnabled)` is false, or when it throws. Keep all three paths; hiding the gesture alone does not protect a typed URL.
- The gesture is shown only through `FeatureFlagWrapper(flagKey: DeveloperFlags.screenEnabled)`; when disabled it returns `child` untouched (no `GestureDetector`).
- `DeveloperScreen` takes its `Logger` as a parameter (no `di` lookup) and must keep working with a non-Talker logger.
- `_OpenDevToolsWrapperState.dispose` cancels `_resetTimer` and disposes `_animationController`; any new timer, controller or subscription must be released there too. Guard `setState` / `context.push` with `mounted`.
- Always reference the flag through `DeveloperFlags.screenEnabled`; never inline the string.

## Common changes

- **Add a dev-tools entry (e.g. a flags or environment page):** add a screen under `lib/src/screens/` and export it from `screens/index.dart`, add a constant to `DeveloperRoutes` and a `GoRoute` to `DeveloperRouter.routes` with the same `redirect` guard, and add a denied-navigation and an allowed-navigation case to `test/navigation_test.dart`.
- **Change the unlock gesture:** edit `OpenDevToolsWrapper` defaults or `_handleTap`; update the default-value assertions in `test/developer_test.dart` and the tap-window test in `test/navigation_test.dart`.
- **Change the guard flag:** change `DeveloperFlags.screenEnabled` and the flag name in your remote config.

## Tests

- `test/developer_test.dart`: route constant and `OpenDevToolsWrapper` default/custom constructor values.
- `test/navigation_test.dart`: non-Talker logger shows `strings.developer.no_viewer`; disabled flag keeps the gesture inert; direct navigation redirected to `/` with no `FeatureFlag` registered; enabled gesture honours `tapWindow` and opens `TalkerScreen`, run with `enableVisualFeedback` false and true.
- Pattern: `setUp(core.init)`, `tearDown(di.reset)`; a fake `FeatureFlagProvider` (`_Flags`) wrapped in a real `FeatureFlag(provider:, logger:)` registered with `di`; `GoRouter` with `addTearDown(router.dispose)`.

Run: `dart run melos exec --scope=developer -- flutter test`. `dart run melos run coverage` must stay 100%.

## Gotchas

- `DeveloperRouter` calls `di.get<Logger>()` when constructed, so `core.init()` must run before the app router is built.
- The tap-count badge uses `colorScheme.error` / `onError`; keep it on theme roles.
- `DeveloperRouter` resolves `FeatureFlag` from `di` inside `redirect`, so a flag registered after router creation is still honoured.
