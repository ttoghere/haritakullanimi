import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:haritakullanimi/models/place.dart';
import 'package:provider/provider.dart';
import '../providers/app_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

//Google Servisten alınan geçici api anahtarı
const gApiKey = "AIzaSyC31EGjb-OZwdbT1SitmlBtl8stSuc6wsg";

class _HomePageState extends State<HomePage> {
  //Arama alanı geçişi için scaffold anahtarı
  final homeScaffold = GlobalKey<ScaffoldState>();
  //Cihaz içi lokasyon izni alımı sağlar
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

  final mode = Mode.overlay;
  //Hata durumunda olacak olan aksiyon
  void onError(PlacesAutocompleteResponse hata) {
    homeScaffold.currentState!.showSnackBar(
      SnackBar(
        content: Text(
          hata.errorMessage.toString(),
        ),
      ),
    );
  }

  //Arama alanı tahmini sağlar
  Future<void> tahminGosterimi(
      {required Prediction p, required ScaffoldState scaffoldState}) async {
    //Harita kullanım setup
    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: gApiKey, apiHeaders: await GoogleApiHeaders().getHeaders());
    //Girilecek olan metin için arama
    PlacesDetailsResponse detailsResponse =
        await places.getDetailsByPlaceId(p.placeId.toString());
    final lat = detailsResponse.result.geometry!.location.lat;
    final lng = detailsResponse.result.geometry!.location.lng;
    markersList.clear();
    markersList.add(
      //Haritada nokta gösterimi sağlayan imleç
      Marker(
          markerId: MarkerId("0"),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: detailsResponse.result.name)),
    );
    setState(() {});
    googleMapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(lat, lng),
        12,
      ),
    );
  }

  @override
  void initState() {
    konumIzniAl();
    var appBloc = Provider.of<AppBloc>(context, listen: false);
    locationSubscription = appBloc.selectedLocation.stream.listen((event) {
      if (event != null) {
        _goToPlace(event);
      }
    });
    super.initState();
  }

  late StreamSubscription locationSubscription;

  //Harita Kontrolcüsü
  late GoogleMapController googleMapController;
  //Varsayılan nokta(Uygulama apisinden müşteri koordinatları latlng parametrelerine girilecek)
  var baslangic = CameraPosition(
    target: LatLng(
      36.782599,
      34.572200,
    ),
    zoom: 12,
  );

  //imleç kayıt listesi
  Set<Marker> markersList = {};

  Completer<GoogleMapController> _completer = Completer();
  Future<void> _goToPlace(Place place) async {
    final GoogleMapController controller = await _completer.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
              place.geometry.location.lat,
              place.geometry.location.lng,
            ),
            zoom: 14),
      ),
    );
  }

  @override
  void dispose() {
    var appBloc = Provider.of<AppBloc>(context, listen: false);
    locationSubscription.cancel();
    appBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appBloc = Provider.of<AppBloc>(context);
    return SafeArea(
      child: Scaffold(
        key: homeScaffold,
        body: (appBloc.currentLocation == null)
            ? Center(
                child: Text("Location Error, Please Try again later"),
              )
            : Stack(
                children: [
                  GoogleMap(
                    myLocationEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        appBloc.currentLocation!.latitude,
                        appBloc.currentLocation!.longitude,
                      ),
                      zoom: 14,
                    ),
                    markers: markersList,
                    mapType: MapType.satellite,
                    onMapCreated: (GoogleMapController controller) {
                      _completer.complete(controller);
                    },
                  ),
                  if (appBloc.searchResults != "" &&
                      appBloc.searchResults.length != 0)
                    Container(
                      margin: EdgeInsets.only(top: 70),
                      child: Stack(
                        children: [
                          Container(
                           
                             margin: const EdgeInsets.only(
                          right: 70,left: 20),
                            height: 400,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height,
                            child: Container(
                              height: 300,
                              child: ListView.builder(
                                itemCount: appBloc.searchResults.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    child: ListTile(
                                      onTap: () {
                                        appBloc.setSelectedLocation(
                                            appBloc.searchResults[index].place_id);
                                      },
                                      title: Text(
                                        appBloc.searchResults[index].description,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Align(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 10, right: 70,left: 20),
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        onChanged: (value) => appBloc.searchPlaces(value),
                        decoration: InputDecoration(
                          fillColor: Colors.black,
                          filled: true,
                          suffixIcon: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.brown, width: 1),
                          ),
                          hintText: "Konum Arayınız",
                          hintStyle: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    alignment: Alignment.topLeft,
                  ),
                ],
              ),
      ),
    );
  }
}
