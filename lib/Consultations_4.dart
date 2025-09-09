import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Consultations_5.dart';
import 'AppBar.dart';

class Consultations_4 extends StatefulWidget {
  final String transportType;
  final String observation;
  final String startAddress;
  final LatLng startCoordinates;
  final String price;

  const Consultations_4({
    Key? key,
    required this.transportType,
    required this.observation,
    required this.startAddress,
    required this.startCoordinates,
    required this.price,
  }) : super(key: key);

  @override
  _Consultations_4State createState() => _Consultations_4State();
}

class _Consultations_4State extends State<Consultations_4> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String userName = "... chargement";
  String userProfilePic = "...";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(showBackButton: true),
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
                  Text(
                    'Consultation',
                    style: TextStyle(color: Colors.grey[800], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "🩺 Type de Consultation :",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    widget.transportType,
                    style: TextStyle(color: Colors.grey[800], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "📝Observation:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    widget.observation,
                    style: TextStyle(color: Colors.grey[800], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "📍 Votre position :",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "${widget.startAddress} ",
                    style: TextStyle(color: Colors.grey[800], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  // Début du design harmonisé
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
                        "${double.tryParse(widget.price)?.toStringAsFixed(0) ?? "..."} DA",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                    "${double.tryParse(widget.price)?.toStringAsFixed(0) ?? "..."} DA",
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color(0xFFF11477),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Fin du design harmonisé
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
                              'service': 'Consultation',
                              'sous-service': widget.transportType,
                              'observation': widget.observation,
                              'startAddress': widget.startAddress,
                              'startCoordinates': GeoPoint(
                                widget.startCoordinates.latitude,
                                widget.startCoordinates.longitude,
                              ),
                              'endCoordinates': null,
                              'prix': double.tryParse(widget.price) ?? 0.0,
                              'status': 'en_attente',
                              'timestamp': FieldValue.serverTimestamp(),
                              'soignantId': null,
                              'maladeId': userId,
                            });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Consultations_5(demandeId: doc.id),
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
