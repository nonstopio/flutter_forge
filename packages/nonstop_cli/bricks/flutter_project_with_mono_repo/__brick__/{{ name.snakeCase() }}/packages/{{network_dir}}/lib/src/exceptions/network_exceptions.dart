import 'package:localization/localization.dart';
import 'package:network/network.dart';

abstract class NetworkException implements Exception {
  const NetworkException({this.message, this.statusCode, this.error});

  final String? message;
  final int? statusCode;
  final ErrorResponse? error;

  String get displayMessage => message ?? strings.errors.unknown_network;

  @override
  String toString() => '$runtimeType: $displayMessage';
}

class BadRequestException extends NetworkException {
  const BadRequestException({super.message, super.error})
    : super(statusCode: 400);

  @override
  String get displayMessage => message ?? strings.errors.bad_request;
}

class UnauthorizedException extends NetworkException {
  const UnauthorizedException({super.message, super.error})
    : super(statusCode: 401);

  @override
  String get displayMessage => message ?? strings.errors.unauthorized;
}

class ForbiddenException extends NetworkException {
  const ForbiddenException({super.message, super.error})
    : super(statusCode: 403);

  @override
  String get displayMessage => message ?? strings.errors.forbidden;
}

class NotFoundException extends NetworkException {
  const NotFoundException({super.message, super.error})
    : super(statusCode: 404);

  @override
  String get displayMessage => message ?? strings.errors.not_found;
}

class ConflictException extends NetworkException {
  const ConflictException({super.message, super.error})
    : super(statusCode: 409);

  @override
  String get displayMessage => message ?? strings.errors.conflict;
}

class UnprocessableEntityException extends NetworkException {
  const UnprocessableEntityException({super.message, super.error})
    : super(statusCode: 422);

  @override
  String get displayMessage => message ?? strings.errors.unprocessable_entity;
}

class InternalServerException extends NetworkException {
  const InternalServerException({super.message, super.error})
    : super(statusCode: 500);

  @override
  String get displayMessage => message ?? strings.errors.internal_server_error;
}

class ConnectionTimeoutException extends NetworkException {
  const ConnectionTimeoutException({super.message}) : super(statusCode: 599);

  @override
  String get displayMessage => message ?? strings.errors.connection_timeout;
}

class ReceiveTimeoutException extends NetworkException {
  const ReceiveTimeoutException({super.message}) : super(statusCode: null);

  @override
  String get displayMessage => message ?? strings.errors.receive_timeout;
}

class SendTimeoutException extends NetworkException {
  const SendTimeoutException({super.message}) : super(statusCode: null);

  @override
  String get displayMessage => message ?? strings.errors.send_timeout;
}

class NoInternetConnectionException extends NetworkException {
  const NoInternetConnectionException({super.message})
    : super(statusCode: null);

  @override
  String get displayMessage => message ?? strings.errors.no_internet;
}

class UnknownNetworkException extends NetworkException {
  const UnknownNetworkException({super.message, super.statusCode, super.error});

  @override
  String get displayMessage => message ?? strings.errors.unknown_network;
}
