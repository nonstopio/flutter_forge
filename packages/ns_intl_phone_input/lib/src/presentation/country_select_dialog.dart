import 'package:flutter/material.dart';

import '../data/models/country.dart';
import 'country_selection_widget.dart';

void countrySelectDialog(
  BuildContext context, {
  required Function(CountryModel) onCountrySelected,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: CountrySelectionDialogWidget(
          onCountrySelected: onCountrySelected,
        ),
      );
    },
  );
}

class CountrySelectionDialogWidget extends StatelessWidget {
  const CountrySelectionDialogWidget({
    super.key,
    required this.onCountrySelected,
  });

  final Function(CountryModel) onCountrySelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select Country',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Flexible(
            child: CountrySelectionWidget(
              onCountrySelected: (country) {
                onCountrySelected(country);
                Navigator.of(context).pop(country);
              },
            ),
          ),
        ],
      ),
    );
  }
}
