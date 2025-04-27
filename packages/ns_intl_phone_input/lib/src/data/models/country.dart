import 'package:equatable/equatable.dart';

class CountryModel extends Equatable {
  ///for ex. India/
  final String countryName;

  ///for ex. [Asia]/
  final Set<String> regions;

  ///for ex. in/
  final String iso2Code;

  final String flag;

  ///for ex. 91/
  final String intlDialCode;

  ///for ex. '.....-.....'/
  final String? format;

  ///if >1 country with same dial code
  final int? orderPriority;

  ///if >1 country with same dial code
  final Set<String>? areaCodes;

  final String currentAreaCode;

  String get dialCode =>
      '$intlDialCode${currentAreaCode.isNotEmpty ? ' ($currentAreaCode)' : ''}';

  bool isContain(String value) {
    return countryName.toLowerCase().contains(value.toLowerCase()) ||
        intlDialCode.contains(value) ||
        currentAreaCode.contains(value) ||
        iso2Code.toLowerCase().contains(value.toLowerCase());
  }

  const CountryModel({
    required this.countryName,
    required this.regions,
    required this.iso2Code,
    required this.intlDialCode,
    this.flag = '🏳️',
    this.format = '... ... ... ...',
    this.orderPriority,
    this.areaCodes,
    this.currentAreaCode = '',
  });

  CountryModel copyWith({
    String? countryName,
    Set<String>? regions,
    String? iso2Code,
    String? flag,
    String? intlDialCode,
    String? format,
    int? orderPriority,
    Set<String>? areaCodes,
    String? currentAreaCode,
  }) {
    return CountryModel(
      countryName: countryName ?? this.countryName,
      regions: regions ?? this.regions,
      iso2Code: iso2Code ?? this.iso2Code,
      flag: flag ?? this.flag,
      intlDialCode: intlDialCode ?? this.intlDialCode,
      format: format ?? this.format,
      orderPriority: orderPriority ?? this.orderPriority,
      areaCodes: areaCodes ?? this.areaCodes,
      currentAreaCode: currentAreaCode ?? this.currentAreaCode,
    );
  }

  @override
  String toString() {
    return '''CountryModel(
      countryName: $countryName, 
      regions: $regions, 
      iso2Code: $iso2Code, 
      flag: $flag, 
      intlDialCode: $intlDialCode, 
      format: $format, 
      orderPriority: $orderPriority, 
      areaCodes: $areaCodes, 
      currentAreaCode: $currentAreaCode
      )''';
  }

  @override
  List<Object?> get props => [
        countryName,
        regions,
        iso2Code,
        flag,
        intlDialCode,
        format,
        orderPriority,
        areaCodes,
        currentAreaCode,
      ];
}
