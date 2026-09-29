import 'package:core/bloc/global_event.dart';
import 'package:equatable/equatable.dart';

class GlobalEventState extends Equatable {
  final List<GlobalEventType> history;
  final Map<Type, int> eventCounts;
  final GlobalEventType? current;
  final int maxRecentEvents;

  const GlobalEventState({
    this.history = const [],
    this.eventCounts = const {},
    this.current,
    this.maxRecentEvents = 50,
  });

  GlobalEventState copyWith({
    List<GlobalEventType>? history,
    Map<Type, int>? eventCounts,
    GlobalEventType? current,
    int? maxRecentEvents,
  }) {
    return GlobalEventState(
      history: history ?? this.history,
      eventCounts: eventCounts ?? this.eventCounts,
      current: current ?? this.current,
      maxRecentEvents: maxRecentEvents ?? this.maxRecentEvents,
    );
  }

  @override
  List<Object?> get props => [history, eventCounts, current, maxRecentEvents];
}
