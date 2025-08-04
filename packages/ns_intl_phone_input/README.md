<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# Flutter Phone Validation Package by Nonstop IO

<p align="center">
<a href="https://pub.dev/packages/ns_intl_phone_input"><img src="https://img.shields.io/pub/v/ns_intl_phone_input.svg" alt="Pub"></a>
<a href="https://codecov.io/gh/Rajan-Metaliya/ns_intl_phone_input" > 
 <img src="https://codecov.io/gh/Rajan-Metaliya/ns_intl_phone_input/graph/badge.svg?token=COLM0SJLJA"  alt="codecov"/> 
 </a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>


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

## Getting Started

To use the Flutter Phone Validation Package in your project, follow these simple steps:

1. Add the package to your `pubspec.yaml` file:

   ```yaml
   dependencies:
     ns_intl_phone_input: ^1.0.0
   ```

2. Install the package by running:

   ```bash
   flutter pub get
   ```

3. Import the package in your Dart file:

   ```dart
   import 'package:ns_intl_phone_input/ns_intl_phone_input.dart';
   ```

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

> 🎉 [Founded by Rajan Metaliya](https://github.com/rajan-nonstopio) 🎉**

</div>
