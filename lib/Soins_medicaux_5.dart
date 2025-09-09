import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Soins_medicaux_6.dart';
import 'Home.dart';

class Soins_medicaux_5 extends StatefulWidget {
  final String demandeId;

  const Soins_medicaux_5({Key? key, required this.demandeId}) : super(key: key);

  @override
  State<Soins_medicaux_5> createState() => _Soins_medicaux_5State();
}

class _Soins_medicaux_5State extends State<Soins_medicaux_5> {
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
              Text(
                "Bonjour $userName",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: DecorationImage(
                    image: userProfilePic.startsWith('http')
                        ? NetworkImage(userProfilePic)
                        : AssetImage(userProfilePic) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
                              Soins_medicaux_6(soignant: soignant),
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
                  "Nous recherchons un soignant pour vous...",
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
