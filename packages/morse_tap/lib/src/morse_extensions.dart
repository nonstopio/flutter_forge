import 'morse_algorithm.dart';

/// Extension methods for converting strings to Morse code
extension StringToMorse on String {
  /// Converts this string to Morse code representation
  ///
  /// Returns a string with dots and dashes representing the Morse code.
  /// Spaces separate letters, and " / " separates words.
  ///
  /// Example:
  /// ```dart
  /// "HELLO".toMorseCode(); // Returns: ".... . .-.. .-.. ---"
  /// "SOS".toMorseCode(); // Returns: "... --- ..."
  /// ```
  String toMorseCode() {
    return MorseCodec.textToMorse(this);
  }

  /// Converts this string to Morse code with timing indicators
  ///
  /// Returns a formatted string that includes timing information for
  /// dots, dashes, and pauses between letters and words.
  ///
  /// Format:
  /// - . = dot (100ms)
  /// - - = dash (300ms)
  /// - (space) = letter separator (200ms pause)
  /// - / = word separator (700ms pause)
  ///
  /// Example:
  /// ```dart
  /// "HI".toMorseCodeWithTiming(); // Returns: ".... .. (dot=100ms, dash=300ms)"
  /// ```
  String toMorseCodeWithTiming() {
    final morse = toMorseCode();
    if (morse.isEmpty) return '';

    return '$morse (dot=100ms, dash=300ms, letter_gap=200ms, word_gap=700ms)';
  }

  /// Validates if this string contains only valid Morse code input characters
  ///
  /// Returns true if the string contains only dots (.), dashes (-), spaces,
  /// and forward slashes (/) which are valid Morse code characters.
  ///
  /// Example:
  /// ```dart
  /// "... --- ...".isValidMorseInput(); // Returns: true
  /// "... abc ...".isValidMorseInput(); // Returns: false
  /// ```
  bool isValidMorseInput() {
    if (isEmpty) return true;

    // Check if string contains only valid Morse characters: ., -, space, /
    final validPattern = RegExp(r'^[.\-\s/]*$');
    return validPattern.hasMatch(this);
  }

  /// Converts Morse code string back to text
  ///
  /// If this string is a valid Morse code sequence, it will be converted
  /// back to readable text. Invalid sequences will return an empty string.
  ///
  /// Example:
  /// ```dart
  /// "... --- ...".fromMorseCode(); // Returns: "SOS"
  /// ".... . .-.. .-.. ---".fromMorseCode(); // Returns: "HELLO"
  /// ```
  String fromMorseCode() {
    return MorseCodec.morseToText(this);
  }

  /// Checks if this string represents a valid Morse code sequence
  ///
  /// Returns true if all Morse codes in the string are valid and can be
  /// converted back to text.
  ///
  /// Example:
  /// ```dart
  /// "... --- ...".isValidMorseSequence(); // Returns: true
  /// "... xyz ...".isValidMorseSequence(); // Returns: false
  /// ```
  bool isValidMorseSequence() {
    return MorseCodec.isValidMorseSequence(this);
  }
}
