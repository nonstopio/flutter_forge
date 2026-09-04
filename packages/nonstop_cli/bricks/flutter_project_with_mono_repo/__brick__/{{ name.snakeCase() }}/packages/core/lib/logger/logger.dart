import 'package:core/logger/talker_logger_impl.dart';
import 'package:di/di.dart';
import 'package:talker_flutter/talker_flutter.dart';

void registerLoggerWithDI() {
  final talker = TalkerFlutter.init();
  final logger = TalkerLoggerImpl(talker);

  di.register<Logger>(logger);
}

abstract class Logger {
  Object get logger;

  void d(String message);

  void i(String message);

  void w(String message);

  void e(String message, [Object? error, StackTrace? stackTrace]);
}
