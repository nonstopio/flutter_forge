import 'package:core/logger/logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

class TalkerLoggerImpl implements Logger {
  final Talker _talker;

  TalkerLoggerImpl(this._talker);

  @override
  void d(String message) {
    _talker.debug(message);
  }

  @override
  void i(String message) {
    _talker.info(message);
  }

  @override
  void w(String message) {
    _talker.warning(message);
  }

  @override
  void e(String message, [Object? error, StackTrace? stackTrace]) {
    _talker.error(message, error, stackTrace);
  }

  @override
  Object get logger => _talker;
}
