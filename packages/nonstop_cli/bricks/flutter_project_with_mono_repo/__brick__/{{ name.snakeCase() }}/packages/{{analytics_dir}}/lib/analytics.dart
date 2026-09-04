library;

import 'package:analytics/src/client/index.dart';
import 'package:analytics/src/config/index.dart';
import 'package:core/core.dart';
import 'package:di/di.dart';

export 'src/client/index.dart';
export 'src/config/index.dart';
export 'src/models/index.dart';
export 'src/observer/index.dart';
export 'src/utils/index.dart';

Future<void> init({
  AnalyticsConfig config = const DefaultAnalyticsConfig(),
}) async {
  await registerAnalyticsWithDI(config);
  final logger = di.get<Logger>();
  logger.i('Analytics module initialized with Firebase Analytics');
}

Future<void> registerAnalyticsWithDI(AnalyticsConfig config) async {
  final logger = di.get<Logger>();

  final analyticsClient = FirebaseAnalyticsClient(config);
  di.register<AnalyticsClient>(
    analyticsClient,
    dispose: (client) => client.dispose(),
  );
  di.register<AnalyticsConfig>(config);

  if (config.enableAnalytics) {
    logger.i('🔍 Analytics client registered with collection enabled');
  } else {
    logger.i('🔍 Analytics client registered with collection disabled');
  }
}
