import 'package:flutter/material.dart';

import '../data/models/country.dart';
import 'country_selection_widget.dart';

class CountrySelectScreen extends StatelessWidget {
  const CountrySelectScreen({
    super.key,
    required this.onCountrySelected,
  });

  final Function(CountryModel) onCountrySelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Country'),
      ),
      body: CountrySelectionWidget(
        onCountrySelected: (country) {
          onCountrySelected(country);
          Navigator.of(context).pop(country);
        },
      ),
    );
  }
}
