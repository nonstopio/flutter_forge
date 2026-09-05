import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:dio/dio.dart';
import 'package:network/src/auth/auth_token_provider.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._authTokenProvider) : _logger = di.get<Logger>();

  final AuthTokenProvider _authTokenProvider;
  final Logger _logger;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Skip authentication for requests that already have authorization header
      if (options.headers.containsKey('Authorization')) {
        handler.next(options);
        return;
      }

      final token = await _authTokenProvider.getValidToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        _logger.d('🔐 Added Bearer token to request: ${options.uri}');
      } else {
        _logger.d('🔓 No auth token available for request: ${options.uri}');
      }

      handler.next(options);
    } catch (e) {
      _logger.e('🚨 Error adding auth token to request', e);
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - token might be expired
    if (err.response?.statusCode == 401) {
      _logger.w('🔐 Received 401 Unauthorized, attempting token refresh');

      try {
        final newToken = await _authTokenProvider.refreshToken();
        if (newToken != null) {
          _logger.i('🔄 Token refreshed successfully, retrying request');

          // Clone the request with new token
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newToken';

          // Retry the request
          final response = await Dio().fetch(requestOptions);
          handler.resolve(response);
          return;
        } else {
          _logger.w('❌ Token refresh failed, user needs to re-authenticate');
        }
      } catch (refreshError) {
        _logger.e('🚨 Error during token refresh', refreshError);
      }
    }

    // Handle 403 Forbidden - user doesn't have permission
    if (err.response?.statusCode == 403) {
      _logger.w('🚫 Received 403 Forbidden, insufficient permissions');
    }

    handler.next(err);
  }
}
