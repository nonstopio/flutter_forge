# network

HTTP layer for {{name.titleCase()}}: a Dio-backed `NetworkClient`, an auth
interceptor, a privacy-safe logging interceptor, typed response envelopes and a
closed set of `NetworkException`s.

## Initialise

```dart
import 'package:network/network.dart' as network;

await network.init(
  config: network.DefaultNetworkConfig(baseUrl: Environment.baseUrl),
);

final client = di.get<network.NetworkClient>();
```

`init` registers `NetworkClient` and the `NetworkConfig` instance you passed
(your own `NetworkConfig` implementation is kept as-is). A `Logger` must already
be registered.

Credentials: with `useAuthentication: true` (the default) the client uses
`config.authTokenProvider`, or otherwise an `AuthTokenProvider` registered in DI
(the auth feature registers one). Pass `useAuthentication: false` for an
unauthenticated client.

## Configure

| `DefaultNetworkConfig` field | Default |
| --- | --- |
| `baseUrl` | required |
| `connectTimeout` / `receiveTimeout` / `sendTimeout` | 30 s (send timeout is not applied on web) |
| `defaultHeaders` | `{}` |
| `enableLogging` | `true` |
| `authTokenProvider` | `null` (resolved from DI, see above) |

## Make requests

```dart
final response = await client.get<User>(
  '/users/me',
  fromJsonT: (json) => User.fromJson(json! as Map<String, dynamic>),
);
final user = client.handleResponse(response); // throws on ErrorResponse
```

Bodies shaped `{success: true|false, ...}` decode into `SuccessResponse` /
`ErrorResponse`; any other body is passed to `fromJsonT` as a success.

## Errors

Transport and HTTP failures are thrown as a `NetworkException` subtype:

| Cause | Exception | `statusCode` |
| --- | --- | --- |
| 400 / 401 / 403 / 404 / 409 / 422 | `BadRequest` / `Unauthorized` / `Forbidden` / `NotFound` / `Conflict` / `UnprocessableEntity` `Exception` | the HTTP status |
| 500, 502, 503, 504 | `InternalServerException` | 500 |
| connect / receive / send timeout | `ConnectionTimeout` / `ReceiveTimeout` / `SendTimeout` `Exception` | `null` |
| socket failure | `NoInternetConnectionException` | `null` |
| anything else | `UnknownNetworkException` | the HTTP status, if any |

`displayMessage` gives a localised message; `error.message()` (from
`ErrorMessageExtension`) turns any thrown object into user-facing text.

## Privacy rules

- The logging interceptor records only the HTTP method, path and status code:
  never headers, query strings or bodies.
- The auth interceptor adds `Authorization: Bearer <token>` only to requests on
  the configured base URL's origin, never overrides a caller-supplied
  `Authorization` header, and retries a 401 at most once after a token refresh.
