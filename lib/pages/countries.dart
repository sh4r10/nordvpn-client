import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nordvpn_client/models/country.dart';

class CountriesPage extends StatelessWidget {
  final List<Country> countries;
  const CountriesPage({super.key, required this.countries});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countries', style: TextStyle(fontSize: 16)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context, ''),
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: const Color(0xff3E5FFF),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: countries.length,
          itemBuilder: (context, index) => Container(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: ListTile(
              onTap: () => Navigator.pop(context, countries[index].name),
              title: Row(
                children: [
                  SvgPicture.asset(
                    countries[index].flag,
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(countries[index].name,
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
