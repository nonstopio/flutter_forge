import 'dart:io';

/// Platform utilities for native platforms (mobile and desktop)
class PlatformUtils {
  /// Checks if haptic feedback is supported on the current platform
  /// Returns true for iOS and Android platforms
  /// Desktop platforms (Linux, macOS, Windows) don't support haptic feedback
  static bool get isHapticSupported => Platform.isIOS || Platform.isAndroid;
}