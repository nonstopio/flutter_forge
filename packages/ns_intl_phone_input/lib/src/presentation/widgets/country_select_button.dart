import 'package:flutter/material.dart';

import '../../data/models/country.dart';
import '../../data/models/country_select_button_options.dart';
import 'font_text_widget.dart';

class CountrySelectButton extends StatelessWidget {
  const CountrySelectButton({
    super.key,
    required this.onPressed,
    required this.selectedCountry,
    required this.options,
  });

  final void Function()? onPressed;
  final CountryModel? selectedCountry;
  final CountrySelectOption options;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      onPressed: onPressed,
      child: (selectedCountry == null)
          ? Text(
              options.defaultText,
              style: options.defaultTextStyle,
            )
          : Row(
              children: [
                FontTextWidget(text: selectedCountry?.flag ?? ''),
                const SizedBox(width: 10),
                if (options.showCode) ...[
                  Text(
                    selectedCountry?.iso2Code.toUpperCase() ?? '',
                    style: options.countryIsoCodeTextStyle,
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  '+${selectedCountry?.intlDialCode}',
                  style: options.countryDialCodeTextStyle,
                ),
              ],
            ),
    );
  }
}
