import 'package:di/di.dart';
import 'package:feature_flags/src/feature_flag_service.dart';
import 'package:flutter/material.dart';

/// A wrapper widget that conditionally renders content based on feature flags
class FeatureFlagWrapper extends StatelessWidget {
  const FeatureFlagWrapper({
    super.key,
    required this.flagKey,
    required this.builder,
    this.defaultValue = false,
    this.loading,
  });

  /// The feature flag key to check
  final String flagKey;

  /// Builder function that receives the context and feature flag value
  final Widget Function(BuildContext context, bool value) builder;

  /// The default value to use if the feature flag service is unavailable
  final bool defaultValue;

  /// Widget to show while loading the feature flag value
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkFeatureFlag(),
      builder: (context, snapshot) {
        // Show loading widget while waiting for feature flag
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading ?? const SizedBox.shrink();
        }

        // Get the feature flag value, defaulting to false if there's an error
        final isEnabled = snapshot.data ?? defaultValue;

        // Return the widget built by the builder function
        return builder(context, isEnabled);
      },
    );
  }

  Future<bool> _checkFeatureFlag() async {
    try {
      final featureFlag = di.get<FeatureFlag>();
      return await featureFlag.isEnabled(flagKey, defaultValue: defaultValue);
    } catch (e) {
      // If there's an error accessing the feature flag service,
      // return the default value
      return defaultValue;
    }
  }
}
