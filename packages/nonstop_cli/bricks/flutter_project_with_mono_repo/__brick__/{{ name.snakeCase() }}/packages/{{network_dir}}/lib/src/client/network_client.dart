import 'package:network/src/models/network_response.dart';

abstract class NetworkClient {
  Future<NetworkResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(Object? json) fromJsonT,
  });

  Future<NetworkResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(Object? json) fromJsonT,
  });

  Future<NetworkResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(Object? json) fromJsonT,
  });

  Future<NetworkResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(Object? json) fromJsonT,
  });

  Future<NetworkResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(Object? json) fromJsonT,
  });

  T handleResponse<T>(final NetworkResponse<T> response);

  SuccessResponse<T> handleSuccessResponse<T>(
    final NetworkResponse<T> response,
  );

  void dispose();
}
