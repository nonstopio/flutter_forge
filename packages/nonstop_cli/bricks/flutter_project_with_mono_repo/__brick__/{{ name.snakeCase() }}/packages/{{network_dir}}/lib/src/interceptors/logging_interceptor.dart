import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor() : _logger = di.get<Logger>();

  final Logger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('🚀 Request: ${options.method} ${options.uri}');
    _logger.d('Headers: ${options.headers}');
    if (options.data != null) {
      _logger.d('Data: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      _logger.d('Query Parameters: ${options.queryParameters}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d(
      '✅ Response: ${response.statusCode} ${response.requestOptions.uri}',
    );
    _logger.d('Response Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '❌ Error: ${err.response?.statusCode} ${err.requestOptions.uri}',
      err,
      err.stackTrace,
    );
    if (err.response?.data != null) {
      _logger.e('Error Data: ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}
