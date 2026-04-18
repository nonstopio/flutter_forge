import 'dart:io';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddressCheckOptions', () {
    test('constructs with an InternetAddress', () {
      final address = InternetAddress('1.1.1.1');
      final options = AddressCheckOptions(address: address);
      expect(options.address, address);
      expect(options.hostname, isNull);
      expect(options.port, 53);
      expect(options.timeout, const Duration(seconds: 5));
    });

    test('constructs with a hostname and custom port/timeout', () {
      final options = AddressCheckOptions(
        hostname: 'example.com',
        port: 80,
        timeout: const Duration(seconds: 1),
      );
      expect(options.hostname, 'example.com');
      expect(options.address, isNull);
      expect(options.port, 80);
      expect(options.timeout, const Duration(seconds: 1));
    });

    test('asserts that neither address nor hostname is null', () {
      expect(
        () => AddressCheckOptions(),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts that both address and hostname are not provided', () {
      expect(
        () => AddressCheckOptions(
          address: InternetAddress('1.1.1.1'),
          hostname: 'example.com',
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('toString contains the address and port', () {
      final options =
          AddressCheckOptions(address: InternetAddress('1.1.1.1'), port: 123);
      final s = options.toString();
      expect(s, contains('1.1.1.1'));
      expect(s, contains('123'));
    });
  });

  group('AddressCheckResult', () {
    test('constructs with options and isSuccess flag', () {
      final options = AddressCheckOptions(address: InternetAddress('1.1.1.1'));
      final result = AddressCheckResult(options, isSuccess: true);
      expect(result.options, options);
      expect(result.isSuccess, isTrue);
    });

    test('toString contains the options and success flag', () {
      final options = AddressCheckOptions(address: InternetAddress('1.1.1.1'));
      final result = AddressCheckResult(options, isSuccess: false);
      final s = result.toString();
      expect(s, contains('1.1.1.1'));
      expect(s, contains('false'));
    });
  });
}
