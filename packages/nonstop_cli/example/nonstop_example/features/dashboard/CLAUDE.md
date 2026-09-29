# Nonstop Example: `features/dashboard`

The bottom-navigation shell for the signed-in area and its starter tabs (Home,
Explore, Profile). It owns tab layout and tab screens only. It does not know
about auth: the route guard and the sign-out action are injected by the app. It
has no `init()`, no services and no `di` registrations.

Read the root `CLAUDE.md` and `features/CLAUDE.md` first.
Load the `design-system` skill before changing UI.

## Public API (`package:dashboard/dashboard.dart`)

| Symbol | Kind | Notes |
|---|---|---|
| `DashboardRouter.createShellRoute({redirect, onOpenSettings, onSignOut})` | `StatefulShellRoute` | `redirect` applied to every tab; `onOpenSettings` and `onSignOut` forwarded to `ProfileTabScreen` |
| `DashboardRouter.home` / `explore` / `profile` | route constants | `/home/dashboard`, `/home/explore`, `/home/profile` |
| `DashboardShellScreen({navigationShell})` | widget | `NavigationBar` over the shell |
| `HomeTabScreen`, `ExploreTabScreen` | widgets | placeholder tabs |
| `ProfileTabScreen({onOpenSettings, onSignOut})` | widget | avatar (dev-tools entry), optional settings tile, optional sign-out |
| `PlaceholderTab({icon, title, subtitle, action})` | widget | "nothing here yet" body |

The app wires it as
`DashboardRouter.createShellRoute(redirect: auth.authRedirect(allowUnconfigured: true), onSignOut: AppRouter.signOut)`
(no `onOpenSettings` yet, so the settings tile is hidden).

## Layout

```
lib/
  dashboard.dart                       barrel
  router/dashboard_router.dart         DashboardRouter: paths + indexed-stack shell, one branch per tab
  ui/screens/dashboard_shell_screen.dart  NavigationBar; destinations are positional with branches
  ui/screens/home_tab_screen.dart      Home placeholder
  ui/screens/explore_tab_screen.dart   Explore placeholder
  ui/screens/profile_tab_screen.dart   profile, optional settings tile, sign-out with confirm dialog
  ui/widgets/placeholder_tab.dart      PlaceholderTab
```

## Rules

- Never import `auth` (or any feature). New cross-feature behavior is a new
  optional parameter on `createShellRoute`, supplied by `apps/nonstop_example/lib/router/router.dart`.
- Branch order in `createShellRoute` must match destination order in
  `DashboardShellScreen`; `goBranch` uses the index.
- Every tab goes through the local `tab(path, screen)` helper so it gets `redirect`.
- Sign-out runs only after the dialog returns `true` and `context.mounted`.
  Each profile tile is hidden when its callback (`onOpenSettings`, `onSignOut`) is null.
- Tapping the current tab again calls `goBranch(..., initialLocation: true)`
  (pops to the tab root).
- The avatar is wrapped in `developer`'s `OpenDevToolsWrapper` (5 taps).

## Common changes

- **Add a tab:** path constant and `StatefulShellBranch` via `tab(...)` in
  `router/dashboard_router.dart`; screen in `ui/screens/` + `index.dart`;
  `NavigationDestination` at the same index in `dashboard_shell_screen.dart`
  (icon from `NavigationIcons`, label from `strings.nav.*`, add the key in `localization`). Extend the
  navigation test in `test/dashboard_test.dart` to tap it and assert its path
  was redirected through.
- **Replace a placeholder tab:** swap `PlaceholderTab` in the tab screen for real
  content; real data and state belong in their own feature, passed in the same
  way as `onSignOut`.
- **Inject another app callback:** add an optional parameter to
  `createShellRoute`, forward it to the screen, wire it in the app router, and
  test both the set and null cases like `onOpenSettings` / `onSignOut`.

## Tests

`test/dashboard_test.dart`: tab navigation hits `home`/`explore`/`profile` and
runs the injected `redirect` for each; the settings tile calls `onOpenSettings`;
sign-out cancel does nothing, confirm calls `onSignOut` once;
`ProfileTabScreen()` hides settings and sign-out; `PlaceholderTab` action fires. Pattern: real `GoRouter` with a recording `redirect` and counter
callbacks, `setUp(core.init)` / `tearDown(di.reset)`.

`dart run melos exec --scope=dashboard -- flutter test`; `dart run melos run coverage` must stay 100%.

## Gotchas

- All copy comes from `strings.*`, including the placeholder subtitles; tests
  find the tab by `strings.nav.explore`.
- `core` and `di` are dev dependencies, used only by the test.
- Route paths live on `DashboardRouter`, not in a `constants/routes.dart`.
