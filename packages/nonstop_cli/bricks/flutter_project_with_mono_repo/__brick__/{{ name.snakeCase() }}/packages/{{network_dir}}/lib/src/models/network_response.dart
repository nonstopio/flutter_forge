import 'package:json_annotation/json_annotation.dart';

part 'network_response.g.dart';

abstract class NetworkResponse<T> {
  const NetworkResponse({
    required this.statusCode,
    required this.success,
    this.message,
    required this.timestamp,
    this.headers,
  });

  final int statusCode;
  final bool success;
  final String? message;
  final String timestamp;
  final Map<String, List<String>>? headers;

  bool get isSuccess => success && statusCode >= 200 && statusCode < 300;
}

@JsonSerializable(genericArgumentFactories: true)
class SuccessResponse<T> extends NetworkResponse<T> {
  final T data;
  final Pagination? pagination;

  const SuccessResponse({
    required super.statusCode,
    required super.success,
    required this.data,
    super.message,
    required super.timestamp,
    this.pagination,
    super.headers,
  });

  factory SuccessResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$SuccessResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$SuccessResponseToJson(this, toJsonT);
}

@JsonSerializable()
class ErrorResponse<T> extends NetworkResponse<T> {
  final ErrorDetails error;

  const ErrorResponse({
    required super.statusCode,
    required super.success,
    required this.error,
    required super.timestamp,
    super.message,
    super.headers,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}

@JsonSerializable()
class ErrorDetails {
  const ErrorDetails({required this.code, required this.message, this.details});

  final String code;
  final String message;
  final Map<String, dynamic>? details;

  factory ErrorDetails.fromJson(Map<String, dynamic> json) =>
      _$ErrorDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorDetailsToJson(this);
}

@JsonSerializable()
class Pagination {
  const Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}
