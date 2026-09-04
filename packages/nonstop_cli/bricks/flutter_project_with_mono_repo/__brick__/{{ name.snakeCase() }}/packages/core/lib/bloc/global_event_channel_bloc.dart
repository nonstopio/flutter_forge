import 'package:bloc/bloc.dart';
import 'package:core/bloc/global_event.dart';
import 'package:core/bloc/global_event_channel_state.dart';
import 'package:core/logger/logger.dart';
import 'package:di/di.dart';

class GlobalEventChannel extends Bloc<FireGlobalEvent, GlobalEventState> {
  final Logger _logger = di.get<Logger>();

  GlobalEventChannel({required int maxRecentEvents})
    : super(GlobalEventState(maxRecentEvents: maxRecentEvents)) {
    on<FireGlobalEvent>(_onFireGlobalEvent);
  }

  void _onFireGlobalEvent(
    FireGlobalEvent event,
    Emitter<GlobalEventState> emit,
  ) {
    _logger.i('GlobalEventChannel: Processing ${event.eventType.runtimeType}');

    final eventType = event.eventType;
    final newHistory = List<GlobalEventType>.from(state.history);
    newHistory.insert(0, eventType);

    if (newHistory.length > state.maxRecentEvents) {
      newHistory.removeLast();
    }

    final newEventCounts = Map<Type, int>.from(state.eventCounts);
    final eventTypeKey = eventType.runtimeType;
    newEventCounts[eventTypeKey] = (newEventCounts[eventTypeKey] ?? 0) + 1;

    emit(
      state.copyWith(
        history: newHistory,
        eventCounts: newEventCounts,
        current: eventType,
      ),
    );
  }
}
