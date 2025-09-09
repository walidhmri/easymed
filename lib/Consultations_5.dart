import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Consultations_6.dart';
import 'AppBar.dart';
import 'Home.dart';

class Consultations_5 extends StatefulWidget {
  final String demandeId;

  const Consultations_5({Key? key, required this.demandeId}) : super(key: key);

  @override
  State<Consultations_5> createState() => _Consultations_5State();
}

class _Consultations_5State extends State<Consultations_5> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _demandeStream;

  String userName = "...";
  String userProfilePic = "...";
  String userId = "";

  final String defaultAvatarUrl =
      "https://firebasestorage.googleapis.com/v0/b/easy-med-c3f69.firebasestorage.app/o/profile_images%2Favatar-simple.jpg?alt=media&token=cbf516b6-ad37-4c50-852d-58f0b83564d5";

  @override
  void initState() {
    super.initState();
    getUserData();

    _demandeStream = FirebaseFirestore.instance
        .collection('demandes')
        .doc(widget.demandeId)
        .snapshots();
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
            userName = userDoc["name"];
            userProfilePic = userDoc["profileImage"];
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
      appBar: CustomAppBar(showBackButton: false),
      body: Center(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _demandeStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            final data = snapshot.data!.data();

            if (data == null) {
              return Text("Demande introuvable.");
            }

            if (data['status'] == 'accepté' && data['soignantId'] != null) {
              final soignantId = data['soignantId'];

              FirebaseFirestore.instance
                  .collection('soignants')
                  .doc(soignantId)
                  .get()
                  .then((soignantDoc) {
                    if (soignantDoc.exists) {
                      final soignant = soignantDoc.data()!;
                      // On ajoute les coordonnées de la demande au Map soignant
                      soignant['startCoordinates'] = data['startCoordinates'];

                      soignant['demandeId'] = snapshot.data!.id;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Consultations_6(soignant: soignant),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Soignantable.")));
                    }
                  });

              return CircularProgressIndicator();
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Nous recherchons un soignant pour vous.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1170AD)),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('demandes')
                          .doc(widget.demandeId)
                          .update({'status': 'annulé'});

                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Erreur lors de l'annulation.")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF11477),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Annuler la demande",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
