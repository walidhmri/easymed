import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Importez l'écran de mise à jour séparé
import 'UpdateScreen.dart';

import 'Home.dart';
import 'Connexion.dart';
import 'Transport_5.dart';
import 'Transport_6.dart';
import 'Transport_7.dart';
import 'Transport_8.dart';

import 'Soins_medicaux_5.dart';
import 'Soins_medicaux_6.dart';
import 'Soins_medicaux_7.dart';
import 'Soins_medicaux_8.dart';

import 'Consultations_5.dart';
import 'Consultations_6.dart';
import 'Consultations_7.dart';
import 'Consultations_8.dart';

import 'Analyses_medicales_5.dart';
import 'Analyses_medicales_6.dart';
import 'Analyses_medicales_7.dart';
import 'Analyses_medicales_8.dart';

class Demarrage extends StatefulWidget {
  @override
  _DemarrageState createState() => _DemarrageState();
}

class _DemarrageState extends State<Demarrage> {
  bool isLoading = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    _checkVersionAndRedirect();
  }

  int _compareVersions(String v1, String v2) {
    List<int> parts1 = v1.split('.').map(int.parse).toList();
    List<int> parts2 = v2.split('.').map(int.parse).toList();
    int length = parts1.length > parts2.length ? parts1.length : parts2.length;
    for (int i = 0; i < length; i++) {
      int p1 = i < parts1.length ? parts1[i] : 0;
      int p2 = i < parts2.length ? parts2[i] : 0;
      if (p1 < p2) return -1;
      if (p1 > p2) return 1;
    }
    return 0;
  }

  Future<void> _checkVersionAndRedirect() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('version_control')
          .get();

      if (doc.exists) {
        final String minVersion = doc.data()?['min_version'] ?? '1.0.0';
        final String updateUrl = doc.data()?['update_url'] ?? '';

        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        final String currentVersion = packageInfo.version;

        if (_compareVersions(currentVersion, minVersion) < 0) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => UpdateScreen(updateUrl: updateUrl),
            ),
          );
          return;
        }
      } else {
        print("Document de configuration de version non trouvé.");
      }
    } catch (e) {
      print("Erreur de vérification de version : $e");
    }

    _checkUserId();
  }

  Future<void> _checkUserId() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('user_id');

    setState(() {
      userId = storedUserId;
    });

    if (userId == null) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => Connexion()));
      return;
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final List<String> statusPriority = [
      'validé_soignant',
      'arrivé',
      'accepté',
      'en_attente',
    ];

    for (final status in statusPriority) {
      try {
        final snapshot = await firestore
            .collection('demandes')
            .where('maladeId', isEqualTo: userId)
            .where('status', isEqualTo: status)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final demandeDoc = snapshot.docs.first;
          final demandeData = demandeDoc.data();
          final demandeId = demandeDoc.id;

          if (status == 'en_attente') {
            final service = demandeData['service'];

            if (service == 'transport') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => Transport_5(demandeId: demandeId),
                ),
              );
              return;
            } else if (service == 'Soins medicaux') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => Soins_medicaux_5(demandeId: demandeId),
                ),
              );
              return;
            } else if (service == 'Consultation') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => Consultations_5(demandeId: demandeId),
                ),
              );
              return;
            } else if (service == 'Analyses medicales') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => Analyses_medicales_5(demandeId: demandeId),
                ),
              );
              return;
            }
          }

          final soignantId = demandeData['soignantId'];

          if (soignantId != null) {
            final soignantDoc = await firestore
                .collection('soignants')
                .doc(soignantId)
                .get();

            if (soignantDoc.exists) {
              final soignantData = soignantDoc.data()!;
              soignantData['startCoordinates'] =
                  demandeData['startCoordinates'];
              soignantData['endCoordinates'] = demandeData['endCoordinates'];
              soignantData['demandeId'] = demandeId;

              final service = demandeData['service'];
              Widget nextScreen;
              switch (status) {
                case 'validé_soignant':
                  if (service == 'transport') {
                    nextScreen = Transport_8(soignant: soignantData);
                  } else if (service == 'Soins medicaux') {
                    nextScreen = Soins_medicaux_8(soignant: soignantData);
                  } else if (service == 'Consultation') {
                    nextScreen = Consultations_8(soignant: soignantData);
                  } else if (service == 'Analyses medicales') {
                    nextScreen = Analyses_medicales_8(soignant: soignantData);
                  } else {
                    nextScreen = Home();
                  }
                  break;
                case 'arrivé':
                  if (service == 'transport') {
                    nextScreen = Transport_7(soignant: soignantData);
                  } else if (service == 'Soins medicaux') {
                    nextScreen = Soins_medicaux_7(soignant: soignantData);
                  } else if (service == 'Consultation') {
                    nextScreen = Consultations_7(soignant: soignantData);
                  } else if (service == 'Analyses medicales') {
                    nextScreen = Analyses_medicales_7(soignant: soignantData);
                  } else {
                    nextScreen = Home();
                  }
                  break;
                case 'accepté':
                  if (service == 'transport') {
                    nextScreen = Transport_6(soignant: soignantData);
                  } else if (service == 'Soins medicaux') {
                    nextScreen = Soins_medicaux_6(soignant: soignantData);
                  } else if (service == 'Consultation') {
                    nextScreen = Consultations_6(soignant: soignantData);
                  } else if (service == 'Analyses medicales') {
                    nextScreen = Analyses_medicales_6(soignant: soignantData);
                  } else {
                    nextScreen = Home();
                  }
                  break;
                default:
                  nextScreen = Home();
              }
              Navigator.of(
                context,
              ).pushReplacement(MaterialPageRoute(builder: (_) => nextScreen));
              return;
            }
          }
        }
      } catch (e) {
        print("Erreur lors de la vérification de la demande ($status) : $e");
      }
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/gloves.jpg', fit: BoxFit.cover),
          ),
          Positioned(
            top: screenHeight * 0.75 - 70,
            left: screenWidth * 0.28,
            right: 0,
            child: Center(
              child: Image.asset('assets/images/logo.png', width: 180),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
