import 'dart:math' show cos, sqrt, asin, pi, sin;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Transport_5.dart';

class Transport4 extends StatefulWidget {
  final String transportType;
  final String observation;
  final String startAddress;
  final String endAddress;
  final LatLng startCoordinates;
  final LatLng endCoordinates;

  const Transport4({
    Key? key,
    required this.transportType,
    required this.observation,
    required this.startAddress,
    required this.endAddress,
    required this.startCoordinates,
    required this.endCoordinates,
  }) : super(key: key);

  @override
  _Transport4State createState() => _Transport4State();
}

class _Transport4State extends State<Transport4> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String userName = "... chargement";
  String userProfilePic = "...";
  String userId = "";

  final String defaultAvatarUrl =
      "https://firebasestorage.googleapis.com/v0/b/easy-med-c3f69.firebasestorage.app/o/profile_images%2Favatar-simple.jpg?alt=media&token=cbf516b6-ad37-4c50-852d-58f0b83564d5";

  double? prix;
  double? distanceKm;

  @override
  void initState() {
    super.initState();
    getUserData();
    fetchPriceFromFirestore(); // récupération dynamique du prix
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
            userName = userDoc["name"] ?? "Nom inconnu";
            userProfilePic = userDoc["profileImage"] ?? defaultAvatarUrl;
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

  Future<void> fetchPriceFromFirestore() async {
    distanceKm = calculateDistanceInKm(
      widget.startCoordinates,
      widget.endCoordinates,
    );

    String transportType;

    if (widget.transportType.toLowerCase().contains("simple")) {
      transportType = "Paramédicalisé";
    } else if (widget.transportType.toLowerCase().contains("équipé") ||
        widget.transportType.toLowerCase().contains("equipe")) {
      transportType = "Médicalisé";
    } else {
      // A default value in case none of the conditions are met
      transportType = "Non spécifié";
    }

    String zone;
    if (distanceKm! <= 20) {
      zone = "zone_1_$transportType";
    } else if (distanceKm! <= 40) {
      zone = "zone_2_$transportType";
    } else {
      zone = "zone_3_$transportType";
    }

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("prix")
          .doc("transport")
          .get();

      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        // ✅ Convertir proprement même si le champ est un String
        double fetchedPrice =
            double.tryParse(data[zone]?.toString() ?? '') ?? 0;
        setState(() {
          prix = fetchedPrice;
        });
      } else {
        setState(() {
          prix = 0;
        });
      }
    } catch (e) {
      print("Erreur récupération prix: $e");
      setState(() {
        prix = 0;
      });
    }
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

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
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
                    "🏥 Type de service:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text('Transport', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  const Text(
                    "🚑 Type de transport :",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(widget.transportType, style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  const Text(
                    "📝 Observation :",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(widget.observation, style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  const Text(
                    "📍 Point de départ :",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "${widget.startAddress} (${widget.startCoordinates.latitude}, ${widget.startCoordinates.longitude})",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "📌 Point d’arrivée :",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "${widget.endAddress} (${widget.endCoordinates.latitude}, ${widget.endCoordinates.longitude})",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Prix :",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF000000),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    prix != null ? "${prix!.toStringAsFixed(2)} DA" : "...",
                    style: TextStyle(
                      fontSize: 24,
                      color: Color(0xFFF11477),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text("Confirmer la demande"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF11477),
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
                              'service': 'transport',
                              'sous-service': widget.transportType,
                              'observation': widget.observation,
                              'startAddress': widget.startAddress,
                              'endAddress': widget.endAddress,
                              'startCoordinates': GeoPoint(
                                widget.startCoordinates.latitude,
                                widget.startCoordinates.longitude,
                              ),
                              'endCoordinates': GeoPoint(
                                widget.endCoordinates.latitude,
                                widget.endCoordinates.longitude,
                              ),
                              'prix': prix ?? 0.0,
                              'status': 'en_attente',
                              'timestamp': FieldValue.serverTimestamp(),
                              'soignantId': null,
                              'maladeId': userId,
                            });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Transport_5(demandeId: doc.id),
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
