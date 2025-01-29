import 'dart:async';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';

/// [ConnectivityProvider] event ChangeNotifier class for ConnectivityStatus
/// which extends [ChangeNotifier].
///
class ConnectivityProvider extends ChangeNotifier {
  StreamController<ConnectivityStatus> connectivityController =
      StreamController<ConnectivityStatus>();

  /// Stream of [ConnectivityStatus] events.
  /// 
  Stream<ConnectivityStatus> get connectivityStream =>
      connectivityController.stream;

  /// [ConnectivityProvider] Constructor
  ///
  /// Initializes the connectivity status to CONNECTED and updates the 
  /// connectivity status.
  ConnectivityProvider() {
    connectivityController.add(ConnectivityStatus.CONNECTED);
    _updateConnectivityStatus();
  }


  _updateConnectivityStatus() async {
    ConnectivityWrapper.instance.onStatusChange
        .listen((ConnectivityStatus connectivityStatus) {
      connectivityController.add(connectivityStatus);
    });
  }
}
