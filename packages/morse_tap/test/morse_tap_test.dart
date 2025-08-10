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
      expect(MorseCodec.textToMorse('HELLO WORLD'), 
             '.... . .-.. .-.. --- / .-- --- .-. .-.. -..');
    });

    test('morseToText handles multiple words', () {
      expect(MorseCodec.morseToText('... --- ... / - . ... -'), 
             'SOS TEST');
    });

    test('getCharacterDuration returns correct durations', () {
      expect(MorseCodec.getCharacterDuration('.'), 
             const Duration(milliseconds: 100));
      expect(MorseCodec.getCharacterDuration('-'), 
             const Duration(milliseconds: 300));
      expect(MorseCodec.getCharacterDuration('x'), 
             const Duration(milliseconds: 0));
    });

    test('splitMorseSequence extracts dots and dashes', () {
      expect(MorseCodec.splitMorseSequence('... --- ...'), 
             ['.','.','.','-','-','-','.','.','.']);
    });
  });
}
