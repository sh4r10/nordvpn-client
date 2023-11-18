import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nordvpn_client/services/connection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:nordvpn_client/services/location.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isConnected = false;
  String selectedCountry = '';
  String selectedCity = '';
  List<String> countries = [];
  List<String> cities = [];
  Map<String, String> connectionInfo = {};
  (double, double) coordinates = (0.0, 0.0);
  final MapController mapController = MapController();

  void updateConnection() {
    ConnectionService.getConnectionInfo().then((value) {
      setState(() {
        connectionInfo = value;
        isConnected = value['status'] == 'Connected';
        selectedCity = value['city'] ?? selectedCity;
        selectedCountry = value['country'] ?? selectedCountry;
      });
      getCities(selectedCountry);
    });
  }

  void getCities(String? country) {
    setState(() {
      selectedCountry = country ?? selectedCountry;
    });
    ConnectionService.getCities(selectedCountry).then((value) {
      setState(() {
        cities = value;
        selectedCity = value[0];
      });
      LocationService.getCityCoords(value[0], selectedCountry).then((value) {
        setState(() {
          coordinates = value;
        });
        mapController.move(LatLng(value.$1, value.$2), 15);
      });
    });
  }

  void connect() {
    ConnectionService.connect(selectedCountry, selectedCity)
        .then((value) => {updateConnection()});
  }

  void toggleConnect() async {
    bool success = false;
    if (selectedCity == connectionInfo['city']) {
      success = await ConnectionService.disconnect();
    } else {
      success = await ConnectionService.connect(selectedCountry, selectedCity);
    }
    setState(() {
      isConnected = success ? !isConnected : isConnected;
      updateConnection();
    });
  }

  @override
  void initState() {
    super.initState();

    LocationService.getRecommendedConnection().then((value) {
      setState(() {
        selectedCountry = value.$1;
        selectedCity = value.$2;
      });
      getCities(value.$1);
    });

    ConnectionService.getCountries().then((value) {
      setState(() {
        countries = value;
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
          Column(
            children: [
              DropdownSearch<String>(
                items: countries,
                selectedItem: selectedCountry,
                onChanged: (value) => getCities(value),
              ),
              DropdownSearch<String>(
                items: cities,
                selectedItem: selectedCity,
                onChanged: (value) => selectedCity = value ?? selectedCity,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: toggleConnect,
                  style: ElevatedButton.styleFrom(
                    maximumSize: const Size(150, 50),
                    minimumSize: const Size(150, 50),
                    padding: const EdgeInsets.all(15),
                    backgroundColor:
                        selectedCity == connectionInfo['city'] ? Colors.black : const Color(0xff3E5FFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: selectedCity == connectionInfo['city']
                      ? const Text('Disconnect')
                      : const Text('Connect'))
            ],
          ),
        ],
      ),
      appBar: connectionBar(),
    );
  }

  SizedBox mapView(BuildContext context) {
    return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 400,
          child: FlutterMap(
            mapController: mapController,
            options: const MapOptions(
                maxZoom: 15,
                minZoom: 5,
                keepAlive: true,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.pinchZoom |
                      InteractiveFlag.drag |
                      InteractiveFlag.scrollWheelZoom,
                )),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                        : const Icon(
                            Icons.location_on,
                            color: Colors.black,
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
                connectionInfo['status'] ?? 'Disconnected',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              )
            ],
          ),
          if (isConnected)
            Text(
              '${connectionInfo['city'] ?? 'Loading'}, ${connectionInfo['country'] ?? 'Loading'}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            )
        ],
      ),
    );
  }
}
