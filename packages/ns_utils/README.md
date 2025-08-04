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

# ns_utils - Flutter Utility Library

[![Build Status](https://img.shields.io/pub/v/ns_utils.svg)](https://github.com/nonstopio/flutter_forge/tree/main/packages/ns_utils)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Introduction

ns_utils is a powerful Flutter utility library that simplifies and enhances your Flutter app development experience. It provides a collection of methods and extensions to streamline your code, making it more readable and efficient. Whether you need responsive design, date and time handling, map operations, string manipulation, or widget customization, ns_utils has got you covered.

## Getting Started

1. Open your project's `pubspec.yaml` file.
2. Add ns_utils as a dependency and replace `[version]` with the latest version:

```yaml
dependencies:
  flutter:
    sdk: flutter
  ns_utils: ^[version]
```

3. Run `flutter pub get` to fetch the package.

## Import the Package

```dart
import 'package:ns_utils/src.dart';
```

## What's Inside

ns_utils offers a wide range of features to simplify your Flutter development process:

### CustomErrorWidget

![Demo](https://miro.medium.com/max/1000/1*KcW6GbjeMUO2zeiGV7KRzQ.png)

Learn more about it in the article [Flutter -: KILL THE RED SCREEN OF DEATH](https://medium.com/nonstopio/flutter-kill-the-red-screen-of-death-f5e0601d1cdc).

### Sizes

![Demo](https://miro.medium.com/max/2160/1*zNcRtlhzm9407KJWtAFnFw.png)

Read about responsive app design in Flutter in [Responsive App in Flutter](https://medium.com/nonstopio/let-make-responsive-app-in-flutter-e48428795476).

### BuildContext Extensions

Simplify your code by using these extensions:

- Replace lengthy `Navigator.of(context).push(...)` with `context.push(...)`.
- More intuitive methods like `context.replace(...)`, `context.makeFirst(...)`, and `context.pop(...)` are available.
- Easily access device dimensions with `context.mq.sizeX.width` and `context.mq.sizeX.height`.
- Simplify focus management with `context.setFocus(focusNode: focusNode)`.

### DateTime Extensions

Enhance date and time handling with extensions like:

- `dayDifference`: Get the difference in days between a date and the current date.
- `toServerFormat()`: Get an ISO-8601 formatted date string.
- `isToday`, `isYesterday`, `isTomorrow`: Check if a date is today, yesterday, or tomorrow.
- `tomorrow()` and `yesterday()`: Get the next day or previous day.

### Map Extensions

Streamline operations on Map objects:

- Use methods like `getBool('key')`, `getInt('key')`, `getDouble('key')`, `getString('key')`, `getList('key')`, and `getMap('key')` to retrieve values with optional default values.
- Convert a Map to a JSON string using `toJson()`.
- Beautify Map output with `toPretty()`.

### List Extensions

Manipulate lists easily with `toJson()`, which converts a list to a JSON string.

### String Extensions

Simplify string operations:

- `toMap()`: Parse a JSON string into a Map.
- `toList()`: Parse a JSON string into a List.
- `isEmptyOrNull`: Check if a string is null or empty.
- `isNotBlank`: Check if a string is not null, not empty, and not just whitespace.
- `toINT` and `toDOUBLE`: Parse a string as an int or double.
- `asBool`: Convert a string into a boolean.

### double/int Extensions

Enhance numeric operations with extensions like:

- `asBool`: Convert an integer into a boolean.
- Fractional operations: `tenth`, `fourth`, `third`, `half`, `doubled`, `tripled`.

### Widget Extensions & Spacers

Customize widgets with ease:

- Add tooltips and gestures to widgets without complex nesting.
- Utilize widgets like `Container` and `SizedBox` with simplified notation.
- Expect even more widget enhancements in future updates.

## Contributing

We welcome contributions in various forms:

- Proposing new features or enhancements.
- Reporting and fixing bugs.
- Engaging in discussions to help make decisions.
- Improving documentation, as it is essential.
- Sending Pull Requests is greatly appreciated!

A big thank you to all our contributors! 🙌

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
