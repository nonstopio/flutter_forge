import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network/network.dart';

class _Dio extends Mock implements Dio {}

class _Logger extends Mock implements Logger {}

class _UnknownResponse extends NetworkResponse<int> {
  const _UnknownResponse()
    : super(statusCode: 202, success: false, timestamp: 'now');
}

void main() {
  setUpAll(() => registerFallbackValue(Options()));
  test(
    'unexpected transport failures are normalized at the client boundary',
    () async {
      final dio = _Dio();
      when(() => dio.interceptors).thenReturn(Interceptors());
      when(
        () => dio.get<Object?>(any(), options: any(named: 'options')),
      ).thenThrow(StateError('transport'));
      final client = DioNetworkClient(
        const DefaultNetworkConfig(baseUrl: 'https://example.test'),
        logger: _Logger(),
        dio: dio,
      );
      addTearDown(client.dispose);
      await expectLater(
        client.get<Object?>('/request', fromJsonT: (json) => json),
        throwsA(isA<UnknownNetworkException>()),
      );
    },
  );

  test(
    'response handlers preserve nullable successes and reject unsupported or failed envelopes',
    () {
      final client = DioNetworkClient(
        const DefaultNetworkConfig(baseUrl: 'https://example.test'),
        logger: _Logger(),
      );
      addTearDown(client.dispose);
      const success = SuccessResponse<String?>(
        statusCode: 204,
        success: true,
        data: null,
        timestamp: 'now',
      );
      expect(client.handleResponse(success), isNull);
      expect(client.handleSuccessResponse(success), same(success));
      const error = ErrorResponse<int>(
        statusCode: 200,
        success: false,
        timestamp: 'now',
        error: ErrorDetails(code: 'INVALID', message: 'Rejected'),
      );
      expect(
        () => client.handleSuccessResponse(error),
        throwsA(isA<UnknownNetworkException>()),
      );
      expect(
        () => client.handleResponse(error),
        throwsA(isA<UnknownNetworkException>()),
      );
      expect(
        () => client.handleResponse(const _UnknownResponse()),
        throwsA(isA<UnknownNetworkException>()),
      );
      expect(
        () => client.handleSuccessResponse(const _UnknownResponse()),
        throwsA(isA<UnknownNetworkException>()),
      );
    },
  );
}
