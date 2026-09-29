import 'dart:async';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:network/src/auth/auth_token_provider.dart';

/// Adds session credentials and retries an authenticated request at most once.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(
    this._authTokenProvider, {
    required Dio dio,
    required Logger logger,
  }) : _dio = dio,
       _logger = logger;

  final AuthTokenProvider _authTokenProvider;
  final Dio _dio;
  final Logger _logger;
  Future<String?>? _refreshing;
  static const _managed = 'nonstop.auth.managed';
  static const _retried = 'nonstop.auth.retried';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final origin = Uri.parse(options.baseUrl);
      if (!origin.hasScheme || options.uri.origin != origin.origin) {
        handler.next(options);
        return;
      }
      if (options.headers.keys.any(
        (key) => key.toLowerCase() == 'authorization',
      )) {
        handler.next(options);
        return;
      }
      final token = await _authTokenProvider.getValidToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        options.extra[_managed] = true;
      }
      handler.next(options);
    } catch (error) {
      _logger.e('Unable to obtain an authentication token', error);
      handler.next(options);
    }
  }

  Future<String?> _refresh() async {
    if (_refreshing != null) return _refreshing;
    final pending = _authTokenProvider.refreshToken();
    _refreshing = pending;
    try {
      return await pending;
    } finally {
      _refreshing = null;
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        request.extra[_managed] != true ||
        request.extra[_retried] == true ||
        request.data is Stream) {
      handler.next(err);
      return;
    }
    try {
      final token = await _refresh();
      if (token != null) {
        final response = await _dio.fetch<dynamic>(
          request.copyWith(
            headers: {...request.headers, 'Authorization': 'Bearer $token'},
            extra: {...request.extra, _retried: true},
            data: request.data is FormData
                ? (request.data as FormData).clone()
                : request.data,
          ),
        );
        handler.resolve(response);
        return;
      }
    } catch (refreshError) {
      _logger.e('Authentication retry failed', refreshError);
    }
    handler.next(err);
  }
}
