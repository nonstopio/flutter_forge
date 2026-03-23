<!-- BEGIN:nonstop-header — auto-generated, do not edit. Run `melos sync:readme` to update -->
<p align="center">
  <a href="https://nonstopio.com">
    <img src="https://github.com/nonstopio.png" alt="Nonstop Logo" height="128" />
  </a>
  <h1 align="center">NonStop</h1>
  <p align="center">Digital Product Development Experts for Startups & Enterprises</p>
  <p align="center">
    <a href="https://nonstopio.com/about-us">About</a> |
    <a href="https://nonstopio.com">Website</a>
  </p>
</p>
<!-- END:nonstop-header -->

# morse_tap

<!-- BEGIN:badges — auto-generated, do not edit. Run `melos sync:readme` to update -->
[![Build Status](https://img.shields.io/pub/v/morse_tap.svg)](https://github.com/nonstopio/flutter_forge/tree/main/packages/morse_tap)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
<!-- END:badges -->

A Flutter package that provides Morse code input functionality using intuitive gestures. Create interactive Morse code experiences with single taps for dots, double taps for dashes, and long presses for spaces.

![Morse Tap Demo](morse_tap.png)

## Features

✨ **MorseTapDetector** - Widget that detects specific Morse code patterns using gestures
🎯 **MorseTextInput** - Real-time gesture-to-text conversion widget
🔄 **String Extensions** - Convert any string to/from Morse code
⚡ **Fast Algorithm** - Efficient Morse code conversion with comprehensive character support
🎨 **Intuitive Gestures** - Single tap = dot, double tap = dash, long press = space
📳 **Haptic Feedback** - Customizable tactile feedback for enhanced user experience

<!-- BEGIN:getting-started — auto-generated, do not edit. Run `melos sync:readme` to update -->
## Getting Started

1. Open your project's `pubspec.yaml` file.
2. Add the `morse_tap` package to your dependencies, replacing `[version]` with the latest version:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     morse_tap: ^[version]
   ```
3. Run `flutter pub get` to fetch the package.
<!-- END:getting-started -->

<!-- BEGIN:import-package — auto-generated, do not edit. Run `melos sync:readme` to update -->
## Import the Package

```dart
import 'package:morse_tap/morse_tap.dart';
```
<!-- END:import-package -->

## Usage Examples

### 1. MorseTapDetector - Pattern Detection

Detect when users input a specific Morse code pattern using gestures:

```dart
MorseTapDetector(
  expectedMorseCode: "... --- ...", // SOS pattern
  onCorrectSequence: () {
    print("SOS detected!");
    // Handle correct sequence
  },
  onIncorrectSequence: () {
    print("Wrong pattern, try again");
  },
  onSequenceChange: (sequence) {
    print("Current sequence: $sequence");
    // Update UI with current input
  },
  onDotAdded: () => print("Dot added"),
  onDashAdded: () => print("Dash added"),
  onSpaceAdded: () => print("Space added"),
  child: Container(
    width: 200,
    height: 200,
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Center(
      child: Text(
        'Use Gestures for SOS',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    ),
  ),
)
```

### 2. MorseTextInput - Real-time Conversion

Convert tap input to text in real-time:

```dart
class MorseInputExample extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MorseTextInput(
          controller: controller,
          autoConvertToText: true,
          showMorsePreview: true,
          onTextChanged: (text) {
            print("Converted text: $text");
          },
          decoration: const InputDecoration(
            labelText: 'Tap to input text',
            border: OutlineInputBorder(),
          ),
        ),
        // Your converted text appears in the controller
        TextField(
          controller: controller,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Output',
          ),
        ),
      ],
    );
  }
}
```

### 3. String Extensions

Easy string to Morse code conversion:

```dart
// Convert text to Morse code
String morse = "HELLO WORLD".toMorseCode();
print(morse); // ".... . .-.. .-.. --- / .-- --- .-. .-.. -.."

// Convert Morse code back to text
String text = "... --- ...".fromMorseCode();
print(text); // "SOS"

// Validate Morse input
bool isValid = "... --- ...".isValidMorseSequence();
print(isValid); // true

