<!-- BEGIN:nonstop-header -->
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

# contact_permission

<!-- BEGIN:badges -->
[![Build Status](https://img.shields.io/pub/v/contact_permission.svg)](https://github.com/nonstopio/flutter_forge/tree/main/plugins/contact_permission)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
<!-- END:badges -->


A plugin for Flutter that requests and verifies contact permissions.

> Why this package?
> 
> Integrating Flutter Frameworks into the Android and iOS "add-to-app" 
> scenario can pose its own set of challenges. In one instance, when 
> attempting to integrate the permission_handler, we mistakenly added 
> `GCC_PREPROCESSOR_DEFINITIONS` flags to the root project instead of 
> within the module package. After numerous hours of researching the 
> issue, it became evident that this approach was not effective. 
> As a result, we had to relocate the flags to the Flutter Module 
> Podfile, which should not have been committed in the first place. 
> However, even after this adjustment, we discovered that the 
> Android permission was still not functioning correctly 
> on many devices. 
>This predicament led to the development of this package.

<!-- BEGIN:getting-started -->
## Getting Started

1. Open your project's `pubspec.yaml` file.
2. Add the `contact_permission` package to your dependencies, replacing `[version]` with the latest version:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     contact_permission: ^[version]
   ```
3. Run `flutter pub get` to fetch the package.
<!-- END:getting-started -->

<!-- BEGIN:import-package -->
## Import the Package

```dart
import 'package:contact_permission/contact_permission.dart';
```
<!-- END:import-package -->

## Check if permission is granted or not

```dart
...

 onTap: () async {
        if (await ContactPermission.isPermissionGranted) {
          showSnackBar(
            _scaffoldKey,
            title: "Contact Permission Granted",
            color: Colors.green,
          );
        } else {
          showSnackBar(
            _scaffoldKey,
            title: "Contact Permission Not Granted",
          );
        }
      },

...

```

## Request permission

```dart
...

 onTap: () async {
        if (await ContactPermission.requestPermission) {
          showSnackBar(
            _scaffoldKey,
            title: "Contact Permission Granted",
            color: Colors.green,
          );
        } else {
          showSnackBar(
            _scaffoldKey,
            title: "Contact Permission Not Granted",
          );
        }
      },
```      



<!-- BEGIN:contributing -->
## Contributing

We welcome contributions in various forms:

- Proposing new features or enhancements.
- Reporting and fixing bugs.
- Engaging in discussions to help make decisions.
- Improving documentation, as it is essential.
- Sending Pull Requests is greatly appreciated!

A big thank you to all our contributors! 🙌
<!-- END:contributing -->

<!-- BEGIN:connect -->
## 🔗 Connect with NonStop

<p align="center">
  <a href="https://www.linkedin.com/company/nonstopio"><img src="https://img.shields.io/badge/-LinkedIn-blue?style=flat-square&logo=Linkedin&logoColor=white" alt="LinkedIn"></a>
  <a href="https://x.com/nonstopio"><img src="https://img.shields.io/badge/-X.com-000000?style=flat-square&logo=X&logoColor=white" alt="X.com"></a>
  <a href="https://www.instagram.com/nonstopio/"><img src="https://img.shields.io/badge/-Instagram-E4405F?style=flat-square&logo=Instagram&logoColor=white" alt="Instagram"></a>
  <a href="https://www.youtube.com/@nonstopio"><img src="https://img.shields.io/badge/-YouTube-FF0000?style=flat-square&logo=YouTube&logoColor=white" alt="YouTube"></a>
  <a href="mailto:hello@nonstopio.com"><img src="https://img.shields.io/badge/-Email-D14836?style=flat-square&logo=Gmail&logoColor=white" alt="Email"></a>
</p>
<!-- END:connect -->

<!-- BEGIN:star-footer -->
<div align="center">

>  ⭐ Star us on [GitHub](https://github.com/nonstopio/flutter_forge) if this helped you!

</div>
<!-- END:star-footer -->

<!-- BEGIN:license -->
## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
<!-- END:license -->

<!-- BEGIN:founded-by -->
<div align="center">

> 🎉 [Founded by Ajay Kumar](https://github.com/ProjectAJ14) 🎉**

</div>
<!-- END:founded-by -->
