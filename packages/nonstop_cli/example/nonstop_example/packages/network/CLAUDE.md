# Nonstop Example: `packages/network`

Owns the HTTP layer: the Dio client, auth and logging interceptors, the
`success`/`error` response envelope and the mapping of transport failures to
typed `NetworkException`s. It does not own tokens or sign-in (it consumes an
`AuthTokenProvider` supplied by the app or an auth feature), endpoints or
feature DTOs. Layer 2: depends on `core`, `di`, `localization`.

Read the root `CLAUDE.md` and `packages/CLAUDE.md` first.

## Public API

| Symbol | Kind |
|---|---|
| `NetworkClient` / `DioNetworkClient(config, logger:, dio:, authTokenProvider:, useAuthentication:)` | `abstract interface class` / Dio implementation: `get`/`post`/`put`/`patch`/`delete<T>(path, fromJsonT:)`, `handleResponse`, `handleSuccessResponse`, `dispose` |
| `init({required config, useAuthentication = true})`, `registerNetworkWithDI(config, {useAuthentication, dio})` | Registers `NetworkClient` (with `dispose`) and the caller's own `NetworkConfig` instance |
| `NetworkConfig` (interface) / `DefaultNetworkConfig` | `baseUrl`, 30s timeouts, `defaultHeaders`, `enableLogging`, `authTokenProvider` |
| `AuthTokenProvider` | `abstract interface class` token contract implemented outside this package |
| `AuthInterceptor`, `LoggingInterceptor` | Dio interceptors (exported) |
| `NetworkResponse<T>`, `SuccessResponse<T>`, `ErrorResponse<T>`, `ErrorDetails`, `Pagination` | Envelope models (`json_serializable`) |
| `NetworkException` + `BadRequest`/`Unauthorized`/`Forbidden`/`NotFound`/`Conflict`/`UnprocessableEntity`/`InternalServer`/`ConnectionTimeout`/`ReceiveTimeout`/`SendTimeout`/`NoInternetConnection`/`UnknownNetworkException` | Typed failures, localized `displayMessage`; timeout and no-internet exceptions have a null `statusCode` |
| `ErrorMessageExtension.message()`, `ErrorMessageOnError`, `ErrorCodes` | Any error to a localized user message |
| `ApiUrlConfig`, `NetworkApi<T>` | Base classes for feature API definitions |

## Layout

| Path | Responsibility |
|---|---|
| `lib/network.dart` | Barrel, `init`, `registerNetworkWithDI` (auth provider resolution) |
| `lib/src/client/` | `NetworkClient` contract, `DioNetworkClient` (envelope decoding, error mapping) |
| `lib/src/interceptors/` | `AuthInterceptor` (bearer + single retry), `LoggingInterceptor` (method + path only) |
| `lib/src/config/` | `NetworkConfig`, `DefaultNetworkConfig` |
| `lib/src/auth/` | `AuthTokenProvider` contract |
| `lib/src/models/` | Envelope models; `network_response.g.dart` is generated |
| `lib/src/exceptions/` | `network_exceptions.dart` |
| `lib/src/api/` | `ApiUrlConfig`, `NetworkApi` |
| `lib/src/utils/extensions/` | `error_message_extension.dart` |

## Rules

- **Auth origin.** `AuthInterceptor.onRequest` adds `Authorization: Bearer` only when the request origin equals `baseUrl`'s origin and the caller set no `authorization` header (case-insensitive). Absolute URLs to other hosts go out bare.
- **Token failures never fail a request.** If `getValidToken()` throws, the error is logged and the request proceeds unauthenticated.
- **Retry.** Only on 401, only for requests the interceptor authorized (`nonstop.auth.managed`), at most once (`nonstop.auth.retried`). Concurrent 401s share one `refreshToken()` future. `FormData` is `clone()`d for the retry; `Stream` bodies are never retried. A null or failed refresh surfaces the original `UnauthorizedException`.
- **Logs.** `LoggingInterceptor` logs method, status and `uri.path` only; never headers, query values or bodies (asserted by a test). Keep it that way when adding logging.
- **Failure policy.** Non-2xx and transport errors throw a typed `NetworkException` from `Never _handleError` (never returned); non-Dio errors become `UnknownNetworkException`. A 2xx body with `success: false` returns an `ErrorResponse`; `handleResponse`/`handleSuccessResponse` turn it into `UnknownNetworkException`. Envelope `statusCode`/`headers` fields are overwritten by the real HTTP values. Unparseable bodies return `ErrorResponse` with code `PARSE_ERROR`.
- **Injected:** `Logger` and `Dio` (tests pass `Dio()..httpClientAdapter = fake`). `dispose()` closes the Dio transport.
- `init` without `config.authTokenProvider` falls back to `di.get<AuthTokenProvider>()` when `di.has<AuthTokenProvider>()`; `useAuthentication: false` strips any provider. The config is registered as passed, so custom `NetworkConfig` implementations are preserved.
- No talker dependency: logging goes through the injected core `Logger` only.

## Common changes

- **Add an interceptor:** add it under `lib/src/interceptors/`, export it from `interceptors/index.dart`, add it in `DioNetworkClient._setupDio`. Order matters: auth is added before logging. Test through `DioNetworkClient` with the `_Adapter` fake in `test/dio_network_client_test.dart`.
- **Map a new status code:** add a subclass in `network_exceptions.dart` with a `strings.errors.*` message (new key in `packages/localization`), add the case in `_mapDioException`, add the row to the status table test in `dio_network_client_test.dart` and to the list in `test/models_test.dart`.
- **Change an envelope model:** edit `network_response.dart`, run `dart run melos run generate`, extend `test/models_test.dart`.

## Tests

| File | Covers |
|---|---|
| `test/dio_network_client_test.dart` | Verbs, envelope decoding, status/transport mapping, auth origin, refresh sharing, retry limits, multipart/stream, log redaction, `init` provider resolution, dispose |
| `test/response_contract_test.dart` | Non-Dio errors become `UnknownNetworkException`; handler branches (mocktail `Dio`) |
| `test/models_test.dart` | Exception messages, `ErrorMessageExtension`, JSON round-trips, `NetworkApi` |
| `test/network_test.dart` | `DefaultNetworkConfig` defaults |

Doubles: `_Adapter` (`HttpClientAdapter`), `_Tokens`/`_DelayedTokens` (`AuthTokenProvider`), `_Logger` recording messages.

`dart run melos exec --scope=network -- flutter test`; `dart run melos run coverage` must stay 100%.

## Gotchas

- `network_response.g.dart` is generated: `dart run melos run generate`.
- `ErrorResponse.toJson()` keeps `error` as an object, not a map; tests reassign it before `fromJson`.
- `sendTimeout` is dropped on web (`kIsWeb`) because Dio rejects it without a body.
