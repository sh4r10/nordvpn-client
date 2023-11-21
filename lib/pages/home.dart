import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:nordvpn_client/models/country.dart';
import 'package:nordvpn_client/pages/countries.dart';
import 'package:nordvpn_client/services/connection.dart';
import 'package:nordvpn_client/services/location.dart';
import 'package:nordvpn_client/services/settings.dart';
import 'package:nordvpn_client/services/storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isConnected = false;
  Country selectedCountry = Country('');
  String selectedCity = '';
  List<Country> countries = [];
  List<String> cities = [];
  String mapAPIKey = '';

  Map<String, String> connectionInfo = {};
  (double, double) coordinates = (0.0, 0.0);
  final MapController mapController = MapController();

  void updateConnection() {
    ConnectionService.getConnectionInfo().then((value) {
      setState(() {
        connectionInfo = value;
        isConnected = value['status'] == 'Connected';
        Country temp = Country(value['country'] ?? selectedCountry.name);
        selectedCountry = temp;
        getCities(temp.name);
      });
    });
  }

  Future<bool> getRecommendations() async {
    bool showRecommendations = await SettingsService.getRecommendationSetting();
    if (showRecommendations) {
      (String, String) recommendations =
          await LocationService.getRecommendedConnection();
      setState(() {
        getCities(recommendations.$1);
        selectedCountry = Country(recommendations.$1);
        selectedCity = recommendations.$2;
      });
      return true;
    }
    return false;
  }

  void getCities(String? country) {
    setState(() {
      String newCountry = country ?? selectedCountry.name;
      selectedCountry = Country(newCountry);
      ConnectionService.getCities(newCountry).then((value) {
        setState(() {
          cities = value;
          selectedCity = connectionInfo['country'] != newCountry
              ? cities[0]
              : connectionInfo['city'] ?? '';
        });
        LocationService.getCityCoords(value[0], newCountry).then((value) {
          setState(() {
            coordinates = value;
          });
          mapController.move(LatLng(value.$1, value.$2), 7);
        });
      });
    });
  }

  void toggleConnect() async {
    bool success = false;
    if (selectedCity == connectionInfo['city']) {
      success = await ConnectionService.disconnect();
    } else {
      success =
          await ConnectionService.connect(selectedCountry.name, selectedCity);
    }
    setState(() {
      isConnected = success ? !isConnected : isConnected;
      updateConnection();
    });
  }

  void disconnect() {
    ConnectionService.disconnect().then((success) {
      if (success) {
        updateConnection();
      }
    });
  }

  void quickConnect() async {
    ConnectionService.quickConnect().then((success) {
      if (success) {
        updateConnection();
      }
    });
  }

  Future<void> displayCountries() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CountriesPage(countries: countries),
      ),
    );
    if (result != null && result != '') {
      getCities(result);
    }
  }

  @override
  void initState() {
    super.initState();
    // TODO: remove this line later
    StorageService.getString('mapAPIKey').then((value) {
      setState(() {
        mapAPIKey = '';
      });
    });

    getRecommendations().then((hasSetRecommended) {
      ConnectionService.getCountries().then((value) {
        setState(() {
          countries = createCountryModels(value);
          if (!hasSetRecommended) {
            selectedCountry = countries[0];
            getCities(countries[0].name);
          }
        });
      });
      updateConnection();
    });
  }

  @override
  Widget build(BuildContext context) {
    ConnectionService.getCountries();
    return Scaffold(
      body: Column(
        children: [
          mapView(context),
          const SizedBox(height: 10),
          connectionSection(context),
        ],
      ),
      appBar: connectionBar(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          top: 70.0,
        ),
        child: SizedBox(
          width: 40,
          height: 40,
          child: FloatingActionButton(
            elevation: 0,
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            backgroundColor: const Color(0xffeeeeee),
            hoverColor: Colors.white,
            hoverElevation: 0,
            child: const Icon(
              Icons.settings,
              color: Color(0xff3E5FFF),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  SizedBox connectionSection(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Column(
        children: [
          Builder(builder: (context) {
            return Container(
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: TextButton(
                onPressed: displayCountries,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.05),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      selectedCountry.flag,
                      width: 18,
                      height: 18,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(selectedCountry.name,
                            style: const TextStyle(fontSize: 16))),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
            ),
            child: DropdownButton(
              value: selectedCity,
              isExpanded: true,
              icon: Container(),
              autofocus: false,
              focusColor: Colors.transparent,
              underline: Container(),
              items: cities.map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem(
                    value: value,
                    child: Center(
                      child: Text(
                        value,
                        textAlign: TextAlign.center,
                      ),
                    ));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCity = value ?? '';
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
                onPressed: toggleConnect,
                style: ElevatedButton.styleFrom(
                  maximumSize: const Size(150, 50),
                  minimumSize: const Size(150, 50),
                  padding: const EdgeInsets.all(15),
                  backgroundColor: selectedCity == connectionInfo['city']
                      ? Colors.black
                      : const Color(0xff3E5FFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: selectedCity == connectionInfo['city']
                    ? const Text('Disconnect', style: TextStyle(fontSize: 16))
                    : const Text('Connect', style: TextStyle(fontSize: 16))),
          )
        ],
      ),
    );
  }

  SizedBox mapView(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.7,
      child: FlutterMap(
        mapController: mapController,
        options: const MapOptions(
            maxZoom: 17,
            minZoom: 4,
            keepAlive: true,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.pinchZoom |
                  InteractiveFlag.drag |
                  InteractiveFlag.scrollWheelZoom,
            )),
        children: [
          TileLayer(
            urlTemplate: mapAPIKey != ''
                ? 'https://maps.geoapify.com/v1/tile/dark-matter/{z}/{x}/{y}.png?apiKey=$mapAPIKey'
                : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(coordinates.$1, coordinates.$2),
                child: selectedCity == connectionInfo['city']
                    ? const Icon(
                        Icons.location_on,
                        color: Color(0xff3E5FFF),
                        size: 48,
                      )
                    : Icon(
                        Icons.location_on,
                        color: mapAPIKey == ''
                            ? Colors.black
                            : const Color(0xffFF7059),
                        size: 48,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  AppBar connectionBar() {
    return AppBar(
      backgroundColor: isConnected ? const Color(0xff1fa302) : Colors.black,
      actions: [
        Container(),
      ],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isConnected
                  ? const Icon(Icons.lock, size: 16)
                  : const Icon(Icons.lock_open, size: 16),
              const SizedBox(width: 5),
              Text(
                isConnected ? 'Connected' : 'Disconnected',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              )
            ],
          ),
          if (isConnected)
            Row(
              children: [
                SizedBox(
                  width: 35,
                  child: TextButton(
                    onPressed: disconnect,
                    child: const Icon(Icons.power_settings_new,
                        color: Colors.white, size: 20),
                  ),
                ),
                Text(
                  '${connectionInfo['city'] ?? 'Loading'}, ${connectionInfo['country'] ?? 'Loading'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          if (!isConnected)
            SizedBox(
              width: 40,
              child: TextButton(
                onPressed: quickConnect,
                child: const Icon(Icons.play_arrow, color: Color(0xff3E5FFF)),
              ),
            ),
        ],
      ),
    );
  }
}
