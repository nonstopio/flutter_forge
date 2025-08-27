import 'haptic_feedback_type.dart';

/// Configuration class for haptic feedback settings in Morse code widgets.
///
/// This class defines the haptic feedback intensity for different Morse code
/// gestures and events, allowing users to customize their tactile experience.
class HapticConfig {
  /// Creates a haptic configuration.
  const HapticConfig({
    this.enabled = false,
    this.dotIntensity = HapticFeedbackType.lightImpact,
    this.dashIntensity = HapticFeedbackType.mediumImpact,
    this.spaceIntensity = HapticFeedbackType.heavyImpact,
    this.correctSequenceIntensity = HapticFeedbackType.mediumImpact,
    this.incorrectSequenceIntensity = HapticFeedbackType.heavyImpact,
    this.timeoutIntensity = HapticFeedbackType.lightImpact,
  });

  /// Whether haptic feedback is enabled globally
  final bool enabled;

  /// Haptic intensity for dots (single taps)
  final HapticFeedbackType dotIntensity;

  /// Haptic intensity for dashes (double taps)
  final HapticFeedbackType dashIntensity;

  /// Haptic intensity for spaces (long press)
  final HapticFeedbackType spaceIntensity;

  /// Haptic intensity for correct sequence completion
  final HapticFeedbackType correctSequenceIntensity;

  /// Haptic intensity for incorrect sequences
  final HapticFeedbackType incorrectSequenceIntensity;

  /// Haptic intensity for input timeout
  final HapticFeedbackType timeoutIntensity;

  /// Creates a copy of this config with the given fields replaced with new values.
  HapticConfig copyWith({
    bool? enabled,
    HapticFeedbackType? dotIntensity,
    HapticFeedbackType? dashIntensity,
    HapticFeedbackType? spaceIntensity,
    HapticFeedbackType? correctSequenceIntensity,
    HapticFeedbackType? incorrectSequenceIntensity,
    HapticFeedbackType? timeoutIntensity,
  }) {
    return HapticConfig(
      enabled: enabled ?? this.enabled,
      dotIntensity: dotIntensity ?? this.dotIntensity,
      dashIntensity: dashIntensity ?? this.dashIntensity,
      spaceIntensity: spaceIntensity ?? this.spaceIntensity,
      correctSequenceIntensity:
          correctSequenceIntensity ?? this.correctSequenceIntensity,
      incorrectSequenceIntensity:
          incorrectSequenceIntensity ?? this.incorrectSequenceIntensity,
      timeoutIntensity: timeoutIntensity ?? this.timeoutIntensity,
    );
  }

  /// Default haptic configuration with moderate settings
  static const HapticConfig defaultConfig = HapticConfig(
    enabled: true,
    dotIntensity: HapticFeedbackType.lightImpact,
    dashIntensity: HapticFeedbackType.lightImpact,
    spaceIntensity: HapticFeedbackType.lightImpact,
    correctSequenceIntensity: HapticFeedbackType.mediumImpact,
    incorrectSequenceIntensity: HapticFeedbackType.mediumImpact,
    timeoutIntensity: HapticFeedbackType.mediumImpact,
  );

  /// Disabled haptic configuration
  static const HapticConfig disabled = HapticConfig(enabled: false);

  /// Light haptic configuration with subtle feedback
  static const HapticConfig light = HapticConfig(
    enabled: true,
    dotIntensity: HapticFeedbackType.selectionClick,
    dashIntensity: HapticFeedbackType.lightImpact,
    spaceIntensity: HapticFeedbackType.mediumImpact,
    correctSequenceIntensity: HapticFeedbackType.lightImpact,
    incorrectSequenceIntensity: HapticFeedbackType.mediumImpact,
    timeoutIntensity: HapticFeedbackType.selectionClick,
  );

  /// Strong haptic configuration with intense feedback
  static const HapticConfig strong = HapticConfig(
    enabled: true,
    dotIntensity: HapticFeedbackType.mediumImpact,
    dashIntensity: HapticFeedbackType.heavyImpact,
    spaceIntensity: HapticFeedbackType.heavyImpact,
    correctSequenceIntensity: HapticFeedbackType.heavyImpact,
    incorrectSequenceIntensity: HapticFeedbackType.heavyImpact,
    timeoutIntensity: HapticFeedbackType.mediumImpact,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HapticConfig &&
        other.enabled == enabled &&
        other.dotIntensity == dotIntensity &&
        other.dashIntensity == dashIntensity &&
        other.spaceIntensity == spaceIntensity &&
        other.correctSequenceIntensity == correctSequenceIntensity &&
        other.incorrectSequenceIntensity == incorrectSequenceIntensity &&
        other.timeoutIntensity == timeoutIntensity;
  }

  @override
  int get hashCode {
    return Object.hash(
      enabled,
      dotIntensity,
      dashIntensity,
      spaceIntensity,
      correctSequenceIntensity,
      incorrectSequenceIntensity,
      timeoutIntensity,
    );
  }

  @override
  String toString() {
    return 'HapticConfig('
        'enabled: $enabled, '
        'dotIntensity: $dotIntensity, '
        'dashIntensity: $dashIntensity, '
        'spaceIntensity: $spaceIntensity, '
        'correctSequenceIntensity: $correctSequenceIntensity, '
        'incorrectSequenceIntensity: $incorrectSequenceIntensity, '
        'timeoutIntensity: $timeoutIntensity)';
  }
}
