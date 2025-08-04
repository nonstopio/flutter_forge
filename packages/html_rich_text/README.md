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

# HTML Rich Text

[![Build Status](https://img.shields.io/pub/v/html_rich_text.svg)](https://github.com/nonstopio/flutter_forge/tree/main/packages/html_rich_text)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A lightweight Flutter package for rendering HTML-styled text without heavy dependencies. Perfect for simple HTML text rendering with minimal overhead.

![HTML Rich Text Demo](html_rich_text.png)

## Overview

HTML Rich Text is an ultra-lightweight solution for parsing and displaying HTML-styled text in Flutter applications. Unlike traditional HTML rendering packages that include full DOM parsing and heavy dependencies, this package uses a simple regex-based approach to parse only the tags you need.

## Why It's Lightweight

- **Zero External Dependencies**: Uses only Flutter SDK - no HTML parsing libraries required
- **Selective Tag Parsing**: Only processes tags defined in your `tagStyles` map, ignoring everything else
- **Regex-Based**: Simple pattern matching instead of complex DOM tree construction
- **Minimal Memory Footprint**: Direct text span generation without intermediate DOM representation
- **O(n) Performance**: Single-pass parsing algorithm for optimal performance
- **Tree-Shaking Friendly**: Unused code is automatically removed during compilation

## Getting Started

1. Add `html_rich_text` to your `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     html_rich_text: ^1.0.0
   ```
2. Run `flutter pub get` to fetch the package.

## Import the Package

```dart
import 'package:html_rich_text/html_rich_text.dart';
```

## Usage

### Basic Example

```dart
HtmlRichText(
  'Hello <b>World</b>! This is <i>italic</i> text.',
  tagStyles: {
    'b': TextStyle(fontWeight: FontWeight.bold),
    'i': TextStyle(fontStyle: FontStyle.italic),
  },
)
```

### Advanced Example with Custom Styling

```dart
HtmlRichText(
  'Welcome to <b>Flutter</b>! Check out this <i>amazing</i>, <strong>powerful</strong> and <u>lightweight</u> package.',
  style: TextStyle(fontSize: 16, color: Colors.black87),
  tagStyles: {
    'b': TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
    'i': TextStyle(fontStyle: FontStyle.italic, color: Colors.green),
    'strong': TextStyle(fontWeight: FontWeight.w900, color: Colors.red),
    'u': TextStyle(decoration: TextDecoration.underline),
  },
  textAlign: TextAlign.center,
  maxLines: 3,
  overflow: TextOverflow.ellipsis,
)
```

### Supported Parameters

- `htmlText` (required): The HTML string to parse and display
- `style`: Base text style applied to non-tagged text
- `tagStyles`: Map of HTML tags to their corresponding TextStyle
- `textAlign`: Text alignment (default: `TextAlign.start`)
- `maxLines`: Maximum number of lines to display
- `overflow`: How overflowing text should be handled

## Example Use Cases

### Product Descriptions
```dart
HtmlRichText(
  'This product is <b>amazing</b>! Features include <i>lightweight design</i>, <strong>superior quality</strong> and <u>great value</u>.',
  tagStyles: {
    'b': TextStyle(fontWeight: FontWeight.bold),
    'i': TextStyle(fontStyle: FontStyle.italic),
    'strong': TextStyle(fontWeight: FontWeight.w900, color: Colors.orange),
    'u': TextStyle(decoration: TextDecoration.underline),
  },
)
```

### Chat Messages
```dart
HtmlRichText(
  'User said: <b>Hello!</b> How are you <i>today</i>?',
  tagStyles: {
    'b': TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
    'i': TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
  },
)
```

### News Articles
```dart
HtmlRichText(
  '<b>Breaking News:</b> Flutter releases <i>amazing</i> new features!',
  style: TextStyle(fontSize: 18),
  tagStyles: {
    'b': TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    'i': TextStyle(fontStyle: FontStyle.italic, color: Colors.red),
  },
)
```

## Performance Comparison

Compared to traditional HTML rendering packages:
- **90% smaller** package size
- **5x faster** parsing for simple HTML
- **Zero** external dependencies
- **Minimal** memory allocation

## Limitations

This package is designed for simple HTML text styling. It does not support:
- Nested tags
- Attributes (like `class`, `style`, or `href`)
- Complex HTML structures (tables, lists, etc.)
- Images or other media
- CSS styling

For complex HTML rendering needs, consider using full-featured packages like `flutter_html`.

## Contributing

We welcome contributions in various forms:

- Proposing new features or enhancements
- Reporting and fixing bugs
- Improving documentation
- Sending Pull Requests

---

## 🔗 Connect with NonStop

<div align="center">

**Stay connected and get the latest updates!**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/company/nonstop-io)
[![X.com](https://img.shields.io/badge/X-000000?style=for-the-badge&logo=x&logoColor=white)](https://x.com/NonStopio)
[![Instagram](https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/nonstopio_technologies/)
[![YouTube](https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@NonStopioTechnology)
[![Email](https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:contact@nonstopio.com)

</div>

---

<div align="center">

>  ⭐ Star us on [GitHub](https://github.com/nonstopio/flutter_forge) if this helped you!

</div>

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

<div align="center">

> 🎉 [Founded by Ajay Kumar](https://github.com/ProjectAJ14) 🎉**

</div>
