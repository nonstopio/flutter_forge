import 'package:core/logger/logger.dart';
import 'package:di/di.dart';
import 'package:feature_flags/src/feature_flag_provider.dart';
import 'package:feature_flags/src/feature_flag_service.dart';
import 'package:feature_flags/src/firebase_remote_config_provider.dart';

/// Register feature flags services with dependency injection
///
Future<void> registerFeatureFlagsWithDI({FeatureFlagsConfig? config}) async {
  final logger = di.get<Logger>();

  // Register the provider
  final provider = FirebaseRemoteConfigProvider(config: config);
  di.register<FeatureFlagProvider>(provider, dispose: (p) => p.dispose());

  // Register the service
  final service = FeatureFlag(provider: provider, logger: logger);
  di.register<FeatureFlag>(service, dispose: (s) => s.dispose());
}
