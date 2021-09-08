/* import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

//App is suppose to take your current location coordinates, then call a weather
//api and get the current temperature, then use the same coordinates to
//update the google map location in the background

//408bd3349e9f9b61fbc39d92abd92853
//https://api.openweathermap.org/data/2.5/weather?q=Odense&units=metric&appid=408bd3349e9f9b61fbc39d92abd92853
void main() => runApp(weather_app());

class weather_app extends StatefulWidget {
  const weather_app({Key? key}) : super(key: key);

  @override
  _weather_appState createState() => _weather_appState();
}

class _weather_appState extends State<weather_app> {
  int temperature = 0;
  String location = 'location';
  String lat = '';
  String long = '';

  Location location2 = new Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  bool _isListenLocation = false, _isGetLocation = false;

  //String searchApiUrl = 'https://api.openweathermap.org/data/2.5/weather?q=';
  //String searchApiUrl2 = '&units=metric&appid=408bd3349e9f9b61fbc39d92abd92853';

  String searchByCoors1 =
      'https://api.openweathermap.org/data/2.5/weather?lat=';
  String searchByCoors2 = '&lon=';
  String searchByCoors3 =
      '&units=metric&appid=408bd3349e9f9b61fbc39d92abd92853';

  void getCurrentLocation() async {
    _serviceEnabled = await location2.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location2.requestService();
      if (_serviceEnabled) return;
    }

    _permissionGranted = await location2.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location2.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }
    _locationData = await location2.getLocation();

    setState(() {
      _isGetLocation = true;
      //location = "${_locationData.latitude}/${_locationData.longitude}";
      lat = "${_locationData.latitude}";
      print(lat);
      long = "${_locationData.longitude}";
      print(long);
    });
  }

  void fetchTemp() async {
    var locationResult = await http.get(Uri.parse(
        searchByCoors1 + lat + searchByCoors2 + long + searchByCoors3));
    var result = json.decode(locationResult.body);
    //print(result);
    var weather_temp = result["main"];
    var cityName = result["name"];
    print(cityName);
    //print(weather_temp);

    setState(() {
      temperature = weather_temp["temp"].round();
      location = cityName;
    });
  }

  void onButtonPressed() {
    getCurrentLocation();
    fetchTemp();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: Stack(
        children: <Widget>[
          MapSample(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text(
                  temperature.toString() + '°C',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 60.0,
                      decoration: TextDecoration.none),
                ),
              ),
              Center(
                child: Text(
                  location,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 40.0,
                      decoration: TextDecoration.none),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Center(
                  child: FloatingActionButton(
                child: Icon(Icons.navigation),
                onPressed: onButtonPressed,
              ))
            ],
          ),
        ],
      ),
    );
  }
}

// The below is taken from the docks; https://pub.dev/packages/google_maps_flutter

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  // ignore: non_constant_identifier_names
  static final CameraPosition _Odense = CameraPosition(
    target: LatLng(55.74159532304784, 10.644310212664259),
    zoom: 6.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
    target: LatLng(55.37061706516505, 10.382200114840725),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _Odense,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
/*       floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.navigation),
        onPressed: _buttonName,
      ), */
    );
  }

  Future<void> switchPosition() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
    print(':)');
    //_weather_appState().onButtonPressed();
  }
}
 */