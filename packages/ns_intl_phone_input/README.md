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

# Flutter Phone Validation Package by Nonstop IO

<!-- BEGIN:badges -->
<p align="center">
<a href="https://pub.dev/packages/ns_intl_phone_input"><img src="https://img.shields.io/pub/v/ns_intl_phone_input.svg" alt="Pub"></a>
<a href="https://codecov.io/gh/Rajan-Metaliya/ns_intl_phone_input" >
 <img src="https://codecov.io/gh/Rajan-Metaliya/ns_intl_phone_input/graph/badge.svg?token=COLM0SJLJA"  alt="codecov"/>
 </a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<!-- END:badges -->


The Flutter Phone Validation Package by Nonstop IO is a versatile and easy-to-use Flutter package designed to validate phone numbers from more than 200 countries. With this package, users can seamlessly integrate phone number validation into their Flutter applications, enhancing user experience and ensuring data integrity.

## Screenshots

- Widget with Country Code and Phone Number Field:
  <br><img width="417" alt="Screenshot 2023-12-20 at 4 47 30 PM" src="https://github.com/rajan-nonstopio/ns_intl_phone_input/assets/132648639/b3b827c1-c9b9-4773-980d-8e4a3618372c">


- Drop Down Menu Options for Country code list:
  <br><img width="901" alt="Screenshot 2023-12-20 at 3 04 24 PM" src="https://github.com/rajan-nonstopio/ns_intl_phone_input/assets/132648639/8fb0f20c-e815-4c8d-9b6d-3d182222884a">

- Widget with Country Code , Phone Number Field & Area code format:
  <br><img width="425" alt="Screenshot 2023-12-20 at 3 05 32 PM" src="https://github.com/rajan-nonstopio/ns_intl_phone_input/assets/132648639/e9032139-4bad-4428-a589-61090aa7db52">

## Features

- **Country Selection Dropdown:** Users can choose the desired country code from a dropdown menu, making it easy to validate phone numbers for different regions.

- **Comprehensive Validation:** The package supports validation for phone numbers from over 200 countries, ensuring accuracy and inclusively.

- **Various Number Formats:** Users can input phone numbers in different formats, and the package adapts to validate them accordingly. This includes support for various masks and formats.

- **Support for area codes of country:** The package provides support for area codes within countries. Users can input phone numbers with area codes, and the package takes this into consideration during validation. This feature enhances the package's flexibility and applicability to regions where area codes are an integral part of phone numbers.

<!-- BEGIN:getting-started -->
## Getting Started

1. Open your project's `pubspec.yaml` file.
2. Add the `ns_intl_phone_input` package to your dependencies, replacing `[version]` with the latest version:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     ns_intl_phone_input: ^[version]
   ```
3. Run `flutter pub get` to fetch the package.
<!-- END:getting-started -->

<!-- BEGIN:import-package -->
## Import the Package

```dart
import 'package:ns_intl_phone_input/ns_intl_phone_input.dart';
```
<!-- END:import-package -->

4. Implement the `NsIntlPhoneInput` widget in your UI, providing the necessary callbacks and customization options.

   ```dart
   NsIntlPhoneInput(
        textEditingController: _phoneNumberController,
        enableValidation: false,
        onPhoneChange: (countrySelection) {
                        setState(() {
                          this.countrySelection = countrySelection;
                        });
                      },
     // Other customization options...
   ),
   ```

## Usage

### Country Selection

The package provides a user-friendly country selection dropdown, allowing users to choose the relevant country code for phone number validation.

```dart
class SampleScreen extends StatefulWidget {
  const SampleScreen({super.key});

  @override
  State<SampleScreen> createState() => _SampleScreenState();
}

class _SampleScreenState extends State<SampleScreen> {
  /// Initialize the controller for Intl Text editing
  final _phoneNumberController = IntlTextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('NsIntlPhoneInput Example',
              style: Theme.of(context).textTheme.titleLarge),
        ),
        body: Center(
          /// Assign it to NsIntlPhoneInput widget
          child: NsIntlPhoneInput(
            textEditingController: _phoneNumberController,
            onPhoneChange: (countrySelection) {
              debugPrint(countrySelection);
            },
          ),
        ));
  }
}

```

#### Initialize Phone

```dart
    _phoneNumberController.initialPhone(
      phoneNumber: '9876543210',
      intlDialCode: '91',
    );
```

#### Clear Phone Number with country code
```dart
   _phoneNumberController.clear();
```

### Phone Number Validation

Validate phone numbers easily with the `onPhoneChange` callback. The package supports various phone number formats.

```dart
MaterialButton(
  onPressed: () {
    if (_formKey.currentState!.validate()) {
      print('Valid Phone number');
    } else {
      print('Invalid Phone Number');
    }
  },
  child: const Text('Submit'),
),
```



### Customization

Customize the package to suit your application's needs with various options like initial country code, formatting, and more.

```dart
NsIntlPhoneInput(
      /// Phone number controller
      textEditingController: _phoneNumberController,

      /// Enable or disable validation
      enableValidation: false,
      autovalidateMode: AutovalidateMode.always,

      /// Country selection options for UI experience
      countrySelectOption: const CountrySelectOption(
        countryDialCodeTextStyle: TextStyle(),
        countryIsoCodeTextStyle: TextStyle(),
        defaultText: "000",
        defaultTextStyle: TextStyle(),
        showCode: false,
      ),

      /// Optional to select country selection as dialog or new screen
      countrySelectionType: CountrySelectionTypeEnum.screen,
      focusNode: FocusNode(),
      phoneFieldDecoration: const InputDecoration(),
      phoneInputFontSize: 20,
      validationErrorText: "Validation Message",
      onPhoneChange: (countrySelection) {
        setState(() {
          this.countrySelection = countrySelection;
        });
      },
  ),
```

## Example

For a quick start, check out the provided example in the `lib/home` folder with `home_screen.dart` file. It demonstrates the integration of the Flutter Phone Validation Package into a sample Flutter application.

## Support and Contributions

If you encounter any issues or have suggestions for improvement, feel free to open an issue on the [GitHub repository](https://github.com/Rajan-Metaliya/ns_intl_phone_input/issues). Contributions are welcome!
There are couple of ways in which you can contribute.

- Propose any feature, enhancement
- Report a bug
- Fix a bug
- Participate in a discussion and help in decision making
- Write and improve some documentation. Documentation is super critical and its importance cannot be overstated!
- Send in a Pull Request :-)

Thank you for choosing the Flutter Phone Validation Package by Nonstop IO. Happy coding!

---

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

> 🎉 [Founded by Rajan Metaliya](https://github.com/rajan-nonstopio) 🎉**

</div>
<!-- END:founded-by -->
