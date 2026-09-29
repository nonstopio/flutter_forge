---
name: new-feature
description: Add a product feature end to end in this mono-repo - scaffold the feature package, define its contract and data layer, state, screens, routes, strings, DI registration, app wiring and tests. Use when asked to build a new screen flow, module or capability, not for a one-line change inside an existing feature.
---

# New feature, end to end

Follow the steps in order. {{#auth}}`features/auth` is the reference: open the matching
file there before writing each piece.{{/auth}}{{^auth}}{{#dashboard}}`features/dashboard` is the reference: open the matching
file there before writing each piece.{{/dashboard}}{{^dashboard}}The shape to follow is in `features/CLAUDE.md`.{{/dashboard}}{{/auth}}

## 0. Decide where it goes

- Product behavior with screens -> `features/<name>`.
- A capability several features need (storage, payments SDK wrapper) ->
  `packages/<name>`, then a feature consumes it.
- If the feature needs something from another feature, move that contract into
  `packages/` first. Never import one feature from another.

## 1. Scaffold and register

Follow "Add a package" in the `melos-workspace` skill with `-o features`.
Depend only on what you use: usually `core`, `di`, `design_system`,
`localization`, `go_router`{{#network}}, plus `network`{{#analytics}}/`analytics`{{/analytics}} when needed{{/network}}{{^network}}{{#analytics}}, plus `analytics` when needed{{/analytics}}{{/network}}.

## 2. Contract first

```dart
// lib/data/services/orders_service.dart
abstract interface class OrdersService {
  Future<List<Order>> list();
}

// lib/data/services/orders_service_imp.dart
class OrdersServiceImp implements OrdersService {
{{#network}}  OrdersServiceImp({required NetworkClient client, required Logger logger})
    : _client = client,
      _logger = logger;
  final NetworkClient _client;
  final Logger _logger;
  // ...map transport errors to the feature's typed exceptions
{{/network}}{{^network}}  OrdersServiceImp({required Logger logger}) : _logger = logger;
  final Logger _logger;
  // ...call your data source; map its errors to the feature's typed exceptions
{{/network}}}
```

Models are immutable (`final` fields, `const` constructors, `Equatable` or
value equality), with `fromJson`/`toJson` via `json_serializable` if they cross
the wire. Run `dart run melos run generate`.

## 3. State

Use a `Cubit` (or `Bloc` for event-heavy flows) per screen, taking the service
contract in its constructor. Add `flutter_bloc` to the feature with the same
version constraint the app uses. State is a sealed class hierarchy:

```dart
sealed class OrdersState {}
final class OrdersLoading extends OrdersState {}
final class OrdersLoaded extends OrdersState { OrdersLoaded(this.orders); final List<Order> orders; }
final class OrdersFailed extends OrdersState { OrdersFailed(this.message); final String message; }
```

Widgets switch exhaustively on it. No service calls from widgets.

## 4. UI

- One screen per file in `lib/ui/screens/`, exported from `index.dart`.
- Build with `design_system` components and `Theme.of(context)`.
- Every string from `strings.<group>.<key>`: add keys to
  `packages/localization/lib/messages.i69n.yaml`, then
  `dart run melos run generate:i69n`.
- Handle loading, empty, error and data states explicitly.
- Load the `flutter-best-practices` and `design-system` skills for widget and
  visual rules.

## 5. Routes

```dart
// lib/constants/routes.dart
abstract final class OrdersRoutes { static const list = '/orders'; }

// lib/router/router.dart
class OrdersRouter implements CoreRouter {
  OrdersRouter({this.redirect});
  final GoRouterRedirect? redirect; // the app passes {{#auth}}auth.authRedirect(){{/auth}}{{^auth}}its guard{{/auth}}

  @override
  List<RouteBase> get routes => [
    GoRoute(path: OrdersRoutes.list, redirect: redirect, builder: (_, _) => const OrdersScreen()),
  ];
}
```

{{#auth}}A feature cannot import `auth`, so signed-in-only routes take the guard as a
parameter{{#dashboard}} (as `DashboardRouter.createShellRoute(redirect:)` does){{/dashboard}}; the app
passes `auth.authRedirect()`.{{/auth}}{{^auth}}A feature never imports another feature, so a route guard is a parameter
that the app passes in.{{/auth}} Cross-feature actions (sign-out, settings) are
callbacks injected the same way. Deep-link parameters are parsed and validated
in the route, not in the screen.

## 6. Register and wire

```dart
// lib/orders.dart
Future<void> init() async {
  di.register<OrdersService>(
{{#network}}    OrdersServiceImp(client: di.get<NetworkClient>(), logger: di.get<Logger>()),
{{/network}}{{^network}}    OrdersServiceImp(logger: di.get<Logger>()),
{{/network}}  );
}
```

In the app: call `orders.init()` in `bootstrap.dart` after the modules it
depends on, and spread `...OrdersRouter({{#auth}}redirect: auth.authRedirect(){{/auth}}).routes` in
`router/router.dart`.
Add the dependency to `apps/{{name.snakeCase()}}/pubspec.yaml`.

## 7. Tests (required, 100% coverage)

- Service: success, each typed failure, malformed payload ({{#network}}fake `NetworkClient`{{/network}}{{^network}}fake data source{{/network}}).
- Cubit: every state transition (fake service).
- Screens: each state renders; primary action works; navigation happens.
- `init()`: registers the expected types (`setUp(core.init)`, `tearDown(di.reset)`).

## 8. Finish

`dart run melos run lint`, `dart run melos run coverage`, run the app and try
the flow. Add a `README.md` (purpose, routes, config) and a `CLAUDE.md`
(match {{#auth}}`features/auth/CLAUDE.md`{{/auth}}{{^auth}}{{#dashboard}}`features/dashboard/CLAUDE.md`{{/dashboard}}{{^dashboard}}the sections of `packages/core/CLAUDE.md`{{/dashboard}}{{/auth}}), and list the feature in the root
`README.md` module table.
