import 'package:core/logger/logger.dart';
import 'package:di/di.dart';
import 'package:feature_flags/src/client/index.dart';
import 'package:feature_flags/src/config/index.dart';
import 'package:feature_flags/src/providers/index.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Register feature flags services with dependency injection
Future<void> registerFeatureFlagsWithDI({
  FeatureFlagsConfig? config,
  FeatureFlagProvider? provider,
}) async {
  final logger = di.get<Logger>();

  final selectedProvider =
      provider ??
      FirebaseRemoteConfigProvider(
        config: config,
        logger: logger,
        remoteConfig: FirebaseRemoteConfig.instance,
      );
  // The service owns provider disposal; registering it twice would dispose
  // platform subscriptions twice when the container is reset.
  di.register<FeatureFlagProvider>(selectedProvider);

  final service = FeatureFlagService(
    provider: selectedProvider,
    logger: logger,
  );
  di.register<FeatureFlag>(service, dispose: (s) => s.dispose());
}
