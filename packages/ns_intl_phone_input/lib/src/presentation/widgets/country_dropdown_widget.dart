import 'package:flutter/widgets.dart';

import '../../data/models/country.dart';
import 'font_text_widget.dart';

class CountryDropDownWidget extends StatelessWidget {
  const CountryDropDownWidget({
    super.key,
    required this.country,
  });

  final CountryModel country;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            FontTextWidget(text: country.flag),
            const SizedBox(width: 8),
            Text(
              '${country.iso2Code.toUpperCase()} +${country.dialCode}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        Flexible(
          child: Text(
            country.countryName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
