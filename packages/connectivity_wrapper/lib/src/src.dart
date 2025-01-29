import 'dart:async';

import 'models/models.dart';
import 'network/network.dart';
import 'utils/utils.dart';

export 'models/models.dart';
export 'providers/providers.dart';
export 'utils/utils.dart';
export 'widgets/widgets.dart';

class ConnectivityWrapper {
  static final ConnectivityWrapper instance = ConnectivityWrapper._();

  late List<InternetAddressOption> addresses;
  final _controller = StreamController<ConnectivityStatus>.broadcast();
  Timer? _timerHandle;
  ConnectivityStatus? _lastResponse;
  late Duration interval;

  ConnectivityWrapper._() {
    addresses = Network.defaultPingTargets;
    interval = DEFAULT_INTERVAL;
    _controller.onListen = _maybeEmitStatusUpdate;
    _controller.onCancel = () {
      _timerHandle?.cancel();
      _lastResponse = null;
    };
  }

  Stream<ConnectivityStatus> get onChange => _controller.stream;

  Future<ConnectionStatus> get connectionStatus async {
    await _checkConnectivityAndSpeed();
    return _lastResponse?.status ?? ConnectionStatus.DISCONNECTED;
  }

  Future<bool> get isConnected async {
    await _checkConnectivityAndSpeed();
    return await connectionStatus == ConnectionStatus.CONNECTED;
  }

  Future<InternetSpeed> get currentInternetSpeed async {
    await _checkConnectivityAndSpeed();
    return _lastResponse?.speed ?? InternetSpeed.BAD;
  }

  void configure({
    required List<InternetAddressOption> addresses,
    Duration? interval,
  }) {
    this.addresses = addresses;
    if (interval != null) {
      this.interval = interval;
    }
  }

  void _maybeEmitStatusUpdate([Timer? timer]) async {
    _timerHandle?.cancel();
    timer?.cancel();

    await _checkConnectivityAndSpeed();

    if (!_controller.hasListener) return;
    _timerHandle = Timer(interval, _maybeEmitStatusUpdate);
  }

  Future<void> _checkConnectivityAndSpeed() async {
    final results = await Future.wait(
        addresses.map((address) => Network.checkHostReachability(address)));

    final successfulResults =
        results.where((result) => result.isSuccess).toList();

    if (successfulResults.isEmpty) {
      _lastResponse = ConnectivityStatus(
        status: ConnectionStatus.DISCONNECTED,
        speed: InternetSpeed.BAD,
      );
    } else {
      _lastResponse = ConnectivityStatus(
        status: ConnectionStatus.CONNECTED,
        speed: successfulResults.determineInternetSpeed(),
      );
    }

    if (_controller.hasListener) {
      _controller.add(_lastResponse!);
    }
  }
}
