import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:di/di.dart';
import 'package:network/network.dart' as network;
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';

class _Logger implements Logger {
  final messages = <String>[];
  @override
  Object get logger => this;
  @override
  void d(String message) => messages.add(message);
  @override
  void i(String message) => messages.add(message);
  @override
  void w(String message) => messages.add(message);
  @override
  void e(String message, [Object? error, StackTrace? stackTrace]) =>
      messages.add(message);
}

class _Adapter implements HttpClientAdapter {
  Object? body;
  int status = 200;
  final statuses = <int>[];
  bool closed = false;
  Object? failure;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (failure != null) throw failure!;
    return ResponseBody.fromString(
      jsonEncode(body),
      statuses.isEmpty ? status : statuses.removeAt(0),
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) => closed = true;
}

class _Tokens implements AuthTokenProvider {
  int refreshes = 0;
  String? refreshed = 'new-token';
  bool failRefresh = false;
  bool failRead = false;
  @override
  Future<String?> getValidToken() async {
    if (failRead) throw StateError('token unavailable');
    return 'old-token';
  }

  @override
  Future<String?> refreshToken() async {
    refreshes++;
    if (failRefresh) throw StateError('refresh failed');
    return refreshed;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DelayedTokens extends _Tokens {
  final pending = Completer<String?>();
  @override
  Future<String?> refreshToken() {
    refreshes++;
    return pending.future;
  }
}

void main() {
  late _Adapter adapter;
  late _Logger logger;
  late DioNetworkClient client;

  setUp(() {
    adapter = _Adapter();
    logger = _Logger();
    client = DioNetworkClient(
      DefaultNetworkConfig(baseUrl: 'https://example.test'),
      logger: logger,
      dio: Dio()..httpClientAdapter = adapter,
    );
  });
  tearDown(() => client.dispose());

  test('concurrent unauthorized requests share one token refresh', () async {
    final tokens = _DelayedTokens();
    adapter.statuses.addAll([401, 401, 200, 200]);
    final authenticated = DioNetworkClient(
      DefaultNetworkConfig(
        baseUrl: 'https://example.test',
        authTokenProvider: tokens,
      ),
      logger: logger,
      dio: Dio()..httpClientAdapter = adapter,
    );
    addTearDown(authenticated.dispose);
    final first = authenticated.get<Object?>(
      '/first',
      fromJsonT: (json) => json,
    );
    final second = authenticated.get<Object?>(
      '/second',
      fromJsonT: (json) => json,
    );
    await pumpEventQueue();
    expect(tokens.refreshes, 1);
    tokens.pending.complete('new-token');
    final results = await Future.wait([first, second]);
    expect(results.every((r) => r.isSuccess), isTrue);
    expect(adapter.requests, hasLength(4));
  });

  test(
    'multipart retries clone consumed bodies; streams are never replayed',
    () async {
      final tokens = _Tokens();
      final authenticated = DioNetworkClient(
        DefaultNetworkConfig(
          baseUrl: 'https://example.test',
          authTokenProvider: tokens,
        ),
        logger: logger,
        dio: Dio()..httpClientAdapter = adapter,
      );
      addTearDown(authenticated.dispose);
      adapter.statuses.addAll([401, 200]);
      final form = FormData.fromMap({'field': 'value'});
      expect(
        (await authenticated.post<Object?>(
          '/file',
          data: form,
          fromJsonT: (json) => json,
        )).isSuccess,
        isTrue,
      );
      expect(adapter.requests.last.data, isNot(same(form)));
      adapter.status = 401;
      await expectLater(
        authenticated.post<Object?>(
          '/stream',
          data: Stream.value([1, 2]),
          fromJsonT: (json) => json,
        ),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(tokens.refreshes, 1);
    },
  );

  test('API payload cannot override HTTP status or response headers', () async {
    adapter.body = {
      'success': true,
      'timestamp': 'now',
      'data': 1,
      'statusCode': 500,
      'headers': {
        'fake': ['value'],
      },
    };
    final response = await client.get<int>(
      '/value',
      fromJsonT: (json) => json as int,
    );
    expect(response.statusCode, 200);
    expect(response.headers, isNot(contains('fake')));
  });

  for (final (status, expected) in <(int, Type)>[
    (400, BadRequestException),
    (403, ForbiddenException),
    (404, NotFoundException),
    (409, ConflictException),
    (422, UnprocessableEntityException),
    (500, InternalServerException),
    (502, InternalServerException),
    (503, InternalServerException),
    (504, InternalServerException),
    (418, UnknownNetworkException),
  ]) {
    test(
      'HTTP $status maps to $expected and preserves API error details',
      () async {
        adapter.status = status;
        adapter.body = {
          'success': false,
          'timestamp': '2026-01-01',
          'error': {'code': 'FAIL', 'message': 'Request rejected'},
        };
        await expectLater(
          client.get<Object?>('/request', fromJsonT: (json) => json),
          throwsA(
            predicate<NetworkException>(
              (e) =>
                  e.runtimeType == expected && e.message == 'Request rejected',
            ),
          ),
        );
      },
    );
  }

  test('every transport failure maps to a domain exception', () async {
    for (final (type, error, expected) in <(DioExceptionType, Object?, Type)>[
      (DioExceptionType.connectionTimeout, null, ConnectionTimeoutException),
      (DioExceptionType.receiveTimeout, null, ReceiveTimeoutException),
      (DioExceptionType.sendTimeout, null, SendTimeoutException),
      (
        DioExceptionType.connectionError,
        const SocketException('offline'),
        NoInternetConnectionException,
      ),
      (DioExceptionType.connectionError, null, UnknownNetworkException),
      (DioExceptionType.cancel, null, UnknownNetworkException),
    ]) {
      adapter.failure = DioException(
        requestOptions: RequestOptions(path: '/request'),
        type: type,
        error: error,
      );
      await expectLater(
        client.get<Object?>('/request', fromJsonT: (json) => json),
        throwsA(predicate<NetworkException>((e) => e.runtimeType == expected)),
      );
    }
  });

  test(
    'write verbs consistently propagate transport errors and malformed envelopes do not hide HTTP failures',
    () async {
      adapter.status = 500;
      adapter.body = {'success': false, 'error': 'invalid shape'};
      for (final operation in [
        () => client.post<Object?>('/request', fromJsonT: (j) => j),
        () => client.put<Object?>('/request', fromJsonT: (j) => j),
        () => client.patch<Object?>('/request', fromJsonT: (j) => j),
        () => client.delete<Object?>('/request', fromJsonT: (j) => j),
      ]) {
        await expectLater(operation(), throwsA(isA<InternalServerException>()));
      }
    },
  );

  test(
    'auth tokens stay on the configured origin and provider failures do not crash requests',
    () async {
      final tokens = _Tokens();
      final transport = Dio()..httpClientAdapter = adapter;
      final authenticated = DioNetworkClient(
        DefaultNetworkConfig(
          baseUrl: 'https://example.test',
          authTokenProvider: tokens,
        ),
        logger: logger,
        dio: transport,
      );
      addTearDown(authenticated.dispose);
      await authenticated.get<Object?>(
        'https://external.test/image',
        fromJsonT: (j) => j,
      );
      expect(adapter.requests.last.headers, isNot(contains('Authorization')));
      tokens.failRead = true;
      await authenticated.get<Object?>('/image', fromJsonT: (j) => j);
      expect(adapter.requests.last.headers, isNot(contains('Authorization')));
    },
  );

  test(
    'module respects explicit disable, injected credentials and unconfigured auth',
    () async {
      addTearDown(di.reset);
      for (final supplied in [false, true]) {
        for (final enabled in [false, true]) {
          await di.reset();
          di.register<Logger>(logger);
          final tokens = _Tokens();
          await network.init(
            config: DefaultNetworkConfig(
              baseUrl: 'https://example.test',
              authTokenProvider: supplied ? tokens : null,
            ),
            useAuthentication: enabled,
          );
          expect(
            di.get<NetworkConfig>().authTokenProvider,
            supplied && enabled ? same(tokens) : isNull,
          );
        }
      }
      await di.reset();
      di.register<Logger>(logger);
      final tokens = _Tokens();
      di.register<AuthTokenProvider>(tokens);
      await network.init(
        config: DefaultNetworkConfig(baseUrl: 'https://example.test'),
      );
      expect(di.get<NetworkConfig>().authTokenProvider, same(tokens));
    },
  );

  test('plain JSON uses the supplied decoder', () async {
    adapter.body = {'count': 7};
    final response = await client.get<int>(
      '/count',
      fromJsonT: (json) => (json as Map)['count'] as int,
    );
    expect(response.isSuccess, isTrue);
    expect(client.handleResponse(response), 7);
    expect(client.handleSuccessResponse(response).data, 7);
  });

  test('API errors in HTTP 200 stay errors', () async {
    adapter.body = {
      'success': false,
      'timestamp': '2026-01-01',
      'message': 'Cannot save',
      'error': {'code': 'INVALID', 'message': 'Invalid input'},
    };
    final response = await client.post<String>(
      '/save',
      fromJsonT: (json) => json as String,
    );
    expect(response, isA<ErrorResponse<String>>());
    expect(response.isSuccess, isFalse);
    expect((response as ErrorResponse).error.code, 'INVALID');
    expect(
      () => client.handleResponse(response),
      throwsA(isA<NetworkException>()),
    );
  });

  test('envelope success decodes data and retains metadata', () async {
    adapter.body = {
      'success': true,
      'timestamp': '2026-01-01',
      'data': {'count': 3},
    };
    final response = await client.get<int>(
      '/count',
      fromJsonT: (json) => (json as Map)['count'] as int,
    );
    expect(client.handleResponse(response), 3);
    expect(response.timestamp, '2026-01-01');
  });

  test('invalid payload becomes a parse error', () async {
    adapter.body = 'invalid';
    final response = await client.get<int>(
      '/count',
      fromJsonT: (json) => json as int,
    );
    expect(response, isA<ErrorResponse<int>>());
    expect((response as ErrorResponse).error.code, 'PARSE_ERROR');
  });

  for (final method in ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']) {
    test('$method forwards query and headers and decodes response', () async {
      adapter.body = 8;
      final request = switch (method) {
        'POST' => client.post<int>,
        'PUT' => client.put<int>,
        'PATCH' => client.patch<int>,
        'DELETE' => client.delete<int>,
        _ => client.get<int>,
      };
      final response = await request(
        '/items',
        queryParameters: {'page': 2},
        headers: {'X-Request': 'test'},
        fromJsonT: (json) => json as int,
      );
      expect(client.handleResponse(response), 8);
      expect(adapter.requests.single.method, method);
      expect(adapter.requests.single.queryParameters, {'page': 2});
      expect(adapter.requests.single.headers['X-Request'], 'test');
    });
  }

  test('unauthorized HTTP responses throw a typed exception', () async {
    adapter.status = 401;
    adapter.body = {'message': 'Unauthorized'};
    await expectLater(
      client.get<int>('/private', fromJsonT: (json) => json as int),
      throwsA(isA<UnauthorizedException>()),
    );
  });

  test('logs do not contain credentials, query values or payloads', () async {
    adapter.body = {'secret': 'response-secret'};
    await client.post<Object?>(
      '/items',
      headers: {'Authorization': 'Bearer header-secret'},
      queryParameters: {'token': 'query-secret'},
      data: {'password': 'body-secret'},
      fromJsonT: (json) => json,
    );
    expect(logger.messages.join('\n'), isNot(contains('secret')));
  });

  test('dispose closes the transport', () {
    client.dispose();
    expect(adapter.closed, isTrue);
  });

  group('authentication retries', () {
    late _Tokens tokens;
    setUp(() {
      client.dispose();
      adapter = _Adapter()..body = 9;
      tokens = _Tokens();
      client = DioNetworkClient(
        DefaultNetworkConfig(
          baseUrl: 'https://example.test',
          authTokenProvider: tokens,
        ),
        logger: logger,
        dio: Dio()..httpClientAdapter = adapter,
      );
    });

    test('uses the configured transport and refreshes once', () async {
      adapter.statuses.addAll([401, 200]);
      final response = await client.get<int>(
        '/items',
        fromJsonT: (json) => json as int,
      );
      expect(client.handleResponse(response), 9);
      expect(adapter.requests, hasLength(2));
      expect(
        adapter.requests.last.headers['Authorization'],
        'Bearer new-token',
      );
      expect(tokens.refreshes, 1);
    });

    test('a repeated 401 does not loop', () async {
      adapter.status = 401;
      await expectLater(
        client.get<int>('/items', fromJsonT: (json) => json as int),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(adapter.requests, hasLength(2));
      expect(tokens.refreshes, 1);
    });

    test('caller authorization is respected case-insensitively', () async {
      adapter.status = 401;
      await expectLater(
        client.get<int>(
          '/items',
          headers: {'authorization': 'custom'},
          fromJsonT: (json) => json as int,
        ),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(adapter.requests, hasLength(1));
      expect(adapter.requests.single.headers['authorization'], 'custom');
      expect(tokens.refreshes, 0);
    });

    for (final fails in [true, false]) {
      test(
        'unavailable refreshed token preserves the original error ($fails)',
        () async {
          tokens.failRefresh = fails;
          tokens.refreshed = null;
          adapter.status = 401;
          await expectLater(
            client.get<int>('/items', fromJsonT: (json) => json as int),
            throwsA(isA<UnauthorizedException>()),
          );
          expect(adapter.requests, hasLength(1));
        },
      );
    }
  });
}
