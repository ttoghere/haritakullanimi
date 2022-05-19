import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:haritakullanimi/models/place.dart';
import 'package:haritakullanimi/models/place_search.dart';
import 'package:haritakullanimi/services/geolocator_service.dart';
import 'package:haritakullanimi/services/place_services.dart';

class AppBloc with ChangeNotifier {
  //Değişkenler
  final geolocatorService = GeolocatorService();
  final placesService = PlacesService();
  Position? currentLocation;
  List<PlaceSearch> searchResults = [];
  StreamController<Place> selectedLocation = StreamController<Place>();
  //Oluşturucu
  AppBloc() {
    setCurrentLocation();
  }
  //Methodlar
  setCurrentLocation() async {
    currentLocation = await geolocatorService.getCurrentLocation();
    notifyListeners();
  }

  searchPlaces(String search) async {
    searchResults = await placesService.getAutoComplete(search);
    notifyListeners();
  }

  setSelectedLocation(String placeId) async {
    selectedLocation.add(await placesService.getPlace(placeId));
    searchResults = [];
    notifyListeners();
  }

  @override
  void dispose() {
    selectedLocation.close();
    super.dispose();
  }
}
