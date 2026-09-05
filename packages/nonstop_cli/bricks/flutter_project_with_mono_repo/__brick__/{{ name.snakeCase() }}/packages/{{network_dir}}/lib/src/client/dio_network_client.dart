import 'dart:io';

import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:localization/localization.dart';
import 'package:network/src/client/network_client.dart';
import 'package:network/src/config/network_config.dart';
import 'package:network/src/exceptions/network_exceptions.dart';
import 'package:network/src/interceptors/auth_interceptor.dart';
import 'package:network/src/models/network_response.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

class DioNetworkClient implements NetworkClient {
  DioNetworkClient(this._config) : _dio = Dio() {
    _setupDio();
  }

  final NetworkConfig _config;
  final Dio _dio;
  final Logger _logger = di.get<Logger>();

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: _config.baseUrl,
      connectTimeout: _config.connectTimeout,
      receiveTimeout: _config.receiveTimeout,
      //sendTimeout cannot be used without a request body to send on Web
      sendTimeout: kIsWeb ? null : _config.sendTimeout,
      headers: _config.defaultHeaders,
    );

    // Add authentication interceptor if token provider is available
    if (_config.authTokenProvider != null) {
      _dio.interceptors.add(AuthInterceptor(_config.authTokenProvider!));
      _logger.d('🔐 Auth interceptor added to network client');
    }

    if (_config.enableLogging) {
      _dio.interceptors.add(
        TalkerDioLogger(
          talker: di.get<Logger>().logger as Talker,
          settings: TalkerDioLoggerSettings(
            printResponseData: true,
            printResponseTime: true,
          ),
        ),
      );
    }
  }

  @override
  Future<NetworkResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(Object? json) fromJsonT,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return _handleResponse<T>(response, fromJsonT: fromJsonT);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  @override
  Future<NetworkResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(Object? json) fromJsonT,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return _handleResponse<T>(response, fromJsonT: fromJsonT);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  @override
  Future<NetworkResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(Object? json) fromJsonT,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return _handleResponse<T>(response, fromJsonT: fromJsonT);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  @override
  Future<NetworkResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(Object? json) fromJsonT,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return _handleResponse<T>(response, fromJsonT: fromJsonT);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  @override
  Future<NetworkResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(Object? json) fromJsonT,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return _handleResponse<T>(response, fromJsonT: fromJsonT);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  NetworkResponse<T> _handleResponse<T>(
    Response response, {
    required T Function(Object? json) fromJsonT,
  }) {
    try {
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('success')) {
          if (responseData['success'] == true) {
            return SuccessResponse.fromJson({
              'statusCode': response.statusCode ?? 200,
              'headers': response.headers.map,
              ...responseData,
            }, fromJsonT);
          } else {
            ErrorResponse.fromJson({
              'statusCode': response.statusCode ?? 500,
              'headers': response.headers.map,
              ...responseData,
            });
          }
        }
      }

      // Ideally, should not reach here if the API follows the
      // standard response format
      _logger.w('Invalid response format: ${response.data}');

      // Fallback to a generic success response
      return SuccessResponse.fromJson({
        'statusCode': response.statusCode ?? 200,
        'headers': response.headers.map,
        'data': response.data,
      }, (value) => value as T);
    } catch (e, s) {
      _logger.e('Error parsing response', e);
      return ErrorResponse(
        statusCode: response.statusCode ?? 500,
        success: false,
        message: 'Network Client failed to parse response!',
        error: ErrorDetails(
          code: 'PARSE_ERROR',
          message: e.toString(),
          details: {'stackTrace': s.toString()},
        ),
        timestamp: DateTime.now().toIso8601String(),
      );
    }
  }

  NetworkResponse<T> _handleError<T>(dynamic error) {
    NetworkException networkException;
    ErrorResponse? apiError;

    if (error is DioException) {
      apiError = _parseApiError(error.response);
      networkException = _mapDioException(error, apiError);
    } else {
      networkException = UnknownNetworkException(message: error.toString());
    }

    _logger.e('Network error occurred', networkException);

    throw networkException;
  }

  ErrorResponse? _parseApiError(Response? response) {
    try {
      final responseData = response?.data;
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('success') &&
          responseData['success'] == false) {
        return ErrorResponse.fromJson({
          'statusCode': response?.statusCode ?? 500,
          'headers': response?.headers.map,
          ...responseData,
        });
      }
    } catch (e) {
      _logger.w('Failed to parse API error: $e');
    }
    return null;
  }

  NetworkException _mapDioException(
    DioException dioException,
    ErrorResponse? apiError,
  ) {
    final message = apiError?.error.message;

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return ConnectionTimeoutException(message: message);
      case DioExceptionType.receiveTimeout:
        return ReceiveTimeoutException(message: message);
      case DioExceptionType.sendTimeout:
        return SendTimeoutException(message: message);
      case DioExceptionType.connectionError:
        if (dioException.error is SocketException) {
          return NoInternetConnectionException(message: message);
        }
        return UnknownNetworkException(message: message);
      case DioExceptionType.badResponse:
        final statusCode = dioException.response?.statusCode;
        switch (statusCode) {
          case 400:
            return BadRequestException(message: message, error: apiError);
          case 401:
            return UnauthorizedException(message: message, error: apiError);
          case 403:
            return ForbiddenException(message: message, error: apiError);
          case 404:
            return NotFoundException(message: message, error: apiError);
          case 409:
            return ConflictException(message: message, error: apiError);
          case 422:
            return UnprocessableEntityException(
              message: message,
              error: apiError,
            );
          case 500:
          case 502:
          case 503:
          case 504:
            return InternalServerException(message: message, error: apiError);
          default:
            return UnknownNetworkException(
              message: message,
              statusCode: statusCode,
              error: apiError,
            );
        }
      default:
        return UnknownNetworkException(message: message, error: apiError);
    }
  }

  @override
  T handleResponse<T>(final NetworkResponse<T> response) {
    switch (response) {
      case SuccessResponse<T>():
        return response.data!;
      case ErrorResponse<T>():
        throw UnknownNetworkException(
          message: response.message ?? strings.errors.network_error,
          statusCode: response.statusCode,
          error: response,
        );
      default:
        throw UnknownNetworkException(
          message: strings.errors.unknown_error,
          statusCode: response.statusCode,
        );
    }
  }

  @override
  SuccessResponse<T> handleSuccessResponse<T>(
    final NetworkResponse<T> response,
  ) {
    switch (response) {
      case SuccessResponse<T>():
        return response;
      case ErrorResponse<T>():
        throw UnknownNetworkException(
          message: response.message ?? strings.errors.network_error,
          statusCode: response.statusCode,
          error: response,
        );
      default:
        throw UnknownNetworkException(
          message: strings.errors.unknown_error,
          statusCode: response.statusCode,
        );
    }
  }

  @override
  void dispose() {
    _dio.close();
  }
}
