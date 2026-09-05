library;

import 'package:core/logger/logger.dart';
import 'package:di/di.dart';
import 'package:feature_flags/src/feature_flag_service.dart';
import 'package:feature_flags/src/register.dart';

export 'src/index.dart';

/// Initialize the feature flags module and register with DI
Future<void> init({
  FeatureFlagsConfig config = const FeatureFlagsConfig(
    fetchTimeout: Duration(seconds: 10),
    minimumFetchInterval: Duration(minutes: 30),
    defaultParameters: {},
  ),
}) async {
  final logger = di.get<Logger>();
  try {
    logger.i('init feature flags module with Firebase Remote Config');
    await registerFeatureFlagsWithDI(config: config);
    final service = di.get<FeatureFlag>();
    await service.init();
    logger.i('Feature flags module initialized with Firebase Remote Config');
  } catch (e, stackTrace) {
    logger.e('Failed to initialize feature flags module', e, stackTrace);
    rethrow;
  }
}
