import 'package:flutter_test/flutter_test.dart';

import 'package:morse_tap/morse_tap.dart';

void main() {
  group('MorseCodec', () {
    test('converts text to Morse code', () {
      expect('SOS'.toMorseCode(), '... --- ...');
      expect('HELLO'.toMorseCode(), '.... . .-.. .-.. ---');
      expect('TEST'.toMorseCode(), '- . ... -');
    });

    test('converts Morse code to text', () {
      expect('... --- ...'.fromMorseCode(), 'SOS');
      expect('.... . .-.. .-.. ---'.fromMorseCode(), 'HELLO');
      expect('- . ... -'.fromMorseCode(), 'TEST');
    });

    test('validates Morse sequences', () {
      expect('... --- ...'.isValidMorseSequence(), true);
      expect('... xyz ...'.isValidMorseSequence(), false);
      expect(''.isValidMorseSequence(), true);
    });

    test('validates Morse input characters', () {
      expect('... --- ...'.isValidMorseInput(), true);
      expect('... abc ...'.isValidMorseInput(), false);
      expect('.-.. --- ...- .'.isValidMorseInput(), true);
    });
  });

  group('MorseCodec direct methods', () {
    test('textToMorse handles multiple words', () {
      expect(
        MorseCodec.textToMorse('HELLO WORLD'),
        '.... . .-.. .-.. --- / .-- --- .-. .-.. -..',
      );
    });

    test('morseToText handles multiple words', () {
      expect(MorseCodec.morseToText('... --- ... / - . ... -'), 'SOS TEST');
    });

    test('getCharacterDuration returns correct durations', () {
      expect(
        MorseCodec.getCharacterDuration('.'),
        const Duration(milliseconds: 100),
      );
      expect(
        MorseCodec.getCharacterDuration('-'),
        const Duration(milliseconds: 300),
      );
      expect(
        MorseCodec.getCharacterDuration('x'),
        const Duration(milliseconds: 0),
      );
    });

    test('splitMorseSequence extracts dots and dashes', () {
      expect(MorseCodec.splitMorseSequence('... --- ...'), [
        '.',
        '.',
        '.',
        '-',
        '-',
        '-',
        '.',
        '.',
        '.',
      ]);
    });

    test('supportedCharacters contains the alphabet', () {
      expect(MorseCodec.supportedCharacters, contains('A'));
      expect(MorseCodec.supportedCharacters, contains('Z'));
      expect(MorseCodec.supportedCharacters, contains('0'));
    });

    test('supportedMorseCodes contains known codes', () {
      expect(MorseCodec.supportedMorseCodes, contains('...'));
      expect(MorseCodec.supportedMorseCodes, contains('.-'));
    });

    test('textToMorse returns empty string for empty input', () {
      expect(MorseCodec.textToMorse(''), '');
    });

    test('textToMorse skips unsupported characters', () {
      expect(MorseCodec.textToMorse('A#B'), '.- -...');
    });

    test('textToMorse skips empty words from consecutive spaces', () {
      expect(MorseCodec.textToMorse('A  B'), '.- / -...');
    });

    test('morseToText returns empty string for empty input', () {
      expect(MorseCodec.morseToText(''), '');
    });

    test('morseToText skips whitespace-only words', () {
      expect(MorseCodec.morseToText('... /   / ---'), 'S O');
    });

    test('morseToText skips unknown codes', () {
      expect(MorseCodec.morseToText('... xx ...'), 'SS');
    });

    test('isValidMorseSequence is true for empty input', () {
      expect(MorseCodec.isValidMorseSequence(''), isTrue);
    });

    test('isValidMorseSequence ignores whitespace-only parts', () {
      expect(MorseCodec.isValidMorseSequence('... /    / ---'), isTrue);
    });
  });

  group('StringToMorse extension', () {
    test('toMorseCodeWithTiming includes timing metadata', () {
      final result = 'HI'.toMorseCodeWithTiming();
      expect(result, contains('....'));
      expect(result, contains('dot=100ms'));
    });

    test('toMorseCodeWithTiming returns empty for empty input', () {
      expect(''.toMorseCodeWithTiming(), '');
    });

    test('isValidMorseInput returns true for empty input', () {
      expect(''.isValidMorseInput(), isTrue);
    });
  });
}
