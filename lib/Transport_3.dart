import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places_hoc081098/src/google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Transport_4.dart';

const kGoogleApiKey = "AIzaSyDVcpZPqNbR87fJZNWVE4v76KmH1GW-3bw";

class Transport3 extends StatefulWidget {
  final String transportType;
  final String observation;
  final String startAddress;
  final LatLng startCoordinates;

  const Transport3({
    Key? key,
    required this.observation,
    required this.transportType,
    required this.startAddress,
    required this.startCoordinates,
  }) : super(key: key);

  @override
  _Transport3State createState() => _Transport3State();
}

class _Transport3State extends State<Transport3> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String userName = "... chargement";
  String userProfilePic = "...";
  String userPhone = "...";
  String userId = "";

  final String defaultAvatarUrl =
      "https://firebasestorage.googleapis.com/v0/b/easy-med-c3f69.firebasestorage.app/o/profile_images%2Favatar-simple.jpg?alt=media&token=cbf516b6-ad37-4c50-852d-58f0b83564d5";

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString("user_id");

    if (storedUserId != null) {
      setState(() {
        userId = storedUserId;
      });

      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc["name"];
            userProfilePic = userDoc["profileImage"];
          });
        }
      } catch (e) {
        setState(() {
          userName = "Erreur de chargement";
          userProfilePic = defaultAvatarUrl;
        });
      }
    } else {
      setState(() {
        userName = "Utilisateur non connecté";
        userProfilePic = defaultAvatarUrl;
      });
    }
  }

  Future<void> _searchStartAddress() async {
    final place = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      mode: Mode.overlay,
      language: "fr",
      components: [Component(Component.country, "dz")],
    );

    if (place != null) {
      final plist = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );

      final detail = await plist.getDetailsByPlaceId(place.placeId!);
      final geometry = detail.result.geometry!;
      final latLng = LatLng(geometry.location.lat, geometry.location.lng);
    }
  }

  GoogleMapController? mapController;
  LatLng _center = LatLng(36.7525, 3.0420);
  Marker? _endMarker;
  LatLng? _endLocation;
  final TextEditingController _endController = TextEditingController();

  Future<void> _searchEndAddress() async {
    final place = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      mode: Mode.overlay,
      language: "fr",
      components: [Component(Component.country, "dz")],
    );

    if (place != null) {
      final plist = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );

      final detail = await plist.getDetailsByPlaceId(place.placeId!);
      final geometry = detail.result.geometry!;
      final latLng = LatLng(geometry.location.lat, geometry.location.lng);

      setState(() {
        _endLocation = latLng;
        _endMarker = Marker(
          markerId: MarkerId("end"),
          position: latLng,
          infoWindow: InfoWindow(title: "Arrivée"),
        );
        _endController.text = detail.result.name;
        mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez activer la localisation.")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Permission refusée.")));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permission refusée définitivement.")),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    // Reverse geocoding
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    String address = placemarks.isNotEmpty
        ? "${placemarks.first.street}, ${placemarks.first.locality}"
        : "Localisation actuelle";

    setState(() {
      _endLocation = currentLatLng;
      _endMarker = Marker(
        markerId: MarkerId("start"),
        position: currentLatLng,
        infoWindow: InfoWindow(title: "Départ"),
      );
      _endController.text = address;
      mapController?.animateCamera(CameraUpdate.newLatLng(currentLatLng));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/pink_header_3.png'),
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bonjour $userName",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: DecorationImage(
                    image: userProfilePic.startsWith('http')
                        ? NetworkImage(userProfilePic)
                        : AssetImage(userProfilePic) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 13,
                ),
                onMapCreated: (controller) => mapController = controller,
                markers: {if (_endMarker != null) _endMarker!},
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Veuillez indiquer votre adresse d’arrivée svp:"),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: _searchEndAddress,
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _endController,
                        decoration: InputDecoration(
                          hintText: "adresse d’arrivée",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: Icon(Icons.my_location, color: Color(0xFF1170AD)),
                    label: Text("Utiliser ma position actuelle"),
                  ),

                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      if (_endLocation != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Transport4(
                              transportType: widget.transportType,
                              observation: widget.observation,
                              startAddress: widget.startAddress,
                              endAddress: _endController.text,
                              startCoordinates: widget.startCoordinates,
                              endCoordinates: _endLocation!,
                            ),
                          ),
                        );
                      } else {
                        print("❌ Adresse d’arrivée non définie.");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF11477),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text("Confirmer l'adresse"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
