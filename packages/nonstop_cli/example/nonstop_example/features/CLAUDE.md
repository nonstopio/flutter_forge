# Nonstop Example: `features/`

A feature is a vertical slice of the product: UI, state and data access for one
capability. Read the root `CLAUDE.md` first. To add one end to end, load the
`new-feature` skill.

## Shape of a feature

```
features/<name>/
  lib/
    <name>.dart            public API: init(), exports. Nothing else is imported from outside
    config/                feature config contract + default implementation
    constants/routes.dart  route paths
    data/                  `abstract interface class` contracts (`*_service.dart`) and implementations (`*_imp.dart`)
    router/router.dart     `<Name>Router` exposing `List<RouteBase> routes`
    ui/screens/            one screen per file, `index.dart` barrel
    ui/components/         feature-private widgets
    analytics/             feature event names (if analytics is used)
  test/
  pubspec.yaml             `resolution: workspace`
  CLAUDE.md                this feature's contract (required)
```

`features/auth` is the reference implementation. Match its layout. (A small
feature may keep route paths as constants on its router class, as
`dashboard/lib/router/dashboard_router.dart` does. Pick one style per feature.)

## Rules

- **Public surface is the barrel file.** Other code imports
  `package:<name>/<name>.dart` only, never `package:<name>/src/...` or deep paths.
- **No feature-to-feature imports.** A feature that needs another feature's
  behavior takes it as a parameter, and the app passes it in. Example:
  `DashboardRouter.createShellRoute(redirect: auth.authRedirect(...),
  onSignOut: AppRouter.signOut)` in the app router, so `dashboard` never
  imports `auth`. If several features share a contract, move it into `packages/`.
- **Layers inside a feature:** `ui` -> state (Cubit/Bloc or a small controller)
  -> `data` contracts. Widgets never call SDKs, HTTP or Firebase directly.
- `init()` registers services with `di` and is the only place a feature calls
  `di.register`. Services and screens take dependencies (including `Logger`)
  through their constructor so tests can pass fakes; the router resolves them
  once and passes them down.
- Routes are exposed, not registered: the app spreads `<Name>Router().routes`.
  Guard protected routes with `GoAuthRoute`, or, when the feature must not
  depend on `auth`, accept a `GoRouterRedirect` and let the app pass
  `auth.authRedirect()` (as `dashboard` does). Client guards are navigation
  helpers; the backend enforces authorization.
- All strings via `strings.*` from `localization`; all styling via the theme and
  `design_system` components (load the `design-system` skill).
- Emit analytics through the `analytics` package contract, with event names
  defined in the feature's `analytics/` file.

## Tests

Each feature needs tests for: service success and typed failure, the widget
states a screen can show (loading, data, empty, error), navigation of its
routes, and disposal of subscriptions. Use `setUp(core.init)` and
`tearDown(di.reset)` so the locator is clean per test (see
`features/dashboard/test/dashboard_test.dart`).
