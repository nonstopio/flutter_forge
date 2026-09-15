import 'package:core/logger/logger.dart';
import 'package:di/di.dart';
import 'package:feature_flags/src/feature_flag_provider.dart';
import 'package:feature_flags/src/feature_flag_service.dart';
import 'package:feature_flags/src/firebase_remote_config_provider.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Register feature flags services with dependency injection
///
Future<void> registerFeatureFlagsWithDI({
  FeatureFlagsConfig? config,
  FeatureFlagProvider? provider,
}) async {
  final logger = di.get<Logger>();

  // Register the provider
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

  // Register the service
  final service = FeatureFlag(provider: selectedProvider, logger: logger);
  di.register<FeatureFlag>(service, dispose: (s) => s.dispose());
}
