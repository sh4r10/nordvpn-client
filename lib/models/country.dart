import 'package:nordvpn_client/utils.dart';

class Country {
  late final String name;
  late final String flag;

  Country(String givenName) {
    name = givenName;
    flag = 'assets/flags/${name != '' ? underscore(name.toLowerCase()) : 'default'}.svg';
  }

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(json['name']);
  }
}

List<Country> createCountryModels(List<String> countries) {
  List<Country> countryModels = [];
  for (String country in countries) {
    if (country != '') {
      countryModels.add(Country(country));
    }
  }
  return countryModels;
}
