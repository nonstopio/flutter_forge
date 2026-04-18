import 'dart:async';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:connectivity_wrapper/src/providers/connectivity_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _connectivityChannel = MethodChannel(
  'dev.fluttercommunity.plus/connectivity',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_connectivityChannel, (call) async {
      if (call.method == 'check') return <String>['none'];
      return null;
    });
    ConnectivityWrapper.instance.checkInterval =
        const Duration(milliseconds: 50);
    ConnectivityWrapper.instance.addresses = [];
  });

  tearDown(() {
    ConnectivityWrapper.instance.checkInterval = const Duration(seconds: 2);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_connectivityChannel, null);
  });

  // Both tests are combined so we make a single provider, exercise initial
  // emission + forwarded emission, and tear down after both are observed.
  // Closing the controller early conflicts with the provider's leaked
  // subscription to the singleton wrapper.
  test('emits initial CONNECTED then forwards wrapper status', () async {
    final provider = ConnectivityProvider();

    final statuses = <ConnectivityStatus>[];
    final sub = provider.connectivityStream.listen(statuses.add);

    final completer = Completer<void>();
    final poller = Timer.periodic(const Duration(milliseconds: 20), (t) {
      if (statuses.contains(ConnectivityStatus.CONNECTED) &&
          statuses.contains(ConnectivityStatus.DISCONNECTED)) {
        t.cancel();
        if (!completer.isCompleted) completer.complete();
      }
    });

    try {
      await completer.future.timeout(const Duration(seconds: 3));
      expect(statuses.first, ConnectivityStatus.CONNECTED);
      expect(statuses, contains(ConnectivityStatus.DISCONNECTED));
    } finally {
      poller.cancel();
      await sub.cancel();
      // Intentionally do not close provider.connectivityController here —
      // the provider's internal subscription to the singleton wrapper is not
      // exposed and may still push events; the controller will be GC'd once
      // the test ends.
    }
  });
}
