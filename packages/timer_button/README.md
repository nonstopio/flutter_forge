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

# Timer Button

<!-- BEGIN:badges — auto-generated, do not edit. Run `melos sync:readme` to update -->
[![Build Status](https://img.shields.io/pub/v/timer_button.svg)](https://github.com/nonstopio/flutter_forge/tree/main/packages/timer_button)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
<!-- END:badges -->

A versatile Flutter package that provides a timer button widget, which becomes enabled after a
specified time delay.

![Timer Button](https://cdn-images-1.medium.com/max/640/1*NhgmN1C4ltcQA-o34SYbIQ.gif)

## Overview

A customizable button widget capable of activation after a designated time interval.

<!-- BEGIN:getting-started — auto-generated, do not edit. Run `melos sync:readme` to update -->
## Getting Started

1. Open your project's `pubspec.yaml` file.
2. Add the `timer_button` package to your dependencies, replacing `[version]` with the latest version:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     timer_button: ^[version]
   ```
3. Run `flutter pub get` to fetch the package.
<!-- END:getting-started -->

<!-- BEGIN:import-package — auto-generated, do not edit. Run `melos sync:readme` to update -->
## Import the Package

```dart
import 'package:timer_button/timer_button.dart';
```
<!-- END:import-package -->

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

---

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

---

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

---

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
