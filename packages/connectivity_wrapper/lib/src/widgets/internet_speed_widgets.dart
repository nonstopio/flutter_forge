import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InternetSpeedIcon extends StatelessWidget {
  const InternetSpeedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final speed = Provider.of<ConnectivityStatus>(context).speed;

    return Icon(
      speed.icon,
      color: speed.color,
    );
  }
}

typedef InternetSpeedWidgetBuilder = Widget Function(
    BuildContext context, InternetSpeed speed);

class InternetSpeedBuilder extends StatelessWidget {
  final InternetSpeedWidgetBuilder builder;

  const InternetSpeedBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final speed = Provider.of<ConnectivityStatus>(context).speed;

    return builder(context, speed);
  }
}
