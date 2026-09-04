import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:talker_bloc_logger/talker_bloc_logger_observer.dart';
import 'package:talker_bloc_logger/talker_bloc_logger_settings.dart';
import 'package:talker_flutter/talker_flutter.dart';

class CoreBlocObserver extends BlocObserver {
  final TalkerBlocObserver _observer;

  CoreBlocObserver()
    : _observer = TalkerBlocObserver(
        talker: di.get<Logger>().logger as Talker,
        settings: TalkerBlocLoggerSettings(printEventFullData: true),
      );

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    _observer.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    _observer.onTransition(bloc, transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _observer.onError(bloc, error, stackTrace);
  }
}
