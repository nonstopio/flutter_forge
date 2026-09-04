import 'package:core/bloc/global_event_channel_bloc.dart';
import 'package:core/bloc/global_event_channel_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GlobalEventChannelProvider extends StatelessWidget {
  final Widget child;
  final int maxRecentEvents;
  final bool lazy;

  const GlobalEventChannelProvider({
    super.key,
    required this.child,
    this.maxRecentEvents = 50,
    this.lazy = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GlobalEventChannel>(
      lazy: lazy,
      create: (context) => GlobalEventChannel(maxRecentEvents: maxRecentEvents),
      child: child,
    );
  }
}

class GlobalEventChannelBuilder extends StatelessWidget {
  final BlocWidgetBuilder<GlobalEventState> builder;
  final BlocBuilderCondition<GlobalEventState>? buildWhen;

  const GlobalEventChannelBuilder({
    super.key,
    required this.builder,
    this.buildWhen,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalEventChannel, GlobalEventState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }
}

class GlobalEventChannelListener extends StatelessWidget {
  final Widget child;
  final BlocWidgetListener<GlobalEventState> listener;
  final BlocListenerCondition<GlobalEventState>? listenWhen;

  const GlobalEventChannelListener({
    super.key,
    required this.child,
    required this.listener,
    this.listenWhen,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<GlobalEventChannel, GlobalEventState>(
      listenWhen: listenWhen,
      listener: listener,
      child: child,
    );
  }
}

class GlobalEventChannelConsumer extends StatelessWidget {
  final BlocWidgetBuilder<GlobalEventState> builder;
  final BlocWidgetListener<GlobalEventState> listener;
  final BlocBuilderCondition<GlobalEventState>? buildWhen;
  final BlocListenerCondition<GlobalEventState>? listenWhen;

  const GlobalEventChannelConsumer({
    super.key,
    required this.builder,
    required this.listener,
    this.buildWhen,
    this.listenWhen,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GlobalEventChannel, GlobalEventState>(
      buildWhen: buildWhen,
      listenWhen: listenWhen,
      builder: builder,
      listener: listener,
    );
  }
}
