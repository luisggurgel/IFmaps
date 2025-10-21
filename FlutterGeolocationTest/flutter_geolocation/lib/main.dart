import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }
//a
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately. 
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Verificando se está no IF ou não.'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String _currentLocation = "Localização atual";
  double? latitude;
  double? longitude;
  String locationMessage = "";
  List<double> minMaxLatLong = [];

  void _liveLocation(){
  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 1, //Taxa de atualização, atualiza a cada 1m
  );

  Geolocator.getPositionStream().listen(
    (Position position) {
      latitude = position.latitude;
      longitude = position.longitude;

      setState(() {
        locationMessage = "Latitude: $latitude Longitude $longitude";
      });
    }
  );
  }

  Future<void> _openMap(double? latitude, double? longitude) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    // tenta abrir diretamente no browser / app externo
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Não conseguiu abrir a url: $uri');
    }
  }

  @override 
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
      centerTitle: true,
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(_currentLocation),
          Text(locationMessage),
          ElevatedButton(
            onPressed: () {
              _determinePosition().then((value) {
                latitude = value.latitude;
                longitude = value.longitude;
                setState(() {
                  locationMessage = "Latitude: $latitude Longitude $longitude";
                });
                _liveLocation();
              });
            }, 
            child: Text("Pegue a sua localização atual"),
          ),
          ElevatedButton(
            onPressed: () {
              _openMap(latitude, longitude);
            },
            child: Text("Ver no google maps"),
          )
        ],
      ) 
      ,
    ),
  );
}

