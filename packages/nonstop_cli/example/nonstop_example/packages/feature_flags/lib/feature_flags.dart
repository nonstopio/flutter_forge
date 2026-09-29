library;

import 'package:core/logger/logger.dart';
import 'package:di/di.dart';
import 'package:feature_flags/src/client/index.dart';
import 'package:feature_flags/src/config/index.dart';
import 'package:feature_flags/src/di/index.dart';
import 'package:feature_flags/src/providers/index.dart';

export 'src/client/index.dart';
export 'src/config/index.dart';
export 'src/di/index.dart';
export 'src/providers/index.dart';
export 'src/widgets/index.dart';

/// Initialize the feature flags module and register with DI
Future<void> init({
  FeatureFlagProvider? provider,
  FeatureFlagsConfig config = const FeatureFlagsConfig(),
}) async {
  final logger = di.get<Logger>();
  try {
    await registerFeatureFlagsWithDI(config: config, provider: provider);
    await di.get<FeatureFlag>().init();
    logger.i('Feature flags module initialized');
  } catch (e, stackTrace) {
    logger.e('Failed to initialize feature flags module', e, stackTrace);
    rethrow;
  }
}