// Check if string contains only Morse characters
bool isMorseInput = "... abc".isValidMorseInput();
print(isMorseInput); // false
```

## Configuration

### Timing Configuration

Customize the input timeout:

```dart
MorseTapDetector(
  expectedMorseCode: "... --- ...",
  inputTimeout: Duration(seconds: 5),  // Time allowed for next input
  onCorrectSequence: () => print("Correct!"),
  child: MyButton(),
)
```

Note: The timeout resets after each input, allowing users to take their time
with long sequences as long as they keep entering characters.

### Haptic Feedback

Provide tactile feedback for gestures:

```dart
MorseTapDetector(
  expectedMorseCode: "... --- ...",
  hapticConfig: HapticConfig.defaultConfig,  // Enable haptic feedback
  onCorrectSequence: () => print("Correct!"),
  child: MyButton(),
)
```

**Preset configurations:**
```dart
// Different preset options
HapticConfig.disabled       // No haptic feedback
HapticConfig.light          // Subtle feedback
HapticConfig.defaultConfig  // Moderate feedback  
HapticConfig.strong         // Intense feedback

// Custom configuration
HapticConfig(
  enabled: true,
  dotIntensity: HapticFeedbackType.lightImpact,
  dashIntensity: HapticFeedbackType.mediumImpact,
  correctSequenceIntensity: HapticFeedbackType.heavyImpact,
)
```

### Visual Feedback

Control visual feedback options:

```dart
MorseTextInput(
  controller: controller,
  showMorsePreview: true,              // Show Morse preview
  feedbackColor: Colors.green,         // Tap feedback color
  tapAreaHeight: 150.0,               // Height of tap area
  autoConvertToText: false,           // Keep as Morse code
)
```

## Supported Characters

The package supports:
- **Letters**: A-Z (26 letters)
- **Numbers**: 0-9 (10 digits)  
- **Punctuation**: . , ? ' ! / ( ) & : ; = + - _ " $ @

*See the complete mapping in `MorseCodec` class documentation.*

## Advanced Usage

### Custom Morse Patterns

Create custom pattern detection:

```dart
final customPattern = "HELP".toMorseCode();

MorseTapDetector(
  expectedMorseCode: customPattern,
  onCorrectSequence: () => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Help Requested!"),
      content: Text("Someone needs assistance."),
    ),
  ),
  child: EmergencyButton(),
)
```

<!-- BEGIN:contributing — auto-generated, do not edit. Run `melos sync:readme` to update -->
## Contributing

We welcome contributions in various forms:

- Proposing new features or enhancements.
- Reporting and fixing bugs.
- Engaging in discussions to help make decisions.
- Improving documentation, as it is essential.
- Sending Pull Requests is greatly appreciated!

A big thank you to all our contributors! 🙌
<!-- END:contributing -->

<!-- BEGIN:connect — auto-generated, do not edit. Run `melos sync:readme` to update -->
## 🔗 Connect with NonStop

<p align="center">
  <a href="https://www.linkedin.com/company/nonstopio"><img src="https://img.shields.io/badge/-LinkedIn-blue?style=flat-square&logo=Linkedin&logoColor=white" alt="LinkedIn"></a>
  <a href="https://x.com/nonstopio"><img src="https://img.shields.io/badge/-X.com-000000?style=flat-square&logo=X&logoColor=white" alt="X.com"></a>
  <a href="https://www.instagram.com/nonstopio/"><img src="https://img.shields.io/badge/-Instagram-E4405F?style=flat-square&logo=Instagram&logoColor=white" alt="Instagram"></a>
  <a href="https://www.youtube.com/@nonstopio"><img src="https://img.shields.io/badge/-YouTube-FF0000?style=flat-square&logo=YouTube&logoColor=white" alt="YouTube"></a>
  <a href="mailto:hello@nonstopio.com"><img src="https://img.shields.io/badge/-Email-D14836?style=flat-square&logo=Gmail&logoColor=white" alt="Email"></a>
</p>
<!-- END:connect -->

<!-- BEGIN:star-footer — auto-generated, do not edit. Run `melos sync:readme` to update -->
<div align="center">

>  ⭐ Star us on [GitHub](https://github.com/nonstopio/flutter_forge) if this helped you!

</div>
<!-- END:star-footer -->

<!-- BEGIN:license — auto-generated, do not edit. Run `melos sync:readme` to update -->
## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
<!-- END:license -->

<!-- BEGIN:founded-by — auto-generated, do not edit. Run `melos sync:readme` to update -->
<div align="center">

> 🎉 [Founded by Ajay Kumar](https://github.com/ProjectAJ14) 🎉**

</div>
<!-- END:founded-by -->
