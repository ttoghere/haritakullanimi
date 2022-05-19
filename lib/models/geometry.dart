import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:haritakullanimi/models/location.dart';

class Geometry {
  final Location location;
  Geometry({required this.location});

  factory Geometry.fromJson(Map<String, dynamic> parsedJson) {
    return Geometry(
        location: Location(
            lat: parsedJson["location"]["lat"],
            lng: parsedJson["location"]["lng"]));
  }
}
