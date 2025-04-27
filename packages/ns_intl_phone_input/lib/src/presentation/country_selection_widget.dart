import 'package:flutter/material.dart';

import '../data/models/country.dart';
import 'helper/ns_intl_helper.dart';
import 'widgets/country_dropdown_widget.dart';

class CountrySelectionWidget extends StatefulWidget {
  const CountrySelectionWidget({
    super.key,
    required this.onCountrySelected,
  });

  final Function(CountryModel) onCountrySelected;

  @override
  State<CountrySelectionWidget> createState() => _CountrySelectionWidgetState();
}

class _CountrySelectionWidgetState extends State<CountrySelectionWidget> {
  final _countriesLookupMap = NSIntlPhoneHelper.getAllCountriesMap();

  late final List<CountryModel> countries;

  List<CountryModel> filteredCountries = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    countries = _countriesLookupMap.entries
        .map((e) => e.value)
        .toList()
        .cast<CountryModel>();

    filteredCountries = countries;
  }

  void filterCountries() {
    List<CountryModel> tempCountries = [];
    tempCountries.addAll(countries);
    if (searchController.text.isNotEmpty) {
      tempCountries
          .retainWhere((country) => country.isContain(searchController.text));
    }
    setState(() {
      filteredCountries = tempCountries;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            key: const Key('ns_country_search_field'),
            controller: searchController,
            onChanged: (value) {
              filterCountries();
            },
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Search',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredCountries.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: CountryDropDownWidget(
                  country: filteredCountries[index],
                ),
                onTap: () {
                  widget.onCountrySelected(filteredCountries[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
