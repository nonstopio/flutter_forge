import 'dart:async';
import 'package:flutter/material.dart';

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
class MorseTapDetector extends StatefulWidget {
  /// Creates a Morse tap detector widget.
  ///
  /// [expectedMorseCode] The Morse code sequence that should be tapped
  /// [onCorrectSequence] Callback triggered when correct sequence is completed
  /// [child] The child widget to wrap
  /// [sequenceTimeout] Timeout for incomplete sequences
  /// [showVisualFeedback] Whether to show visual feedback during input
  /// [feedbackColor] Color for visual feedback
  const MorseTapDetector({
    super.key,
    required this.expectedMorseCode,
    required this.onCorrectSequence,
    required this.child,
    this.sequenceTimeout = const Duration(seconds: 10),
    this.showVisualFeedback = true,
    this.feedbackColor = Colors.blue,
    this.onIncorrectSequence,
    this.onSequenceTimeout,
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

  /// Timeout duration for incomplete sequences
  final Duration sequenceTimeout;

  /// Whether to show visual feedback during tap input
  final bool showVisualFeedback;

  /// Color for visual feedback overlay
  final Color feedbackColor;

  /// Callback for when an incorrect sequence is detected
  final VoidCallback? onIncorrectSequence;

  /// Callback for when a sequence times out
  final VoidCallback? onSequenceTimeout;

  /// Callback when a dot is added
  final VoidCallback? onDotAdded;

  /// Callback when a dash is added
  final VoidCallback? onDashAdded;

  /// Callback when a space is added
  final VoidCallback? onSpaceAdded;

  @override
  State<MorseTapDetector> createState() => _MorseTapDetectorState();
}

class _MorseTapDetectorState extends State<MorseTapDetector>
    with TickerProviderStateMixin {
  final List<String> _currentSequence = [];
  Timer? _timeoutTimer;
  
  late AnimationController _feedbackController;
  
  late AnimationController _dotController;
  late AnimationController _dashController;
  late AnimationController _spaceController;

  @override
  void initState() {
    super.initState();
    
    // Feedback animation controller (unused but kept for potential future use)
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    // Individual gesture feedback animations
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _dashController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _spaceController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _feedbackController.dispose();
    _dotController.dispose();
    _dashController.dispose();
    _spaceController.dispose();
    super.dispose();
  }

  void _startSequenceTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(widget.sequenceTimeout, () {
      _resetSequence();
      widget.onSequenceTimeout?.call();
    });
  }

  void _resetSequence() {
    _currentSequence.clear();
    _timeoutTimer?.cancel();
    if (mounted) {
      setState(() {});
    }
  }

  void _addMorseCharacter(String character) {
    _currentSequence.add(character);
    _startSequenceTimeout();
    setState(() {});
    
    // Check if sequence matches expected pattern
    _checkSequence();
  }

  void _onSingleTap() {
    // Single tap = dot
    _addMorseCharacter('.');
    widget.onDotAdded?.call();
    
    // Visual feedback
    if (widget.showVisualFeedback) {
      _dotController.forward().then((_) => _dotController.reverse());
    }
  }

  void _onDoubleTap() {
    // Double tap = dash
    _addMorseCharacter('-');
    widget.onDashAdded?.call();
    
    // Visual feedback
    if (widget.showVisualFeedback) {
      _dashController.forward().then((_) => _dashController.reverse());
    }
  }

  void _onLongPress() {
    // Long press = space (letter separator)
    _addMorseCharacter(' ');
    widget.onSpaceAdded?.call();
    
    // Visual feedback
    if (widget.showVisualFeedback) {
      _spaceController.forward().then((_) => _spaceController.reverse());
    }
  }

  void _checkSequence() {
    final currentMorse = _currentSequence.join('');
    final expectedMorse = widget.expectedMorseCode;

    if (currentMorse == expectedMorse) {
      // Correct sequence detected!
      _resetSequence();
      widget.onCorrectSequence();
    } else if (currentMorse.length >= expectedMorse.length || 
               !expectedMorse.startsWith(currentMorse)) {
      // Sequence is wrong or too long
      _resetSequence();
      widget.onIncorrectSequence?.call();
    }
    // Otherwise, continue waiting for more input
  }

  String get _currentMorseDisplay {
    return _currentSequence.join('');
  }

  Color _getCurrentFeedbackColor() {
    if (_dotController.isAnimating) {
      return Colors.green;
    } else if (_dashController.isAnimating) {
      return Colors.orange;
    } else if (_spaceController.isAnimating) {
      return Colors.purple;
    }
    return widget.feedbackColor;
  }

  double _getCurrentFeedbackValue() {
    if (_dotController.isAnimating) {
      return _dotController.value * 0.3;
    } else if (_dashController.isAnimating) {
      return _dashController.value * 0.3;
    } else if (_spaceController.isAnimating) {
      return _spaceController.value * 0.3;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onSingleTap,
      onDoubleTap: _onDoubleTap,
      onLongPress: _onLongPress,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _dotController,
          _dashController, 
          _spaceController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Base widget with feedback overlay
              Container(
                decoration: BoxDecoration(
                  color: widget.showVisualFeedback 
                      ? _getCurrentFeedbackColor().withValues(
                          alpha: _getCurrentFeedbackValue(),
                        )
                      : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: widget.child,
              ),
              
              // Current sequence display
              if (_currentSequence.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.radio_button_checked,
                          color: Colors.blue[300],
                          size: 12,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _currentMorseDisplay,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Gesture hints overlay
              if (_currentSequence.isEmpty)
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          '1 tap = •',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          '2 taps = —',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          'Hold = space',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}