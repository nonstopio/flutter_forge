library;

import 'dart:async';

import 'package:core/core.dart';
import 'package:crashlytics/src/client/index.dart';
import 'package:crashlytics/src/config/index.dart';
import 'package:di/di.dart';

export 'src/client/index.dart';
export 'src/config/index.dart';
export 'src/models/index.dart';

/// Initialize the crashlytics module with dependency injection
Future<void> init({CrashlyticsConfig? config}) async {
  await registerCrashlyticsWithDI(config ?? const DefaultCrashlyticsConfig());
  final logger = di.get<Logger>();
  logger.i('🔥 Crashlytics module initialized');
}

/// Register crashlytics components with DI container
Future<void> registerCrashlyticsWithDI(CrashlyticsConfig config) async {
  final logger = di.get<Logger>();

  try {
    // Register config
    di.register<CrashlyticsConfig>(config);

    // Create and register crashlytics client
    final client = FirebaseCrashlyticsClient(config: config, logger: logger);
    di.register<CrashlyticsClient>(
      client,
      dispose: (client) => client.dispose(),
    );

    // Initialize the client
    await client.initialize();

    // Check if there are any unsent reports
    unawaited(
      client.checkForUnsentReports().then<void>((hasReports) {
        if (hasReports) {
          logger.w('⚠️ There are unsent crash reports.');
          unawaited(client.sendUnsentReports());
        } else {
          logger.i('✅ No unsent crash reports found.');
        }
      }),
    );

    logger.i('🔥 Crashlytics registered with DI container');
  } catch (e, stackTrace) {
    logger.e('❌ Failed to register crashlytics with DI', e, stackTrace);
    rethrow;
  }
}
