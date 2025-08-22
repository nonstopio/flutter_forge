/// Platform utilities for web platform
class PlatformUtils {
  /// Checks if haptic feedback is supported on the current platform
  /// Always returns false for web platform
  static bool get isHapticSupported => false;
}