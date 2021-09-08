import 'dart:async';
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
void main() => runApp(MapSample());

// The below is taken from the docks; https://pub.dev/packages/google_maps_flutter

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  int temperature = 0;
  String location = 'Your Location';
  double lat = 55.3942;
  double long = 10.3822;

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
      lat = double.parse("${_locationData.latitude}");
      print(lat);
      long = double.parse("${_locationData.longitude}");
      print(long);
    });
  }

  void fetchTemp() async {
    var locationResult = await http.get(Uri.parse(searchByCoors1 +
        "${_locationData.latitude}" +
        searchByCoors2 +
        "${_locationData.longitude}" +
        searchByCoors3));
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

  // ignore: non_constant_identifier_names
  static final CameraPosition _MapOfDenmark = CameraPosition(
    target: LatLng(55.74159532304784, 10.644310212664259),
    zoom: 6.4746,
  );

/*   static final CameraPosition _switchMapToCurrentLocation = CameraPosition(
    target: LatLng(double.parse(lat), 10.382200114840725),
    zoom: 13.4746,
  ); */

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _MapOfDenmark,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
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

/*       floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.navigation),
        onPressed: _buttonName,
      ), */
          ],
        ),
      ),
    );
  }

  Future<void> switchPosition() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(lat, long),
        zoom: 10.4746,
      ),
    ));
    //_weather_appState().onButtonPressed();
  }

  void onButtonPressed() {
    getCurrentLocation();
    fetchTemp();
    switchPosition();
  }
}
