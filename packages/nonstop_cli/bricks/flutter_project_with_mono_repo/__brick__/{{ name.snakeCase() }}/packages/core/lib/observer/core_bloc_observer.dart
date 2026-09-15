import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:di/di.dart';

class CoreBlocObserver extends BlocObserver {
  final Logger _logger;

  CoreBlocObserver({Logger? logger}) : _logger = logger ?? di.get<Logger>();

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    _logger.d('${bloc.runtimeType}: event ${event.runtimeType}');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    _logger.d(
      '${bloc.runtimeType}: ${transition.currentState.runtimeType} -> ${transition.nextState.runtimeType}',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _logger.e('${bloc.runtimeType}: unhandled error', error, stackTrace);
  }
}
