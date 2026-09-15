library;

import 'package:core/core.dart';
import 'package:crashlytics/src/client/index.dart';
import 'package:crashlytics/src/config/index.dart';
import 'package:di/di.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

export 'src/client/index.dart';
export 'src/config/index.dart';
export 'src/models/index.dart';

/// Initialize the crashlytics module with dependency injection
Future<void> init({
  CrashlyticsConfig? config,
  FirebaseCrashlytics? crashlytics,
}) async {
  await registerCrashlyticsWithDI(
    config ?? const DefaultCrashlyticsConfig(),
    crashlytics: crashlytics,
  );
  final logger = di.get<Logger>();
  logger.i('🔥 Crashlytics module initialized');
}

/// Register crashlytics components with DI container
Future<void> registerCrashlyticsWithDI(
  CrashlyticsConfig config, {
  FirebaseCrashlytics? crashlytics,
}) async {
  final logger = di.get<Logger>();

  final client = FirebaseCrashlyticsClient(
    config: config,
    logger: logger,
    crashlytics: crashlytics ?? FirebaseCrashlytics.instance,
  );
  try {
    // Publish only a fully initialized client; failed startup remains retryable.
    await client.initialize();

    // Check if there are any unsent reports
    if (await client.checkForUnsentReports()) {
      logger.w('⚠️ There are unsent crash reports.');
      await client.sendUnsentReports();
    } else {
      logger.i('✅ No unsent crash reports found.');
    }

    di.register<CrashlyticsConfig>(config);
    di.register<CrashlyticsClient>(
      client,
      dispose: (client) => client.dispose(),
    );
    logger.i('🔥 Crashlytics registered with DI container');
  } catch (e, stackTrace) {
    client.dispose();
    logger.e('❌ Failed to register crashlytics with DI', e, stackTrace);
    rethrow;
  }
}
