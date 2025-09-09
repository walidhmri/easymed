import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AppBar.dart';
import 'Home.dart';
import 'Soins_medicaux_8.dart';

class Soins_medicaux_7 extends StatefulWidget {
  final Map<String, dynamic> soignant;

  const Soins_medicaux_7({Key? key, required this.soignant}) : super(key: key);

  @override
  State<Soins_medicaux_7> createState() => _Soins_medicaux_7State();
}

class _Soins_medicaux_7State extends State<Soins_medicaux_7> {
  String? service;
  String? sous_service;
  double? _price;

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
                    builder: (_) => Soins_medicaux_8(soignant: widget.soignant),
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
