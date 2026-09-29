# {{name.titleCase()}}: `features/`

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
{{#analytics}}    analytics/             feature event names (if analytics is used)
{{/analytics}}  test/
  pubspec.yaml             `resolution: workspace`
  CLAUDE.md                this feature's contract (required)
```

{{#auth}}`features/auth` is the reference implementation. Match its layout.{{#dashboard}} (A small
feature may keep route paths as constants on its router class, as
`dashboard/lib/router/dashboard_router.dart` does. Pick one style per feature.){{/dashboard}}
{{/auth}}{{^auth}}{{#dashboard}}`features/dashboard` is the reference implementation. It keeps route paths as
constants on its router class (`lib/router/dashboard_router.dart`) rather than
in `constants/routes.dart`; pick one style per feature.
{{/dashboard}}{{^dashboard}}No feature ships with this project yet, so the first one you add sets the
reference layout. Follow the shape above.
{{/dashboard}}{{/auth}}
## Rules

- **Public surface is the barrel file.** Other code imports
  `package:<name>/<name>.dart` only, never `package:<name>/src/...` or deep paths.
- **No feature-to-feature imports.** A feature that needs another feature's
  behavior takes it as a parameter, and the app passes it in.{{#auth}}{{#dashboard}} Example:
  `DashboardRouter.createShellRoute(redirect: auth.authRedirect(...),
  onSignOut: {{#notifications}}AppRouter.signOut{{/notifications}}{{^notifications}}auth.signOut{{/notifications}})` in the app router, so `dashboard` never
  imports `auth`.{{/dashboard}}{{/auth}} If several features share a contract, move it into `packages/`.
- **Layers inside a feature:** `ui` -> state (Cubit/Bloc or a small controller)
  -> `data` contracts. Widgets never call SDKs{{#firebase}}, HTTP or Firebase{{/firebase}}{{^firebase}} or HTTP{{/firebase}} directly.
- `init()` registers services with `di` and is the only place a feature calls
  `di.register`. Services and screens take dependencies (including `Logger`)
  through their constructor so tests can pass fakes; the router resolves them
  once and passes them down.
- Routes are exposed, not registered: the app spreads `<Name>Router().routes`.{{#auth}}
  Guard protected routes with `GoAuthRoute`, or, when the feature must not
  depend on `auth`, accept a `GoRouterRedirect` and let the app pass
  `auth.authRedirect()`{{#dashboard}} (as `dashboard` does){{/dashboard}}.{{/auth}}{{^auth}}
  A protected route takes a `GoRouterRedirect` that the app passes in.{{/auth}} Client guards are navigation
  helpers; the backend enforces authorization.
- All strings via `strings.*` from `localization`; all styling via the theme and
  `design_system` components (load the `design-system` skill).
{{#analytics}}- Emit analytics through the `analytics` package contract, with event names
  defined in the feature's `analytics/` file.
{{/analytics}}
## Tests

Each feature needs tests for: service success and typed failure, the widget
states a screen can show (loading, data, empty, error), navigation of its
routes, and disposal of subscriptions. Use `setUp(core.init)` and
`tearDown(di.reset)` so the locator is clean per test{{#dashboard}} (see
`features/dashboard/test/dashboard_test.dart`){{/dashboard}}.
