// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:ns_intl_phone_input/ns_intl_phone_input.dart';

void main() {
  runApp(
    const MaterialApp(
      home: SampleScreen(),
    ),
  );
}

class SampleScreen extends StatefulWidget {
  const SampleScreen({super.key});

  @override
  State<SampleScreen> createState() => _SampleScreenState();
}

class _SampleScreenState extends State<SampleScreen> {
  // Initialize the controller for Intl Text editing
  final _phoneNumberController = IntlTextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('NsIntlPhoneInput Example',
              style: Theme.of(context).textTheme.titleLarge),
        ),
        body: Center(
          child: NsIntlPhoneInput(
            textEditingController: _phoneNumberController,
            enableValidation: false,
            onPhoneChange: (countrySelection) {
              print(countrySelection);
            },
          ),
        ));
  }
}
