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

# Timer Button

[![Build Status](https://img.shields.io/pub/v/timer_button.svg)](https://github.com/nonstopio/flutter_forge/tree/main/packages/timer_button)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A versatile Flutter package that provides a timer button widget, which becomes enabled after a
specified time delay.

![Timer Button](https://cdn-images-1.medium.com/max/640/1*NhgmN1C4ltcQA-o34SYbIQ.gif)

## Overview

A customizable button widget capable of activation after a designated time interval.

## Getting Started

1. Open your project's `pubspec.yaml` file.
2. Add the `timer_button` package to your dependencies, replacing `[version]` with the latest
   version:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     timer_button: ^[version]
   ```
3. Run `flutter pub get` to fetch the package.

## Import the Package

```dart
import 'package:timer_button/timer_button.dart';
```

## Usage

To use the Timer Button, follow these steps:

1. Set the button type. There are six types to choose from:
    - ElevatedButton (`buttonType: ButtonType.elevatedButton`) - default
    - TextButton (`buttonType: ButtonType.textButton`)
    - OutlineButton (`buttonType: ButtonType.outlineButton`)
    - Custom (`buttonType: ButtonType.custom`)
2. Specify the button label using `label: "Your Label"`.
3. Set the timeout duration in seconds with `timeOutInSeconds: 20`.
4. Customize the button's color using `color: Colors.deepPurple`.
5. Define the disabled color with `disabledColor: Colors.red`.

## Example

Default Timer Button:

```dart
                TimerButton(
                  label: "Try Again",
                  timeOutInSeconds: 5,
                  onPressed: () {
                    log("Time for some action!");
                  },
                ),
```

With `TimerButton.builder`: You can customize the button's appearance by passing a `builder`
function:

```dart
                TimerButton.builder(
                  builder: (context, timeLeft) {
                    return Text(
                      "Custom: $timeLeft",
                      style: const TextStyle(color: Colors.red),
                    );
                  },
                  onPressed: () {
                    log("Time for some action!");
                  },
                  timeOutInSeconds: 5,
                ),
```

## Contributing

We welcome contributions in various forms:

- Proposing new features or enhancements.
- Reporting and fixing bugs.
- Engaging in discussions to help make decisions.
- Improving documentation, as it is essential.
- Sending Pull Requests is greatly appreciated!

A big thank you to all our contributors! 🙌

<br></br>
<div align="center">
  <a href="https://github.com/nonstopio/flutter_forge/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=nonstopio/flutter_forge"  alt="contributors"/>
  </a>
</div>
