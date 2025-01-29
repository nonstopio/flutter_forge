/// A pure Dart utility library that checks for an internet connection
/// by opening a socket to a list of specified addresses, each with individual
/// port and timeout. Defaults are provided for convenience.
///
/// All addresses are pinged simultaneously.
/// On successful result (socket connection to address/port succeeds)
/// a true boolean is pushed to a list, on failure
/// (usually on timeout, default 10 sec)
/// a false boolean is pushed to the same list.
///
library connectivity_wrapper;

import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_wrapper/src/utils/constants.dart';
import 'package:flutter/foundation.dart';

import 'src/models/address_check_options.dart';
import 'src/models/address_check_result.dart';

export 'package:connectivity_wrapper/src/widgets/connectivity_app_wrapper_widget.dart';
export 'package:connectivity_wrapper/src/widgets/connectivity_screen_wrapper.dart';
export 'package:connectivity_wrapper/src/widgets/connectivity_widget_wrapper.dart';

export 'src/models/address_check_options.dart';
export 'src/models/address_check_result.dart';

/// Connection Status Check Result
///
/// [CONNECTED]: Device connected to network
/// [DISCONNECTED]: Device not connected to any network
///
enum ConnectivityStatus { CONNECTED, DISCONNECTED }

/// [ConnectivityWrapper] is a class that provides a way to check the
/// connectivity status of the device.
///
class ConnectivityWrapper {
  static List<AddressCheckOptions> get _defaultAddresses => (kIsWeb)
      ? []
      : List<AddressCheckOptions>.unmodifiable(
          <AddressCheckOptions>[
            AddressCheckOptions(
              address: InternetAddress(
                '1.1.1.1',
                type: InternetAddressType.IPv4,
              ),
            ),
            AddressCheckOptions(
              address: InternetAddress(
                '2606:4700:4700::1111',
                type: InternetAddressType.IPv6,
              ),
            ),
            AddressCheckOptions(
              address: InternetAddress(
                '8.8.4.4',
                type: InternetAddressType.IPv4,
              ),
            ),
            AddressCheckOptions(
              address: InternetAddress(
                '2001:4860:4860::8888',
                type: InternetAddressType.IPv6,
              ),
            ),
            AddressCheckOptions(
              address: InternetAddress(
                '208.67.222.222',
                type: InternetAddressType.IPv4,
              ),
            ),
            AddressCheckOptions(
              address: InternetAddress(
                '2620:0:ccc::2',
                type: InternetAddressType.IPv6,
              ),
            ),
          ],
        );

  List<AddressCheckOptions> addresses = _defaultAddresses;

  ConnectivityWrapper._() {
    _statusController.onListen = () {
      _maybeEmitStatusUpdate();
    };
    _statusController.onCancel = () {
      _timerHandle?.cancel();
      _lastStatus = null;
    };
  }

  /// [ConnectivityWrapper]'s singleton instance.
  ///
  static final ConnectivityWrapper instance = ConnectivityWrapper._();

  /// [isHostReachable] is a function that checks if a host is reachable.
  ///
  /// [options] is the options to use for the address check.
  ///
  /// Returns an [AddressCheckResult] indicating whether the address check was
  /// successful.
  ///
  Future<AddressCheckResult> isHostReachable(
    AddressCheckOptions options,
  ) async {
    Socket? sock;
    try {
      sock = await Socket.connect(
        options.address ?? options.hostname,
        options.port,
        timeout: options.timeout,
      )
        ..destroy();
      return AddressCheckResult(
        options,
        isSuccess: true,
      );
    } catch (e) {
      sock?.destroy();
      return AddressCheckResult(
        options,
        isSuccess: false,
      );
    }
  }

  /// [lastTryResults] is a list of [AddressCheckResult] objects that stores
  /// the results of the last address check.
  ///
  List<AddressCheckResult> get lastTryResults => _lastTryResults;
  List<AddressCheckResult> _lastTryResults = <AddressCheckResult>[];

  /// [isConnected] is a boolean that indicates whether the device is connected
  /// to the network.
  ///
  Future<bool> get isConnected async {
    bool connected = await _checkWebConnection();
    if (kIsWeb) return connected;
    if (!connected) return connected;

    List<Future<AddressCheckResult>> requests = [];

    for (var addressOptions in addresses) {
      requests.add(isHostReachable(addressOptions));
    }
    _lastTryResults = List.unmodifiable(await Future.wait(requests));

    return _lastTryResults.map((result) => result.isSuccess).contains(true);
  }

  /// [connectionStatus] is a [Future] that returns a [ConnectivityStatus]
  /// indicating whether the device is connected to the network.
  ///
  /// Returns a [ConnectivityStatus] indicating whether the device is connected
  /// to the network.
  ///
  Future<ConnectivityStatus> get connectionStatus async {
    return await isConnected
        ? ConnectivityStatus.CONNECTED
        : ConnectivityStatus.DISCONNECTED;
  }

  /// [_checkWebConnection] is a function that checks if the device is connected
  /// to the network.
  ///
  /// Returns a boolean indicating whether the device is connected to the network.
  ///
  Future<bool> _checkWebConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet)) {
      return true;
    }
    return false;
  }

  /// [checkInterval] is the interval at which the connectivity status is checked.
  ///
  Duration checkInterval = DEFAULT_INTERVAL;

  ConnectivityStatus? _lastStatus;

  Timer? _timerHandle;

  final StreamController<ConnectivityStatus> _statusController =
      StreamController.broadcast();

  /// [onStatusChange] is a [Stream] that emits [ConnectivityStatus] events.
  ///
  Stream<ConnectivityStatus> get onStatusChange => _statusController.stream;

  /// [hasListeners] is a boolean that indicates whether the [onStatusChange]
  /// stream has listeners.
  ///
  bool get hasListeners => _statusController.hasListener;

  /// [isActivelyChecking] is a boolean that indicates whether the connectivity
  /// status is being actively checked.
  ///
  bool get isActivelyChecking => _statusController.hasListener;

  ConnectivityStatus? get lastStatus => _lastStatus;

  _maybeEmitStatusUpdate([Timer? timer]) async {
    _timerHandle?.cancel();
    timer?.cancel();

    var currentStatus = await connectionStatus;

    if (_lastStatus != currentStatus && _statusController.hasListener) {
      _statusController.add(currentStatus);
    }

    if (!_statusController.hasListener) return;
    _timerHandle = Timer(checkInterval, _maybeEmitStatusUpdate);

    _lastStatus = currentStatus;
  }
}
