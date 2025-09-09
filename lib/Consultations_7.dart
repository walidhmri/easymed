import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http; // Importez le package http
import 'dart:convert';
import 'AppBar.dart';
import 'Home.dart';
import 'Consultations_8.dart';

class Consultations_7 extends StatefulWidget {
  final Map<String, dynamic> soignant;

  const Consultations_7({Key? key, required this.soignant}) : super(key: key);

  @override
  State<Consultations_7> createState() => _Consultations_7State();
}

class _Consultations_7State extends State<Consultations_7> {
  String? service;
  String? sous_service;
  double? _price;
  String? _time; // Variable pour le temps de trajet

  @override
  void initState() {
    super.initState();
    _listenToStatusChanges();
    _fetchRealTimeDrivingTime();
  }

  // Fonction pour calculer le temps de trajet en utilisant une API de navigation
  Future<void> _fetchRealTimeDrivingTime() async {
    final soignant = widget.soignant;
    final GeoPoint? startCoordinates = soignant["startCoordinates"];

    // Coordonnées précises de Zéralda
    const double zeraldaLat = 36.7118;
    const double zeraldaLon = 2.8421;

    if (startCoordinates == null) {
      setState(() {
        _time = 'Non disponible';
      });
      return;
    }

    // REMPLACEZ 'YOUR_API_KEY' par votre véritable clé API
    const String apiKey = 'AIzaSyDVcpZPqNbR87fJZNWVE4v76KmH1GW-3bw';

    final Uri url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${startCoordinates.latitude},${startCoordinates.longitude}&'
      'destination=$zeraldaLat,$zeraldaLon&'
      'mode=driving&'
      'key=$apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final legs = data['routes'][0]['legs'][0];
          final durationInSeconds = legs['duration']['value'];
          final durationInMinutes = (durationInSeconds / 60).round();
          setState(() {
            _time = '$durationInMinutes minutes';
          });
        } else {
          final apiError = data['error_message'] ?? 'Erreur inconnue de l\'API';
          setState(() {
            _time = 'Erreur: $apiError';
          });
        }
      } else {
        setState(() {
          _time = 'Erreur réseau: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _time = 'Erreur: $e';
      });
    }
  }

  void _listenToStatusChanges() {
    final String? demandeId = widget.soignant['demandeId'];
    if (demandeId != null) {
      FirebaseFirestore.instance
          .collection('demandes')
          .doc(demandeId)
          .snapshots()
          .listen((snapshot) {
            if (snapshot.exists) {
              final data = snapshot.data();
              final status = data?['status'];
              setState(() {
                service = data?['service'];
                sous_service = data?['sous-service'];
                _price = data?['prix']?.toDouble();
              });

              if (status == 'validé_soignant') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => Consultations_8(soignant: widget.soignant),
                  ),
                );
              }
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final soignant = widget.soignant;

    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Votre soignant est arrivé',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      soignant['profileImage'],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    soignant['name'] ?? "Nom inconnu",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    soignant['phone'] ?? 'Non disponible',
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        service ?? 'Non disponible',
                        style: const TextStyle(
                          color: Color(0xFF1170AD),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        sous_service ?? 'Non disponible',
                        style: const TextStyle(
                          color: Color(0xFF1170AD),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Text(
                        'Prix: ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF000000),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _price != null ? '$_price DA' : 'Non disponible',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFFF11477),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
