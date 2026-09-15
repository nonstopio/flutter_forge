library;

import 'package:analytics/src/client/index.dart';
import 'package:analytics/src/config/index.dart';
import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

export 'src/client/index.dart';
export 'src/config/index.dart';
export 'src/models/index.dart';
export 'src/observer/index.dart';
export 'src/utils/index.dart';

Future<void> init({
  AnalyticsConfig config = const DefaultAnalyticsConfig(),
  FirebaseAnalytics? analytics,
}) async {
  await registerAnalyticsWithDI(config, analytics: analytics);
  final logger = di.get<Logger>();
  logger.i('Analytics module initialized with Firebase Analytics');
}

Future<void> registerAnalyticsWithDI(
  AnalyticsConfig config, {
  FirebaseAnalytics? analytics,
}) async {
  final logger = di.get<Logger>();

  final analyticsClient = FirebaseAnalyticsClient(
    config,
    analytics: analytics ?? FirebaseAnalytics.instance,
    logger: logger,
  );
  await analyticsClient.initialize();
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
