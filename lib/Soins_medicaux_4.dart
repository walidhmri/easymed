import 'dart:math' show cos, sqrt, asin, pi, sin;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Soins_medicaux_5.dart';

class Soins_medicaux_4 extends StatefulWidget {
  final String selectedSoins;
  final String observation;
  final String price;
  final String startAddress;
  final LatLng startCoordinates;

  const Soins_medicaux_4({
    Key? key,
    required this.selectedSoins,
    required this.observation,
    required this.price,
    required this.startAddress,
    required this.startCoordinates,
  }) : super(key: key);

  @override
  _Soins_medicaux_4State createState() => _Soins_medicaux_4State();
}

class _Soins_medicaux_4State extends State<Soins_medicaux_4> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final LatLng zeraldaCoordinates = LatLng(36.7116, 2.8425);

  String userName = "... chargement";
  String userProfilePic = "...";
  String userId = "";
  final String defaultAvatarUrl =
      "https://firebasestorage.googleapis.com/v0/b/easy-med-c3f69.firebasestorage.app/o/profile_images%2Favatar-simple.jpg?alt=media&token=cbf516b6-ad37-4c50-852d-58f0b83564d5";

  // These variables are no longer necessary for the total price,
  // but they are kept here to avoid errors in the `calculateAndSetPrice` method.
  double? prixTransport;
  double? prixSoins;
  double? prixTotal;

  @override
  void initState() {
    super.initState();
    getUserData();
    calculateAndSetPrice();
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
            userName = userDoc["name"] ?? "Nom inconnu";
            userProfilePic = userDoc["profileImage"] ?? defaultAvatarUrl;
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

  // MODIFIED: `calculateAndSetPrice` no longer adds `prixTransport` to `prixTotal`
  void calculateAndSetPrice() {
    // Transport price calculation is still performed, but not used for `prixTotal`
    double distanceKm = calculateDistanceInKm(
      widget.startCoordinates,
      zeraldaCoordinates,
    );
    prixTransport = calculateTransportPrice(distanceKm);

    prixSoins = double.tryParse(widget.price) ?? 0;
    // The total price is now just the price of the care
    prixTotal = prixSoins!;

    setState(() {}); // Refresh the UI
  }

  double calculateDistanceInKm(LatLng start, LatLng end) {
    const double earthRadius = 6371;
    double dLat = _degreesToRadians(end.latitude - start.latitude);
    double dLng = _degreesToRadians(end.longitude - start.longitude);
    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(start.latitude)) *
            cos(_degreesToRadians(end.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;

  double calculateTransportPrice(double distanceInKm) {
    if (distanceInKm <= 7) return 500;
    if (distanceInKm <= 15) return 750;
    return 1200;
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
              Expanded(
                child: Text(
                  "Bonjour $userName",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: userProfilePic.startsWith('http')
                      ? NetworkImage(userProfilePic)
                      : AssetImage(userProfilePic) as ImageProvider,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Compte rendu de la demande",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "🏥 Soins sélectionnés :",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    widget.selectedSoins,
                    style: TextStyle(color: Colors.grey[800], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "📝 Observation :",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    widget.observation,
                    style: TextStyle(color: Colors.grey[800], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "📍 Votre adresse :",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    widget.startAddress,
                    style: TextStyle(color: Colors.grey[800], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 30, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "💉 Total soins :",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${prixSoins?.toStringAsFixed(0) ?? "..."} DA",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // REMOVED: The Row for "Transport" is no longer visible
                  // If you want to keep the code but hide it, you can wrap it in Visibility(visible: false, child: ...)
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     const Text(
                  //       "🚗 Transport :",
                  //       style: TextStyle(
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //     Text(
                  //       "${prixTransport?.toStringAsFixed(0) ?? "..."} DA",
                  //       style: const TextStyle(
                  //         fontSize: 16,
                  //         color: Colors.black87,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const Divider(height: 30, thickness: 1),
                  const Text(
                    "💰 Total à payer :",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF000000),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    prixTotal != null
                        ? "${prixTotal!.toStringAsFixed(0)} DA"
                        : "...",
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color(0xFFF11477),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text(
                        "Confirmer la demande",
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF11477),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () async {
                        final doc = await FirebaseFirestore.instance
                            .collection('demandes')
                            .add({
                              'service': 'Soins medicaux',
                              'sous-service': widget.selectedSoins,
                              'observation': widget.observation,
                              'startAddress': widget.startAddress,
                              'startCoordinates': GeoPoint(
                                widget.startCoordinates.latitude,
                                widget.startCoordinates.longitude,
                              ),
                              'endCoordinates': null,
                              'prix': prixTotal ?? 0.0,
                              // MODIFIED: The transport price is now explicitly set to 0.0
                              'prixTransport': 0.0,
                              'prixSoins': prixSoins ?? 0.0,
                              'status': 'en_attente',
                              'timestamp': FieldValue.serverTimestamp(),
                              'soignantId': null,
                              'maladeId': userId,
                            });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Soins_medicaux_5(demandeId: doc.id),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
