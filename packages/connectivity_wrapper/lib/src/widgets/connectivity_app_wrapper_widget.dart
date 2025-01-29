import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///[ConnectivityAppWrapper] is a StatelessWidget.

class ConnectivityAppWrapper extends StatelessWidget {
  /// [app] will accept MaterialApp or CupertinoApp must be non-null
  final Widget app;

  /// [ConnectivityAppWrapper] Constructor
  ///
  /// [app] will accept MaterialApp or CupertinoApp must be non-null
  ///
  const ConnectivityAppWrapper({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<ConnectivityStatus>(
      initialData: ConnectivityStatus.connected(),
      create: (context) => ConnectivityProvider().connectivityStream,
      child: app,
    );
  }
}
