import 'package:equatable/equatable.dart';

enum ConnectionStatus { CONNECTED, DISCONNECTED }

enum InternetSpeed { GOOD, SLOW, BAD }

class ConnectivityStatus extends Equatable {
  final ConnectionStatus status;
  final InternetSpeed speed;

  const ConnectivityStatus({
    required this.status,
    required this.speed,
  });

  factory ConnectivityStatus.connected({
    InternetSpeed speed = InternetSpeed.GOOD,
  }) {
    return ConnectivityStatus(status: ConnectionStatus.CONNECTED, speed: speed);
  }

  factory ConnectivityStatus.disconnected() {
    return ConnectivityStatus(
      status: ConnectionStatus.DISCONNECTED,
      speed: InternetSpeed.BAD,
    );
  }

  bool get isConnected => status == ConnectionStatus.CONNECTED;

  bool get isDisconnected => status == ConnectionStatus.DISCONNECTED;

  @override
  List<Object?> get props => [status, speed];
}
