import 'package:core/logger/logger.dart';
import 'package:di/di.dart';
import 'package:feature_flags/src/client/feature_flag.dart';
import 'package:flutter/material.dart';

/// A wrapper widget that conditionally renders content based on feature flags
class FeatureFlagWrapper extends StatefulWidget {
  const FeatureFlagWrapper({
    super.key,
    required this.flagKey,
    required this.builder,
    this.defaultValue = false,
    this.loading,
    this.service,
    this.logger,
  });

  /// The single locator fallback in this package, used only for collaborators
  /// not passed to the constructor. It resolves the registered [FeatureFlag]
  /// and [Logger] at the widget build edge (null when not registered) so a
  /// screen can drop the wrapper in without threading services through.
  static ({FeatureFlag? service, Logger? logger}) resolve() => (
    service: di.has<FeatureFlag>() ? di.get<FeatureFlag>() : null,
    logger: di.has<Logger>() ? di.get<Logger>() : null,
  );

  /// The feature flag key to check
  final String flagKey;

  /// Builder function that receives the context and feature flag value
  final Widget Function(BuildContext context, bool value) builder;

  /// The default value to use if the feature flag service is unavailable
  final bool defaultValue;

  /// Widget to show while loading the feature flag value
  final Widget? loading;

  /// Flag source; defaults to the registered one (see [resolve]).
  final FeatureFlag? service;

  /// Receives read failures; defaults to the registered one (see [resolve]).
  final Logger? logger;

  @override
  State<FeatureFlagWrapper> createState() => _FeatureFlagWrapperState();
}

class _FeatureFlagWrapperState extends State<FeatureFlagWrapper> {
  late Future<bool> _value;

  @override
  void initState() {
    super.initState();
    _value = _checkFeatureFlag();
  }

  @override
  void didUpdateWidget(FeatureFlagWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flagKey != widget.flagKey ||
        oldWidget.defaultValue != widget.defaultValue ||
        oldWidget.service != widget.service) {
      _value = _checkFeatureFlag();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _value,
      builder: (context, snapshot) {
        // Show loading widget while waiting for feature flag
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loading ?? const SizedBox.shrink();
        }

        // Get the feature flag value, defaulting to false if there's an error
        final isEnabled = snapshot.data ?? widget.defaultValue;

        // Return the widget built by the builder function
        return widget.builder(context, isEnabled);
      },
    );
  }

  Future<bool> _checkFeatureFlag() async {
    final service = widget.service ?? FeatureFlagWrapper.resolve().service;
    // Feature flags not configured: render with the default.
    if (service == null) return widget.defaultValue;
    try {
      return await service.isEnabled(
        widget.flagKey,
        defaultValue: widget.defaultValue,
      );
    } catch (error, stackTrace) {
      (widget.logger ?? FeatureFlagWrapper.resolve().logger)?.e(
        'Feature flag ${widget.flagKey} could not be read; using default',
        error,
        stackTrace,
      );
      return widget.defaultValue;
    }
  }
}
