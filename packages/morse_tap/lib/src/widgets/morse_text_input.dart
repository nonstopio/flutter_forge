import 'dart:async';
import 'package:flutter/material.dart';
import '../morse_algorithm.dart';

/// A widget that converts tap input to Morse code and updates a text controller
/// or calls a method in real-time.
///
/// This widget provides a complete Morse code input experience using gestures:
/// - Single tap = dot (.)
/// - Double tap = dash (-)
/// - Long press = space between letters
///
/// It converts Morse patterns into readable text automatically or provides raw Morse code.
class MorseTextInput extends StatefulWidget {
  /// Creates a Morse text input widget.
  ///
  /// Either [controller] or [onTextChanged] must be provided.
  ///
  /// [controller] Text editing controller to update with converted text
  /// [onTextChanged] Callback for text changes
  /// [letterGap] Pause duration between letters for auto-completion
  /// [wordGap] Pause duration between words for auto-completion
  /// [showMorsePreview] Whether to show Morse code preview
  /// [autoConvertToText] Whether to auto-convert Morse to readable text
  /// [onClear] Callback when input is cleared
  /// [decoration] Input decoration for the text field
  const MorseTextInput({
    super.key,
    this.controller,
    this.onTextChanged,
    this.letterGap = const Duration(milliseconds: 1200),
    this.wordGap = const Duration(seconds: 3),
    this.showMorsePreview = true,
    this.autoConvertToText = true,
    this.onClear,
    this.decoration,
    this.tapAreaHeight = 120.0,
    this.feedbackColor = Colors.blue,
  }) : assert(
         controller != null || onTextChanged != null,
         'Either controller or onTextChanged must be provided',
       );

  /// Text editing controller to update with converted text
  final TextEditingController? controller;

  /// Callback for text changes
  final ValueChanged<String>? onTextChanged;

  /// Pause duration between letters for auto letter completion
  final Duration letterGap;

  /// Pause duration between words for auto word completion
  final Duration wordGap;

  /// Whether to show Morse code preview above the input
  final bool showMorsePreview;

  /// Whether to automatically convert Morse code to readable text
  final bool autoConvertToText;

  /// Callback when input is cleared
  final VoidCallback? onClear;

  /// Input decoration for the text field display
  final InputDecoration? decoration;

  /// Height of the tap detection area
  final double tapAreaHeight;

  /// Color for tap feedback
  final Color feedbackColor;

  @override
  State<MorseTextInput> createState() => _MorseTextInputState();
}

