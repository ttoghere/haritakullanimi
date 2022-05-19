import 'dart:convert';
import 'package:haritakullanimi/models/place_search.dart';
import 'package:http/http.dart' as http;

class PlacesService {
  final key = "AIzaSyC31EGjb-OZwdbT1SitmlBtl8stSuc6wsg";
  Future<List<PlaceSearch>> getAutoComplete(String search) async {
    var url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&language=tr_TR&types=%28cities%29&key=$key";
    var response = await http.get(Uri.parse(url));
    var json = jsonDecode(response.body);
    var jsonResults = json["predictions"] as List;
    return jsonResults.map((e) => PlaceSearch.fromJson(e)).toList();
  }
}
