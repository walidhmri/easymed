import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'AppBar.dart';
import 'Home.dart';
import 'Analyses_medicales_7.dart';

class Analyses_medicales_6 extends StatefulWidget {
  final Map<String, dynamic> soignant;

  const Analyses_medicales_6({Key? key, required this.soignant})
    : super(key: key);

  @override
  State<Analyses_medicales_6> createState() => _Analyses_medicales_6State();
}

class _Analyses_medicales_6State extends State<Analyses_medicales_6> {
  String? service;
  String? sous_service;
  double? _price;
  String? _time;

  @override
  void initState() {
    super.initState();
    _listenToStatusChanges();
    _fetchRealTimeDrivingTime();
  }

  Future<void> _fetchRealTimeDrivingTime() async {
    final soignant = widget.soignant;
    final GeoPoint? startCoordinates = soignant["startCoordinates"];

    const double zeraldaLat = 36.7118;
    const double zeraldaLon = 2.8421;

    if (startCoordinates == null) {
      setState(() {
        _time = 'Non disponible';
      });
      return;
    }

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
                _price = data?['prix']
                    ?.toDouble(); // Mettez à jour la variable ici
              });

              if (status == 'arrivé') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) =>
                        Analyses_medicales_7(soignant: widget.soignant),
                  ),
                );
              }
            }
          });
    }
  }

  void _annulerDemande(BuildContext context, String demandeId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer l’annulation"),
        content: const Text("Voulez-vous vraiment annuler la demande ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Non"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Oui"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('demandes')
            .doc(demandeId)
            .update({'status': 'annulé'});

        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => Home()),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur lors de l’annulation : $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final soignant = widget.soignant;
    final String? demandeId = soignant["demandeId"];

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
                      'Votre soignant est en route',
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
                      fontSize: 20,
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
                        'Temps estimé: ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF000000),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _time ?? 'Calcul en cours...',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFF11477),
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                  const SizedBox(height: 30),
                  if (demandeId != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _annulerDemande(context, demandeId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF11477),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          "Annuler la demande",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
