import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nordvpn_client/utils.dart';

class LocationService {
 
  static Future<(String, String)> getRecommendedConnection() async {
    Uri url = Uri.parse(
        'https://nordvpn.com/wp-admin/admin-ajax.php?action=servers_recommendations');
    var response = await http.get(url);
    var decoded = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    String country = decoded[0]['locations'][0]['country']['name'];
    String city = decoded[0]['locations'][0]['country']['city']['name'];
    country = space(country);
    city = space(city);
    return (country, city);
  }

  static Future<(double, double)> getCityCoords(String city, String country) async {
    city = space(city);
    country = space(country);
    Uri url = Uri.parse('https://geocode.maps.co/search?q=$city,$country');
    var response = await http.get(url);
    var decoded = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    double lat = double.parse(decoded[0]['lat']);
    double lon = double.parse(decoded[0]['lon']);
    return (lat,lon);
  }

}
