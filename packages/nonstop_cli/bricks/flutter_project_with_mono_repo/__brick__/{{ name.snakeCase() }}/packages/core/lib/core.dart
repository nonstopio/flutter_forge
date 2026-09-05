library;

import 'package:core/logger/logger.dart';
import 'package:di/di.dart';

export 'bloc/index.dart';
export 'constants/index.dart';
export 'converters/index.dart';
export 'errors/index.dart';
export 'extensions/index.dart';
export 'logger/logger.dart';
export 'observer/index.dart';
export 'router/core_router.dart';

Future<void> init() async {
  registerLoggerWithDI();
  final logger = di.get<Logger>();
  logger.i('Core module initialized');
}
