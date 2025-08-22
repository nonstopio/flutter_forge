import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/haptic_config.dart';
import '../models/haptic_feedback_type.dart';
import 'platform_utils_io.dart'
    if (dart.library.html) 'platform_utils_web.dart';

/// Utility class for managing haptic feedback in Morse code widgets.
///
/// Provides safe execution of haptic feedback with platform detection,
/// error handling, and user-friendly descriptions for haptic types.
class HapticUtils {
  HapticUtils._();

  /// Map of haptic feedback types to user-friendly display names
  static final Map<HapticFeedbackType, String> hapticTypeNames = {
    HapticFeedbackType.lightImpact: 'Light',
    HapticFeedbackType.mediumImpact: 'Medium',
    HapticFeedbackType.heavyImpact: 'Heavy',
    HapticFeedbackType.selectionClick: 'Selection',
    HapticFeedbackType.vibrate: 'Vibrate',
  };

  /// Map of haptic feedback types to detailed descriptions
  static final Map<HapticFeedbackType, String> hapticTypeDescriptions = {
    HapticFeedbackType.lightImpact: 'Subtle, gentle feedback',
    HapticFeedbackType.mediumImpact: 'Moderate, noticeable feedback',
    HapticFeedbackType.heavyImpact: 'Strong, pronounced feedback',
    HapticFeedbackType.selectionClick: 'Quick selection feedback',
    HapticFeedbackType.vibrate: 'Standard vibration pattern',
  };

  /// List of available haptic feedback types in order of intensity
  static final List<HapticFeedbackType> availableHapticTypes = [
    HapticFeedbackType.selectionClick,
    HapticFeedbackType.lightImpact,
    HapticFeedbackType.mediumImpact,
    HapticFeedbackType.heavyImpact,
    HapticFeedbackType.vibrate,
  ];

  /// Checks if haptic feedback is supported on the current platform
  static bool get isHapticSupported {
    if (kIsWeb) return false;
    return PlatformUtils.isHapticSupported;
  }

  /// Safely executes haptic feedback with error handling
  ///
  /// Returns true if haptic was executed successfully, false otherwise.
  static Future<bool> triggerHaptic(HapticFeedbackType? type) async {
    if (type == null || !isHapticSupported) {
      return false;
    }

    try {
      switch (type) {
        case HapticFeedbackType.lightImpact:
          await HapticFeedback.lightImpact();
        case HapticFeedbackType.mediumImpact:
          await HapticFeedback.mediumImpact();
        case HapticFeedbackType.heavyImpact:
          await HapticFeedback.heavyImpact();
        case HapticFeedbackType.selectionClick:
          await HapticFeedback.selectionClick();
        case HapticFeedbackType.vibrate:
          await HapticFeedback.vibrate();
      }
      return true;
    } catch (e) {
      // Silently handle haptic feedback errors
      debugPrint('Haptic feedback error: $e');
      return false;
    }
  }

  /// Executes haptic feedback based on configuration
  ///
  /// Only triggers if haptic is enabled in the config and supported by platform.
  static Future<bool> executeFromConfig(
    HapticConfig? config,
    HapticFeedbackType type,
  ) async {
    if (config == null || !config.enabled) {
      return false;
    }
    return await triggerHaptic(type);
  }

  /// Gets the display name for a haptic feedback type
  static String getHapticTypeName(HapticFeedbackType type) {
    return hapticTypeNames[type] ?? 'Unknown';
  }

  /// Gets the description for a haptic feedback type
  static String getHapticTypeDescription(HapticFeedbackType type) {
    return hapticTypeDescriptions[type] ?? 'No description available';
  }

  /// Creates a dropdown item for a haptic feedback type
  static DropdownMenuItem<HapticFeedbackType> createDropdownItem(
    HapticFeedbackType type,
  ) {
    return DropdownMenuItem<HapticFeedbackType>(
      value: type,
      child: Text(getHapticTypeName(type)),
    );
  }

  /// Preset configurations for quick selection
  static final Map<String, HapticConfig> presetConfigs = {
    'Disabled': HapticConfig.disabled,
    'Light': HapticConfig.light,
    'Default': HapticConfig.defaultConfig,
    'Strong': HapticConfig.strong,
  };

  /// Gets the name of a preset configuration, if it matches
  static String? getPresetName(HapticConfig config) {
    for (final entry in presetConfigs.entries) {
      if (entry.value == config) {
        return entry.key;
      }
    }
    return null;
  }

  /// Tests haptic feedback by triggering it immediately
  ///
  /// Used for preview functionality in configuration dialogs.
  static Future<void> testHaptic(HapticFeedbackType type) async {
    if (isHapticSupported) {
      await triggerHaptic(type);
      // Add a small delay to prevent rapid-fire haptics
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Validates a haptic configuration
  ///
  /// Returns null if valid, or an error message if invalid.
  static String? validateConfig(HapticConfig config) {
    if (!isHapticSupported && config.enabled) {
      return 'Haptic feedback is not supported on this platform';
    }
    return null;
  }
}
