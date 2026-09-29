import 'package:core/bloc/global_event.dart';
import 'package:core/bloc/global_event_channel_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension GlobalEventChannelExtension on BuildContext {
  /// Fires a global event with the given [eventType].
  void fire(GlobalEventType eventType) {
    final bloc = read<GlobalEventChannel>();
    bloc.add(FireGlobalEvent(eventType: eventType));
  }
}
