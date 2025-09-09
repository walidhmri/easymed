import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:easy_malade/AppBar.dart';

class Hospitalisation_success extends StatefulWidget {
  Hospitalisation_success({super.key});

  @override
  State<Hospitalisation_success> createState() =>
      _Hospitalisation_successState();
}

class _Hospitalisation_successState extends State<Hospitalisation_success> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF1170AD),
                size: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                "Demande envoyée avec succès !",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1170AD),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Nous avons bien reçu votre demande d'hospitalisation. Nous l'étudions et vous appellerons dans les plus brefs délais pour confirmer les détails.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 30,
                  ),
                  backgroundColor: const Color(0xFF1170AD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: () {
                  // Naviguer vers l'écran d'accueil
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text(
                  "Retour à l'accueil",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
