import 'package:flutter/material.dart';
import 'package:ns_intl_phone_input/ns_intl_phone_input.dart';

const samplePhoneNumber = '9876543210';
const sampleCountryCode = '91';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CountrySelection countrySelection = CountrySelection(
    selectedCountry: const CountryModel(
      countryName: 'India',
      regions: {'Asia'},
      iso2Code: 'IN',
      flag: '🇮🇳',
      intlDialCode: '+91',
      format: '...-..-....',
      orderPriority: 0,
      areaCodes: {'91'},
      currentAreaCode: '',
    ),
    formattedPhoneNumber: '',
    unformattedPhoneNumber: '',
  );

  final _formKey = GlobalKey<FormState>();

  final _phoneNumberController = IntlTextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NsIntlPhoneInput Example',
            style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
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
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Validated')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Not Validated')),
                          );
                        }
                      },
                      child: const Text('Submit'),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () {
                        _phoneNumberController.clear();
                      },
                      child: const Text('Clear'),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () {
                        _phoneNumberController.initialPhone(
                          phoneNumber: samplePhoneNumber,
                          intlDialCode: sampleCountryCode,
                        );
                      },
                      child: const Text('Set Sample Phone Number'),
                    ),
                    Text(
                      'Selected Country: $countrySelection',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
