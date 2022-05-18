import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const gApiKey = "AIzaSyASN-XHVoXc78gyYQVnWCwS8Vh4aLB2-vQ";
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Position> konumIzniAl() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    konumIzniAl();
    super.initState();
  }

  double enlem = 0.0;
  double boylam = 0.0;
  Completer<GoogleMapController> hKontrol = Completer();
  var baslangic = CameraPosition(
    target: LatLng(
      36.782599,
      34.572200,
    ),
    zoom: 12,
  );

  Future<void> konumBilgisiAl() async {
    var konum = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      enlem = konum.latitude;
      boylam = konum.longitude;
      print("Enlem: $enlem ve Boylam: $boylam");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maps Kullanımı'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              initialCameraPosition: baslangic,
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                hKontrol.complete(controller);
              },
            ),
          ),
        ],
      )),
    );
  }
}
