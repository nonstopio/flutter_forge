import 'dart:async';

import 'package:flutter/material.dart';
import '../models/haptic_config.dart';
import '../utils/haptic_utils.dart';

/// A widget that detects Morse code tap patterns and triggers callbacks
/// when the correct sequence is tapped.
///
/// The widget uses discrete gestures:
/// - Single tap (onTap) = dot (.)
/// - Double tap (onDoubleTap) = dash (-)
/// - Long press (onLongPress) = space between letters
///
/// It validates the tapped sequence against the expected Morse code pattern
/// and only triggers [onCorrectSequence] when the correct sequence is completed.
///
/// The timeout resets after each input, giving users time to enter the next
/// character. This allows for entering long sequences at a comfortable pace.
class MorseTapDetector extends StatefulWidget {
  /// Creates a Morse tap detector widget.
  ///
  /// [expectedMorseCode] The Morse code sequence that should be tapped
  /// [onCorrectSequence] Callback triggered when correct sequence is completed
  /// [child] The child widget to wrap
  /// [inputTimeout] Timeout duration to wait for the next input character
  const MorseTapDetector({
    super.key,
    required this.expectedMorseCode,
    required this.onCorrectSequence,
    required this.child,
    this.inputTimeout = const Duration(seconds: 10),
    this.hapticConfig,
    this.onIncorrectSequence,
    this.onInputTimeout,
    this.onSequenceChange,
    this.onDotAdded,
    this.onDashAdded,
    this.onSpaceAdded,
  });

  /// The expected Morse code sequence (e.g., "... --- ..." for SOS)
  final String expectedMorseCode;

  /// Callback triggered when the correct sequence is detected
  final VoidCallback onCorrectSequence;

  /// The child widget to detect taps on
  final Widget child;

  /// Timeout duration to wait for the next input character.
  /// This resets after each valid input, allowing users to take their time
  /// with long sequences as long as they keep entering characters.
  final Duration inputTimeout;

  /// Haptic feedback configuration
  /// If null, no haptic feedback will be provided
  final HapticConfig? hapticConfig;

  /// Callback for when an incorrect sequence is detected
  final VoidCallback? onIncorrectSequence;

  /// Callback for when input times out (no input received within timeout duration)
  final VoidCallback? onInputTimeout;

  /// Callback when a dot is added
  final VoidCallback? onDotAdded;

  /// Callback when a dash is added
  final VoidCallback? onDashAdded;

  /// Callback when a space is added
  final VoidCallback? onSpaceAdded;

  /// Callback when the sequence changes
  /// Provides the current sequence string, empty when incorrect or reset
  final ValueChanged<String>? onSequenceChange;

  @override
  State<MorseTapDetector> createState() => _MorseTapDetectorState();
}

class _MorseTapDetectorState extends State<MorseTapDetector> {
  final List<String> _currentSequence = [];
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _startInputTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(widget.inputTimeout, () {
      // Trigger timeout haptic feedback
      if (widget.hapticConfig != null) {
        HapticUtils.executeFromConfig(
          widget.hapticConfig,
          widget.hapticConfig!.timeoutIntensity,
        );
      }

      _resetSequence();
      widget.onInputTimeout?.call();
    });
  }

  void _resetSequence() {
    _currentSequence.clear();
    _timeoutTimer?.cancel();
    // Notify sequence change with empty string on reset
    widget.onSequenceChange?.call('');
  }

  void _addMorseCharacter(String character) {
    _currentSequence.add(character);
    _startInputTimeout();

    // Notify sequence change
    final currentMorse = _currentSequence.join('');
    widget.onSequenceChange?.call(currentMorse);

    // Check if sequence matches expected pattern
    _checkSequence();
  }

  void _onSingleTap() {
    // Single tap = dot
    _addMorseCharacter('.');
    widget.onDotAdded?.call();

    // Trigger haptic feedback
    if (widget.hapticConfig != null) {
      HapticUtils.executeFromConfig(
        widget.hapticConfig,
        widget.hapticConfig!.dotIntensity,
      );
    }
  }

  void _onDoubleTap() {
    // Double tap = dash
    _addMorseCharacter('-');
    widget.onDashAdded?.call();

    // Trigger haptic feedback
    if (widget.hapticConfig != null) {
      HapticUtils.executeFromConfig(
        widget.hapticConfig,
        widget.hapticConfig!.dashIntensity,
      );
    }
  }

  void _onLongPress() {
    // Long press = space (letter separator)
    _addMorseCharacter(' ');
    widget.onSpaceAdded?.call();

    // Trigger haptic feedback
    if (widget.hapticConfig != null) {
      HapticUtils.executeFromConfig(
        widget.hapticConfig,
        widget.hapticConfig!.spaceIntensity,
      );
    }
  }

  void _checkSequence() {
    final currentMorse = _currentSequence.join('');
    final expectedMorse = widget.expectedMorseCode;

    if (currentMorse == expectedMorse) {
      // Correct sequence detected!
      widget.onCorrectSequence();

      // Trigger success haptic feedback
      if (widget.hapticConfig != null) {
        HapticUtils.executeFromConfig(
          widget.hapticConfig,
          widget.hapticConfig!.correctSequenceIntensity,
        );
      }

      _resetSequence();
    } else if (currentMorse.length >= expectedMorse.length ||
        !expectedMorse.startsWith(currentMorse)) {
      // Sequence is wrong or too long
      widget.onIncorrectSequence?.call();

      // Trigger error haptic feedback
      if (widget.hapticConfig != null) {
        HapticUtils.executeFromConfig(
          widget.hapticConfig,
          widget.hapticConfig!.incorrectSequenceIntensity,
        );
      }

      _resetSequence();
    }
    // Otherwise, continue waiting for more input
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onSingleTap,
      onDoubleTap: _onDoubleTap,
      onLongPress: _onLongPress,
      child: widget.child,
    );
  }
}
