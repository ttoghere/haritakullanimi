import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:haritakullanimi/screens/geolocator_service.dart';

class AppBloc with ChangeNotifier {
  //Değişkenler
  final geolocatorService = GeolocatorService();
  Position? currentLocation;
  //Oluşturucu
  AppBloc() {
    setCurrentLocation();
  }
  //Methodlar
  setCurrentLocation() async {
    currentLocation = await geolocatorService.getCurrentLocation();
    notifyListeners();
  }
}
