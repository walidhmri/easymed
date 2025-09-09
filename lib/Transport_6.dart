import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'AppBar.dart';
import 'Home.dart';
import 'Transport_7.dart'; // N'oublie pas d'importer le fichier suivant

class Transport_6 extends StatefulWidget {
  final Map<String, dynamic> soignant;

  const Transport_6({Key? key, required this.soignant}) : super(key: key);

  @override
  State<Transport_6> createState() => _Transport_6State();
}

class _Transport_6State extends State<Transport_6> {
  String? service;
  String? sous_service;

  @override
  void initState() {
    super.initState();
    _listenToStatusChanges();
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
              final status = snapshot.data()?['status'];
              setState(() {
                service = snapshot.data()?['service'];
                sous_service = snapshot.data()?['sous-service'];
              });

              if (status == 'arrivé') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => Transport_7(soignant: widget.soignant),
                  ),
                );
              }
            }
          });
    }
  }

  double _calculateDistance(GeoPoint start, GeoPoint end) {
    const R = 6371;
    final lat1 = start.latitude * pi / 180;
    final lon1 = start.longitude * pi / 180;
    final lat2 = end.latitude * pi / 180;
    final lon2 = end.longitude * pi / 180;

    final dlat = lat2 - lat1;
    final dlon = lon2 - lon1;

    final a =
        pow(sin(dlat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dlon / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  int calculateEstimatedTime(double distanceInKm) {
    const double realismFactor = 1.5;
    const double averageSpeedKmPerHour = 30;
    double realDistance = distanceInKm * realismFactor;
    double timeInHours = realDistance / averageSpeedKmPerHour;
    return (timeInHours * 60).round();
  }

  int _calculatePrice(double distance) {
    if (distance <= 10) return 500;
    if (distance <= 30) return 750;
    return 1200;
  }

  void _annulerDemande(BuildContext context, String demandeId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmer l’annulation"),
        content: Text("Voulez-vous vraiment annuler la demande ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Non"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Oui"),
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

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => Home()),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l’annulation : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final soignant = widget.soignant;
    final GeoPoint? start = soignant["startCoordinates"];
    final GeoPoint? end = soignant["endCoordinates"];
    final String? demandeId = soignant["demandeId"];

    double distance = 0.0;
    int price = 0;
    int time = 0;

    if (start != null && end != null) {
      distance = _calculateDistance(start, end);
      price = _calculatePrice(distance);
      time = calculateEstimatedTime(distance);
    }

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
                  Center(
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    soignant['phone'] ?? 'Non disponible',
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        service ?? 'Non disponible',
                        style: TextStyle(
                          color: Color(0xFF1170AD),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        sous_service ?? 'Non disponible',
                        style: TextStyle(
                          color: Color(0xFF1170AD),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  if (start != null && end != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Temps estimé: ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF000000),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$time minutes',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFF11477),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Prix: ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF000000),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$price DA',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFF11477),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 30),
                        if (demandeId != null)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () =>
                                  _annulerDemande(context, demandeId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFF11477),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Text(
                                "Annuler la demande",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  else
                    Text("Coordonnées manquantes pour le calcul du prix."),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