class _MorseTextInputState extends State<MorseTextInput>
    with TickerProviderStateMixin {
  late final TextEditingController _internalController;
  final List<String> _currentLetter = [];
  final List<String> _morseWords = [];
  final List<String> _morseLetters = [];

  Timer? _letterGapTimer;
  Timer? _wordGapTimer;

  late AnimationController _dotController;
  late AnimationController _dashController;
  late AnimationController _spaceController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();

    // Animation controllers for visual feedback
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
    _letterGapTimer?.cancel();
    _wordGapTimer?.cancel();
    _dotController.dispose();
    _dashController.dispose();
    _spaceController.dispose();
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _onSingleTap() {
    // Single tap = dot
    _currentLetter.add('.');
    _dotController.forward().then((_) => _dotController.reverse());

    // Cancel pending timers and start letter gap timer
    _letterGapTimer?.cancel();
    _wordGapTimer?.cancel();

    _letterGapTimer = Timer(widget.letterGap, () {
      _completeLetter();
    });

    setState(() {});
  }

  void _onDoubleTap() {
    // Double tap = dash
    _currentLetter.add('-');
    _dashController.forward().then((_) => _dashController.reverse());

    // Cancel pending timers and start letter gap timer
    _letterGapTimer?.cancel();
    _wordGapTimer?.cancel();

    _letterGapTimer = Timer(widget.letterGap, () {
      _completeLetter();
    });

    setState(() {});
  }

  void _onLongPress() {
    // Long press = complete current letter and add space
    _spaceController.forward().then((_) => _spaceController.reverse());

    _letterGapTimer?.cancel();
    _wordGapTimer?.cancel();

    if (_currentLetter.isNotEmpty) {
      _completeLetter();
    }

    // Force word completion after a short delay to allow letter to process
    Timer(const Duration(milliseconds: 100), () {
      _completeWord();
    });
  }

  void _completeLetter() {
    if (_currentLetter.isNotEmpty) {
      final letterMorse = _currentLetter.join('');
      _morseLetters.add(letterMorse);
      _currentLetter.clear();

      // Start word gap timer
      _wordGapTimer = Timer(widget.wordGap, () {
        _completeWord();
      });

      _updateOutput();
      setState(() {});
    }
  }

  void _completeWord() {
    if (_morseLetters.isNotEmpty) {
      final wordMorse = _morseLetters.join(' ');
      _morseWords.add(wordMorse);
      _morseLetters.clear();

      _updateOutput();
      setState(() {});
    }
  }

  void _updateOutput() {
    final currentMorse = _getCurrentMorseCode();

    if (widget.autoConvertToText) {
      final text = MorseCodec.morseToText(currentMorse);
      _internalController.text = text;
      widget.onTextChanged?.call(text);
    } else {
      _internalController.text = currentMorse;
      widget.onTextChanged?.call(currentMorse);
    }
  }

  String _getCurrentMorseCode() {
    final words = <String>[];

    // Add completed words
    words.addAll(_morseWords);

    // Add current word in progress
    if (_morseLetters.isNotEmpty || _currentLetter.isNotEmpty) {
      final currentWordLetters = <String>[];
      currentWordLetters.addAll(_morseLetters);

      // Add current letter in progress
      if (_currentLetter.isNotEmpty) {
        currentWordLetters.add(_currentLetter.join(''));
      }

      if (currentWordLetters.isNotEmpty) {
        words.add(currentWordLetters.join(' '));
      }
    }

    return words.join(' / ');
  }

  String _getCurrentLetterPreview() {
    if (_currentLetter.isNotEmpty) {
      final letterMorse = _currentLetter.join('');
      final possibleChar = MorseCodec.morseToText(letterMorse);
      if (possibleChar.isNotEmpty) {
        return '$letterMorse → $possibleChar';
      }
      return letterMorse;
    }
    return '';
  }

  void _clearInput() {
    _currentLetter.clear();
    _morseWords.clear();
    _morseLetters.clear();
    _letterGapTimer?.cancel();
    _wordGapTimer?.cancel();

    _internalController.clear();
    widget.onTextChanged?.call('');
    widget.onClear?.call();

    setState(() {});
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
      return _dotController.value * 0.15;
    } else if (_dashController.isAnimating) {
      return _dashController.value * 0.15;
    } else if (_spaceController.isAnimating) {
      return _spaceController.value * 0.15;
    }
    return 0.02;
  }

  @override
  Widget build(BuildContext context) {
    final currentMorse = _getCurrentMorseCode();
    final letterPreview = _getCurrentLetterPreview();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Morse preview (optional)
        if (widget.showMorsePreview) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.radio_button_checked,
                      size: 16,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Morse Code:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(
                        currentMorse.isEmpty
                            ? 'Tap below to input...'
                            : currentMorse,
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                          color: currentMorse.isEmpty
                              ? Colors.grey[500]
                              : Colors.black87,
                        ),
                      ),
                      if (letterPreview.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            border: Border.all(color: Colors.blue[200]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            letterPreview,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue[700],
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Text output field
        TextField(
          controller: _internalController,
          readOnly: true,
          maxLines: 3,
          decoration:
              widget.decoration ??
              InputDecoration(
                hintText: widget.autoConvertToText
                    ? 'Converted text will appear here...'
                    : 'Morse code will appear here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.vertical(
                    top: widget.showMorsePreview
                        ? Radius.zero
                        : const Radius.circular(8),
                    bottom: Radius.zero,
                  ),
                ),
                suffixIcon: currentMorse.isNotEmpty
                    ? IconButton(
                        onPressed: _clearInput,
                        icon: const Icon(Icons.clear),
                        tooltip: 'Clear input',
                      )
                    : null,
              ),
        ),

        // Tap detection area
        AnimatedBuilder(
          animation: Listenable.merge([
            _dotController,
            _dashController,
            _spaceController,
          ]),
          builder: (context, child) {
            return GestureDetector(
              onTap: _onSingleTap,
              onDoubleTap: _onDoubleTap,
              onLongPress: _onLongPress,
              child: Container(
                height: widget.tapAreaHeight,
                decoration: BoxDecoration(
                  color: _getCurrentFeedbackColor().withValues(
                    alpha: _getCurrentFeedbackValue(),
                  ),
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 32,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap for Morse Input',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '1 tap = • | 2 taps = — | Hold = space',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Current letter being typed
                    if (_currentLetter.isNotEmpty)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit,
                                color: Colors.yellow[300],
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _currentLetter.join(''),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Gesture feedback indicators
                    if (_dotController.isAnimating)
                      const Positioned(
                        bottom: 8,
                        left: 8,
                        child: Icon(
                          Icons.circle,
                          color: Colors.green,
                          size: 12,
                        ),
                      ),
                    if (_dashController.isAnimating)
                      const Positioned(
                        bottom: 8,
                        left: 28,
                        child: Icon(
                          Icons.remove,
                          color: Colors.orange,
                          size: 16,
                        ),
                      ),
                    if (_spaceController.isAnimating)
                      const Positioned(
                        bottom: 8,
                        left: 52,
                        child: Icon(
                          Icons.space_bar,
                          color: Colors.purple,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
