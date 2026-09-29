import 'package:core/core.dart';
import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Credentials and personal data can occur in headers, query strings and
    // bodies. Log only the HTTP method and path by default.
    _logger.d('Request: ${options.method} ${options.uri.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d(
      'Response: ${response.statusCode} ${response.requestOptions.uri.path}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      'Network error: ${err.type.name} ${err.response?.statusCode} '
      '${err.requestOptions.uri.path}',
    );
    super.onError(err, handler);
  }
}
