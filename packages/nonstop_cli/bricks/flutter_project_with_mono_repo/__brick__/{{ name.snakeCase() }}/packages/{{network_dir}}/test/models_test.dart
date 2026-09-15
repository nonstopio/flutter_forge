import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';

class _BaseError extends NetworkException {}

class _OtherError extends Error {}

class _Urls extends ApiUrlConfig {
  _Urls() : super(pathPrefix: '/v1');
}

class _Api extends NetworkApi<_Urls> {
  _Api() : super(urlConfig: _Urls());
  @override
  Map<String, String> get headers => {};
}

void main() {
  test('network failures provide readable localized messages and statuses', () {
    final errors = <NetworkException>[
      _BaseError(),
      const BadRequestException(),
      const UnauthorizedException(),
      const ForbiddenException(),
      const NotFoundException(),
      const ConflictException(),
      const UnprocessableEntityException(),
      const InternalServerException(),
      const ConnectionTimeoutException(),
      const ReceiveTimeoutException(),
      const SendTimeoutException(),
      const NoInternetConnectionException(),
      const UnknownNetworkException(),
    ];
    for (final error in errors) {
      expect(error.displayMessage, isNotEmpty);
      expect(error.toString(), contains(error.displayMessage));
      expect((error as Object).message(), error.displayMessage);
    }
    expect(
      const UnauthorizedException(message: 'Custom').displayMessage,
      'Custom',
    );
    expect(const UnauthorizedException().statusCode, 401);
    final api = _Api();
    expect(api.urlConfig.pathPrefix, '/v1');
    expect(api.headers, isEmpty);
  });

  test('application errors map to readable messages with diagnostic codes', () {
    TypeError? typeError;
    try {
      final dynamic value = 'not a number';
      value as int;
    } on TypeError catch (error) {
      typeError = error;
    }
    final errors = <Object?>[
      CoreException(message: 'Core error'),
      const FormatException('invalid'),
      typeError,
      IndexError.withLength(2, 1),
      RangeError('range'),
      ArgumentError('arg'),
      StateError('state'),
      UnimplementedError(),
      UnsupportedError('unsupported'),
      ConcurrentModificationError(),
      const OutOfMemoryError(),
      const StackOverflowError(),
      _OtherError(),
      null,
    ];
    for (final error in errors) {
      expect(error.message(), isNotEmpty);
    }
    expect(
      (CoreException(message: 'Core error') as Object).message(),
      'Core error',
    );
    expect(
      (StateError('state') as Error).message(),
      contains(ErrorCodes.stateError),
    );
  });

  test('success, error and pagination metadata round-trip JSON', () {
    const pagination = Pagination(
      page: 1,
      limit: 10,
      total: 20,
      totalPages: 2,
      hasNextPage: true,
      hasPreviousPage: false,
    );
    const success = SuccessResponse<int>(
      statusCode: 200,
      success: true,
      data: 3,
      timestamp: '2026',
      pagination: pagination,
      headers: {
        'x': ['y'],
      },
    );
    final json = success.toJson((value) => value);
    // toJson intentionally retains nested objects until JSON encoding.
    json['pagination'] = pagination.toJson();
    final decoded = SuccessResponse<int>.fromJson(
      json,
      (value) => value as int,
    );
    expect(decoded.data, 3);
    expect(decoded.pagination!.hasNextPage, isTrue);
    expect(decoded.isSuccess, isTrue);
    const details = ErrorDetails(
      code: 'INVALID',
      message: 'Invalid',
      details: {'field': 'email'},
    );
    const error = ErrorResponse<int>(
      statusCode: 400,
      success: false,
      error: details,
      timestamp: '2026',
    );
    final errorJson = error.toJson()..['error'] = details.toJson();
    expect(ErrorResponse<int>.fromJson(errorJson).error.code, 'INVALID');
    expect(ErrorDetails.fromJson(details.toJson()).details, {'field': 'email'});
    expect(error.isSuccess, isFalse);
  });
}
