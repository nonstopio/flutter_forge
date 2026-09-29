# Architecture decisions

The app is the composition root. Features own screens and feature behavior;
shared packages expose cohesive contracts and implementations. Keep dependencies
pointing from apps to features to packages, never back toward the app.

## SOLID boundaries

| Principle | Starter boundary |
| --- | --- |
| Single responsibility | `App` renders an injected router; bootstrap composes services; lifecycle handling owns foreground work. |
| Open/closed | Implement the client/provider contracts to swap a backend or add a feature without editing existing consumers. |
| Liskov substitution | Tests exercise fakes against the same contracts; core observers accept any `Logger`, not only Talker. |
| Interface segregation | Auth tokens, device identity, notification permission and notification delivery have separate contracts. |
| Dependency inversion | Clients accept their transport, SDK, logger and clock dependencies. Resolve the locator at composition boundaries. |

The locator is a convenience at Flutter composition edges, not a requirement for
business logic. Prefer constructor injection in new services and repositories.
The container disposes dependents before dependencies and awaits async cleanup.
Only one component should own each subscription or disposable service.

## Adding a feature

1. Put behavior behind a small contract in the owning feature or shared package.
2. Inject its dependencies. Use an optional clock callback for time-sensitive behavior.
3. Write tests for success, invalid input, platform failure and lifecycle cleanup.
4. Expose feature routes and compose them in the app router.
5. Register implementations in bootstrap; keep registration separate from widget rendering.
6. Run `dart run melos run lint` and `dart run melos run coverage` before committing.

```dart
abstract interface class GreetingRepository {
  Future<String> loadGreeting();
}

class LoadGreeting {
  const LoadGreeting(this.repository);
  final GreetingRepository repository;

  Future<String> call() => repository.loadGreeting();
}
```

Test `LoadGreeting` using a small fake repository. Test a real repository's adapter
with an injected transport rather than making live requests in unit tests.

## Failure and privacy policy

- HTTP failures stay typed; application-level error envelopes never masquerade as success.
- Automatic bearer headers stay on the configured API origin. One retry follows a shared token refresh; consumed streams are not replayed.
- SDK initialization is awaited. An unavailable optional Firebase configuration permits the starter demo to boot; emulator setup failures are surfaced.
- Analytics failures do not interrupt UI behavior. SDK state is not cached across DI resets.
- Network logs omit headers, query values and bodies. Auth success logs omit email addresses; add your own redaction rules for domain errors.
- Platform crash handlers are restored when their owning client is disposed.

## What the tests do not replace

100% line coverage measures execution, not every branch or possible input. Add
security rules tests, device tests, accessibility checks and backend integration
tests for your product. Configure provider credentials, privacy consent and native
permissions deliberately; a starter cannot choose these product policies for you.
