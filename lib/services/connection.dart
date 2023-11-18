import 'dart:io';
import 'package:nordvpn_client/utils.dart';

class ConnectionService {
  static Future<bool> quickConnect() async {
    ProcessResult result = await Process.run('nordvpn', ['connect']);
    return result.exitCode == 0;
  }

  static Future<bool> disconnect() async {
    ProcessResult result = await Process.run('nordvpn', ['disconnect']);
    return result.exitCode == 0;
  }

  static Future<Map<String, String>> getConnectionInfo() async {
    List<String> valuesToExtract = [
      'status',
      'hostname',
      'ip',
      'country',
      'city',
      'technology',
      'protocol',
      'transfer',
      'uptime'
    ];
    Map<String, String> info = {};
    ProcessResult result = await Process.run(
        'bash', ['-c', "nordvpn status | awk -F': ' '{print \$2}'"]);
    String data = result.stdout.trim();
    List<String> extractedData = data.split('\n');
    for (var i = 0; i < valuesToExtract.length; i++) {
      if (info['status'] != 'Disconnected') {
        var split = extractedData[i].toLowerCase().split('');
        split[0] = split[0].toUpperCase();
        info[valuesToExtract[i]] = split.join('');
      }
    }
    return info;
  }

  static Future<bool> connectToCountry(String country) async {
    country = underscore(country);
    ProcessResult result = await Process.run('nordvpn', ['connect', country]);
    return result.exitCode == 0;
  }

  static Future<bool> connect(String country, String city) async {
    country = underscore(country);
    city = underscore(city);
    ProcessResult result =
        await Process.run('nordvpn', ['connect', country, city]);
    return result.exitCode == 0;
  }

  static Future<List<String>> getCountries() async {
    ProcessResult result = await Process.run('nordvpn', ['countries']);
    String input =
        result.stdout.toString().replaceAll(RegExp(r'[^\w_,\\n\s]'), '');
    String processed = input.split('\n').length > 1
        ? input.split('\n')[1].trim()
        : input.trim();
    List<String> countries = processed.split(', ');
    return capitalize(countries);
  }

  static Future<List<String>> getCities(String country) async {
    country = underscore(country);
    ProcessResult result = await Process.run('nordvpn', ['cities', country]);
    String input =
        result.stdout.toString().replaceAll(RegExp(r'[^\w_,\\n\s]'), '');
    String processed = input.split('\n').length > 1
        ? input.split('\n')[1].trim()
        : input.trim();
    List<String> cities = processed.split(', ');
    return capitalize(cities);
  }
}

// utility functions
