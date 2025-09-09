import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places_hoc081098/src/google_maps_webservice/places.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Soins_medicaux_4.dart';

const kGoogleApiKey = "AIzaSyDVcpZPqNbR87fJZNWVE4v76KmH1GW-3bw";

class Soins_medicaux_2 extends StatefulWidget {
  final String observation;
  final String price;
  final String selectedSoins;

  const Soins_medicaux_2({
    Key? key,
    required this.selectedSoins,
    required this.observation,
    required this.price,
  }) : super(key: key);

  @override
  _Soins_medicaux_2State createState() => _Soins_medicaux_2State();
}

class _Soins_medicaux_2State extends State<Soins_medicaux_2> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String userName = "... chargement";
  String userProfilePic = "...";
  String userPhone = "...";
  String userId = "";

  final String defaultAvatarUrl =
      "https://firebasestorage.googleapis.com/v0/b/easy-med-c3f69.firebasestorage.app/o/profile_images%2Favatar-simple.jpg?alt=media&token=cbf516b6-ad37-4c50-852d-58f0b83564d5";

  GoogleMapController? mapController;
  LatLng _center = LatLng(36.7525, 3.0420); // Alger
  Marker? _startMarker;
  LatLng? _startLocation;
  final TextEditingController _startController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString("user_id");

    if (storedUserId != null) {
      setState(() => userId = storedUserId);

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
      } catch (_) {
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

      bool isInAlger = detail.result.addressComponents.any(
        (component) =>
            (component.types.contains("locality") ||
                component.types.contains("administrative_area_level_1")) &&
            component.longName.toLowerCase().contains("alger"),
      );

      if (!isInAlger) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Veuillez sélectionner une adresse située à Alger."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _startLocation = latLng;
        _startMarker = Marker(
          markerId: const MarkerId("start"),
          position: latLng,
          infoWindow: const InfoWindow(title: "Départ"),
        );
        _startController.text = detail.result.name;
        mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez activer la localisation.")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Permission refusée.")));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission refusée définitivement.")),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    String address = placemarks.isNotEmpty
        ? "${placemarks.first.street}, ${placemarks.first.locality}"
        : "Localisation actuelle";

    setState(() {
      _startLocation = currentLatLng;
      _startMarker = Marker(
        markerId: const MarkerId("start"),
        position: currentLatLng,
        infoWindow: const InfoWindow(title: "Départ"),
      );
      _startController.text = address;
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
      body: Column(
        children: [
          // Carte
          SizedBox(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: _center, zoom: 13),
              onMapCreated: (controller) => mapController = controller,
              markers: {if (_startMarker != null) _startMarker!},
            ),
          ),
          // Formulaire
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Veuillez indiquer votre adresse svp:"),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _searchStartAddress,
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _startController,
                      decoration: const InputDecoration(
                        hintText: "Votre adresse",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location, color: Color(0xFF1170AD)),
                  label: const Text("Utiliser ma position actuelle"),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    if (_startLocation != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Soins_medicaux_4(
                            selectedSoins: widget.selectedSoins,
                            observation: widget.observation,
                            price: widget.price,
                            startAddress: _startController.text,
                            startCoordinates: _startLocation!,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1170AD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text("Confirmer l'adresse"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
