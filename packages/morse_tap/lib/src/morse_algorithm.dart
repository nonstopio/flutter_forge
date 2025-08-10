/// Core algorithm for Morse code conversion and validation.
class MorseCodec {
  /// Character mappings from text to Morse code
  static const Map<String, String> _textToMorse = {
    'A': '.-',
    'B': '-...',
    'C': '-.-.',
    'D': '-..',
    'E': '.',
    'F': '..-.',
    'G': '--.',
    'H': '....',
    'I': '..',
    'J': '.---',
    'K': '-.-',
    'L': '.-..',
    'M': '--',
    'N': '-.',
    'O': '---',
    'P': '.--.',
    'Q': '--.-',
    'R': '.-.',
    'S': '...',
    'T': '-',
    'U': '..-',
    'V': '...-',
    'W': '.--',
    'X': '-..-',
    'Y': '-.--',
    'Z': '--..',
    '0': '-----',
    '1': '.----',
    '2': '..---',
    '3': '...--',
    '4': '....-',
    '5': '.....',
    '6': '-....',
    '7': '--...',
    '8': '---..',
    '9': '----.',
    '.': '.-.-.-',
    ',': '--..--',
    '?': '..--..',
    "'": '.----.',
    '!': '-.-.--',
    '/': '-..-.',
    '(': '-.--.',
    ')': '-.--.-',
    '&': '.-...',
    ':': '---...',
    ';': '-.-.-.',
    '=': '-...-',
    '+': '.-.-.',
    '-': '-....-',
    '_': '..--.-',
    '"': '.-..-.',
    '\$': '...-..-',
    '@': '.--.-.',
  };

  /// Reverse mapping for Morse code to text conversion
  static final Map<String, String> _morseToText = {
    for (final entry in _textToMorse.entries) entry.value: entry.key,
  };

  /// Converts text to Morse code representation
  ///
  /// [text] The input text to convert
  /// Returns Morse code string with spaces between letters and " / " between words
  static String textToMorse(String text) {
    if (text.isEmpty) return '';

    final words = text.toUpperCase().split(' ');
    final morseWords = <String>[];

    for (final word in words) {
      if (word.isEmpty) continue;

      final morseLetters = <String>[];
      for (int i = 0; i < word.length; i++) {
        final char = word[i];
        final morse = _textToMorse[char];
        if (morse != null) {
          morseLetters.add(morse);
        }
      }

      if (morseLetters.isNotEmpty) {
        morseWords.add(morseLetters.join(' '));
      }
    }

    return morseWords.join(' / ');
  }

  /// Converts Morse code to text
  ///
  /// [morse] The Morse code string to convert
  /// Returns the decoded text
  static String morseToText(String morse) {
    if (morse.isEmpty) return '';

    final words = morse.split(' / ');
    final textWords = <String>[];

    for (final word in words) {
      if (word.trim().isEmpty) continue;

      final letters = word.trim().split(' ');
      final textLetters = <String>[];

      for (final letter in letters) {
        if (letter.isEmpty) continue;
        final char = _morseToText[letter];
        if (char != null) {
          textLetters.add(char);
        }
      }

      if (textLetters.isNotEmpty) {
        textWords.add(textLetters.join());
      }
    }

    return textWords.join(' ');
  }

  /// Validates if a Morse code sequence is valid
  ///
  /// [sequence] The Morse code sequence to validate
  /// Returns true if all characters in the sequence are valid Morse codes
  static bool isValidMorseSequence(String sequence) {
    if (sequence.isEmpty) return true;

    // Split by word separators first
    final words = sequence.split(' / ');

    for (final word in words) {
      if (word.trim().isEmpty) continue;

      // Split by letter separators
      final letters = word.trim().split(' ');

      for (final letter in letters) {
        if (letter.isEmpty) continue;

        // Check if this morse code exists in our mapping
        if (!_morseToText.containsKey(letter)) {
          return false;
        }
      }
    }

    return true;
  }

  /// Gets the relative duration for a Morse character
  ///
  /// [morseChar] Single Morse character (. or -)
  /// Returns duration in milliseconds (dot = 100ms, dash = 300ms)
  static Duration getCharacterDuration(String morseChar) {
    switch (morseChar) {
      case '.':
        return const Duration(milliseconds: 100);
      case '-':
        return const Duration(milliseconds: 300);
      default:
        return const Duration(milliseconds: 0);
    }
  }

  /// Splits a Morse code sequence into individual characters
  ///
  /// [sequence] The Morse code sequence to split
  /// Returns list of individual Morse characters (dots and dashes)
  static List<String> splitMorseSequence(String sequence) {
    final characters = <String>[];

    for (int i = 0; i < sequence.length; i++) {
      final char = sequence[i];
      if (char == '.' || char == '-') {
        characters.add(char);
      }
    }

    return characters;
  }

  /// Gets all supported characters
  static Set<String> get supportedCharacters => _textToMorse.keys.toSet();

  /// Gets all Morse codes
  static Set<String> get supportedMorseCodes => _morseToText.keys.toSet();
}
