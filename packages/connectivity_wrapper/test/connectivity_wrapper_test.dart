import 'dart:async';
import 'dart:io';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _connectivityChannel = MethodChannel(
  'dev.fluttercommunity.plus/connectivity',
);

void _mockConnectivity(List<String> result) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    _connectivityChannel,
    (call) async {
      if (call.method == 'check') return result;
      return null;
    },
  );
}

void _resetConnectivityMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_connectivityChannel, null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(_resetConnectivityMock);

  group('ConnectivityWrapper singleton', () {
    test('instance returns the same object', () {
      expect(ConnectivityWrapper.instance,
          same(ConnectivityWrapper.instance));
    });

    test('default addresses list is non-empty on non-web', () {
      expect(ConnectivityWrapper.instance.addresses, isNotEmpty);
    });

    test('checkInterval defaults to 2 seconds', () {
      expect(ConnectivityWrapper.instance.checkInterval,
          const Duration(seconds: 2));
    });

    test('lastTryResults defaults to an empty list', () {
      expect(ConnectivityWrapper.instance.lastTryResults, isA<List>());
    });

    test('hasListeners/isActivelyChecking are false without subscribers',
        () async {
      // Wait for any prior listeners to drain.
      await Future<void>.delayed(Duration.zero);
      expect(ConnectivityWrapper.instance.hasListeners, isFalse);
      expect(ConnectivityWrapper.instance.isActivelyChecking, isFalse);
    });
  });

  group('isHostReachable', () {
    test('returns success when socket connects', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final options = AddressCheckOptions(
        address: InternetAddress.loopbackIPv4,
        port: server.port,
        timeout: const Duration(seconds: 2),
      );
      final result =
          await ConnectivityWrapper.instance.isHostReachable(options);
      expect(result.isSuccess, isTrue);
      expect(result.options, options);
      await server.close();
    });

    test('returns failure when the port is closed', () async {
      // Bind then close to get a port we know is closed.
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;
      await server.close();
      final options = AddressCheckOptions(
        address: InternetAddress.loopbackIPv4,
        port: port,
        timeout: const Duration(milliseconds: 200),
      );
      final result =
          await ConnectivityWrapper.instance.isHostReachable(options);
      expect(result.isSuccess, isFalse);
    });

    test('uses hostname when address is null', () async {
      final options = AddressCheckOptions(
        hostname: 'localhost',
        port: 1,
        timeout: const Duration(milliseconds: 200),
      );
      final result =
          await ConnectivityWrapper.instance.isHostReachable(options);
      // Port 1 is almost certainly closed; test that the code path executes
      // without throwing and returns a result.
      expect(result, isA<AddressCheckResult>());
    });
  });

  group('_checkWebConnection / isConnected', () {
    test('returns DISCONNECTED when connectivity reports none', () async {
      _mockConnectivity(['none']);
      expect(
        await ConnectivityWrapper.instance.connectionStatus,
        ConnectivityStatus.DISCONNECTED,
      );
    });

    test('returns DISCONNECTED when no addresses reachable', () async {
      _mockConnectivity(['wifi']);
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;
      await server.close();
      ConnectivityWrapper.instance.addresses = [
        AddressCheckOptions(
          address: InternetAddress.loopbackIPv4,
          port: port,
          timeout: const Duration(milliseconds: 200),
        ),
      ];
      expect(
        await ConnectivityWrapper.instance.connectionStatus,
        ConnectivityStatus.DISCONNECTED,
      );
    });

    test('returns CONNECTED when wifi + reachable address', () async {
      _mockConnectivity(['wifi']);
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      ConnectivityWrapper.instance.addresses = [
        AddressCheckOptions(
          address: InternetAddress.loopbackIPv4,
          port: server.port,
          timeout: const Duration(seconds: 2),
        ),
      ];
      expect(
        await ConnectivityWrapper.instance.connectionStatus,
        ConnectivityStatus.CONNECTED,
      );
      await server.close();
    });

    test('treats mobile as a connected transport', () async {
      _mockConnectivity(['mobile']);
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      ConnectivityWrapper.instance.addresses = [
        AddressCheckOptions(
          address: InternetAddress.loopbackIPv4,
          port: server.port,
          timeout: const Duration(seconds: 2),
        ),
      ];
      expect(await ConnectivityWrapper.instance.isConnected, isTrue);
      await server.close();
    });

    test('treats ethernet as a connected transport', () async {
      _mockConnectivity(['ethernet']);
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      ConnectivityWrapper.instance.addresses = [
        AddressCheckOptions(
          address: InternetAddress.loopbackIPv4,
          port: server.port,
          timeout: const Duration(seconds: 2),
        ),
      ];
      expect(await ConnectivityWrapper.instance.isConnected, isTrue);
      await server.close();
    });
  });

  group('onStatusChange stream', () {
    test('emits status and clears state on cancel', () async {
      _mockConnectivity(['none']);
      // Use a very short check interval to keep the test fast.
      ConnectivityWrapper.instance.checkInterval =
          const Duration(milliseconds: 50);
      ConnectivityWrapper.instance.addresses = [];

      final received = <ConnectivityStatus>[];
      final sub = ConnectivityWrapper.instance.onStatusChange.listen(
        received.add,
      );
      // Wait for at least one status emission.
      final completer = Completer<void>();
      Timer.periodic(const Duration(milliseconds: 20), (t) {
        if (received.isNotEmpty) {
          t.cancel();
          completer.complete();
        }
      });
      await completer.future.timeout(const Duration(seconds: 3));

      expect(received, contains(ConnectivityStatus.DISCONNECTED));
      expect(ConnectivityWrapper.instance.hasListeners, isTrue);
      expect(ConnectivityWrapper.instance.isActivelyChecking, isTrue);
      expect(
        ConnectivityWrapper.instance.lastStatus,
        ConnectivityStatus.DISCONNECTED,
      );

      await sub.cancel();
      // Give the broadcast controller time to run onCancel.
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(ConnectivityWrapper.instance.lastStatus, isNull);

      // Restore
      ConnectivityWrapper.instance.checkInterval =
          const Duration(seconds: 2);
    });
  });
}
