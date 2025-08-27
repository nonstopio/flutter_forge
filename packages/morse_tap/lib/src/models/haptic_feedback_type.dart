/// Custom enum for haptic feedback types to provide a unified interface
/// for different haptic feedback intensities available in Flutter.
enum HapticFeedbackType {
  /// Light haptic feedback - subtle, gentle touch sensation
  lightImpact,

  /// Medium haptic feedback - moderate, noticeable touch sensation
  mediumImpact,

  /// Heavy haptic feedback - strong, pronounced touch sensation
  heavyImpact,

  /// Selection click feedback - quick, precise feedback for selections
  selectionClick,

  /// Vibration feedback - standard system vibration pattern
  vibrate,
}
