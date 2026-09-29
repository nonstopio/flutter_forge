# Nonstop Example: `features/auth`

Firebase Authentication (email, Google, Apple on iOS) built on `firebase_ui_auth`:
sign-in, register and forgot-password screens, the `AuthService` identity
contract, the bearer-token adapter for `network`, route guards and a sign-out
helper for other features. It must not decide where the user lands after auth
(the app passes `onSignedIn` / `onSignedUp`) and must not import other features.

Read the root `CLAUDE.md` and `features/CLAUDE.md` first.
Load the `design-system` skill before changing UI.

## Public API (`package:auth/auth.dart`)

| Symbol | Kind | Notes |
|---|---|---|
| `init(AuthConfig, {firebaseAuth, configureProviders})` | function | Configures FirebaseUI providers, registers `AuthService` and `AuthTokenProvider` |
| `AuthConfig` / `DefaultAuthConfig` | interface / impl | `clientId` for `GoogleProvider` |
| `AuthService` / `AuthServiceImp` | interface / impl | `uid`, `isSignedIn`, `signOut()` |
| `FirebaseAuthTokenProvider` | impl of `network`'s `AuthTokenProvider` | owns the `idTokenChanges` subscription |
| `AuthRouter({onSignedIn, onSignedUp})` | implements `core.CoreRouter` | `routes`: sign-in, sign-up, forgot-password; callbacks are `FutureOr<void> Function(BuildContext)`; resolves `Logger` once and passes it to the screens |
| `authRedirectLocation({allowUnconfigured})` | function | null when signed in, else `AuthRoutes.signIn`; used by the app's `SplashScreen` |
| `authRedirect({allowUnconfigured})` | `GoRouterRedirect` | route-guard wrapper around `authRedirectLocation` |
| `signOut(BuildContext)` | function | no-op without `AuthService`; signs out, then `go(signIn)` if mounted |
| `GoAuthRoute` | `GoRoute` | `redirect` preset to `authRedirect` |
| `AuthRoutes` | constants | `/auth/sign-in`, `/auth/sign-up`, `/auth/forgot-password` |
| `AuthAnalytics` | static helpers | all auth analytics events |
| `SignInScreen({onSignedIn, logger})`, `RegisterScreen({onSignedUp, logger})`, `ForgotPasswordScreen({email})` | widgets | wrap the `firebase_ui_auth` screens |

## Layout

```
lib/
  auth.dart                         barrel + init()
  analytics/analytics.dart          AuthAnalytics: event names and params via AnalyticsHelper
  config/                           AuthConfig contract, DefaultAuthConfig
  constants/routes.dart             AuthRoutes
  data/services/                    AuthService contract, AuthServiceImp (FirebaseAuth + Logger injected)
  data/token/firebase_auth_token_provider.dart  token cache, expiry, refresh, stale-response guard
  router/router.dart                AuthRouter, authRedirectLocation, authRedirect, signOut, GoAuthRoute
  ui/screens/                       SignIn / Register / ForgotPassword adapters (index.dart barrel)
  ui/components/                    headerBuilder (theme-drawn), footerBuilder(context, action, type, logger) + FooterType (not exported)
```

## Rules

- `init()` needs `Logger` in `di` and Firebase initialised; call it before
  `network.init()` (which picks up `AuthTokenProvider`) and before the router.
- The token provider is registered with `dispose: (_) => tokens.dispose()`; it
  owns its subscription and broadcast controller. Nothing else may cancel them.
- `FirebaseAuthTokenProvider` bumps `_revision` on every token event, sign-out
  and dispose; `_readToken` drops a result whose revision or `currentUser.uid`
  changed. Keep that guard on any new read path.
- A token counts as expired 5 minutes before `expirationTime`; the clock is
  injectable (`now:`).
- `AuthServiceImp.signOut` logs and reports failures, then **rethrows**.
- `allowUnconfigured` exists only for the demo dashboard before Firebase is set up.
- Screens and `footerBuilder` take `Logger` as a parameter; only `AuthRouter` and `init()` use `di`.

## Common changes

- **Add an auth provider:** add it to the list in `init()` in `lib/auth.dart`
  (platform-guard like `AppleProvider`), add its package to `pubspec.yaml`, and
  map its `providerId` in `AuthAnalytics.getAuthMethod`. Extend the provider
  loop in `test/presentation_test.dart`.
- **Add an auth screen/route:** constant in `constants/routes.dart`, screen in
  `ui/screens/` + `index.dart`, `GoRoute` in `AuthRouter.routes`; assert the
  builder type in the `auth screen adapters` test.
- **Add an `AuthService` member:** contract, `AuthServiceImp`, and a case in
  `test/auth_service_test.dart` (success and SDK failure).
- **New auth analytics event:** static method on `AuthAnalytics`; call it in `presentation_test.dart`.
## Tests

| File | Covers |
|---|---|
| `auth_service_test.dart` | `AuthServiceImp` identity + sign-out, sign-out error rethrown, `init()` registers types and `di.reset` disposes the token provider |
| `token_provider_test.dart` | expiry-driven reuse vs refresh, signed-out null, stream publish/clear, read and stream errors, late refresh after sign-out or account change, idempotent dispose, null token |
| `presentation_test.dart` | `getAuthMethod`, every analytics call, route builders, SDK state actions invoke callbacks, forgot-password push with email, header/footer builders, `GoAuthRoute` for no service / signed out / signed in, `signOut` with and without service, footer navigation |

Pattern: `mocktail` mocks of `FirebaseAuth`, `User`, `IdTokenResult`, `AuthService`;
`setUp(core.init)` / `tearDown(di.reset)` in widget tests.

`dart run melos exec --scope=auth -- flutter test`; `dart run melos run coverage` must stay 100%.

## Gotchas

- Screen actions fire `AuthAnalytics.*` with `unawaited`, then `await` the callback.
- `SignInScreen` also handles `UserCreated`, `RegisterScreen` also `SignedIn`; both log a sign-up.
- Both screens log and show `Toast.error` on `AuthFailed`.
- Success analytics carry only method, `success`, `timestamp`: no user data.
- `ui/components/` is not exported; tests import `footer_builder.dart` directly.
